# KindleWake — Next AI Start Here

**Repository:** `ninjun42215-gif/KindleWake`  
**Canonical project directory:** `Kindlewake/`  
**Current target branch:** `main`  
**Current game version:** `0.10.0` (Android version code `1000`)  
**Timezone:** Asia/Manila (UTC+08:00)

## Current repository state
- Operations Toolbox was integrated and merged via PR #7. Merge commit: `d4b696938fcb22fc1e40862b11a900d435ab75b1`.
- Rune System source checkpoint: `01cd3f67a344a964b26eb4150167a21bd3fb733c`; its changes are being reconciled onto the latest main, not blindly merged from the stale branch.
- Safe auto-merge discovery was repaired in PR #6. It can still fail to auto-enable GitHub auto-merge in some workflow-run contexts; inspect exact-head CI and mergeability before taking a safe manual merge action.
- Required validation includes Android APK build, version synchronization, workflow YAML lint and Project Health Audit.
- Main's version-sync workflow treats `Kindlewake/project.godot` as the authoritative version. Keep README and Android export metadata synchronized.

## Product and engineering constraints
- KindleWake is an offline-first Godot 4.2+ Android/iOS tactical RPG. Do not add networking, accounts, multiplayer or Android INTERNET permission.
- Preserve save compatibility and existing legacy save fields when evolving runes, equipment or campaign systems.
- Runes include active spells, passive effects, unique and heirloom types. Three-copy mixed-grade fusion and mastery bonuses are part of the intended design.
- Protect unique/heirloom runes from accidental selling/fusion.
- Do not claim physical-device QA unless actually performed.
- The voxel-building pack currently used by the game has unverified licence/redistribution rights. Do not publish commercially/publicly until verified or replaced. Other provenance is documented in `Kindlewake/data/asset_provenance.json` and `Kindlewake/assets/art/CREDITS.md`.

## First actions for the next AI
1. Read this file, `docs/CONTINUATION_PROMPT.md`, `docs/SESSION_HANDOFF.md`, and `docs/GDD.md`.
2. Read live GitHub refs and PRs; do not rely on this snapshot if newer commits exist.
3. Check Actions runs for the exact current main SHA before calling builds current.
4. Run the strict Godot tests, balance report and Android export through GitHub Actions; inspect logs and APK artifact.
5. Update this file and session handoff with exact SHAs, tests, artifact links and remaining QA.
6. Keep a fresh split source-handoff artifact available for the next session; verify its embedded SHA matches the source ref.

## Relevant links
- Repository: https://github.com/ninjun42215-gif/KindleWake
- Main: https://github.com/ninjun42215-gif/KindleWake/tree/main
- Actions: https://github.com/ninjun42215-gif/KindleWake/actions
- PR #7: https://github.com/ninjun42215-gif/KindleWake/pull/7
- Source branch history: https://github.com/ninjun42215-gif/KindleWake/tree/feature/rune-system-v1

