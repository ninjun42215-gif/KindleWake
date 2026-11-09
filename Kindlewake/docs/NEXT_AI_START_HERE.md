# KindleWake — Next AI Start Here

**Repository:** `ninjun42215-gif/KindleWake`  
**Canonical project directory:** `Kindlewake/`  
**Current branch:** `main`  
**Main before this handoff refresh:** `fa34541df7f37a7f992f10bba3b5cb8f4afd7e23`  
**Game version:** `0.10.0` · **Android version code:** `1000`  
**Timezone:** Asia/Manila (UTC+08:00)

## Merged work
- PR #7 Operations Toolbox: source handoff, full backup, branch hygiene, repository organizer, safe branch integration, health audit and workflow lint.
- PR #8 Rune System: 77 rune definitions; active/passive/support/stat/independent categories; unique and heirloom flags; mixed-grade fusion; mastery bonuses; combat statuses; regional rune merchants; original rune/UI/environment art.
- PR #9 and #10 Safe Auto Merge: REST-based exact-SHA workflow discovery and expected-SHA REST merge without local Git metadata.
- PR #11 handoff refresh, PR #13 four-check gate and PR #14 end-to-end gate verification all automatically merged.
- PR #14 Safe Auto Merge run `42705647621` succeeded after exact-head discovery, all four required checks and REST merge.

## Latest verified APK and source handoff
- PR #14 Build Android APK passed: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42705446416 (APK artifact ID `13712692998`, test logs `13712578070`).
- PR #14 Version Sync: run `42705446459`; Project Health Audit: `42705446873`; Workflow YAML Lint: `42705446519`.
- PR #14 source handoff: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42705423062 (artifact ID `13713023290`; 177 tracked files, 4 parts, zero excluded; archive SHA-256 `370d8ac7ce2bebf9896bdc99f848be102f1552e54daca7a037266bff1fa9d580`). Exact snapshot SHA `3ed23761ddd6ac2a2fbede88742893b2870111b9`, tree merged by PR #14.

## Automatic merge behavior (verified)
1. Successful Build Android APK run for a PR triggers the gate.
2. The gate waits up to five minutes for Build APK, Version Sync, Workflow YAML Lint and Project Health Audit all to pass on the exact same head SHA.
3. It rejects failed/missing checks, stale heads, drafts, conflicts, wrong base branches and ambiguous PRs.
4. It rechecks the expected SHA and squash-merges through GitHub REST.
5. PR #14 passed this process end to end; preserve these safeguards.

## Non-negotiable constraints
- Offline-first Godot 4.2+ RPG. No networking, accounts, multiplayer or Android INTERNET permission.
- Preserve existing save compatibility and legacy sigil fields/aliases when changing rune systems.
- Do not claim physical Android testing without device evidence.
- The voxel-building pack currently used in game has unverified licence/redistribution rights. Public/commercial release is blocked until verified or replaced. Keep credits and `data/asset_provenance.json` synchronized.

## Next tasks
1. Continue game improvements from `docs/GDD.md` and inspect the live repository state before editing.
2. Generate a fresh source handoff artifact for the latest main SHA after this documentation update; verify the manifest and part-size limits.
3. Perform physical Android QA: install APK; test launch/orientation/touch HUD; rune inventory/socketing/fusion; specialist shops; Burn/Chill/Shock/Exposed/Regeneration/Shadow effects; save/load; performance.
4. Verify the voxel-building pack licence from authoritative source or replace those assets.
5. Update GDD, README, session handoff and continuation prompts for every meaningful milestone.

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

