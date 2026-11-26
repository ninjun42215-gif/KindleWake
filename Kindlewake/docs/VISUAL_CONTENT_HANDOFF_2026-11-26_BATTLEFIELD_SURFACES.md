# Visual-content handoff — tactical battlefield surface atlas

## Repository checkpoint and coordination

- Repository: https://github.com/ninjun42215-gif/KindleWake
- Project: `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android · offline-first
- Main observed at start of this run: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- Parent visual PR: [#171 — distinct rune-element battle impact effects](https://github.com/ninjun42215-gif/KindleWake/pull/171).
- Parent branch head used as the exact starting point: `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70`.
- Working branch: `art/battlefield-surface-atlas-2026-11-26`.
- This branch is deliberately stacked on PR #171 because #171 already owns the battle renderer and test runner. It does not create a competing branch from main.
- PR #170 changes battle-controller turn flow, not the files changed here. PRs #167/#169 also extend the shared test runner; reconcile that test file when the settlement work is integrated.
- No main edits, merge, force-push, branch deletion, repository-setting change, release publication or secret access.

## Live repository findings

- The project is still Godot 4.2.2 / GL Compatibility, landscape 1280×720 logical design, Android, version 0.12.0, save schema 4 and fully offline.
- The tactical renderer in `scripts/ui/battle_scene.gd` draws 64×32 isometric terrain diamonds with primitive surface marks and existing prop-atlas details.
- Existing terrain IDs include grass, forest, road, hill, ford, deep_water, bridge, rock, marsh, snow, ash, ruins and cliff. Act III also uses a legacy traversable `water` ID that has no explicit terrain definition; this pass gives it the ford visual palette only.
- The current playable battle definitions include the Sallow Road river crossing, Hall of Ash, Three Bridges, and authored dungeon/boss battle maps. This atlas enriches their existing terrain; it does not claim new battle maps or continent regions.
- Optional sprite-pack archives remain intake-only. No archive was opened or imported. Existing Quaternius / Zerie provenance remains governed by the main asset ledger. The new surface atlas is entirely original project-authored SVG.

## Delivered

1. Added `assets/art/tiles/battlefield_surface_atlas.svg`, a 1408×32 transparent atlas with 22 cells (64×32 each), two variants for eleven surface families:
   - grass, forest, road, hill, ford, deep water, marsh, snow, ash, ruins and cliff.
2. Added `scripts/ui/battlefield_surface_style.gd`:
   - loads one Texture2D for the battle scene;
   - maps stable terrain IDs to atlas pairs;
   - chooses a deterministic variant from cell coordinates;
   - returns safely for bridge, raised rock and unknown terrain;
   - retains no animation or per-frame resource construction.
3. Integrated the helper into `battle_scene.gd`:
   - ground details are drawn over the existing terrain fill and under tile outlines;
   - existing larger props and bridge-plank renderer remain;
   - existing primitive detail strokes are retained as fallback when the atlas cannot load;
   - legacy Act III `water` uses ford color/details without changing movement or blocking behavior.
4. Added 19 regression assertions to `tests/run_tests.gd` covering all 22 cells, deterministic two-variant mapping, non-overlapping cell pairs, bridge/rock fallback, legacy-water alias, texture import dimensions, no external raster/link resources and battle-scene integration.
5. Added this per-asset provenance record.

## Changed files

- `Kindlewake/assets/art/tiles/battlefield_surface_atlas.svg`
- `Kindlewake/assets/art/tiles/BATTLEFIELD_SURFACE_ATLAS_PROVENANCE.md`
- `Kindlewake/scripts/ui/battlefield_surface_style.gd`
- `Kindlewake/scripts/ui/battle_scene.gd`
- `Kindlewake/tests/run_tests.gd`
- `.github/workflows/visual-content-validation.yml`
- `Kindlewake/docs/VISUAL_CONTENT_HANDOFF_2026-11-26_BATTLEFIELD_SURFACES.md`

## Commit trail

- Atlas artwork: `798e3cb560e00de57e9db96937fa1c1d4b464b29`
- Cached surface renderer: `96f0da834c65c1960900d45f4da7bb607d73b443`
- Legacy shallow-water mapping: `e3b324174b977672b1be7e7b51e4741e553eef2d`
- Battle-scene integration: `a74d0684f1984b1a27bdd985ccf0cf9927ee3b00`
- Regression coverage: `1f1abd36d333c267d7aef86f3ce38cf62435312b`
- Godot validation workflow: `a45108721bf892eda4b924873c0d5704179deb1b`
- Godot executable PATH fix: `9517f101917568ad643d89e06201481ea14adb70`
- Complete editor scan before tests: `53b2428311ddea10a02d481426ebcb85440ad7ea`
- Provenance and CI/handoff updates follow on this branch.

## Validation

The parent PR #171 exact head `e5e9f3ca1b7c66f7d46069b2b6a2c285dfe29a70` previously passed Godot 4.2.2 import, 20/20 scene smoke, 1,026 strict checks, campaign/UI/continuity/dynasty/family/balance tests, APK export, Project Health Audit, YAML lint and Version Sync. Its AOSP ATD / forced SwiftShader emulator process-liveness check failed; the screenshot was black. This is parent evidence only, not verification of this child branch.

The new read-only visual-content workflow ran successfully on child code head `53b2428311ddea10a02d481426ebcb85440ad7ea`:
- [Visual Content Validation #45768730864](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768730864): Godot 4.2.2 import passed, 20/20 scenes loaded, strict suite **1,060 checks / 0 failures**, and the SVG atlas geometry/provenance check passed.
- [Project Health Audit #45768736764](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736764): passed.
- [Workflow YAML Lint #45768736672](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736672): passed.
- [Version Sync #45768736705](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736705): passed.
- [Android Build #45768736707](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707): overall workflow passed, including Godot import, 20-scene smoke, strict tests, APK export/upload and emulator process-liveness. The build summary reports 1,060 core checks / 0 failures, Act V 0 failures, continuity 70/0, dynasty 39/0 and family development 19/0.
- APK artifact [#15093451389](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707): 65,321,994-byte ZIP. Extracted APK: 65,877,755 bytes, SHA-256 `6fa7fd80033e8426ec09bc601f7fe0e3796cf06837cb347c0fae1528339ceef7`. It has a valid CI/test signature, ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and requests no Android permissions. This is not a production-signed release.

### Android screenshot review — important visual blocker

The process-liveness check passed, but I downloaded and inspected the exact-head test-log artifact [#15093207065](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45768736707/artifacts/15093207065). Its `honor400-emulator.png` (1368×632) shows only a dark central menu shell with blank button rectangles: the title and menu labels are not visible. The app process stayed alive, so the existing main workflow's process check is a false-positive for usable rendering.

The same artifact's `android-logcat.txt` records:
- `rendering/limits/global_shader_variables/buffer_size` exceeding the emulator's 16,384-byte uniform-buffer limit;
- `SceneShaderGLES3` link failures because fragment uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`;
- SwiftShader GLES3 error messages. No fatal Java exception or native fatal signal was captured.

This is a pre-existing AOSP ATD / forced SwiftShader presentation problem; the new battlefield atlas adds no shader or global uniform. Do not count the emulator process-liveness pass as visual verification.

The separate QA branch [PR #164](https://github.com/ninjun42215-gif/KindleWake/pull/164) already has a stronger API 35 Google APIs/default-GPU route, avoids display-size/density mutation and OCR-checks visible title/menu labels. Its exact-head [Build #45014535413](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413) passed; I inspected [test-log artifact #14751421618](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45014535413/artifacts/14751421618): the screenshot visibly renders KINDLEWAKE, THE SUNDERED VOW, NEW GAME, LOAD GAME, SETTINGS and the other menu labels, and the OCR artifact contains those strings. A coordination comment with the false-positive evidence was added to PR #164. Keep that QA work separate and reconcile it before treating emulator screenshots as a release gate.

The first visual-workflow attempt failed because the downloaded executable was not exposed as `godot`; a symlink fixed that. The next attempt exposed an early editor quit that aborted Godot's global-class scan; changing the import command to the repository's proven `--quit-after 120` sequence fixed it. The final child code-head validation above passed.

PR #183 was temporarily targeted at main to run the existing main-target workflows, then retargeted to the exact parent branch `art/rune-combat-vfx-language-2026-11-21`. It is now correctly stacked on PR #171 and must not merge before its parent.

Still required:
- Godot editor screenshots at battle zoom levels, including river, forest, ash, ruins and snow maps.
- Confirm the texture's actual imported dimensions and alpha edges in the editor.
- Physical Android viewport/touch, GPU memory, frame pacing and vendor-GPU checks.
- Compare tile readability at minimum and maximum supported zoom. CI is not visual/device certification.

## Performance and rights

- Source atlas: 1408×32 SVG, transparent, 22×64×32 cells.
- RGBA8 planning estimate: 176 KiB before mipmaps/driver overhead. Actual Godot import size and Android VRAM are unmeasured.
- One cached texture per battle scene; one region draw per supported tile; no extra node, shader, animation or external resource.
- Original project-authored vector art only. No third-party licence dependency was introduced.
- No gameplay, save schema, story, character data, encounter data or project version change.

## Next visual priorities

1. Capture and review actual battlefield screenshots before adding more micro-detail.
2. Add region-specific large-scale battlefield set dressing (river banks, hall pillars, ruined walls, snowdrifts) only where the battle map's authored terrain supports it.
3. Continue enemy/boss silhouette and portrait-to-sprite identity work after current PR #180/#157/#161/#162 are reconciled.
4. Keep every new atlas tied to an actual renderer and a per-asset provenance note; unused drops are not completion.
