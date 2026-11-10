# KindleWake — The Sundered Vow

An offline-first medieval tactical RPG built with **Godot 4.2.2**, GDScript, and the GL Compatibility renderer.

**Canonical project:** `Kindlewake/`  
**Current version:** 0.12.0  
**Android version code:** 1200  
**Save schema:** 4  
**Package ID:** `com.kindlewake.game`

## Project status

KindleWake has a functioning tactical-RPG foundation: character creation, party progression, equipment and runes, traits/personality, tactical battles, regional exploration, location maps, factions, and several authored quest chains.

It is still in active development and is **not release-ready**. The Android Continue crash report has not been reproduced on a physical device. The seven-continent atlas is not yet seven fully playable overworld regions, and the five-act campaign, generic companion-quest framework, regional trade, empire/territory management, and Chronicle epilogue remain unintegrated feature work.

See [Production Audit and Roadmap](docs/PRODUCTION_AUDIT_AND_ROADMAP.md) for the full implementation inventory, branch review, risks, and recommended order.

## Implemented foundations on main

- Grid-based tactical combat, turn control, battle AI, status effects, and deterministic balance simulations.
- Character creator, persistent party, XP/levels, tiered class promotions, equipment, enhancements, runes/sigils, traits, and personality evidence.
- Free-roam regional exploration, terrain movement, places/interactions, encounter buildup, battle transitions, and autosaves.
- Data-driven town/interior maps, two distinct regional overworld datasets, six battle definitions, faction foundations, and authored quest systems.
- Checksummed saves, backups, migrations, campaign restore validation, and battle snapshot validation.
- Android export pipeline with ARM64/ARMv7 support and an offline permission check.

Catalogue counts are documented in the production audit. A data entry or feature branch is not proof that the feature is fully playable.

## Open work and known limitations

- Physical Android reproduction and QA for issue #36 are outstanding.
- The seven-continent atlas currently has only two distinct runtime overworld datasets wired through `GameData.world_for_region()`.
- Main has 28 classes and 15 combat skills, but no persistent node-based class talent tree or skill-point budget yet.
- Traits and personality have a broad initial foundation; event templates still need committed gameplay triggers.
- No generic companion quest system, regional trade system, five-act playable campaign, or Chronicle founder epilogue is integrated on main.
- No bundled music/SFX or font files are present; character sprite/portrait coverage is incomplete.
- Android is the configured build target. iOS export/device QA is not configured.

## Build and test

Run commands from the `Kindlewake/` project directory with Godot 4.2.2 and the configured Android export toolchain.

```bash
# Strict logic/regression suite
godot --headless --path . --script res://tests/run_tests.gd

# Load all scene resources
godot --headless --path . --script res://tests/scene_smoke_test.gd

# Exercise campaign save -> restore -> actual World scene startup
godot --headless --path . res://tests/campaign_continue_lifecycle_test.tscn

# Strict Android build, tests and balance report
python3 tools/build_apk.py --strict --with-balance
```

The campaign lifecycle test runs with project autoloads enabled. It is headless QA; it does not replace physical Android process-restart testing.

## Project layout

- `scripts/core/` — persistent game state, data rules, saves, progression and world systems.
- `scripts/battle/` — tactical battle model, controller, AI and combat calculations.
- `scripts/ui/` — code-built screens and UI components.
- `data/` — local JSON catalogues, maps, encounters, characters, classes, skills and world definitions.
- `assets/` — project-authored vector art, credited third-party runtime art, icons and optional unintegrated archives.
- `tests/` — headless regression, scene smoke, lifecycle and balance checks.
- `tools/` — Android builder, asset tools, audits and source-handoff utilities.
- `docs/` — game design, production audit, release workflow and session handoff.

## Asset and licence policy

Runtime third-party assets are recorded in `data/asset_provenance.json` and `assets/art/CREDITS.md`. Used assets include Quaternius CC0 nature renders and the permitted Free Soldier/Orc subset from Zerie's pack. The legacy voxel-building PNGs are retained but are marked unused; optional sprite-pack ZIPs are not integrated and must not be used until their licences are verified. Do not redistribute source packs as standalone archives.

## Offline and release policy

The game remains offline-first. Android INTERNET permission is disabled. CI/sideload signing is for testing only; production distribution requires the protected production keystore, certificate fingerprint, and approval process described in [Android Release Workflow](docs/ANDROID_RELEASE_WORKFLOW.md).

CI success does not certify device compatibility. Do not publish a production release until physical Android QA, save migration/recovery checks, and the production signing environment are verified.

## Core documents

- [Game Design Document](docs/GDD.md)
- [Production Audit and Roadmap](docs/PRODUCTION_AUDIT_AND_ROADMAP.md)
- [Session Handoff](docs/SESSION_HANDOFF.md)
- [Trait and Personality System](docs/TRAIT_PERSONALITY_SYSTEM.md)
- [Companion Questlines](docs/COMPANION_QUESTLINES.md)
- [Android Release Workflow](docs/ANDROID_RELEASE_WORKFLOW.md)
- [Manual GitHub Workflows](docs/MANUAL_GITHUB_WORKFLOWS.md)
