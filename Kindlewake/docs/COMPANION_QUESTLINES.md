# Companion Questlines

## Maren Vey — The Last Sounding

**Unlock:** Recruit Maren after recovering the Tideglass ledger and settle the Brinegate harbour decision.

**Start:** Speak with Maren at her chart table in Brinegate. She asks the company to restore the old signal at Lantern Quay so she can understand the Northstar's final log.

**Quest mechanic:** The player restores a three-note beacon sequence. The clue describes the harbour answering low, the tower answering high, and the current rising last. Incorrect notes reset the sequence but do not punish the player or consume resources. Progress and attempts are stored in campaign world flags.

**Resolution:**
- **Return the log to Maren:** the record stays with those who remember the Northstar. Maren gains friendship, trust and affection with the company leader; her stress eases.
- **Publish the log for the beacon crews:** the signal record reaches the coast and grants 75 gold. Maren gains respect but loses some trust; the public choice adds a more difficult personal memory.

The quest uses stable relationship evidence IDs, writes distinct character memories, and does not infer romance. It does not require a save schema change.

## Expansion pattern

Each recruitable companion quest should have a clear unlock condition, a distinct gameplay mechanic or authored cinematic/boss encounter, a meaningful choice, relationship and personality consequences, and a one-time completion record. Quest state should use world flags or an existing campaign subsystem rather than new save-schema fields.


### Northstar Wreck dungeon extension

After restoring the Lantern Quay signal, the company can chart and enter the Northstar Wreck. The wreck is a separate explorable dungeon with a captain's logbook cache and a Blackwake salvage-captain boss encounter. Maren's quest cannot resolve until the party defeats the captain and recovers the logbook. This keeps the signal puzzle, dungeon clear and log recovery as distinct campaign milestones.


## Neris Quell — Lantern Quay recruit

Neris is a former Blackwake reef diver freed after the Northstar Wreck battle. She becomes recruitable at Lantern Quay only after the signal is restored, the salvage captain is defeated and the logbook is recovered. She joins without a gold fee and begins with authored trust and respect toward the company lead. Her scout profile emphasizes observation, survival and agility.


## Neris Quell — The Second Beacon

**Unlock:** Recruit Neris and resolve Maren's Northstar quest.

**Start:** Speak with Neris at Lantern Quay. She reveals a hidden beacon route omitted from the Tidebound charts.

**Quest mechanic:** Chart three reef bearings at Saltmere: east with the outgoing tide, south around the black reef, then east toward the unlit beacon. Incorrect bearings reset the sequence without resource loss.

**Resolution:**
- **Publish the route to the Assembly:** opens a merchant passage and rewards 100 gold. Neris gains respect but loses some trust, and remembers making the route public.
- **Keep the route private for local fishers:** reserves the route for the coast's fishing families. Neris gains friendship, trust and affection, and her stress eases.

Both outcomes record a one-time campaign flag, a distinct memory and authored relationship evidence. No save schema change is required.
