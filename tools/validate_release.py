#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
VERSION = "1.0.3"
errors = []

def require(condition, message):
    if not condition:
        errors.append(message)

toc = (ROOT / "AllClassShields_Camelot.toc").read_text(encoding="utf-8")
bootstrap = (ROOT / "Core/Bootstrap.lua").read_text(encoding="utf-8")
tracker = (ROOT / "Core/Tracker.lua").read_text(encoding="utf-8")
shields = (ROOT / "Data/Shields.lua").read_text(encoding="utf-8")
settings = (ROOT / "UI/Settings.lua").read_text(encoding="utf-8")
main = (ROOT / "UI/Main.lua").read_text(encoding="utf-8")

require("## Interface: 16001" in toc, "Interface must be 16001")
require("## Interface-Camelot: 16001" in toc, "Interface-Camelot must be 16001")
require(f"## Version: {VERSION}" in toc, f"TOC version must be {VERSION}")
require("## SavedVariables: AllClassShieldsDB" in toc, "SavedVariables metadata missing")
require("## X-Game-Flavor: Forever" in toc, "Forever flavor metadata missing")
require("## X-Curse-Project-Name: All Class Shields" in toc, "Curse project name metadata missing")
require(f'ns.version = "{VERSION}"' in bootstrap, f"Runtime version must be {VERSION}")

# Prevent the exact secret-key failure mode that can crash Forever combat addons.
require("self.spellLookup[aura.spellId]" not in tracker,
        "Unsafe secret-key lookup regression: aura.spellId indexed directly")
require("addedAuras" not in tracker and "removedAuraInstanceIDs" not in tracker,
        "Unsafe UNIT_AURA secret-container iteration regression")
require("issecretvalue" in tracker, "Secret-value guard missing")
require("UNIT_ABSORB_AMOUNT_CHANGED" in tracker, "Absorb change event missing")
require("UnitGetTotalAbsorbs" in tracker, "Authoritative total absorb API missing")
require("UNIT_SPELLCAST_SUCCEEDED" in tracker, "Self-cast shield correlation missing")
require("pendingShieldUntil" in tracker,
        "Fresh shield settling guard missing")
require("CaptureFreshShieldMax" in tracker and "rawAbsorb" in tracker
        and "shieldCastGeneration" in tracker,
        "Secret out-of-combat shield maximum capture missing")
require("ScheduleFreshMaxCapture" in tracker and "C_Timer.After(0.35" in tracker,
        "Single coalesced shield maximum capture missing")
require("INV_Shield_06" in tracker,
        "Neutral generic shield icon missing")
require("shieldNameLookup" in shields and "string.lower(family.name)" in shields,
        "Canonical shield-name fallback lookup missing")
require("GetAccessibleFamilyByName" in tracker and "GetClientSpellName" in tracker
        and "C_Spell.GetSpellInfo" in tracker,
        "Client spell-name fallback missing")
require("GetAccessibleFamily(aura.spellId, aura.name)" in tracker,
        "Aura name fallback is not wired into shield-family scan")

runtime_sources = "\n".join(
    path.read_text(encoding="utf-8")
    for folder in ("Core", "Data", "Locales", "UI")
    for path in (ROOT / folder).rglob("*.lua")
)
require("ScanPlayerShields" not in runtime_sources,
        "Obsolete ScanPlayerShields call remains in runtime source")
require("function ns:RescanShields()" in tracker,
        "Safe RescanShields method missing")
require("ns:RescanShields()" in settings,
        "Rescan Shields settings button is not wired to RescanShields")

# Product requirements.
for spell in (
    "Power Word: Shield", "Mana Shield", "Fire Ward",
    "Frost Ward", "Ice Barrier", "Sacrifice", "Shadow Ward",
):
    require(spell in shields, f"Shield definition missing: {spell}")

for spell_id in (
    412116, 412118, 412120, 412121, 412122, 412123,
    412214, 412218, 412230, 412231, 412232,
    412202, 412205, 412207, 412209, 412210,
    1213278,
):
    require(str(spell_id) in shields,
            f"Verified WoW Forever shield override ID missing: {spell_id}")

require('MakeSlider(frame, "Bar height", "height", 2, 56, 1' in settings,
        "Bar height release range must be 2-56 with 1px steps")
require("TogglePreview" in main, "Toggleable preview missing")
require('SetPoint("RIGHT", bar, "RIGHT", -4, 0)' in main,
        "Percentage must be aligned to the right side of the bar")
require('SetPoint("CENTER", bar, "CENTER", 0, 0)' in main,
        "Absorb number must be centered in the bar")

for required in (
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "docs/CURSEFORGE_DESCRIPTION.md",
    f"docs/RELEASE_NOTES_{VERSION}.md",
    "docs/RELEASE_CHECKLIST.md",
    "docs/SMOKE_TEST.md",
):
    require((ROOT / required).is_file(), f"Required release file missing: {required}")

# No non-English locale bundles in this intentionally English-only release.
locale_files = sorted((ROOT / "Locales").glob("*.lua"))
require([p.name for p in locale_files] == ["Localization.lua"],
        f"{VERSION} must remain English-only (unexpected locale file present)")

# Source release version should not still identify itself as dev.
for path in [ROOT / "AllClassShields_Camelot.toc", ROOT / "Core/Bootstrap.lua"]:
    require("-dev" not in path.read_text(encoding="utf-8"),
            f"Development version marker remains in {path.name}")

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    sys.exit(1)

print("Release metadata: PASS")
print("Secret-value safety gates: PASS")
print("Shield catalog: PASS")
print("English-only release scope: PASS")
print("CurseForge release docs: PASS")
