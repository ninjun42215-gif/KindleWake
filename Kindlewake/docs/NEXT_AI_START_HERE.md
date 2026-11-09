# KindleWake — Next AI Start Here

**Repository:** `ninjun42215-gif/KindleWake`  
**Canonical project directory:** `Kindlewake/`  
**Current branch:** `main`  
**Current main SHA:** `23979c075244f1212e8313a1f4aa0471001d5fe5`  
**Game version:** `0.10.0`  
**Android version code:** `1000`  
**Timezone:** Asia/Manila (UTC+08:00)

## Merged work
- PR #7 Operations Toolbox: source handoff, full backup, branch hygiene, repository organizer, safe branch integration, health audit and workflow lint.
- PR #8 Rune System: 77 rune definitions; active/passive/support/stat/independent categories; unique and heirloom flags; mixed-grade fusion; mastery bonuses; status effects; regional rune merchants; original rune/UI/environment art.
- PR #9 Safe Auto Merge run discovery: Actions REST API lookup for the exact PR head SHA; no checkout required.
- PR #10 Safe Auto Merge execution: GitHub REST merge endpoint with exact expected head SHA; no checkout or native auto-merge eligibility required.

## CI and deliverables
- Rune integration PR #8: all required checks passed, including Godot import, strict tests, balance report, Android APK export/upload, version sync, workflow lint and health audit. Run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42702932178
- Main APK build after Rune integration passed: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42703185402
- PR #10 exact-head build and checks passed before merge: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42703880883
- Previous source handoff artifact ID `13713170432` from run https://github.com/ninjun42215-gif/KindleWake/actions/runs/42703185474 is for SHA `2a6b31ddb38b67d97a16ad8dc47463cd9e882121`, not the latest main. Generate/verify a fresh artifact for the current SHA after this handoff refresh.

## Non-negotiable constraints
- Offline-first Godot 4.2+ RPG. No networking, accounts, multiplayer or Android INTERNET permission.
- Preserve existing save compatibility and legacy sigil fields/aliases when changing rune systems.
- Do not claim physical Android testing without device evidence.
- The voxel-building pack currently used in game has unverified licence/redistribution rights. Public/commercial release is blocked until verified or replaced. Keep credits and `data/asset_provenance.json` synchronized.

## Next tasks
1. Verify the new automatic REST merge behavior on a safe follow-up PR after the current workflow changes are on main. It must find one open PR, confirm both Build Android APK and Synchronize Project Version succeeded for the exact head SHA, and merge only if the head is unchanged and GitHub reports mergeable.
2. Create and verify a fresh split source handoff artifact for the exact current main SHA; check the SHA256 manifest and part-size limits.
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

