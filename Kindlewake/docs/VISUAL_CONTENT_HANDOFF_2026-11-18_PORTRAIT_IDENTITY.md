# Visual content handoff — 18 November 2026

## Scope and exact source state

- Base: `main` at `751b2f3f6b1104aa30e107659094ae2e221dbe3d`
- Implementation commit before this handoff note: `65136eb4a4e4fd0fc6faab724bff1ec3122578a7`
- Branch: `art/companion-portrait-identity-journal-2026-11-18`
- Pull request: pending creation when this note was authored
- Changes are isolated from the active portrait-gallery, equipment-icon, battle-resume and campaign-save PRs.

## Finding

The repository already contained character-specific portrait artwork, but the shared resolver fell back directly to `portrait_id` SVGs after checking explicit raster overrides. This caused characters with the same legacy portrait ID to display the same face even when an exact character-ID SVG existed.

Baseline inventory on the stated base SHA:

- 48 character definitions
- 28 definitions have an exact character-ID portrait asset
- 11 portrait IDs are shared by multiple character definitions
- 19 characters still rely on a shared legacy portrait fallback because no exact character-ID asset exists
- 21 companion quest definitions / 21 unique companions
- 19 of those companions already have exact character-ID portrait assets; Ilyan Voss and Maren Vey remain without one

## Runtime changes

1. `scripts/ui/portrait_resolver.gd` now preserves explicit character-specific raster overrides first (including the existing Torren, Sela and Kestrel routing), then prefers `assets/art/portraits/<character_id>.svg`, and only then falls back to the legacy `portrait_id` SVG. This avoids assigning another character's face where dedicated art already exists.
2. `scripts/ui/companion_quest_journal.gd` now displays a framed 76×76 character-aware portrait beside each companion quest title, chapter/region and state. Missing textures receive a two-letter initials fallback. Quest progression, unlock requirements, start action and save behavior are unchanged.
3. `tools/project_health_audit.py` now reports portrait inventory, exact character-ID asset coverage, shared-ID fallbacks and missing portrait files. Missing resolvable portraits are errors; remaining shared fallback identities are advisory warnings.
4. `tests/test_project_health_audit.py` adds coverage for unique character portraits, missing portrait files and shared legacy fallbacks.

## Assets and rights

No new artwork or third-party asset was imported. The implementation reuses portrait files already present in the repository and does not change the asset provenance ledger or any license claim. The unverified legacy packs remain excluded from runtime use.

## Verification

- Static baseline inventory was computed from `characters.json`, `companion_quests.json` and the recursive Git tree at the base SHA above.
- CI for the implementation commit was pending when this note was authored. Record exact run URLs and final tested SHAs after GitHub Actions completes.
- The project-health audit remains structural: it verifies file coverage and source wiring, not rendered appearance.
- Godot import/scene smoke, strict suite and Android build must be checked against the exact PR head. No physical-device result is claimed.

## Remaining production gaps

- 19 of 48 character definitions still need approved unique character-ID portrait artwork, including bosses and named enemy identities.
- Ilyan Voss and Maren Vey need dedicated companion portraits before the 21-person companion roster can be called fully portrait-complete.
- Current SVG portraits improve identity coverage but do not replace the approved painterly semi-realistic portrait direction. A higher-resolution master and sprite-identity review remain necessary.
- Inspect the Companion Chronicle on portrait and landscape layouts, then verify portrait crops and frame pacing on a physical Android device.


## 18 November addendum — dedicated companion portrait assets

A dependent visual branch, `art/ilyan-maren-companion-portraits-2026-11-18`, now adds two original character-ID portrait SVGs:

- `assets/art/portraits/ilyan_voss.svg` — Silent Tower guard / House Quillon battle mage; ash-dark hair, greying temples, tower-guard mantle and muted steel/bronze.
- `assets/art/portraits/maren_vey.svg` — Thalassar pilot / archer; wind-tied auburn hair, practical brown leather, tideglass pendant and coastal beacon backdrop.

Both are 512×512 project-authored SVG concepts with no third-party image, font, external package or copied game artwork. The new files use the exact stable IDs already present in `characters.json`. When this dependent branch is combined with the resolver/journal work above, the Companion Chronicle can resolve all 21 companion quest portraits to character-specific files instead of falling back to a shared `courtier` or `ash_scout` face for Ilyan and Maren.

The branch is stacked on the exact PR 161 head and changes no gameplay, roster data, story, save schema, battle logic or shared UI files. A separate provenance note records authorship and import/performance caveats. The project-health audit on the dependent PR must confirm the updated portrait inventory; Godot import, rendered crop review and physical Android QA are still required. These are interim vector identity concepts, not final painterly masters.


## Dependent portrait PR reference

- Dependent PR: https://github.com/ninjun42215-gif/KindleWake/pull/162
- Branch: `art/ilyan-maren-companion-portraits-2026-11-18`
- Initial dependent implementation head: `0b2a1ec7d54b1bf9ac29cd533f98c00d1c22be05`
- Parent PR #161 remains the prerequisite and must be reconciled first.
- The dependent PR is intentionally based on the parent branch; only workflow YAML lint runs for that non-main base. Project-health audit and Android build must be run after the stack is retargeted/rebased onto main.
- The central asset credits/provenance ledgers are not modified in this dependent PR because the separate portrait-gallery PR #157 is already changing those files. The per-asset provenance note is included now; consolidate it into the central ledgers when the overlapping portrait-gallery work is reconciled.


## Runtime and branch coordination — 18 November 2026

### Parent PR #161 exact verification

- PR #161 head: `c8e4782ffb6dae4f06ad54a1639e01ad92c8757d`, base `main` at `751b2f3f6b1104aa30e107659094ae2e221dbe3d`.
- Project Health Audit: passed — https://github.com/ninjun42215-gif/KindleWake/actions/runs/44255293372
- Workflow YAML Lint: passed — https://github.com/ninjun42215-gif/KindleWake/actions/runs/44255293618
- Version sync: passed — https://github.com/ninjun42215-gif/KindleWake/actions/runs/44255293483
- Android build/import/headless checks and strict suites completed successfully: 20 scenes loaded, 0 scene failures; `run_tests`, campaign lifecycle, merchant UI, title/creator UI, Act V, campaign continuity, dynasty and family-development checks exited without reported failures.
- APK artifact: `Kindlewake-APK`, artifact ID `14406156517`, 65,293,159 bytes. Build summary reports a valid signature and no requested Android permissions. Test/log artifact: `test-logs`, ID `14406057005`.
- Android emulator smoke did **not** pass: the screenshot is black and `com.kindlewake.game` did not remain running. Logcat records a configuration change (`0x80000000`), then `GodotActivity` logs “Destroying Godot app” / “Force quitting Godot instance” and the process exits with SIGKILL. No Java fatal exception, native fatal signal, GDScript error or parse error was found in the captured log. GLES3 also logs a 261-fragment-uniform SwiftShader link diagnostic; upstream discussion says this diagnostic can be SwiftShader-specific and not itself fatal, so it is not established as the termination cause: https://github.com/godotengine/godot/issues/109550
- Main itself at the same base SHA `751b2f3f6b1104aa30e107659094ae2e221dbe3d` also has an Android build run that fails at the emulator launch step: https://github.com/ninjun42215-gif/KindleWake/actions/runs/44225653213. This is a pre-existing main-line emulator/runtime-readiness blocker, not evidence that PR #161 or these portrait assets caused the exit.

### Other active visual branches

- PR #157 `art/portrait-gallery-identity-2026-11-17`: head `b9545c5e3fab1ebd5a095bfcf807573bbfc1973c`; based on `adf3d44bbeef1e1e048f2aa244a1a80bf95147fc`; compare against current main reports 34 commits ahead / 4 behind. It changes the central art credits/provenance files plus `art.gd`, creator/preview/world-scene integration and the creator UI test. Reconcile its old base and preserve its ownership of those overlapping files before ledger consolidation.
- PR #158 `art/equipment-icon-atlas-2026-11-17`: head `2a0df2d9bb868ed537d6603bcd2f8b4ba01fac87`; same old base; 4 commits ahead / 4 behind. It adds an equipment atlas and party-screen integration, plus a build helper/test. Its equipment tests reported zero failures; its Android job failed in the old emulator runner shell with an unexpected `fi` syntax error. Rebase and rerun rather than treating that old run as a current gameplay failure.
- The parent PR #161 is based on current main. This PR #162 remains stacked on #161 and changes only the two portrait assets, their provenance note and this handoff document.

### Verification boundary

PR #162 itself only triggers Workflow YAML Lint because its base is another feature branch. That lint passed on head `bb1addba5f3884998ae31540df827855da0918e3`: https://github.com/ninjun42215-gif/KindleWake/actions/runs/44258218834. The new SVGs were XML-parsed and rasterized locally at 512×512 and 76×76. No Godot import, editor screenshot, Android emulator pass or physical-device QA has been completed for these new assets. Re-run project-health, Godot import/scene tests and Android build after the parent stack is reconciled onto main.
