# Visual-content handoff — regional trade-goods iconography

## Repository and scope

- Repository: `ninjun42215-gif/KindleWake`
- Base branch: `main`
- Base SHA at branch creation: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Branch: `art/trade-goods-iconography-2026-11-24`
- Scope: original market icon atlas plus its runtime integration in the regional exchange UI.
- No story, lore, economy values, market rules, cargo rules, saves, save schema, project version, Android permissions or workflows are changed.

## Delivered

- Added a 384 × 128 SVG atlas with twelve original 64 × 64 symbols: grain, salt, dried fish, timber, iron ore, herbs, wool, leather, honey, pearls, glassware and spices.
- Added `TradeGoodsIconAtlas`, mapping exact stable trade-good IDs to AtlasTexture regions. The texture is loaded once and reused; per-row AtlasTexture resources only reference the shared imported atlas.
- Integrated a 44 × 44 icon at the left of each market commodity heading. Unknown IDs preserve the existing text-only behavior.
- Extended the existing merchant-screen runtime test to verify the atlas dimensions, all twelve mappings, visible row textures and unchanged buy/sell row controls.
- Added a per-asset provenance note and this handoff. No unverified third-party asset was imported.

## Performance and compatibility

- One small vector texture: 384 × 128 logical pixels.
- At 44 × 44 display size, the icons are downscaled from 64 px source cells.
- No per-frame drawing, timers, shaders, animations, external fonts, or network resources.
- The static resolver caches the imported Texture2D and creates lightweight AtlasTexture region wrappers per row.
- Existing market quotes, sort order, prices, stock, cargo, transaction callbacks and save data remain authoritative and unchanged.

## Verification status

- The build workflow runs `tests/merchant_screen_test.tscn` under strict mode; this exercises the real regional exchange overlay and its buy/sell actions.
- Exact-head Project Health Audit, Workflow YAML Lint, Version Sync and Android Build results must be recorded after CI completes.
- Godot editor screenshots at portrait and landscape phone sizes are still required for final visual review.
- CI emulator checks are not physical-device QA. Touch, texture residency and frame pacing on a physical Android device remain outstanding.
- No APK is a production release unless the protected production-release workflow publishes it from the exact immutable source tag.

## Coordination

- This branch starts from main SHA `13f66ec19476c9af5ed2b5c81af95e4d8a026876`.
- It changes `merchant_screen.gd` and `merchant_screen_test.gd`; no currently open PR listed at branch creation modified either file.
- It avoids `party_screen.gd`, `location_scene.gd`, `world_scene.gd`, battle code, title/creator UI, atlas/cartography files, workflows and central asset ledgers.
- The central provenance ledger and credits table require a later reconciliation because portrait PR #157 currently changes those shared files.

## Safety

- Main is not modified.
- No merge, force-push, branch deletion, repository-setting change, release publication or secret access is performed.


## Exact implementation-head CI — 24 November 2026

The following workflows ran against implementation commit `6cdbb3640f5eacd3950ec33596a99b17df198a35`:

- [Project Health Audit #45339085478](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339085478) — passed.
- [Workflow YAML Lint #45339085418](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339085418) — passed.
- [Version Sync #45339085537](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339085537) — passed.
- [Android Build #45339085425](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339085425) — Godot import, scene smoke, strict test execution, APK export and artifact upload completed successfully. At this handoff update, the Android emulator install/launch/process-survival step was still running; no emulator pass is claimed.

Exact-head APK artifact:
- [Kindlewake-APK #14894802273](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339085425/artifacts/14894802273)
- GitHub artifact archive size: 65,323,979 bytes.
- GitHub archive digest: `sha256:86a6a37b8188782149eb1ad9424aa924397adfea0cfff8dc54469093a652607d`.
- The artifact metadata identifies source head `6cdbb3640f5eacd3950ec33596a99b17df198a35`. It is a CI candidate, not a production release. No extracted-APK checksum is claimed in this handoff.

The emulator outcome must be refreshed from the final workflow run before describing Android runtime verification. Physical-device QA and Godot editor screenshot review remain outstanding.


## Final exact-head CI outcome — 24 November 2026

The documentation-updated PR head `ce7c500afe6089dad7f18e32db5b78d0db4fa6e0` was also built and tested:

- [Project Health Audit #45339445165](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339445165) — passed.
- [Workflow YAML Lint #45339445158](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339445158) — passed.
- [Version Sync #45339445255](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339445255) — passed.
- [Android Build #45339445216](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339445216) — import, scene smoke, strict tests, APK export and artifact upload passed; the emulator process-survival step failed.

Exact test evidence from the uploaded logs:

- Godot 4.2.2 import: exit 0, no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Core regression suite: 1,009 checks, 0 failures.
- Regional merchant UI test: 40 assertions, 0 failures. This includes atlas import and dimensions, all twelve ID-to-cell mappings, a visible grain-row icon, and successful buy/sell/close actions.
- Campaign lifecycle, title/creator UI, Act V, campaign continuity, dynasty, family-development and balance report all completed successfully.

Exact documentation-head Android artifact:
- [Kindlewake-APK #14894887710](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339445216/artifacts/14894887710)
- Archive: 65,324,024 bytes; digest `sha256:2d68a73e0e023bb41cfd797fab6f8e6e1f7a6d884d0085a76612a6aec0a7ef07`.
- Extracted APK: 65,877,655 bytes; SHA-256 `344bd834819235ef41834134b63ec4308398c877e64638414d28286156e695c4`.
- Build summary reports a valid CI/test signature, native libraries for `arm64-v8a`, `armeabi-v7a`, and `x86_64`, and no requested Android permissions.
- Test/emulator log archive [#14894838226](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45339445216/artifacts/14894838226): 91,915 bytes; digest `sha256:0c28d5c5152162419cfc73ebf8984a993c51043b8e8539f4ea1f8399be7fca17`.

### Emulator failure details

The API 35 AOSP ATD / Google SwiftShader run installed the APK and started `com.godot.game.GodotApp` successfully, but the app process was gone before the 30-second liveness check. The captured screenshot is black.

Logcat records:
- `rendering/limits/global_shader_variables/buffer_size` exceeds the emulator's 16,384-byte uniform-buffer limit.
- `SceneShaderGLES3` repeatedly fails program linking because fragment shader active uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`.
- Godot then destroys the activity and force-quits the instance.
- No Java `FATAL EXCEPTION`, native `Fatal signal`, GDScript `SCRIPT ERROR` or parse error was captured.

This reproduces the previously recorded main-branch SwiftShader/GLES3 compatibility blocker. The logs establish the shader-link failure and subsequent process exit, but do not prove that this is the only underlying cause. It is not caused by the new market atlas, which adds no shader or global uniform.

**Release disposition:** APK export and signing validation passed, but Android runtime verification failed. The artifact is not a production release and must not be presented as device-tested. Physical Android QA and Godot editor portrait/landscape screenshot review remain outstanding.
