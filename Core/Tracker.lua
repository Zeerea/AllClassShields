local _, ns = ...

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function GetAccessibleFamily(spellID)
    if spellID == nil or IsSecret(spellID) then
        return nil
    end
    return ns.spellLookup[spellID]
end

local GENERIC_FAMILY = {
    key = "GENERIC_ABSORB",
    name = "Absorb Shield",
    icon = "Interface\\Icons\\INV_Shield_06",
    classFile = "ALL",
}

function ns:ScanFamilyOutOfCombat()
    if InCombatLockdown and InCombatLockdown() then
        return nil
    end

    local index = 1
    while true do
        local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HELPFUL")
        if not aura then
            break
        end

        if IsSecret(aura) then
            return nil
        end

        local family = GetAccessibleFamily(aura.spellId)
        if family then
            return family
        end

        index = index + 1
    end

    return nil
end

function ns:ResetTrackerSession()
    -- Invalidate any delayed callback from the previous character/shield.
    self.shieldCastGeneration = (self.shieldCastGeneration or 0) + 1

    self.currentFamily = nil
    self.shieldMax = nil
    self.hasShieldMax = false
    self.captureNextAsMax = false
    self.pendingShieldUntil = nil
    self.pendingSameFamilyMax = nil
    self.liveActive = {}

    if not self.previewActive then
        self.active = {}
        if self.RefreshUI then
            self:RefreshUI()
        end
    end
end

function ns:RememberShieldCast(spellID)
    local family = GetAccessibleFamily(spellID)
    if not family then
        return false
    end

    local sameFamily = self.currentFamily
        and self.currentFamily.key == family.key
        and self.hasShieldMax

    local previousMax = sameFamily and self.shieldMax or nil

    self.currentFamily = family
    self.captureNextAsMax = true
    self.pendingShieldUntil = GetTime() + 0.75
    self.shieldCastGeneration = (self.shieldCastGeneration or 0) + 1

    -- For a same-rank recast, keep the old maximum until the fresh raw
    -- snapshot arrives. This prevents a one-frame fallback to player HP.
    if previousMax ~= nil then
        self.shieldMax = previousMax
        self.hasShieldMax = true
        self.pendingSameFamilyMax = previousMax
    else
        self.shieldMax = nil
        self.hasShieldMax = false
        self.pendingSameFamilyMax = nil
    end

    return true
end

function ns:ClearLiveShield()
    self.currentFamily = nil
    self.shieldMax = nil
    self.hasShieldMax = false
    self.captureNextAsMax = false
    self.pendingShieldUntil = nil
    self.pendingSameFamilyMax = nil
    self.liveActive = {}

    if not self.previewActive then
        self.active = {}
        if self.RefreshUI then
            self:RefreshUI()
        end
    end
end

function ns:CaptureFreshShieldMax(generation)
    if generation ~= self.shieldCastGeneration or not self.captureNextAsMax then
        return
    end

    if not UnitGetTotalAbsorbs then
        return
    end

    -- The value can be secret in Forever. Never inspect or compare it:
    -- capture exactly once and pass it only to Blizzard UI sinks.
    local rawAbsorb = UnitGetTotalAbsorbs("player")
    if rawAbsorb == nil then
        return
    end

    self.shieldMax = rawAbsorb
    self.hasShieldMax = true
    self.captureNextAsMax = false
    self.pendingShieldUntil = nil
    self.pendingSameFamilyMax = nil

    self:UpdateLiveShield()
end

function ns:UpdateLiveShield()
    if not UnitGetTotalAbsorbs then
        return
    end

    local totalAbsorb = UnitGetTotalAbsorbs("player") or 0
    local totalIsSecret = IsSecret(totalAbsorb)

    if not totalIsSecret then
        if totalAbsorb <= 0 then
            if self.captureNextAsMax
                and self.pendingShieldUntil
                and GetTime() <= self.pendingShieldUntil then
                return
            end

            self:ClearLiveShield()
            return
        end

        local scannedFamily = self:ScanFamilyOutOfCombat()
        if scannedFamily then
            self.currentFamily = scannedFamily
        end
    end

    if not self.currentFamily then
        self.currentFamily = GENERIC_FAMILY
    end

    local maxValue
    local maxIsSecret = false

    if self.hasShieldMax then
        maxValue = self.shieldMax
        maxIsSecret = IsSecret(maxValue)
    elseif self.captureNextAsMax then
        -- Do not flash a bogus HP-scaled bar while a newly cast shield is
        -- settling. Wait for the single raw max capture instead.
        return
    else
        maxValue = UnitHealthMax("player") or 1
        maxIsSecret = IsSecret(maxValue)
    end

    local entry = {
        family = self.currentFamily,
        amount = totalAbsorb,
        max = maxValue,
        secret = totalIsSecret or maxIsSecret,
    }

    self.liveActive = { entry }

    if not self.previewActive then
        self.active = self.liveActive
        if self.RefreshUI then
            self:RefreshUI()
        end
    end
end

function ns:ScheduleFreshMaxCapture()
    if not C_Timer or not C_Timer.After then
        return
    end

    local generation = self.shieldCastGeneration

    -- One capture only. The old implementation captured more than once and a
    -- later capture could use an already-damaged shield as the new maximum,
    -- which caused the occasional visible bar jump.
    C_Timer.After(0.35, function()
        ns:CaptureFreshShieldMax(generation)
    end)
end

function ns:StartTracker()
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterUnitEvent("UNIT_AURA", "player")
    self.eventFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            ns:ResetTrackerSession()

            -- Let the new character/class/aura state settle before reading it.
            if C_Timer and C_Timer.After then
                local generation = ns.shieldCastGeneration
                C_Timer.After(0.20, function()
                    if generation == ns.shieldCastGeneration then
                        ns.currentFamily = ns:ScanFamilyOutOfCombat()
                        ns:UpdateLiveShield()
                    end
                end)
            else
                ns.currentFamily = ns:ScanFamilyOutOfCombat()
                ns:UpdateLiveShield()
            end
            return
        end

        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local _, _, spellID = ...
            if ns:RememberShieldCast(spellID) then
                ns:ScheduleFreshMaxCapture()
            end
            return
        end

        if event == "PLAYER_REGEN_ENABLED" then
            local family = ns:ScanFamilyOutOfCombat()
            if family then
                ns.currentFamily = family
            end
        end

        -- Never inspect UNIT_AURA updateInfo: Forever can make the container
        -- itself secret. Only re-read the safe aggregate absorb API.
        ns:UpdateLiveShield()
    end)
end
