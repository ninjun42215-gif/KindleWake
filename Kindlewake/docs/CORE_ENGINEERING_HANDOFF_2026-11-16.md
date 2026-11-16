# Core engineering handoff — 2026-11-16

**Repository:** https://github.com/ninjun42215-gif/KindleWake  
**Project:** `Kindlewake/` · Godot 4.2.2 · Android / GL Compatibility  
**Base:** `main` at `8a1f9e4227c3541c34e17593bb317a88c1c2d7a6`  
**Working branch:** `fix/inventory-quantity-guards-2026-11-16`  
**Pull request:** [#133](https://github.com/ninjun42215-gif/KindleWake/pull/133) — draft; exact-head checks pending.

## Implemented

Hardened the party inventory API against invalid quantity operations:

- `PartyState.add_item` now ignores empty item identifiers and quantities less than or equal to zero.
- `PartyState.remove_item` now rejects empty identifiers and non-positive quantities before checking inventory.
- This closes a concrete duplication/corruption path: previously, `remove_item(item_id, -1)` passed the balance check and increased inventory; `add_item(item_id, -1)` silently reduced stock and could create negative counts.
- Added regression assertions to the existing shop/party test section for negative grants, negative removals, zero removals and empty item identifiers.

## Compatibility and scope

- No save format, save schema, item definitions, balance values, UI, story content, or Android permissions changed.
- Existing valid callers use positive quantities; the current shop/equipment paths continue to pass positive counts.
- No item-catalog whitelist was added, so future data-driven item IDs remain supported.
- This is an isolated gameplay-data integrity change, separate from the active visual and release-workflow work.

## Verification

- Source and test changes are committed on the dedicated branch.
- Exact-head GitHub Actions validation must be refreshed after the final documentation commit. Do not treat an earlier branch run as validation of a later head.
- Physical Android device QA remains a separate release gate.

## Review checklist

1. Confirm the inventory guard regression assertions pass in the Godot 4.2.2 strict suite.
2. Confirm the Android APK build and the repository's other required checks pass on the exact PR head SHA.
3. Review the diff for only the four intended paths: `party_state.gd`, `run_tests.gd`, and this handoff/entry-point documentation.
4. Do not merge automatically or change `main`; retain the existing save schema and all player data.
