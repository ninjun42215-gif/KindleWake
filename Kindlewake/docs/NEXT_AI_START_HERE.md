# KindleWake — Next AI Start Here

**Repository:** `ninjun42215-gif/KindleWake`  
**Canonical project directory:** `Kindlewake/`  
**Current branch:** `main`  
**Main before this handoff refresh:** `444f3678b4b8738754fb6cf6e2991dde65bfd243`  
**Game version:** `0.10.0` · **Android version code:** `1000`  
**Timezone:** Asia/Manila (UTC+08:00)

## Merged work
- PR #7 Operations Toolbox: source handoff, full backup, branch hygiene, repository organizer, safe branch integration, health audit and workflow lint.
- PR #8 Rune System: 77 rune definitions; active/passive/support/stat/independent categories; unique and heirloom flags; mixed-grade fusion; mastery bonuses; combat statuses; regional rune merchants; original rune/UI/environment art.
- PR #9 and #10 Safe Auto Merge fixes: exact-SHA run discovery and REST-based merge, without requiring local Git metadata.
- PR #11 session handoff refresh was automatically merged. Safe Auto Merge run `42704448460` completed successfully for exact PR head `b3ae29aef0f71a982a17cf3d292296372303c8e3`.

## CI and downloads
- Rune integration PR #8: Godot import, strict tests, balance report, APK export/upload, version sync, workflow lint and health audit all passed. Run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42702932178 (APK artifact ID `13711239347`).
- Main Android build after Rune integration passed: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42703185402.
- PR #11 handoff run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42704259248 (artifact ID `13712053831`; 177 tracked files, 4 ZIP parts, zero excluded; archive SHA-256 `aa1a2d412a27fa5ab5ab2f41042b185af045e4cfa8e21c9d58c069897f0a54cc`). This is exact head `b3ae29aef0f71a982a17cf3d292296372303c8e3`, merged by PR #11.
- PR #12 strengthens automatic merging: after Build APK success, it waits for Build APK, Version Sync, Workflow YAML Lint and Project Health Audit all to pass for the exact same SHA, then merges through GitHub's REST API with that SHA.

## Non-negotiable constraints
- Offline-first Godot 4.2+ RPG. No networking, accounts, multiplayer or Android INTERNET permission.
- Preserve existing save compatibility and legacy sigil fields/aliases when changing rune systems.
- Do not claim physical Android testing without device evidence.
- The voxel-building pack currently used in game has unverified licence/redistribution rights. Public/commercial release is blocked until verified or replaced. Keep credits and `data/asset_provenance.json` synchronized.

## Next tasks
1. Verify PR #12 and test the four-check automatic merge gate with PR #13 or the next safe PR. It must find one open PR, wait for all four checks to succeed on the exact head SHA, and merge only if the head is unchanged and GitHub reports mergeable.
2. Generate and verify a fresh split source handoff artifact for the latest main SHA; check the SHA256 manifest and part-size limits.
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
- PR #7: https://github.com/ninjun42215-gif/KindleWake/pull/7
- PR #8: https://github.com/ninjun42215-gif/KindleWake/pull/8
- PR #9: https://github.com/ninjun42215-gif/KindleWake/pull/9
- PR #10: https://github.com/ninjun42215-gif/KindleWake/pull/10
- PR #11: https://github.com/ninjun42215-gif/KindleWake/pull/11
- PR #12: https://github.com/ninjun42215-gif/KindleWake/pull/12

