# Chronicle of Houses — Inter-house Diplomacy

## Scope

The Chronicle diplomacy layer adds deterministic, offline political relationships between the player dynasty and three rival houses: Ashcombe, Merevale and Dunmar. It is a social/political simulation layer, not a war or territorial-conquest simulator.

## Persistent state

Diplomacy is stored inside the existing `chronicle_house_state` campaign object under `politics`. It does not add a save-version migration or a separate save slot. Legacy Chronicle saves without this object are initialized with a neutral starting network when the Chronicle House screen opens.

The state records:
- Four house profiles and bounded influence, legitimacy, treasury, food and military indicators.
- Six shared bilateral relationship records, each with a score from -100 to 100, alliance/feud state and a bounded event history.
- Player influence and reputation, a political-year counter and a bounded event log.

Normalization discards malformed house/relation entries, clamps metrics and relation scores, repairs the player-house reference, filters malformed history/events and restores missing pair records.

## Player actions

The Chronicle House screen offers:
- **Send envoy:** spend 5 influence and improve the selected relationship by 8.
- **Public gift:** spend 3 influence, add 5 treasury to the recipient house and improve the relationship by 12.
- **Propose alliance:** requires a relationship score of at least 60 and no active feud.
- **Declare feud:** sets the relationship to at most -50 and ends any alliance.
- **Reconcile feud:** ends the feud and improves the relationship by 15.
- **Break alliance:** ends an existing alliance and reduces the relationship by 20.

All changes are deterministic and saved through the existing Chronicle autosave path.

## Annual rival decisions

Political time advances only when the player explicitly advances the Chronicle by one year. Food shortages reduce a house's legitimacy and influence; strong food reserves improve legitimacy. Treasury changes are bounded. Relations drift slowly toward their current sign, while severe rival hostility can become a feud, friendly houses can ally, and eligible feuds can reconcile.

Rival decisions are processed once per bilateral rival pair per year. The system does not simulate real-time upkeep or background turns.

## Boundaries and future work

This slice does not add political marriages, autonomous claims, territorial transfers, taxation, trade, levies, wars or sieges. Those systems must connect to the existing dynasty, domain and tactical battle rules in separate tested increments. Diplomacy must not invent territorial outcomes or bypass authored campaign events.
