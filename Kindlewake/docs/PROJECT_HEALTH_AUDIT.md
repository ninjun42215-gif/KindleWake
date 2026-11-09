# Project Health Audit — coverage and interpretation

The audit is read-only. It checks JSON parseability, project inventory, project/README version drift, root workflow placement, rune-data shape/count/kind totals, and the asset-credit/provenance ledgers.

## Asset provenance and release gate

Maintain `Kindlewake/data/asset_provenance.json` alongside `assets/art/CREDITS.md`. Each asset entry records its identifier, name, source reference/URL when known, author, licence, evidence, status and whether it is used in game. Never invent a source URL or mark a pack verified without authoritative licence evidence.

The current ledger identifies two used packs whose rights remain unverified: the voxel building packs and Tiny RPG Character Asset Pack 01. Both are release blockers until their exact source and redistribution terms are confirmed. Unused packs with unknown or restrictive licences are recorded but are not treated as used-game release blockers. Project-authored artwork is recorded separately.

Normal audit mode returns non-zero for errors and reports warnings without failing. Run `python3 Kindlewake/tools/project_health_audit.py --root . --output health-audit --fail-on-warnings` as a strict pre-release gate; this returns non-zero if any warning remains. Do not treat a clean report as proof that a third-party licence is valid—the ledger still needs authoritative evidence and human review.

## Rune inventory

The audit counts definitions and reports totals by `kind`, then fails on entries missing an object, display name or kind. This is a structural check only; it does not prove that rune effects are implemented, balanced, reachable in gameplay or compatible with old saves.

## Scope limits

The audit does not run Godot, inspect all GDScript semantics, render/test scenes, verify external licence terms, or certify Android device compatibility. Treat warnings as review work, not as CI proof of release readiness.
