# Project Health Audit — coverage and interpretation

The audit is read-only. It checks JSON parseability, project inventory, project/README version drift, root workflow placement, rune-data shape and count, and the explicit asset-credit ledger.

**Important:** the presence of `assets/art/CREDITS.md` is not proof that every asset is cleared. Rows containing unverified or missing licence markers are surfaced as `ASSET_LICENSE_UNVERIFIED` warnings and must be resolved before public/commercial release. Keep source URLs, author, exact licence/version, attribution obligations and redistribution/editing limits in the ledger. Do not change an unverified row to confirmed without evidence.

Rune checks count definitions and report kind totals, then fail on entries missing an object, display name or kind. This is a structural check only; it does not prove that rune effects are implemented, balanced, reachable in gameplay or compatible with old saves.

The audit does not run Godot, inspect all GDScript semantics, render/test scenes, verify external licence terms, or certify Android device compatibility. Treat warnings as review work, not as CI proof of release readiness.
