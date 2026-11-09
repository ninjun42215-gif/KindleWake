# KindleWake — Next AI Start Here

**Repository:** `ninjun42215-gif/KindleWake`  
**Canonical project directory:** `Kindlewake/`  
**Current branch:** `main`  
**Main before this verification PR:** `10d000922f232ae4566f3ebe8dfe9ba42fdb20b8`  
**Game version:** `0.10.0` · **Android version code:** `1000`  
**Timezone:** Asia/Manila (UTC+08:00)

## Merged work
- PR #7 Operations Toolbox: source handoff, full backup, branch hygiene, repository organizer, safe branch integration, health audit and workflow lint.
- PR #8 Rune System: 77 rune definitions; active/passive/support/stat/independent categories; unique and heirloom flags; mixed-grade fusion; mastery bonuses; combat statuses; regional rune merchants; original rune/UI/environment art.
- PR #9 and #10 Safe Auto Merge: REST-based exact-SHA run discovery and expected-SHA REST merge, with no local Git metadata dependency.
- PR #11 session handoff refresh auto-merged successfully.
- PR #13 four-check Safe Auto Merge gate auto-merged successfully. Run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42705236585

## CI and downloads
- Rune integration PR #8: Godot import, strict tests, balance report, APK export/upload, version sync, workflow lint and health audit passed. Run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42702932178 (APK artifact ID `13711239347`).
- PR #13: all four exact-head checks passed; source handoff artifact ID `13712438222`, run https://github.com/ninjun42215-gif/KindleWake/actions/runs/42705016493. 177 tracked files, 4 ZIP parts, zero excluded; archive SHA-256 `9ed99230c0d0b8e4a8d7859afdcc38ab440ae8433fccfe848ad761946c42c0a2`. Exact source SHA `b74b135155b54f7990e526cace41793b2f5e5bd6`.
- PR #14 is testing the new four-check gate end-to-end. Its Safe Auto Merge run must show exact-SHA validation and successful REST merge.

## Automatic merge rules
1. A successful Build Android APK run for a PR triggers the gate.
2. The gate waits up to five minutes for Build Android APK, Synchronize Project Version, Workflow YAML Lint and Project Health Audit all to pass on the exact same head SHA.
3. It rejects failed checks, stale heads, drafts, conflicts, wrong base branches and ambiguous PRs.
4. It rechecks the expected SHA and squash-merges through GitHub REST.
5. No local Git checkout is required.

## Non-negotiable constraints
- Offline-first Godot 4.2+ RPG. No networking, accounts, multiplayer or Android INTERNET permission.
- Preserve existing save compatibility and legacy sigil fields/aliases when changing rune systems.
- Do not claim physical Android testing without device evidence.
- The voxel-building pack currently used in game has unverified licence/redistribution rights. Public/commercial release is blocked until verified or replaced. Keep credits and `data/asset_provenance.json` synchronized.

## Next tasks
1. Verify PR #14 auto-merges only after all four exact-SHA checks pass.
2. Generate a fresh split source handoff artifact for the latest main SHA; check the SHA256 manifest and part-size limits.
3. Perform physical Android QA: install APK; test launch/orientation/touch HUD; rune inventory/socketing/fusion; specialist shops; Burn/Chill/Shock/Exposed/Regeneration/Shadow effects; save/load; performance.
4. Verify the voxel-building pack licence from authoritative source or replace those assets.
5. Continue planned game improvements from `docs/GDD.md` and update GDD, README, session handoff and continuation prompts for every meaningful milestone.

## Read first
- `docs/SESSION_HANDOFF.md`
- `docs/CONTINUATION_PROMPT.md`
- `docs/GDD.md`
- `docs/SAFE_AUTO_MERGE.md`
- `docs/MANUAL_GITHUB_WORKFLOWS.md`

## Links
- Repository: https://github.com/ninjun42215-gif/KindleWake
- Main: https://github.com/ninjun42215-gif/KindleWake/tree/main
- Actions: https://github.com/ninjun42215-gif/KindleWake/actions
- PR #8: https://github.com/ninjun42215-gif/KindleWake/pull/8
- PR #11: https://github.com/ninjun42215-gif/KindleWake/pull/11
- PR #13: https://github.com/ninjun42215-gif/KindleWake/pull/13
- PR #14: https://github.com/ninjun42215-gif/KindleWake/pull/14

