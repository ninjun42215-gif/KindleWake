# Project Health Audit — coverage and interpretation

The audit is read-only. It checks JSON parseability, project inventory, project/README/Android export version drift, positive Android version-code configuration, root workflow placement, rune-data shape/count/kind totals, and the asset-credit/provenance ledgers.

## Asset provenance and release gate

Maintain `Kindlewake/data/asset_provenance.json` alongside `assets/art/CREDITS.md`. Each asset entry records its identifier, name, source reference/URL when known, author, licence, evidence, status and whether it is used in game. Never invent a source URL or mark a pack verified without authoritative licence evidence.

The current mainline ledger (2026-11-17) marks every runtime-used asset pack as licence-verified. The legacy voxel-building PNG pack remains in the repository for history but is recorded as `used_in_game: false`; it has been replaced at runtime by original KindleWake SVG settlement art. The free Soldier/Orc subset of Tiny RPG Character Asset Pack 01 is linked to the author's official page, with game-use/modification terms recorded; standalone redistribution of that source pack remains prohibited. LimeZu's non-commercial pack and the MountainRocks archive with unknown terms are both recorded as unused. If any unused pack is reintroduced, verify its authoritative licence first and update both ledgers. The audit validates ledger structure and flags used non-verified entries; it does not independently prove external licence terms.

Normal audit mode returns non-zero for errors and reports warnings without failing. Run `python3 Kindlewake/tools/project_health_audit.py --root . --output health-audit --fail-on-warnings` as a strict pre-release gate; this returns non-zero if any warning remains. Do not treat a clean report as proof that a third-party licence is valid—the ledger still needs authoritative evidence and human review.

## Rune inventory

The audit counts definitions and reports totals by `kind`, then fails on entries missing an object, display name or kind. This is a structural check only; it does not prove that rune effects are implemented, balanced, reachable in gameplay or compatible with old saves.

## Scope limits

The audit does not run Godot, inspect all GDScript semantics, render/test scenes, verify external licence terms, or certify Android device compatibility. Treat warnings as review work, not as CI proof of release readiness.
