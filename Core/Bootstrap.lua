local addonName, ns = ...

_G.AllClassShields = ns
ns.name = addonName
ns.version = "1.0.1"
ns.frames = {}
ns.active = {}
ns.auraState = {}

local eventFrame = CreateFrame("Frame")
ns.eventFrame = eventFrame

function ns:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff4aa3ffAll Class Shields|r: " .. tostring(message))
end