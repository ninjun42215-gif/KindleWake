# Visual and content production handoff — 2026-11-17

## Repository checkpoint

- Repository: `ninjun42215-gif/KindleWake`
- Base branch: `main`
- Base SHA for this visual branch: `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`
- Visual branch: `art/portrait-gallery-identity-2026-11-17`
- Pull request: [#157 — Expand protagonist portraits and align sprite identity across scenes](https://github.com/ninjun42215-gif/KindleWake/pull/157)
- Tested implementation revision: `55b2683ac034abbe581e6ef169d846a5f8a69c9b`
- This handoff update is documentation-only; it does not change runtime code after the tested implementation revision.
- No merge, force-push, branch deletion or main write was performed.

## Delivered

1. Added four original 512×512 SVG protagonist portrait concepts:
   - `maelin_tidecaller` — long silver hair, fair skin, soft face, lean build
   - `kellan_ashward` — short ash-brown hair, warm skin, scarred face, sturdy build
   - `nyra_briar` — tied brown hair, deep skin, sharp face, athletic build
   - `orin_lantern` — short dark hair, fair skin, soft face, lean build
2. Expanded the creator gallery to 16 stable portrait IDs. Appearance metadata now includes presentation, face, hair, skin, build and costume accent. New `long_silver` and `short_ash` hair options are supported by creation validation, the portrait fallback and the runtime sprite renderer.
3. Connected the selected profile to `Art.draw_kindlewake_lead()`. The renderer translates face shape, skin palette, hair silhouette/length/colour, face details, sturdy-build shoulder armour and costume accent into the four-direction lead atlas.
4. Integrated the same selected protagonist renderer into all three gameplay contexts:
   - Overworld: `world_scene.gd`, scaled to 0.46 for 48 px tiles instead of the previous oversized generic Soldier sprite.
   - Town/interior exploration: existing `location_scene.gd` integration retained.
   - Tactical battle: existing `battle_scene.gd` integration retained.
5. Added regression checks for all 16 identity records, Maelin and Kellan's new hair variants, creation validation and the three renderer call sites.
6. Updated the art pipeline, character art expansion notes, asset provenance, runtime asset manifest and this handoff.

This is a readable identity translation, not a pixel-perfect miniature of the painted portrait. Animation poses and core body atlas remain shared by presentation. The four new portraits are concept-level vector artwork, not final painterly semi-realistic masters.

## Verification on implementation SHA `55b2683ac034abbe581e6ef169d846a5f8a69c9b`

- [Workflow YAML Lint #44036551888](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44036551888) — passed.
- [Project Health Audit #44036551715](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44036551715) — passed.
- [Synchronize Project Version #44036551762](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44036551762) — passed.
- [Build Android APK #44036551774](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44036551774) — Godot import, headless scene smoke, strict tests and APK export all passed. The overall job is marked failed only because the Android emulator post-launch shell check is malformed.

Automated evidence from the build:

| Check | Result |
|---|---:|
| Authored scenes loaded | 20, 0 failures |
| Strict test suite | 1,009 checks, 0 failures |
| Campaign lifecycle | 0 failures |
| Merchant UI | 0 failures |
| Title and creator UI | 0 failures |
| Act V checks | 0 failures |
| Campaign continuity | 70 checks, 0 failures |
| Chronicle dynasty | 39 checks, 0 failures |
| Chronicle family development | 19 checks, 0 failures |
| APK signature | Valid |
| Android permissions | None requested |

### APK artifact and emulator limitation

- Review-only APK artifact: [Kindlewake-APK.zip — artifact 14307438026](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44036551774/artifacts/14307438026)
- Artifact ZIP size: 65,466,171 bytes.
- Artifact ZIP SHA-256: `017b0538055ba99b89d5ab8fc5a5f2251f2e69d3f9c0005cf2d7d986e1202a68`.
- [Test logs and emulator screenshot — artifact 14307651447](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44036551774/artifacts/14307651447).
- The explicit launcher activity resolved and `adb shell am start -W` returned `Status: ok` with `com.kindlewake.game/com.godot.game.GodotApp`.
- A screenshot was captured (4,858 bytes) but has not been visually inspected. The process-liveness check did not execute.
- The emulator step failed at `if ! adb shell pidof com.kindlewake.game; then` with `/usr/bin/sh: 1: Syntax error: end of file unexpected (expecting "fi")`. The Android emulator action is splitting the multiline `if` block into a standalone shell command. This is a workflow-script defect, not evidence of a game crash. Core QA/release engineering should move the check into a script file or use a supported single-command form; this visual branch deliberately does not change the release workflow.

No physical Android device test, in-editor screenshot inspection or measured GPU-memory/frame-pacing test is claimed.

## Asset rights and mobile budget

- The four new portraits are original KindleWake project-authored SVGs; no third-party artwork, font or audio was imported.
- Each SVG is 512×512 and approximately 3.9–4.2 KB source text.
- A 512×512 RGBA8 raster would be about 1 MiB per portrait (roughly 4 MiB if all four were simultaneously resident), before mipmaps/driver overhead. This is a planning estimate, not a measured Godot or Android allocation.
- Existing optional sprite archives remain intake-only. Unknown or restricted packs were not extracted or integrated. Quaternius Nature remains CC0; the Zerie Soldier/Orc subset retains its game-use terms and must not be redistributed as a standalone source pack.

## Remaining production gaps

- Replace concept portraits with the approved painterly semi-realistic final art after visual review.
- Build unique companion/NPC portraits and matching field/battle sprite identities; the new portrait work is protagonist-only.
- Expand distinct regional human enemies, monsters and bosses with matching dialogue, bestiary and battle art.
- Produce regional settlement/interior kits, varied terrain battle maps, spell and impact VFX, equipment/rune/item icon families, typography polish and authored audio.
- Inspect the Android emulator screenshot and UI on actual devices; measure texture memory, frame pacing, touch targets and long-session behavior.

## Coordination notes

- PR #134 (seven-continent heraldry) is already merged; its runtime overlay is in `GlobalAtlas.tscn`.
- Older portrait/art branches are heavily diverged from current main. Do not merge or cherry-pick them wholesale. In particular, `feature/complete-portrait-coverage-audit` and `feature/creator-touch-portraits` overlap portrait/renderer files and are substantially behind current main.
- PR #42 (regional monsters/human enemy factions) is a stale draft and 152 commits behind current main; its current `world_scene.gd` patch changes ambush text, not the new player-rendering function. Reconcile it selectively before any future merge.
- Keep PR #157 draft until the new sprite is visually inspected and the Android emulator workflow check is repaired.
