# Trade-goods icon provenance

**Asset:** `assets/art/markets/trade_goods_atlas.svg`

**Author/source:** Original vector artwork authored for KindleWake in this repository.

**Rights:** Original project content. No third-party artwork, game screenshots, external fonts, image generators or licensed packs are embedded in the SVG.

**Technical details:** 384 × 128 SVG, 12 cells at 64 × 64, six columns and two rows. It contains only SVG paths, shapes, gradients and groups; no external references or executable content.

**Runtime integration:** `scripts/ui/trade_goods_icon_atlas.gd` resolves the twelve stable IDs from `data/trade_goods.json`. `scripts/ui/merchant_screen.gd` displays each icon beside its commodity heading. Unknown IDs return no atlas texture and retain the text-only fallback.

**Central-ledger note:** The shared `data/asset_provenance.json` and `assets/art/CREDITS.md` are not changed in this branch because active portrait work owns those shared inventory files. Reconcile this entry into both central ledgers when that work is integrated.
