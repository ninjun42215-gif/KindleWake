# Project Health Audit — coverage and interpretation

The audit is read-only. It checks JSON parseability, project inventory, project/README/Android export version drift, positive Android version-code configuration, root workflow placement, rune-data shape/count/kind totals, and the asset-credit/provenance ledgers.

## Asset provenance and release gate

Maintain `Kindlewake/data/asset_provenance.json` alongside `assets/art/CREDITS.md`. Each asset entry records its identifier, name, source reference/URL when known, author, licence, evidence, status and whether it is used in game. Never invent a source URL or mark a pack verified without authoritative licence evidence.

The current ledger marks the unverified voxel building pack as unused: its legacy PNGs are retained for provenance/history but the game loads original KindleWake SVG settlement art instead. It is therefore not a current used-game release blocker. The currently used third-party packs are Quaternius Stylized Nature MegaKit (CC0 1.0) and the Free Soldier/Orc subset of Tiny RPG Character Asset Pack 01 by Zerie, with the author's game-use/modification terms recorded; standalone redistribution of that source pack remains prohibited. Optional archives and other unknown/restricted packs remain unused and must not be imported until their licences are verified. Project-authored artwork is recorded separately.

Normal audit mode returns non-zero for errors and reports warnings without failing. Run `python3 Kindlewake/tools/project_health_audit.py --root . --output health-audit --fail-on-warnings` as a strict pre-release gate; this returns non-zero if any warning remains. Do not treat a clean report as proof that a third-party licence is valid—the ledger still needs authoritative evidence and human review.

## Rune inventory

The audit counts definitions and reports totals by `kind`, then fails on entries missing an object, display name or kind. This is a structural check only; it does not prove that rune effects are implemented, balanced, reachable in gameplay or compatible with old saves.

## Scope limits

The audit does not run Godot, inspect all GDScript semantics, render/test scenes, verify external licence terms, or certify Android device compatibility. Treat warnings as review work, not as CI proof of release readiness.
