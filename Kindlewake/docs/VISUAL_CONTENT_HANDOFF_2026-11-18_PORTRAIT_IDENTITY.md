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
