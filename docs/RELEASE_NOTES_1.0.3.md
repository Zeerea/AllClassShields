# All Class Shields 1.0.3

## Bug fix

This release improves shield identification on World of Warcraft: Forever, with a focus on reports that Mage Mana Shield was not being detected.

### Changes

- Add verified WoW Forever Advanced Warding override IDs for Mana Shield, Fire Ward and Frost Ward.
- Add the current Forever Ice Barrier variant ID 1213278.
- Keep the curated Classic/Forever rank-ID lookup as the first detection path.
- If Forever reports an unknown/override spell ID, ask the client for the canonical spell name and match supported shields by that name.
- Match readable out-of-combat aura names as an additional fallback.
- Scan readable out-of-combat aura identity even when the aggregate absorb amount is secret.
- Preserve all existing secret-value protections: secret values are never used as Lua table keys or in arithmetic.

### Mana Shield

Known rank IDs remain:

- 1463
- 8494
- 8495
- 10191
- 10192
- 10193

The name fallback allows a client-reported Forever override ID to still resolve to Mana Shield without guessing or hardcoding an unverified new ID.
