local _, ns = ...

-- Curated classic/Forever absorb spell IDs. Rank IDs are grouped under one display family.
ns.shields = {
    PRIEST = {
        { key = "POWER_WORD_SHIELD", name = "Power Word: Shield", icon = 135940,
          spells = { 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901 } },
    },
    MAGE = {
        { key = "MANA_SHIELD", name = "Mana Shield", icon = 136153,
          spells = {
              1463, 8494, 8495, 10191, 10192, 10193,
              -- WoW Forever Advanced Warding overrides (Wowhead Forever).
              412116, 412118, 412120, 412121, 412122, 412123,
          } },
        { key = "FIRE_WARD", name = "Fire Ward", icon = 135806,
          spells = {
              543, 8457, 8458, 10223, 10225,
              -- WoW Forever Advanced Warding overrides.
              412214, 412218, 412230, 412231, 412232,
          } },
        { key = "FROST_WARD", name = "Frost Ward", icon = 135850,
          spells = {
              6143, 8461, 8462, 10177, 28609,
              -- WoW Forever Advanced Warding overrides.
              412202, 412205, 412207, 412209, 412210,
          } },
        { key = "ICE_BARRIER", name = "Ice Barrier", icon = 135988,
          spells = {
              11426, 13031, 13032, 13033,
              -- Additional WoW Forever Ice Barrier variant.
              1213278,
          } },
    },
    WARLOCK = {
        { key = "SACRIFICE", name = "Sacrifice", icon = 136190,
          spells = { 7812, 19438, 19440, 19441, 19442, 19443 } },
        { key = "SHADOW_WARD", name = "Shadow Ward", icon = 136121,
          spells = { 6229, 11739, 11740, 28610 } },
    },
}

ns.spellLookup = {}
ns.shieldNameLookup = {}

for classFile, families in pairs(ns.shields) do
    for _, family in ipairs(families) do
        family.classFile = classFile

        for _, spellID in ipairs(family.spells) do
            ns.spellLookup[spellID] = family
        end

        -- Forever can expose override spell IDs while preserving the canonical
        -- spell/aura name. Keep an exact-name fallback so supported shields do
        -- not depend exclusively on a fixed rank-ID list.
        if type(family.name) == "string" then
            ns.shieldNameLookup[string.lower(family.name)] = family
        end
    end
end
