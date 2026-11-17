# Visual/content handoff — equipment icon atlas — 2026-11-17

## Repository checkpoint

- Repository: `ninjun42215-gif/KindleWake`
- Project: `Kindlewake/`
- Branch: `art/equipment-icon-atlas-2026-11-17`
- Base main SHA: `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`
- Code commit tested by the first CI pass: `903cb1fc95409b1c3e6d38e0955f2ba1f6caf683`
- Commit: https://github.com/ninjun42215-gif/KindleWake/commit/903cb1fc95409b1c3e6d38e0955f2ba1f6caf683
- Pull request #158: https://github.com/ninjun42215-gif/KindleWake/pull/158
- Build run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/44039678679
- Project Health Audit: https://github.com/ninjun42215-gif/KindleWake/actions/runs/44039678696
- Workflow YAML Lint: https://github.com/ninjun42215-gif/KindleWake/actions/runs/44039678672
- Version synchronization: https://github.com/ninjun42215-gif/KindleWake/actions/runs/44039678751
- Runtime: Godot 4.2.2, GL Compatibility, Android, offline-first
- This branch is independent of the active protagonist portrait PR #157 and does not modify its files.
- No main merge, force-push, save/schema change, gameplay balance change or third-party asset import was performed.

## Delivered vertical slice

- Added a 16-cell original SVG category atlas for weapons, armor, shields, helms, accessories, trade goods, consumables and a neutral fallback.
- Added `EquipmentIconAtlas`, a small resolver that maps item slot and weapon identity to a stable 64×64 atlas cell.
- Integrated icons into equipped slots, inventory equip choices, shop buy rows and sell rows in the existing Party screen.
- Rune shop rows continue to use the existing rune atlas rather than substituting an equipment icon.
- Added a dedicated headless regression script and made the strict Android builder run it.

## Automated verification

Build run #44039678679 completed the import, strict test and APK export stage successfully:

- Godot import: exit 0, no script errors.
- Scene smoke: 20 scenes loaded, 0 failures.
- Core strict suite: 0 FAIL, 0 SCRIPT ERROR, 0 Parse Error.
- Campaign save/restore lifecycle: passed.
- Merchant UI: passed.
- Title/creator UI: passed.
- Act Five, campaign continuity, dynasty and family development suites: passed.
- Balance report: exit 0.
- Equipment icon test: 25 checks, 0 failures. It covers 18 item mappings, accessory/unknown slot fallbacks, AtlasTexture creation/preload, the 64px helm region, requested icon size and empty-slot icon creation.
- Project Health Audit, Workflow YAML Lint and Version synchronization runs all succeeded.

## Exact Android review artifact

- Artifact: `Kindlewake-APK`, ID `14308029780`
- Run: https://github.com/ninjun42215-gif/KindleWake/actions/runs/44039678679
- Size: 65,255,166 bytes (65.8 MB)
- SHA-256: `3234ecc05808e92464662d79338bf9a5cbaa87ff0d2d6d01f4782dfee09e425a`
- Build summary reports APK signature valid (key SHA-256 prefix `c04a7792715ad8f5`).
- Native libraries present for `arm64-v8a`, `armeabi-v7a` and `x86_64`.
- Android permissions requested: none.
- Archive inspection confirms the imported `equipment_icons.svg` texture, import metadata, resolver and Party screen script are included in this APK.

## Emulator limitation — not a runtime pass

The overall Build Android APK workflow concluded **failure** because its emulator phase failed after the APK export succeeded.

- The captured `honor400-emulator.png` is entirely black.
- Logcat shows the Pixel 5 overlay package being applied to `com.kindlewake.game` at 07:36:11.623; `GodotActivity` is destroyed and the process receives SIGKILL at 07:36:12.032. This is consistent with the emulator reconfiguring the application while it is being launched; it does not establish a game-code crash.
- The process-alive shell guard then fails with an unterminated `if ! adb shell pidof ...; then` command (“expecting fi”), so that guard did not verify the process.
- Logcat also contains the default global shader-variable buffer warning and SwiftShader SceneShaderGLES3 uniform-link errors. Similar Android/SwiftShader reports exist in Godot issue #109550; these messages alone do not prove the app termination cause.

Do not describe this as a successful Android runtime or visual test. Reconfigure/restart the emulator after applying its Pixel 5 overlay, correct the shell guard in the QA-owned workflow, and obtain a non-black capture before treating emulator launch as verified. Physical Android testing remains outstanding.

## Compatibility and performance

- One 256×256 SVG is preloaded and reused through `AtlasTexture` regions.
- No third-party art, font, network dependency or new plugin is introduced.
- No per-frame draw loop, timer or runtime image conversion is added.
- The 0.25 MiB RGBA8 figure in the provenance note is a base-raster estimate only; Godot import size, Android VRAM residency and frame pacing require device measurement.

## Provenance coordination

The existing central `data/asset_provenance.json`, `data/asset_manifest.md` and shared `assets/art/CREDITS.md` are being updated by active portrait PR #157. To avoid editing the same files concurrently, this tranche records its original-art provenance in `assets/art/items/README.md`. Consolidate it into the central ledger after the overlapping visual PR is resolved.

## Remaining art work

- This icon family is a UI aid, not a replacement for unique item illustrations, character equipment sprites, companion portraits, enemy/boss art, regional environment kits, battle VFX or audio.
- The existing character art pipeline remains the source of truth for portrait-to-sprite identity.
