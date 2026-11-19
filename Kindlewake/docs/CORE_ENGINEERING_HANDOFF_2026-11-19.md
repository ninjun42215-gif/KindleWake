# KindleWake — Core Engineering Handoff (2026-11-19)

## Live repository checkpoint

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Project directory: `Kindlewake/`
- Engine: Godot 4.2.2 · GL Compatibility · Android
- Base main SHA at branch creation: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Candidate branch: `fix/chronicle-dynasty-save-normalization-2026-11-19`
- Code commits: `29c3ab3f25dcbe2cad673bd225ae0f1149dc1ef2`, `896b850bae2facee5f9e2d74fdb9d5780eeb9cfd`
- No changes to main; no merge, force-push, branch deletion or repository-setting changes.

## Finding and fix

`ChronicleDynastySystem.normalize_state()` processed people before validating the saved `domains` catalog. It passed `state.get("domains", {})` into `_valid_ids(values: Variant, people: Dictionary)`. A checksum-valid saved Chronicle object with a valid founder and people dictionary but an Array-valued `domains` field could trigger an invalid argument-type runtime error when the Chronicle of Houses screen restored its state. A Dictionary containing non-Dictionary domain records could also leave person records referring to domains that are later discarded.

The fix normalizes the domain catalog before iterating people:
- Non-Dictionary catalogs become an empty Dictionary.
- Non-Dictionary domain entries are discarded.
- Person `domain_ids` are validated against the cleaned catalog, so dangling links are pruned.
- Existing title ownership, domain stewardship, succession, family and history normalization remains in place.

No save-schema/version change, migration, story alteration, player-data rewrite or change to valid Chronicle progression.

## Changed files

- `Kindlewake/scripts/core/chronicle_dynasty_system.gd`
- `Kindlewake/tests/test_chronicle_dynasty.gd`
- `Kindlewake/docs/GDD.md`
- `Kindlewake/docs/CONTINUATION_PROMPT.md`
- `Kindlewake/docs/SESSION_HANDOFF.md`
- `Kindlewake/README.md`
- `Kindlewake/docs/CORE_ENGINEERING_HANDOFF_2026-11-19.md` (this file)

## Regression coverage

Added tests for:
1. An Array-valued saved `domains` catalog.
2. A Dictionary containing a non-Dictionary domain record.
3. Pruning a person's `domain_ids` when the referenced domain is absent after normalization.

The existing valid JSON round-trip, family, title, succession and domain economy assertions remain unchanged. Exact-head GitHub Actions results are pending; no test pass is claimed yet.

## Repository coordination

- PR #160 already covers the distinct top-level `empire_state` type-validation gap in `RegionSaveState`; this branch does not duplicate or modify that fix.
- PRs #164/#165 own Android/release workflow hardening and Safe Auto Merge base-freshness. No workflow files were changed.
- Visual branches/PRs remain untouched.

## Current main Android status at audit

Main SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`:
- Project Health Audit #44446304110 — passed.
- Workflow YAML Lint #44446304180 — passed.
- Version Sync #44446304299 — passed.
- Android Build #44446304169 — import and APK export succeeded; 20/20 scenes loaded; 1,009 strict checks / 0 failures; campaign lifecycle, merchant UI, title/creator UI, Act V, continuity (70), dynasty (39), family development (19) and balance simulation completed. Overall workflow failed because the AOSP ATD emulator process did not remain running after launch; the step's final `pidof com.kindlewake.game` check failed. This run did not capture a reliable Android process-survival pass. APK artifact #14493646109 is a CI-exported candidate, not a release-verified build.
- No physical Android handset testing is available from this run.

## Next steps

1. Inspect the exact PR-head test and Android workflows; report each separately.
2. Keep the PR draft until reviewed; do not merge automatically.
3. QA should reconcile emulator PR #164/#159 and Safe Auto Merge freshness PR #165 with current main.
4. Physical-device testing remains required for creator touch, Chapter 1, world travel, battle controls, pause/resume and save/force-close/Continue.
