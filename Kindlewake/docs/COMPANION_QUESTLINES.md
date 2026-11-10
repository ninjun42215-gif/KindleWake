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
