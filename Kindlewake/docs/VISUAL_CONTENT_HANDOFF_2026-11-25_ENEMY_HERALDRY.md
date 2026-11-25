# Visual-content handoff — named enemy roster heraldry

## Repository snapshot

- Repository: `ninjun42215-gif/KindleWake`
- Base branch: `main`
- Base SHA: `13f66ec19476c9af5ed2b5c81af95e4d8a026876`
- Working branch: `art/enemy-roster-heraldry-2026-11-25`
- Scope: refine the existing named-character battle sprite atlas with restrained, original identity marks for twelve named hostile characters.
- No main-branch changes, merges, force-pushes, branch deletions, release publication, workflow changes, repository-setting changes or secret access.

## Delivered

- Updated `Kindlewake/assets/art/units/character_roster_atlas.svg`.
- Added `Kindlewake/assets/art/units/ENEMY_ROSTER_HERALDRY_PROVENANCE.md`.
- Added twelve compact shield/shoulder heraldic marks to the existing 48-cell atlas:
  - Roadwolf claw marks for Hask Gravelteeth, Roadwolf Reaver, Roadwolf Bowman and Hask's Convoy Champion identity.
  - Reef spiral, crossed cutlasses, Salt-Reef arrow and Blackwake sail for the named coastal enemy identities.
  - Ash Bailiff flame seal, Writ-Captain crown seal, River Marshal crossing mark and Quillon open-record seal.
- The marks are drawn inside their existing 128×160 cells on the left shoulder. This avoids the right-side weapon/class identity strokes drawn after the sprite in the existing battle renderer. They are integrated into the already-loaded atlas, not separate unused textures.

## Runtime and preservation contracts

- Atlas dimensions remain 1024×960; grid remains 8×6; cell size remains 128×160.
- `ROSTER_CHARACTER_IDS` remains 48 entries and retains its existing order.
- `scripts/ui/art.gd` and `draw_roster_character()` are unchanged; the existing runtime texture path automatically renders the updated artwork.
- No new texture, shader, scene node, resource load, per-frame drawing, or external dependency is added.
- No changes to character data, portrait IDs, faction/diplomacy data, combat, enemy stats, encounter weights, story, saves, save schema or project version.
- Marks are visual identity only; they do not create new canon affiliations.
- Central provenance/credits files are left untouched because portrait PR #157 currently owns them. The sidecar records source and integration until a later ledger reconciliation.

## Exact implementation commits

- Atlas integration: `fda5169686d7308f56011a77d612a67291168da1`
- Per-asset provenance: `c5748bd9f8b8d4e950af065e871da3af636cb72a`

## Static source validation completed

- Parsed the stable 48-ID order from `scripts/ui/art.gd`; all twelve target IDs resolved to their expected cells.
- Confirmed 48 original top-level atlas cells remain.
- Confirmed twelve unique roster IDs and twelve unique badge IDs were added.
- Confirmed balanced SVG group tags (60 opening / 60 closing groups).
- Confirmed root dimensions and viewBox remain 1024×960.
- Confirmed no external resource references, raster images, scripts, filters, masks or foreign objects were introduced.

## CI and visual verification

Pending on the implementation head:
- Godot 4.2.2 import and roster atlas resource load.
- Existing 20-scene smoke and strict regression suite, including the current 48-ID atlas assertions.
- Project Health Audit, Workflow YAML Lint, Version Sync and Android APK export.
- Android emulator startup and process survival.

Still required after CI:
- Godot editor screenshot review of the twelve marked sprites at battle scale.
- Portrait and landscape phone-scale readability check.
- Physical Android touch, frame-pacing, memory and long-session QA.

An APK export or emulator launch does not equal physical-device certification. No production release is claimed.


## Verification completed — 25 November 2026

**Exact tested code/source head:** `f55fb0315a2b400e62fb0001e220d76751c5908a`  
**Final art placement commit:** `838c4ebe0e6bd26519f0da0a07dbf55df1976d08`

### CI results on the exact tested source head

- [Project Health Audit #45559792583](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45559792583): passed; 0 errors, 0 warnings, 0 unverified asset entries and 0 unverified used assets.
- [Workflow YAML Lint #45559792476](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45559792476): passed.
- [Version Synchronization #45559792628](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45559792628): passed.
- [Android Build #45559792526](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45559792526): Godot 4.2.2 import passed; 20 scenes loaded with 0 failures; strict regression suite 1,009 checks / 0 failures; campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity (70), dynasty (39), family development (19), and balance report passed; APK export and signature verification passed. The workflow overall failed only at emulator process-liveness.

### Exact-head Android artifact

- [APK artifact #14996679232](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45559792526/artifacts/14996679232)
- Archive size: 65,311,902 bytes.
- Archive SHA-256: `8ed754c0e849e403d5bfecbf985374021bf8c663fb47cefe7c4149aed644d1ac`.
- Extracted APK size: 65,865,050 bytes.
- Extracted APK SHA-256: `a94b38e0a370621316b4e9189f6c8282004c9dd9bca04066409bfe03a523509a`.
- CI/test signature verified (key fingerprint prefix `c04a7792715ad8f5`); native ABIs `arm64-v8a`, `armeabi-v7a`, `x86_64`; no Android permissions requested.
- [Test logs artifact #14997317823](https://github.com/ninjun42215-gif/KindleWake/actions/runs/45559792526/artifacts/14997317823).

### Emulator blocker evidence

The AOSP ATD / SwiftShader GLES3 emulator again reports `SceneShaderGLES3: Program linking failed` because fragment shader active uniforms exceed `GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)`. Godot logs `Destroying Godot app...` followed by `Force quitting Godot instance`; the app process exits before the 30-second liveness assertion, and the captured emulator screenshot is black. No GDScript `SCRIPT ERROR` or parse error was reported. The new heraldry is SVG vector artwork and adds no shaders or global uniforms; this is a renderer/emulator blocker, not an observed atlas import or test failure.

### Remaining verification

- Actual Godot editor screenshot review of the twelve sprites at battle scale.
- Portrait and landscape mobile readability review.
- Physical Android touch, memory, frame-pacing and long-session tests.
- Actual GPU texture residency is not measured. The 1024×960 atlas is about 3.75 MiB at uncompressed RGBA8, excluding driver alignment/mipmap overhead; the vector source is approximately 68.6 KB.
- Central provenance/credits reconciliation remains deferred to portrait PR #157, which owns those shared files.

The APK belongs to the exact tested code head above. This handoff update is documentation-only; it does not change the tested atlas or runtime code.
