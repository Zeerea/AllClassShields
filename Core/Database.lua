local _, ns = ...

local defaults = {
    enabled = true,
    locked = false,
    showIcon = true,
    showName = true,
    showNumber = true,
    showPercent = true,
    compact = false,
    width = 260,
    height = 28,
    spacing = 8,
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = -180,
}

local function CopyDefaults(target, source)
    for key, value in pairs(source) do
        if target[key] == nil then
            target[key] = value
        end
    end
end

function ns:InitDB()
    AllClassShieldsDB = AllClassShieldsDB or {}
    CopyDefaults(AllClassShieldsDB, defaults)
    self.db = AllClassShieldsDB
end