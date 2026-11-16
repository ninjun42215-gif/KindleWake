# KindleWake portrait coverage audit

**Audit date:** 2026-11-17  
**Audited source:** `main` at the time this feature branch was created  
**Status:** **INCOMPLETE — DO NOT SHIP AS COMPLETE PORTRAIT COVERAGE**

## Scope and method

Inspected `data/characters.json`, `data/character_creation.json`, `data/locations.json`, the runtime portrait scripts and the current `assets/art/portraits/` directory. Every character definition and every location spot flagged `npc: true` is represented in `data/portrait_registry.json`. The three named royal story figures required by the brief are also tracked explicitly.

The registry preserves existing `portrait_id` values as *legacy assignments only*. Presence of a file is not proof that the art depicts the assigned character. Reused IDs are flagged for identity review; they are not accepted as complete coverage.

## Baseline results

- Existing portrait files: **12**
- Character definitions audited: **48**
- NPC dialogue/event spots audited: **157**
- Additional named royal story figures tracked: **3**
- Total registry records: **208**
- Existing portrait references requiring identity verification: **48**
- Records with no assigned portrait: **160**
- Reused legacy portrait groups: **11**

## Confirmed gaps

1. The twelve creator gallery SVGs are the only portrait files in the inspected portrait directory. The inspected Torren SVG uses simplified vector shapes and gradients rather than the requested painterly semi-realistic finish; it is a useful legacy UI asset, not an approved final-art reference. These twelve files do not constitute individual coverage for the roster, enemies, named story characters and NPC population.
2. The current character data assigns the same twelve IDs to many distinct people. These are legacy references, not approved likeness matches.
3. Ordinary enemy types (including Roadwolf Reaver and Roadwolf Bowman) currently point into the generic creator portrait set. Hask Gravelteeth also has a reused portrait assignment that is not identity-approved.
4. The creator's `CharacterPreview` draws a procedural geometric bust whenever its portrait asset cannot load. That fallback conflicts with the requested art standard.
5. The location data contains many dialogue/event speakers without portrait IDs. NPCs need stable IDs and an assignment rule based on actual authored identity/type/variant.
6. King Osric IV, Lord Edmer and Regent Maelor are named in the lore but are not separate portrait-backed character definitions in the inspected character data.
7. The requested supplied portrait reference set was not present as a separate reference-art collection in the inspected repository; the only files in the runtime portrait directory are the twelve legacy SVGs.

## Runtime integration progress (feature branch)

The feature branch now loads `portrait_registry.json` through the `GameData` autoload, exposes registry lookup helpers (`portrait_record` and `portrait_asset_path`), and passes the registry through `GameData.party_db()`. The party screen now consults the registry by stable character ID when an older save has no portrait ID. Its previous hash-based random selection from an unrelated gallery portrait list has been removed. This is a compatibility-safe resolver foundation; existing legacy portrait IDs remain explicitly unverified and NPC/dialogue/shop/battle/creator surfaces are not yet fully integrated.

## Required next work

- Commission/generate original, individually art-directed portraits for each named hero, story character, boss and distinct enemy variant.
- Create faction- and role-specific NPC portrait families. Reuse a base only for genuinely identical authored NPC archetypes; distinguish variants by gender, age, equipment, faction and appearance.
- Replace the geometric creator fallback with a proper portrait composition that reflects every selectable appearance. A finite gallery of twelve static images cannot truthfully represent every combination of presentation, face, hair, skin and build; use layered/variant portrait assets or a sufficiently complete authored appearance matrix.
- Integrate a single registry resolver in creator, party/status/inspection, dialogue, recruitment/events, battles, shops/services and quest panels.
- Add automated checks for missing files, duplicate assignments where uniqueness is required, orphan assets, unknown IDs and runtime image-load failures.
- Run Godot import, scene smoke tests, portrait-specific tests and Android build/device QA.

## Acceptance criteria

Coverage is complete only when every registry entity resolves to a valid, reviewed asset; every distinct identity/variant has the intended art; every relevant UI surface uses the resolver; no placeholder/geometric fallback/missing-image state is reachable; and the test suite plus Android verification pass.

**This audit does not claim complete portrait coverage.**
