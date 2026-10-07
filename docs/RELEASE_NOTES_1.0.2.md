# All Class Shields 1.0.2

Bug-fix release for World of Warcraft: Forever.

## Fixed

- Fixed the **Rescan Shields** button calling the removed `ScanPlayerShields()` tracker function.
- Added a safe `RescanShields()` implementation that refreshes the aggregate absorb state and only scans aura details when combat restrictions allow it.
- Strengthened release validation so obsolete tracker references are checked across all runtime source files.
- Added release gates for the rescan method definition and settings-button wiring.

No shield formulas or supported shield families were changed in this release.