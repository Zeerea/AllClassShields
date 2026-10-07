# Changelog

## 1.0.2 - 2026-10-07

- Fixed the `Rescan Shields` button calling a removed tracker function.
- Added a safe `RescanShields()` path that respects WoW Forever combat restrictions.
- Strengthened release validation so obsolete tracker calls are checked across all runtime source files.
- Added a release gate that verifies the rescan method is both defined and wired to the settings button.

## 1.0.1 - 2026-10-06

- Fixed an occasional absorb-bar jump after refreshing a shield.
- Fixed stale Priest shield artwork/state after switching to another class.
- Replaced the generic fallback with a neutral shield icon.
- Fixed preview mode returning through an obsolete tracker function.

## 1.0.0 - 2026-10-04

Initial public release.

- Added player absorb tracking for WoW Forever.
- Added Priest Power Word: Shield support.
- Added Mage Mana Shield, Fire Ward, Frost Ward and Ice Barrier definitions.
- Added Warlock Sacrifice and Shadow Ward definitions.
- Added current absorb value inside the bar.
- Added optional shield percentage at the right edge of the bar.
- Added configurable bar width, 2-56 px bar height and shield spacing.
- Added movable/lockable HUD and compact mode.
- Added toggleable preview mode.
- Added secret-value-safe aura identification and absorb forwarding for Forever combat restrictions.
- Added release validation and deterministic packaging checks.