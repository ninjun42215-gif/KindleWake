# Next AI Start Here — KindleWake

**Current repository:** `ninjun42215-gif/KindleWake`  
**Default branch:** `main`  
**Current main commit:** `036a17da88ab1b1037b224334dbfbbdcb392e195`  
**Engine:** Godot 4.2.2 / GDScript / GL Compatibility  
**Game version:** 0.12.0 · **Android version code:** 1200 · **Save schema:** 4  
**Architecture:** offline-first; no accounts, servers, multiplayer or INTERNET permission.

## Read first

1. [Production Audit and Roadmap](PRODUCTION_AUDIT_AND_ROADMAP.md) — authoritative inventory, implementation gaps, branch risks and integration order.
2. [Session Handoff](SESSION_HANDOFF.md) — current repository state, verified CI, open issues and next steps.
3. [Game Design Document](GDD.md) — authored canon and design intent.
4. [Versioning](VERSIONING.md) and [Android Release Workflow](ANDROID_RELEASE_WORKFLOW.md) — do not change version or signing policy casually.

Older checkpoint notes in other documents are historical. Always verify the live main SHA, open PRs and CI before editing.

## What is actually on main

- Tactical grid combat, turn control, AI, status effects, six battle definitions and balance simulation.
- Character creation, party/XP progression, 28 classes, 15 combat skills, equipment, 77 runes, 69 traits, five trait synergies, 40 personality event templates and 12 curated ambitions.
- 36 character definitions, 39 town/interior maps, two distinct overworld datasets, seven-continent atlas blueprint, faction foundations and several authored quest chains.
- Checksummed saves, schema migrations, semantic campaign validation, backup recovery, malformed-write rejection, future-version protection, battle snapshot validation and isolated save tests.
- Android build pipeline for ARM64/ARMv7, campaign restore-to-World lifecycle test, offline permission checks and protected production publishing workflow.

Counts describe catalogues. They do not prove every item is balanced, exposed in UI, triggered by gameplay or fully playable.

## Known gaps

- Issue #36 Android crash after character creation / Continue remains unresolved. The headless lifecycle test passes, but physical Android process-restart QA and logcat/Godot stack trace are still required.
- The seven-continent atlas is not seven playable overworlds. Only two distinct regional overworld datasets are wired into `GameData.world_for_region()`.
- The 28-class promotion graph is not a full node-based skill tree; there is no persistent talent-point budget.
- Trait and ambition data/APIs exist, but many behavior-evidence triggers and a complete ambition assignment UI remain incomplete.
- The generic 21-companion quest framework, regional trade/economy, five-act campaign continuity, Chronicle founder epilogue, and unified realm/territory management are not integrated on main.
- No bundled fonts, music or sound effects; most classes lack complete original portraits and animation sets.
- Android is configured; iOS export/device QA is not.
- Used third-party art has verified recorded terms (Quaternius CC0 nature art and Zerie's permitted Free Soldier/Orc subset). Unverified legacy voxel-building PNGs and optional sprite-pack archives are marked unused; do not import them until licences are verified.

## Latest mainline verification

Exact-main CI run [#42804577127](https://github.com/ninjun42215-gif/KindleWake/actions/runs/42804577127) passed on commit `036a17da88ab1b1037b224334dbfbbdcb392e195`:
- 671 strict checks / 0 failures.
- 9/9 scene resources loaded.
- Campaign save → reset → restore → World startup lifecycle test: 0 failures.
- Balance report, Android APK export/signature, Project Health Audit, Version Sync and Workflow YAML Lint passed.

The first Godot editor scan still logs transient global-class registration errors; the clean second scan completes without unresolved script errors. Headless ObjectDB/resource cleanup warnings remain on the cleanup backlog. CI is not device QA.

## Integration priorities

1. Reproduce issue #36 on Android; capture logcat and Godot stack trace.
2. Finish one complete companion-quest vertical slice before importing all 21 routes.
3. Integrate regional trading and faction diplomacy.
4. Build real regional maps, route graph, encounter tables and local-map coverage for each unlocked continent.
5. Consolidate holdings, taxation, economy and governance into one canonical simulation.
6. Integrate five-act continuity, then founder epilogue/Chronicle gates in dependency order.
7. Design and balance actual class talent trees.
8. Add original character art, typography, audio, accessibility and mobile polish.

## Engineering rules

- Do not commit directly to main; use focused pull requests.
- Do not merge stale or stacked branches wholesale. Rebase/port against live main and run exact-head CI.
- Preserve offline-first behavior and save schema 4 unless a reviewed migration is necessary.
- A catalogue or data-only feature is not a completed playable system.
- Require Godot import, strict tests, scene smoke, campaign lifecycle, balance, Android export/signature and project audits.
- Physical-device QA is a separate release gate.
