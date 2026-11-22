# Visual content handoff — premium rune icon atlas

## Source state
- Repository: https://github.com/ninjun42215-gif/KindleWake
- Project: `Kindlewake/` · Godot 4.2.2 · GL Compatibility · Android
- Base `main` SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Branch: `art/premium-rune-icon-atlas-2026-11-22`
- Scope: replace the repetitive rune placeholder glyphs with a distinct, grade-aware icon atlas while preserving the existing UI contract.
- Atlas implementation commit: `27a6efd603a9daefe80faf1803632e96bbcc5054`

## Delivered
- Reworked the existing `assets/art/runes/rune_atlas.svg` in place.
- Preserved the 400 × 240 canvas, ten columns, six grade rows and exact 40 × 40 cell geometry expected by `scripts/ui/party_screen.gd::_rune_icon()`.
- Added ten distinct project-authored glyphs: arcane, vitality, flame, frost, holy, shadow, storm, earth, wind and fortune.
- Added six restrained rarity frames and pips: common, uncommon, rare, epic, legendary and mythical.
- Existing runtime lookup, rune IDs, rune grades, equipment sockets, fusion rules, save schema, story and balance are unchanged.
- Added `assets/art/runes/README.md` documenting the grid contract, provenance and memory estimate.

## Asset provenance and technical constraints
- Original KindleWake vector artwork; no third-party images, fonts, external references, packages or copied game artwork.
- SVG uses basic paths, circles, rectangles and linear/radial gradients only. No filters, masks, CSS, embedded raster images or external URLs.
- The existing 40 × 40 `AtlasTexture` lookup contract remains valid.
- Base RGBA8 raster estimate: 384,000 bytes (375 KiB), excluding importer compression, mipmaps and GPU overhead. Actual device residency has not been measured.
- The project-wide asset manifest/provenance ledger already classifies the rune atlas as project-authored artwork; the central ledger was not edited because other active portrait work owns shared inventory files.

## Validation
- This handoff records the implementation, not a passed Godot or Android check.
- Source-level structural checks confirmed the 400 × 240 canvas, 60 translated cell groups, 10 × 6 layout, no embedded raster images, no scripts and no external URL references.
- XML parser validation and Godot import are not yet complete; the exact-branch Project Health Audit, headless tests and Android APK export must be checked against the final PR head.
- Godot editor inspection at 40 px, portrait/landscape mobile layouts and physical Android texture/frame-time QA remain required.
- No physical-device test is claimed.

## Coordination and safety
- Current base main at branch creation: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- This branch changes only the existing rune atlas plus this directory README and this handoff.
- It does not modify `party_screen.gd`, `tests/run_tests.gd`, battle code, save data, project version, workflow files, central credits or the central provenance ledger.
- The existing icon resolver uses column order arcane/vitality/flame/frost/holy/shadow/storm/earth/wind/fortune and row order common/uncommon/rare/epic/legendary/mythical; this contract was preserved.
- No merge, force-push, branch deletion, repository-setting change or release publication was performed.


## Exact-head CI verification — 22 November 2026

The following checks ran on implementation/documentation head `220b278b262910fadcb87279953ac4fa93342108`:

- [Project Health Audit #44994946094](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44994946094): passed; **0 errors, 0 warnings**.
- [Workflow YAML Lint #44994946097](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44994946097): passed.
- [Synchronize Project Version #44994946028](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44994946028): passed.
- [Android Build #44994946052](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44994946052): completed successfully, including Godot import, headless scene smoke, strict tests, APK export, emulator install and 30-second process-survival check.

### Exact build results
- Godot import/preflight: passed.
- Authored scene smoke: **20 scenes loaded, 0 failures**.
- Core strict suite: **1,009 checks, 0 failures**.
- Campaign lifecycle: 0 failures.
- Merchant UI: 0 failures.
- Title/creator UI: 0 failures.
- Act V checks: 0 failures.
- Campaign continuity: 70 checks, 0 failures.
- Chronicle dynasty: 39 checks, 0 failures.
- Chronicle family development: 19 checks, 0 failures.
- Balance report: completed.
- APK native ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`.
- APK signature: valid CI/test signature (certificate SHA-256 prefix `c04a7792715ad8f5`).
- Android permissions requested: none.
- Android emulator: APK installed, launcher activity resolved, app remained running after the 30-second smoke interval, screenshot/logcat captured; no fatal exception, fatal signal, GDScript script error or parse error matched the workflow gate.

### Exact-head artifacts
- [APK artifact #14743741873](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44994946052/artifacts/14743741873), 65,340,653 bytes; GitHub archive digest `sha256:b01e54e0b70b700205e93a0e57485c47d0d0c10be2b437ff04bacb9b51795fd6`.
- [Test-log artifact #14743621544](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44994946052/artifacts/14743621544), 101,271 bytes; GitHub archive digest `sha256:565f5cd4e0f2521c79f23bb9b259c946a12238957fd5fcf0f894fa882bc3069a`.

The APK is a CI/test-signed candidate, not a production-signed release. The successful emulator check is not physical-device QA and does not establish performance or compatibility across vendor GPUs. Editor inspection of the 40 px rune glyphs and physical Android touch, texture residency and frame-pacing checks remain outstanding.


## Follow-up exact-head verification — 22 November 2026

A documentation-only handoff update produced head `262573c92d589a9bea4927a3a9aa1a9f4f5d49df` (the rune SVG and runtime code were unchanged from `220b278b262910fadcb87279953ac4fa93342108`).

- [Project Health Audit #44995275306](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995275306): passed; 0 errors, 0 warnings.
- [Workflow YAML Lint #44995275282](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995275282): passed.
- [Synchronize Project Version #44995275270](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995275270): passed.
- [Android Build #44995275279](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995275279): Godot import, 20-scene smoke, 1,009 strict checks, campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity, dynasty, family-development, balance report and APK export all passed. The Android emulator process-survival step failed.

### Emulator failure evidence
- Captured screenshot: black.
- Logcat: `rendering/limits/global_shader_variables/buffer_size` exceeds the emulator's 16,384-byte uniform buffer limit.
- Repeated `SceneShaderGLES3: Program linking failed` messages report `Fragment shader active uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- Godot then logs `GodotActivity: Destroying Godot app` and `Force quitting Godot instance`; the process is no longer present at the 30-second check.
- No GDScript `SCRIPT ERROR`, parse error, Java `FATAL EXCEPTION` or native `Fatal signal` was found in the captured log.
- This matches the already reproduced AOSP/SwiftShader GLES3 compatibility issue on main; the atlas is SVG-only and does not add a shader or global uniform buffer.

### Exact-head artifacts for the failed emulator attempt
- [APK artifact #14742984758](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995275279/artifacts/14742984758), 65,340,780 bytes; archive digest `sha256:009a2a7babcea92c87338130b4906a3b4fa15260858497e3f3eb20460a0acec7`.
- [Test-log artifact #14743696775](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44995275279/artifacts/14743696775), 108,619 bytes; archive digest `sha256:c89dd57820378c6cb88a1762b79924253e5d8f9b3d458bbdc495ce614d5ef85d`.
- The APK signature was valid with the CI/test certificate and no Android permissions were requested. This APK is **not emulator-verified or production-signed**.

The earlier exact code head `220b278b262910fadcb87279953ac4fa93342108` did pass the emulator smoke on run #44994946052, but the repeat run on the documentation-only head reproduced the known renderer failure. Treat emulator compatibility as nondeterministic and still release-blocking. No physical Android handset test has been performed.
