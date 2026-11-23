# Visual content handoff — 23 November 2026: title-screen landscape

## Summary
Replaced the previous geometric title backdrop with a more layered original illustration of Kaer Sethorn at dawn: distant mountain shelves, a fortified ridge, curtain wall and towers, a stone river bridge, a winding river, mist bands and foreground pines. The composition keeps the strongest castle detail on the right and leaves the central valley comparatively quiet behind the title panel.

## Runtime integration
- Existing `TitleScreen.tscn` continues to instantiate `scripts/ui/title_screen.gd`.
- The script continues to load `res://assets/art/ui/title_illustration.svg`; no scene path or menu flow changed.
- Updated the TextureRect to use linear filtering and raised the illustration's visible contribution while reducing the solid wash from 0.48 to 0.36. The opaque menu panel, labels, button callbacks, creator overlay, save browser, settings and exit flow are unchanged.
- The new SVG is 1200×700, 16,383 bytes and uses only vector paths, circles, rectangles, groups and linear gradients. It has no embedded raster images, fonts, external references, filters or masks.
- The source passed XML parsing and rendered locally to a 1200×700 preview with CairoSVG. This is source-level preview evidence, not a Godot editor screenshot.

## Provenance
- The SVG is original KindleWake vector geometry authored for this project.
- An OpenAI ImageGen concept was used as a composition reference only; the generated raster is not shipped or embedded.
- Per-asset source and rights notes: `assets/art/ui/title_illustration_provenance.md`.
- No third-party pack or external artwork was imported. The existing broad central original-art ledger entry was not edited because active portrait work owns the shared provenance/credits files; reconcile the per-asset note into the central ledger after that work lands.

## Preservation
No story, lore, save format, character data, gameplay rules, project version, Android permissions, menu actions, creator flow or scene routing changed. The old SVG path remains valid, so no resource path migration is required.

## Verification status
- XML parse: passed locally.
- CairoSVG render at 1200×700: passed locally.
- GitHub Project Health, YAML lint, Godot import, scene smoke and Android APK workflows: requested by the draft PR; record exact-head results after Actions completes.
- Godot editor screenshot, landscape/portrait safe-area review, and physical Android rendering/touch/frame-pacing checks remain outstanding. No device test is claimed.

## Exact refs
- Base main: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- Branch: `art/cinematic-title-screen-landscape-2026-11-23`.
- SVG implementation commit: `e074c62ec2e5c246ac20394a85e7ecbf6533df5d`.
- Title-screen presentation commit: `2baab6e1901a6c3b649730aa086cbcbddb01b151`.
- Provenance commit: `724848737b3e729d75c9409185e1b2bda51ed0ed`.
- Handoff commit: recorded by the final PR head.


## Exact-head CI result — 23 November 2026

Tested PR head: `5cd28070ad5edc4f6d6dd6a45569bf4a37f5b0da`.

- [Project Health Audit #45123852239](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45123852239): passed; 0 errors, 0 warnings, 44 JSON files, 88 GDScript files, 20 scenes, 11 workflows, and 0 unverified used-asset entries. The audit is structural/read-only and does not replace Godot or device testing.
- [Workflow YAML Lint #45123852226](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45123852226): passed.
- [Version Sync #45123852313](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45123852313): passed; six tests.
- [Android Build #45123852242](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45123852242): import passed; 20/20 scenes loaded; strict suite 1,009 checks, 0 failures; campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity (70), dynasty (39), family development (19) and balance report all passed; APK export and artifact upload passed. The emulator process-survival step failed.

### Android failure evidence

The exact-head emulator installed and launched `com.kindlewake.game/com.godot.game.GodotApp`; Godot 4.2.2 reported `OnGodotSetupCompleted` and `OnGodotMainLoopStarted`, then `GodotActivity` destroyed the instance about 1.4 seconds later. The 30-second process check failed and the captured 1368×632 emulator screenshot is black.

Logcat records:
- `rendering/limits/global_shader_variables/buffer_size` exceeds the SwiftShader maximum uniform buffer size of 16,384 bytes.
- `SceneShaderGLES3: Program linking failed`.
- Fragment shader active uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- No Java `AndroidRuntime` fatal exception, native `SIGSEGV`, or GDScript parse error was captured.

This matches the previously recorded SwiftShader/GLES3 emulator failure on main (Android run #44446304169). It is a renderer/emulator compatibility blocker, not evidence that this SVG or title-screen code caused the exit. Keep physical Android compatibility unverified.

### Exact APK artifact

- GitHub artifact: [Kindlewake-APK #14794359441](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45123852242/artifacts/14794359441).
- Artifact archive size: 65,397,204 bytes.
- Archive SHA-256: `5041278550f13e82b00aa4860dbace39ba110f216914b3fcaeedee8ac4ae7a61`.
- APK entry: `Kindlewake.apk`, 65,951,066 bytes.
- APK SHA-256: `757fbf46f4052a5ae4870655e90df6d5014d52395f2b597751501c83676c42e0`.
- Build summary reports a valid CI/test signature, ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`, and no requested Android permissions.

This APK was built from the exact PR head above. It is a CI/test-signed candidate only, not a production release or emulator-verified APK. Do not reuse it as a later commit's artifact.
