# All Class Shields

**All Class Shields** is a lightweight absorb-shield tracker built specifically for World of Warcraft: Forever.

It keeps the information that matters visible at a glance: the active shield, its current absorb value, and a bar that drains as the shield is consumed.

## Features

- Live absorb bar for the player
- Exact current absorb value when exposed by the Forever client
- Shield percentage when the value is safely readable
- Tracks the player's total active absorb value
- Individual shield icons and names
- Movable and lockable HUD
- Adjustable bar width, height and spacing
- Compact mode
- Preview mode
- English-only interface
- No external dependencies in the release package
- Secret-value-safe handling for WoW Forever combat restrictions

## Built-in shield families

### Priest
- Power Word: Shield

### Mage
- Mana Shield
- Fire Ward
- Frost Ward
- Ice Barrier

### Warlock
- Sacrifice
- Shadow Ward

Additional absorb sources can be added when they can be identified reliably in the Forever client.

## Commands

- `/acs` - open settings
- `/acs preview` - toggle the preview shield
- `/acs lock`
- `/acs unlock`
- `/acs compact`
- `/acs reset`

## WoW Forever combat restrictions

WoW Forever can mark combat information as secret. All Class Shields avoids arithmetic, comparisons and table lookups on secret combat values. Where Blizzard permits a secret absorb value to be forwarded directly to a UI widget, the addon does so without inspecting the value.

## License

MIT License.
