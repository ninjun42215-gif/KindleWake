# Receiving intake review — 2026-11-10

## Snapshot and intake integrity

Reviewed the tracked `main` snapshot at `fd590215f108a4c2d2a8c846fffe0a881866ee5a`. The repository source-handoff artifact was reassembled with the checked-in `source_handoff.py` helper and verified: 194 tracked files, ZIP CRC passed, every manifest SHA-256 passed, safe extraction passed.

The receiving folder contained two ZIP contributions and its README. Both archives passed ZIP CRC validation. Neither archive included the required `HANDOFF.md`; this review supplies the missing inventory, provenance and disposition record.

| Intake file | SHA-256 | Result |
|---|---|---|
| `Kindlewake_premium_pass.zip` | `5711f4062284f2155769cabe36034df737ffce666c867706f32a28015dbbec38` | Accepted in part; reviewed and integrated below |
| `Kindlewake_repo_update.zip` | `781200b56426e15168e3a9345fa7b67ab317b05b6b2618847602750785132f79` | Superseded; its Chapter I / creator fixes are already present in merged PR #30; no incoming files reapplied |

## Premium Pass contribution inventory

`Kindlewake_premium_pass.zip` contains 13 ZIP entries: `README_APPLY.md`; `docs/DESIGN_REVIEW.md`; `diffs/battle_scene.diff`; `diffs/world_scene.diff`; `scripts/core/kw.gd`; and full replacement copies of `scripts/ui/battle_scene.gd` and `scripts/ui/world_scene.gd`.

No fonts, audio, images, external libraries, plugins, licences or asset provenance records were included. The supplied code is treated as an original code contribution; no third-party asset rights are asserted by this intake. The design review's asset-source/licence claims remain unverified and must be checked on each original download page before any asset is added.

## Accepted implementation

- Added `scripts/core/kw.gd` as the `KW` autoload. It provides a shared brass/ink theme, optional font/audio loading, button press feedback, haptics, persistent reduce-motion/haptics/SFX preferences, and opt-in fade transitions.
- Hardened the submitted bootstrap: preferences load from the existing `user://settings.cfg`; sound resources are cached; button tweens are cancelled before replacement; scene changes validate their resource and restore the fade overlay on failure.
- Added the haptics, reduce-motion and UI-SFX controls to the existing Settings screen. Defaults preserve existing behaviour and no save-schema changes are involved.
- Applied the submitted world overlay z-order fix so Company remains above the minimap.
- Applied the submitted battle readability changes: readable turn chips, active/inspected-only unit tags and wider outlined floating text.
- Added a headless scene-smoke parse check for the new autoload script.

## Superseded contribution

`Kindlewake_repo_update.zip` contains `MASTER_PROMPT.md`, `README_UPLOAD.md`, an APK analysis and full/diff copies of `character_creator.gd`, `escape_sequence.gd` and `title_screen.gd`. Its Chapter I and creator patch is based on an earlier project snapshot and duplicates work already merged in PR #30. It is not reapplied, to avoid reverting later changes. Its analysis remains useful as historical review context but is superseded by this document and the current GDD/session handoff.

## Validation and limitations

- Both incoming archives: ZIP integrity passed.
- Main source snapshot: 194 tracked file hashes and safe extraction passed.
- Static checker: it reports existing checker false positives for engine globals and underscore placeholders, plus `draw_string_outline` not being in its method catalogue. This is not a Godot parse result and is not treated as a passing engine test.
- Godot editor/runtime is not installed in the review container. The required Godot import, strict tests, scene smoke, Android APK export and Android permission audit must pass in GitHub Actions for the exact PR head before merge.
- No fonts, music, SFX or new art assets were included, so the optional asset paths remain empty and the game remains silent until properly licensed assets are added.
- Physical-device QA remains outstanding. CI cannot establish touch feel, haptic quality, safe-area correctness, frame pacing or battery impact on a real phone.
- The third-party voxel-building pack licence remains unresolved and is still a public/commercial release blocker.

## Intake disposition

The premium pass code is accepted for integration subject to exact-head CI. The old repository update is marked superseded by PR #30. After this review and integration are merged, both source ZIPs can be removed from `receiving/`; retain this review and `receiving/README.md` as the audit trail.
