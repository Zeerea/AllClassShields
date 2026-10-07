local _, ns = ...

local function CreateBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.025, 0.035, 0.05, 0.94)
    frame:SetBackdropBorderColor(0.18, 0.24, 0.31, 1)
end

local function GetFamilyColor(family)
    if family.key == "POWER_WORD_SHIELD" then
        return 0.95, 0.75, 0.15
    elseif family.key == "MANA_SHIELD" then
        return 0.10, 0.55, 1.00
    elseif family.key == "FIRE_WARD" then
        return 1.00, 0.35, 0.08
    elseif family.key == "FROST_WARD" or family.key == "ICE_BARRIER" then
        return 0.35, 0.80, 1.00
    elseif family.key == "SACRIFICE" then
        return 0.62, 0.25, 0.90
    elseif family.key == "SHADOW_WARD" then
        return 0.50, 0.20, 0.85
    end
    return 0.35, 0.65, 1.00
end

local function CreateRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(44)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(36, 36)
    icon:SetPoint("LEFT", 4, 0)
    row.icon = icon

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
    name:SetJustifyH("LEFT")
    row.name = name

    local bar = CreateFrame("StatusBar", nil, row, "BackdropTemplate")
    bar:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    bar:SetPoint("RIGHT", -8, 0)
    bar:SetHeight(13)
    bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    bar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    bar:SetBackdropColor(0.05, 0.06, 0.08, 1)
    row.bar = bar

    local number = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    number:SetPoint("CENTER", bar, "CENTER", 0, 0)
    number:SetJustifyH("CENTER")
    row.number = number

    local percent = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    percent:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
    percent:SetJustifyH("RIGHT")
    row.percent = percent

    row.index = index
    return row
end

function ns:CreateHUD()
    if self.hud then
        return
    end

    local hud = CreateFrame("Frame", "AllClassShieldsHUD", UIParent, "BackdropTemplate")
    hud:SetSize(self.db.width, 44)
    hud:SetPoint(self.db.point, UIParent, self.db.relativePoint, self.db.x, self.db.y)
    hud:SetFrameStrata("MEDIUM")
    hud:SetClampedToScreen(true)
    hud:SetMovable(true)
    hud:EnableMouse(not self.db.locked)
    hud:RegisterForDrag("LeftButton")

    hud:SetScript("OnDragStart", function(frame)
        if not ns.db.locked then
            frame:StartMoving()
        end
    end)

    hud:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = frame:GetPoint(1)
        ns.db.point = point
        ns.db.relativePoint = relativePoint
        ns.db.x = x
        ns.db.y = y
    end)

    self.hud = hud
    self.rows = {}
end

function ns:GetRow(index)
    local row = self.rows[index]
    if not row then
        row = CreateRow(self.hud, index)
        self.rows[index] = row
    end
    return row
end

function ns:ApplyRow(entry, row, index)
    local family = entry.family
    local r, g, b = GetFamilyColor(family)

    local barHeight = math.max(2, self.db.height)
    local rowHeight
    if self.db.compact then
        rowHeight = math.max(32, barHeight + 8)
    else
        rowHeight = math.max(44, barHeight + 22)
    end

    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", self.hud, "TOPLEFT", 0, -((index - 1) * (rowHeight + self.db.spacing)))
    row:SetPoint("TOPRIGHT", self.hud, "TOPRIGHT", 0, -((index - 1) * (rowHeight + self.db.spacing)))
    row:SetHeight(rowHeight)

    row.icon:SetShown(self.db.showIcon)
    row.icon:SetTexture(family.icon)
    if self.db.compact then
        row.icon:SetSize(26, 26)
    else
        row.icon:SetSize(36, 36)
    end

    row.name:SetShown(self.db.showName and not self.db.compact)
    row.name:SetText(family.name)

    row.bar:ClearAllPoints()
    row.bar:SetPoint("LEFT", row.icon, "RIGHT", 8, self.db.compact and 0 or -8)
    row.bar:SetPoint("RIGHT", -8, self.db.compact and 0 or -8)
    row.bar:SetHeight(barHeight)

    row.number:SetShown(self.db.showNumber)
    if self.db.showNumber then
        row.number:SetText(entry.amount)
    end

    row.bar:SetStatusBarColor(r, g, b, 1)
    row.bar:SetMinMaxValues(0, entry.max)
    row.bar:SetValue(entry.amount)

    if self.db.showPercent and not entry.secret and entry.max and entry.max > 0 then
        row.percent:SetText(string.format("%d%%", math.floor((entry.amount / entry.max) * 100 + 0.5)))
        row.percent:Show()
    else
        row.percent:Hide()
    end

    row:Show()
end

function ns:RefreshUI()
    if not self.db or not self.db.enabled then
        if self.hud then
            self.hud:Hide()
        end
        return
    end

    self:CreateHUD()

    local count = #self.active
    for i, entry in ipairs(self.active) do
        self:ApplyRow(entry, self:GetRow(i), i)
    end

    for i = count + 1, #self.rows do
        self.rows[i]:Hide()
    end

    if count > 0 then
        local barHeight = math.max(2, self.db.height)
        local rowHeight
        if self.db.compact then
            rowHeight = math.max(32, barHeight + 8)
        else
            rowHeight = math.max(44, barHeight + 22)
        end
        self.hud:SetHeight((count * rowHeight) + (math.max(0, count - 1) * self.db.spacing))
        self.hud:Show()
    else
        self.hud:Hide()
    end
end

function ns:SetLocked(locked)
    self.db.locked = locked
    if self.hud then
        self.hud:EnableMouse(not locked)
    end
    self:Print(locked and self.L.LOCKED or self.L.UNLOCKED)
end

function ns:ResetPosition()
    self.db.point = "CENTER"
    self.db.relativePoint = "CENTER"
    self.db.x = 0
    self.db.y = -180

    if self.hud then
        self.hud:ClearAllPoints()
        self.hud:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
    end

    self:Print("Position reset.")
end

function ns:SetPreviewButtonState()
    if self.previewButton then
        self.previewButton:SetText(self.previewActive and "Hide Preview" or "Preview Shield")
    end
end

function ns:TogglePreview()
    if self.previewActive then
        self.previewActive = false
        self:SetPreviewButtonState()
        self:UpdateLiveShield(false)
        return
    end

    local _, classFile = UnitClass("player")
    local family = (self.shields[classFile] and self.shields[classFile][1]) or self.shields.PRIEST[1]

    self.previewActive = true
    self.active = {
        {
            instanceID = -1,
            family = family,
            amount = 624,
            max = 928,
            secret = false,
        },
    }

    self:SetPreviewButtonState()
    self:RefreshUI()
end

function ns:HandleSlash(msg)
    msg = string.lower((msg or ""):match("^%s*(.-)%s*$"))

    if msg == "" or msg == "settings" or msg == "options" then
        self:OpenSettings()
    elseif msg == "lock" then
        self:SetLocked(true)
    elseif msg == "unlock" then
        self:SetLocked(false)
    elseif msg == "preview" or msg == "test" then
        self:TogglePreview()
    elseif msg == "compact" then
        self.db.compact = not self.db.compact
        self:RefreshUI()
        self:Print("Compact mode: " .. (self.db.compact and "on" or "off"))
    elseif msg == "reset" then
        self:ResetPosition()
    else
        self:Print("/acs | settings | lock | unlock | preview | compact | reset")
    end
end

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(_, _, loaded)
    if loaded ~= ns.name then
        return
    end

    ns:InitDB()
    ns:CreateHUD()
    ns:StartTracker()

    SLASH_ALLCLASSSHIELDS1 = "/acs"
    SLASH_ALLCLASSSHIELDS2 = "/allclassshields"
    SlashCmdList.ALLCLASSSHIELDS = function(msg)
        ns:HandleSlash(msg)
    end

    ns:Print("Loaded. Type /acs for commands.")
end)