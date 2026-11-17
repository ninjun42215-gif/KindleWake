# Visual and content production handoff — 2026-11-17

## Repository checkpoint

- Repository: `ninjun42215-gif/KindleWake`
- Base branch: `main`
- Base SHA for this visual branch: `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`
- Visual branch: `art/portrait-gallery-identity-2026-11-17`
- Pull request: [#157 — Expand protagonist portrait gallery and link sprite palette](https://github.com/ninjun42215-gif/KindleWake/pull/157)
- Tested implementation revision before this documentation-only update: `a9e0d912f187c7353d5f3608bcd661096f18fe03`
- The branch is isolated from current main; no merge, force-push, or main write was performed.

## Delivered

1. Added four original 512×512 SVG protagonist portrait concepts:
   - `maelin_tidecaller`
   - `kellan_ashward`
   - `nyra_briar`
   - `orin_lantern`
2. Expanded the creator gallery to 16 stable portrait IDs, with presentation, face, hair, skin, build and sprite-accent metadata.
3. Connected the selected profile to the shared animated protagonist renderer used by exploration and tactical battle. The renderer now translates the selected identity into a sprite-scale face plane, skin palette, hair silhouette/colour/length, face details, sturdy-build shoulder armour and costume accent. It retains the existing four-direction animation atlas and save schema.
4. Added regression checks for all 16 identity metadata records and the selected portrait's appearance mapping.
5. Updated the art pipeline, character art expansion notes, asset provenance and runtime asset manifest.

The sprite is an identity translation, not a pixel-perfect miniature of the portrait. The animation poses and core body atlas remain shared by presentation. The four new portraits are concept-level vector artwork, not final painterly semi-realistic masters.

## Verification

On implementation SHA `a9e0d912f187c7353d5f3608bcd661096f18fe03`:

- [Workflow YAML Lint #44035428895](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44035428895) — passed.
- [Project Health Audit #44035428912](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44035428912) — passed.
- [Synchronize Project Version #44035428973](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44035428973) — passed.
- [Build Android APK #44035428857](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44035428857) — the Godot import, headless scene smoke, strict-test and APK-export step completed successfully. The Android emulator launch/verification step was still running when this handoff was written; consult the run for its final conclusion.

A prior run on the same PR lineage, [#44033340330](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44033340330), installed the APK and the explicit Godot launcher activity returned `Status: ok`. It then failed in the workflow's post-launch process check with `/usr/bin/sh: 1: Syntax error: end of file unexpected (expecting "fi")`. The action appears to execute the multi-line `if` block as a single shell command. This is a workflow-script issue, not evidence of a game crash; the PID check did not run. It belongs to core QA/release workflow work and was not changed on this visual branch.

No physical Android device test, in-editor screenshot inspection or measured GPU-memory/frame-pacing test is claimed.

## Asset rights and mobile budget

- The four new portraits are original KindleWake project-authored SVGs; no third-party artwork, font or audio was imported.
- Each SVG is 512×512 and approximately 3.9–4.2 KB source text.
- A 512×512 RGBA8 raster would be about 1 MiB per portrait (roughly 4 MiB if all four were simultaneously resident), before mipmaps/driver overhead. This is a planning estimate, not a measured Godot or Android allocation.
- Existing optional sprite archives remain intake-only. Unknown or restricted packs were not extracted or integrated. Quaternius Nature remains CC0; the Zerie Soldier/Orc subset retains its game-use terms and must not be redistributed as a standalone source pack.

## Remaining production gaps

- Replace concept portraits with the approved painterly semi-realistic final art after visual review.
- Build per-character companion portraits and matching field/battle sprite identities; current new portrait work is protagonist-only.
- Expand distinct regional human enemies, monsters and bosses with matching dialogue, bestiary and battle art.
- Produce regional settlement/interior kits, varied terrain battle maps, spell and impact VFX, equipment/rune/item icon families, typography polish and authored audio.
- Inspect the Android emulator screenshot and UI on actual devices; measure texture memory, frame pacing, touch targets and long-session behavior.

## Coordination notes

- PR #134 (seven-continent heraldry) is already merged; its runtime overlay is in `GlobalAtlas.tscn`.
- Older portrait/art branches are heavily diverged from current main. Do not merge or cherry-pick them wholesale. In particular, `feature/complete-portrait-coverage-audit` and `feature/creator-touch-portraits` overlap the same portrait/renderer files and are substantially behind current main.
- Keep this PR draft until the renderer has been visually inspected and the Android emulator workflow check is reliable.
