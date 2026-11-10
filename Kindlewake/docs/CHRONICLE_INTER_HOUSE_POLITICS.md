# Chronicle of Houses — Inter-house Politics Foundation

This deterministic rules module extends the offline Chronicle family, title, claim and council records. It remains within the already gated post-campaign mode; it does not provide an alternate unlock path.

## Seeded houses
Three rival houses enter the political record: House Ashcombe, House Merevale and House Dunmar. Each has a leader, motto, influence, legitimacy, treasury, food and military strength, all bounded from 0 to 100. Pairwise relations are shared records, so both sides see the same treaty and score.

## Relations and diplomacy
Relation scores are bounded from -100 to 100. At -50 or below a house is a rival; at 60 or above it is friendly. A feud overrides alliance. Available actions:
- Envoy: costs 5 player influence, adds 8 relation.
- Public gift: costs 3 influence, adds 12 relation; blocked if recipient treasury is already 100.
- Reconciliation: ends a feud and adds 15 relation.
- Declare feud: cancels alliance and sets relation no better than -50.
- Propose alliance: requires 60+ relation and no feud.
- Break alliance: cancels treaty and costs 20 relation.

## Annual pressure
A political year is advanced separately from the family aging year. Low food (<30) reduces house legitimacy and influence; high food (>70) improves legitimacy. Treasury shifts slightly according to legitimacy. Feuds worsen by two relation points yearly; other relations drift one point toward their current sign. All changes are deterministic and logged.

## Persistence and test
The politics dictionary is intended to live inside the existing Chronicle house-state save payload. Normalization bounds metrics and scores, sanitizes histories, and prevents a feud from coexisting with an alliance.

Run:
```sh
godot --headless --path . --script res://tests/test_chronicle_diplomacy.gd
```

## Deliberate limits
This is a rules/data foundation with a dedicated test, not a finished diplomacy screen or autonomous rival-house AI. It does not yet implement political marriages, autonomous negotiations, domain transfers, taxes, trade, levies, wars or sieges. Those require separate UI and strategic/tactical integration.
