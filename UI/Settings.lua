local _, ns = ...

local function MakeLabel(parent, text, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", size or "GameFontNormal")
    fs:SetText(text)
    fs:SetTextColor(0.88, 0.91, 0.96)
    return fs
end

local function MakeCheck(parent, label, key, x, y)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check.Text:SetText(label)
    check.Text:SetTextColor(0.88, 0.91, 0.96)
    check:SetChecked(ns.db[key])

    check:SetScript("OnClick", function(self)
        ns.db[key] = self:GetChecked() and true or false

        if key == "locked" then
            ns:SetLocked(ns.db[key])
        else
            ns:RefreshUI()
        end
    end)

    return check
end

local function MakeSlider(parent, label, key, minValue, maxValue, step, x, y)
    local title = MakeLabel(parent, label)
    title:SetPoint("TOPLEFT", x, y)

    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y - 24)
    slider:SetWidth(260)
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(ns.db[key])

    slider.Low:SetText(tostring(minValue))
    slider.High:SetText(tostring(maxValue))
    slider.Text:SetText(tostring(ns.db[key]))

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        ns.db[key] = value
        self.Text:SetText(tostring(value))

        if key == "width" and ns.hud then
            ns.hud:SetWidth(value)
        elseif key == "height" then
            ns.db.height = math.max(2, value)
        end

        ns:RefreshUI()
    end)

    return slider
end

function ns:CreateSettings()
    if self.settings then
        return self.settings
    end

    local frame = CreateFrame("Frame", "AllClassShieldsSettings", UIParent, "BackdropTemplate")
    frame:SetSize(610, 560)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.018, 0.025, 0.035, 0.98)
    frame:SetBackdropBorderColor(0.15, 0.23, 0.31, 1)

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    local title = MakeLabel(frame, "All Class Shields", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 24, -22)
    title:SetTextColor(0.35, 0.72, 1.0)

    local subtitle = MakeLabel(frame, "A clean absorb tracker for WoW Forever.")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetTextColor(0.58, 0.64, 0.72)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.12, 0.20, 0.28, 1)
    line:SetPoint("TOPLEFT", 20, -76)
    line:SetPoint("TOPRIGHT", -20, -76)
    line:SetHeight(1)

    local displayHeader = MakeLabel(frame, "DISPLAY", "GameFontNormalLarge")
    displayHeader:SetPoint("TOPLEFT", 28, -102)
    displayHeader:SetTextColor(0.30, 0.67, 1.0)

    MakeCheck(frame, "Show shield icon", "showIcon", 26, -136)
    MakeCheck(frame, "Show shield name", "showName", 26, -170)
    MakeCheck(frame, "Show absorb number", "showNumber", 26, -204)
    MakeCheck(frame, "Show percentage when available", "showPercent", 26, -238)
    MakeCheck(frame, "Compact mode", "compact", 26, -272)
    MakeCheck(frame, "Lock frame position", "locked", 26, -306)

    local layoutHeader = MakeLabel(frame, "LAYOUT", "GameFontNormalLarge")
    layoutHeader:SetPoint("TOPLEFT", 330, -102)
    layoutHeader:SetTextColor(0.30, 0.67, 1.0)

    MakeSlider(frame, "Bar width", "width", 180, 420, 10, 330, -140)
    MakeSlider(frame, "Bar height", "height", 2, 56, 1, 330, -225)
    MakeSlider(frame, "Shield spacing", "spacing", 0, 20, 1, 330, -310)

    local actionsHeader = MakeLabel(frame, "ACTIONS", "GameFontNormalLarge")
    actionsHeader:SetPoint("TOPLEFT", 28, -372)
    actionsHeader:SetTextColor(0.30, 0.67, 1.0)

    local preview = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    preview:SetSize(150, 28)
    preview:SetPoint("TOPLEFT", 28, -405)
    preview:SetText(ns.previewActive and "Hide Preview" or "Preview Shield")
    ns.previewButton = preview
    preview:SetScript("OnClick", function()
        ns:TogglePreview()
    end)

    local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    reset:SetSize(150, 28)
    reset:SetPoint("LEFT", preview, "RIGHT", 10, 0)
    reset:SetText("Reset Position")
    reset:SetScript("OnClick", function()
        ns:ResetPosition()
    end)

    local scan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    scan:SetSize(150, 28)
    scan:SetPoint("LEFT", reset, "RIGHT", 10, 0)
    scan:SetText("Rescan Shields")
    scan:SetScript("OnClick", function()
        ns:ScanPlayerShields()
    end)

    local note = MakeLabel(frame,
        "All Class Shields only displays absorb data exposed by the WoW Forever client.\n" ..
        "If combat restrictions make a value secret, the addon avoids unsafe calculations.")
    note:SetPoint("TOPLEFT", 28, -462)
    note:SetWidth(550)
    note:SetJustifyH("LEFT")
    note:SetTextColor(0.58, 0.64, 0.72)

    self.settings = frame
    return frame
end

function ns:OpenSettings()
    local frame = self:CreateSettings()
    frame:Show()
end

[executed on device: forsaken (ef773606-47da-466d-b53f-3635de586156)]