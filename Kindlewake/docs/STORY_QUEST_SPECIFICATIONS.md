# KindleWake — Main Campaign Quest Specification

**Status:** DESIGNED / REQUESTED. This is an implementation-facing narrative specification, not evidence that these quests, dialogue scenes, cinematics, or battles are playable. Canon authority: `LORE_BIBLE.md`; story overview: `GDD.md §10`. Keep all content original and preserve the Godot/offline architecture.

## 1. Production contract

Every quest is a data-authored unit with a stable ID. Scene prose, objectives, encounter definitions and state mutations must be separate from quest-flow code. Reuse existing quest, dialogue, world-flag, battle and save systems after auditing them; do not create parallel managers.

### 1.1 Required quest record

Each authored quest must provide:

| Field | Contract |
|---|---|
| `id` | Stable snake_case ID; never recycle an ID after release. |
| `chapter_id` | One of `prologue`, `act_1` … `act_5`, `epilogue`. |
| `title`, `summary` | Player-facing text; summary states the immediate dramatic question. |
| `entry_conditions` | Required prior quest completions, flags, region access and optional companion availability. |
| `start_scene` | Scene/dialogue ID, cast, location, opening beat and journal disclosure. |
| `objectives` | Ordered or parallel objective IDs, types, completion rules and optional/required status. |
| `approaches` | Available combat, stealth, diplomacy, investigation, rescue or resource routes. Only include approaches supported by the actual game. |
| `encounter_id` | Existing encounter/battle definition or explicit `none`; never invent an unresolved battle reference. |
| `decisions` | Stable choice IDs, eligibility, options, visible costs and resulting flags/state changes. |
| `aftermath_scene` | Consequence scene, companion reactions and settlement/world changes. |
| `rewards` | Data-backed rewards and unlocks; no reward may bypass progression or create resources from nothing. |
| `failure_recovery` | Retry, retreat, negotiation, partial success or a clearly authored fail-forward path. Avoid dead-end softlocks. |
| `journal_entries` | Confirmed facts, attributed testimony and unresolved theories kept distinct. |
| `exit_conditions` | Exact flags/quest completion needed to unlock the next chapter. |
| `continuity_refs` | Lore sections, prior choices and later callbacks that must remain consistent. |

Quest completion must be idempotent: loading or replaying a completion callback must not duplicate rewards, items, testimony, casualties or world-state changes. Choice IDs are written once to the save; later content reads the recorded result rather than asking again.

### 1.2 Shared narrative state

Use explicit, inspectable flags/counters with documented ranges and default values. These are proposed IDs, not a demand to add all of them before the first vertical slice.

| State ID | Meaning | Rules |
|---|---|---|
| `story.company_cohesion` | Ability to disagree and still cooperate | Bounded; changed by trust, consultation and coercion, not generic good/bad choices. |
| `story.public_trust` | Settlement-level trust in Torren/company | Prefer per-settlement records over one global number when the world model supports it. |
| `story.dunmarrow_legitimacy` | Verified legal evidence supporting the house claim | Evidence-based; reputation cannot substitute for proof. |
| `story.covenant_evidence` | Verified clauses, seals, records and testimony | Store evidence IDs and provenance, not only a completion score. |
| `story.house_commitments` | Promises, conditions and unresolved grievances for each House | Per-house state; never infer consent from positive reputation alone. |
| `story.maelor_channel` | Negotiation status with Maelor | Enum: `open`, `strained`, `closed`, `talks_active`, `settlement_rejected`. |
| `story.companion_arc.<character_id>` | Personal quest milestone/outcome | Per character, explicit milestones and resolution. |
| `story.council_ratifications` | House/community ratification records | Record who voted, legal basis, conditions and dissent. |
| `story.true_ending_authorized` | Valid constitutional route prerequisites | Derived/validated from source records; never set by a dialogue option alone. |
| `story.last_emperor_invested` | Temporary Last Emperor office accepted | Requires valid Council and ratification state. |
| `story.empire_dissolved` | Formal dissolution charter enacted | Immutable charter record and date/chronicle event required. |
| `story.concord_signatories` | Realms/institutions that voluntarily ratified | Per-signatory consent and terms; no forced global membership. |
| `story.late_life_epilogue_complete` | All required late-life scenes completed | Explicit completion marker. |
| `story.founder_death_cause` | Founder death cause | Must be `natural_old_age` for Chronicle unlock. |
| `story.chronicle_of_houses_unlocked` | Post-campaign mode gate | Serverless/local validation of every required milestone; cannot be toggled by UI. |

Do not conflate public trust, faction relations, personal bonds, legal legitimacy or house consent. If existing systems already model one of these concepts, extend that source of truth.

### 1.3 Choice and evidence rules

- Every major choice shows the immediate known cost before confirmation. Do not reveal unknowable future consequences as certainty.
- A choice must record the actor, option, chapter, timestamp/turn if available, and resulting state mutations.
- Testimony records who said it, under what conditions, what they directly witnessed and whether it is corroborated.
- A recantation is not proof that the original testimony was false; coercion and witness safety must be considered.
- Do not make every branch require a unique full quest. Prefer shared mission spine, alternate approaches and state-dependent aftermaths.
- Never force a companion betrayal solely from a hidden score. Departure requires authored motive, warning and an opportunity to respond where plausible.

## 2. Quest catalogue and detailed packets

The IDs below are canonical proposed IDs for implementation. They must be checked against existing live quest data before use. If an ID already exists, preserve the live ID and document the mapping rather than duplicate it.

### Prologue — Smoke on the Wind

#### `q_prologue_last_evening` — The Last Evening
- **Entry:** New campaign; Torren's character setup completed.
- **Scene:** Kaer Dunmarrow, before the attack. Establish Torren's everyday duties, Edmer's guarded concern, household relationships and the sealed packet without explaining its contents.
- **Objectives:** Speak with the household; complete a short training interaction; check the gate or stores; meet the initial companions.
- **Gameplay:** Tutorial interactions only. Optional conversations establish early characterisation and can add journal memories.
- **Decision:** Choose what Torren believes House Dunmarrow should protect first: its people, its oath or its name. This is a stated priority, not an ending lock.
- **State:** Record `prologue.torren_priority`; no morality score.
- **Exit:** The attack cinematic begins. Do not allow the player to miss the main inciting event through optional dialogue.

#### `q_prologue_ash_alarm` — The Ash Alarm
- **Entry:** `q_prologue_last_evening` complete.
- **Scene:** The estate is attacked and burning. Use a readable cinematic-to-control handoff and clear environmental cues.
- **Objectives:** Reach the inner hall; identify reachable survivors; choose a rescue route; escape the collapsing wing.
- **Gameplay:** Movement, interaction, basic defence and hazard tutorial. Fire/smoke hazards must be visually communicated and fair.
- **Decision:** First rescue priority: household rooms, stable yard/injured group, or record room. The chosen route saves one group immediately; another may remain recoverable later at a cost.
- **State:** Record rescue route and survivor outcomes individually. A lost record does not erase every later route to the truth.
- **Failure recovery:** A failed traversal returns to a safe checkpoint; never permadeath Torren in the tutorial.
- **Exit:** Survivors reach the outer grounds; trigger the escape sequence.

#### `q_prologue_broken_road` — The Broken Road
- **Entry:** `q_prologue_ash_alarm` complete.
- **Scene:** Bram holds a narrow passage, Sela scouts the road and Wystan treats the wounded.
- **Objectives:** Secure the retreat route; protect the injured; optionally pursue the masked officer or send a witness ahead.
- **Approaches:** Hold the passage (combat/tutorial), protect the retreat (defence objective), pursue (risk/reward), or dispatch witness (split-party cinematic).
- **Decision:** Pursue the masked officer, prioritise retreat, or send a witness with a warning. Each yields different evidence and risk.
- **State:** Record officer clue, witness identity/status and casualties. Do not make pursuit the only source of the Codicil plot.
- **Exit:** Company reaches the waystation.

#### `q_prologue_first_account` — The First Account
- **Entry:** `q_prologue_broken_road` complete.
- **Scene:** At a ruined waystation, survivors compare conflicting memories. A burned dispatch bears a Crownlands seal, but the author is unknown.
- **Objectives:** Interview survivors; inspect dispatch; classify facts versus testimony versus speculation; choose the first journal statement.
- **Decision:** Publicly swear first to restore the house, discover the truth or protect survivors. The priorities may coexist later.
- **State:** `story.prologue_account`; record evidence provenance. No unsupported claim that Maelor personally ordered the fire unless later proven.
- **Exit:** The group commits to reach Sallow Crossing and seek shelter.

### Act I — Cold Hearth

#### `q_act1_sallow_crossing` — Sallow Crossing
- **Entry:** Prologue complete; Sallow Crossing reachable.
- **Scene:** Winter settlement; granary threatened by armed raiders.
- **Objectives:** Speak to reeve and miller; inspect damaged stores; identify raider intent; protect or recover the grain tally ledger.
- **Approaches:** Negotiate, ambush, evacuate civilians or defend the storehouse. Battle objectives must prioritise the selected plan and civilians.
- **Reveal:** The raiders were paid to seize a ledger hidden among grain tallies, not simply steal food.
- **State:** Settlement trust, civilian harm, ledger custody and raider disposition.
- **Exit:** Ledger recovered, copied or lost with a clear alternative clue route.

#### `q_act1_winter_measure` — The Winter Measure
- **Entry:** `q_act1_sallow_crossing` complete.
- **Scene:** The stores cannot meet every claimant's needs. Reeve, patrol, displaced families and miller each present a defensible case.
- **Objectives:** Audit food, identify dependants and seed reserves, hear claimants, publish a distribution plan.
- **Decision:** Prioritise immediate need, preserve seed grain, honour existing contracts or divide stores under public oversight. No option feeds everyone.
- **State:** Store quantities, recipients, seed reserve, public trust and named grievances. Forecast the next consequence before confirmation.
- **Companion callback:** Wystan comments on sanctuary/need; Bram on security; Sela on who was excluded from the hearing.
- **Exit:** Distribution carried out; record who bears the shortage.

#### `q_act1_names_in_ledger` — Names in the Ledger
- **Entry:** `q_act1_winter_measure` complete and ledger clue available.
- **Scene:** Payments connect raiders to intermediaries, not directly to Maelor.
- **Objectives:** Verify names; trace one intermediary; protect a detained villager; preserve evidence.
- **Decision:** Keep original, publish a verified copy, or bargain with the evidence to release detainees. Bargaining may save people but weakens public corroboration.
- **State:** Evidence integrity, witness safety, detainee outcomes and the identity of the next lead.
- **Safeguard:** Never describe an intermediary as proof of Maelor's direct guilt.
- **Exit:** A credible lead points toward the frontier and Kaer Sethorn.

#### `q_act1_keep_worth_returning` — A Keep Worth Returning To
- **Entry:** Ledger quest resolved; Kaer Sethorn accessible.
- **Scene:** Workers distrust the Dunmarrow name; the company must make the ruined keep useful to others.
- **Objectives:** Survey damage; negotiate with workers; select first visible repair; assign available company labour.
- **Decision:** First investment: shelter, infirmary, stores or training yard. The selected facility gains an early advantage; core campaign access remains available.
- **State:** Facility upgrade, worker confidence, resource expenditure and local quest availability.
- **Exit:** The keep becomes a recognised refuge; unlock Act II lead.

### Act II — Broken Seals

#### `q_act2_orrowen_hearing` — The Orrowen Hearing
- **Entry:** Act I complete; lawful invitation or petition route obtained.
- **Scene:** Orrowen representatives disagree over what the public Covenant requires.
- **Objectives:** Present verified evidence; answer procedural challenges; hear local grievances; secure a hearing record.
- **Gameplay:** Dialogue/investigation sequence. Use evidence IDs and testimony provenance rather than a single persuasion check.
- **Decision:** Lead with famine obligations, conscription limits, sanctuary or common-town appeal. The chosen lead changes the debate and the House's requested concession.
- **State:** Orrowen commitment conditions; public/house distinction; hearing record.
- **Safeguard:** Explicitly distinguish the ancient public compact from the later secret organisation called the Covenant of the Seven Flames.
- **Exit:** Hearing yields a road escort request and a witness lead.

#### `q_act2_witness_price` — The Witness's Price
- **Entry:** Orrowen hearing complete.
- **Scene:** A witness recants after threats against their family.
- **Objectives:** Establish who threatened them; locate family; offer safe relocation; assess original testimony.
- **Decision:** Expose coercion, relocate family, accept a narrower statement or proceed without the witness. A forced public confession is never counted as corroboration.
- **Companion focus:** Sela challenges Torren to protect witness agency rather than possess their story.
- **State:** Witness consent, family safety, testimony reliability, Sela arc milestone.
- **Exit:** Evidence package updated; escort mission becomes available.

#### `q_act2_three_banners` — The Road of Three Banners
- **Entry:** Witness quest resolved; escort party assembled.
- **Scene:** Three armed groups claim authority over a contested road.
- **Objectives:** Verify orders; protect the diplomatic party; determine which group attacks civilians; reach arbitration point.
- **Approaches:** Expose forged orders, negotiate local arbitration, escort around the road or fight an attacking force.
- **Decision:** Use force to clear the road, accept a temporary arbitration or expose a forged authority claim. Force clears the route quickly but may damage the hearing's legitimacy if local law is ignored.
- **State:** Road access, civilian harm, local authority relations and escort survival.
- **Exit:** The company reaches the custodian of the first seal/record.

#### `q_act2_first_flame` — The First Flame
- **Entry:** Road mission complete.
- **Scene:** A seal or verified record authenticates one specific oath and points to another custodian.
- **Objectives:** Establish custody; test provenance; compare the seal to testimony; record the precise clause it authenticates.
- **Gameplay:** Investigation/puzzle may be used, but the seal does not reveal hidden thoughts or solve unrelated political disputes.
- **Decision:** Keep under company protection, entrust to neutral custodians or publish a verified transcript. Each option changes security and access.
- **State:** Add evidence ID to `story.covenant_evidence`; record custody chain and the next House lead.
- **Exit:** Act III river-route briefing begins.

### Act III — The River Campaign

#### `q_act3_river_divided` — A River Divided
- **Entry:** Act II complete; river region opened by story.
- **Scene:** Bridge, ferries and villages are contested; flood level and supply conditions matter.
- **Objectives:** Survey crossing points; assess flood/terrain; locate civilian routes; select a supply plan.
- **Gameplay:** Strategic reconnaissance with a tactical map preview. Costs in time, provisions and risk must be visible.
- **Decision:** Prioritise bridge control, ferry access, village evacuation or supply preservation. The decision determines mission setup, not an automatic success.
- **State:** Crossing plan, provisions, village evacuation status and operation readiness.
- **Exit:** The company discovers the convoy using a false banner.

#### `q_act3_false_banner` — The False Banner
- **Entry:** River survey complete.
- **Scene:** An apparent enemy convoy is carrying refugees under a borrowed military banner.
- **Objectives:** Identify cargo and passengers; determine who issued the banner; decide how to secure passage.
- **Approaches:** Halt and inspect, escort, divert through a dangerous route or attack only if hostile intent is confirmed. If the player attacks on mistaken information, record the harm and allow restitution where possible.
- **State:** Refugee safety, intelligence, commander trust and later testimony.
- **Exit:** A crossing operation becomes possible; refugees may provide route knowledge if trust is earned.

#### `q_act3_redwater_bridge` — The Bridge at Redwater
- **Entry:** False-banner outcome resolved; operation plan selected.
- **Scene:** Multi-stage bridge/river operation.
- **Objectives:** Secure riverbank; disable siege equipment or hold crossing; keep civilian route open; optionally capture quartermaster.
- **Encounter:** Reference a validated encounter ID after source audit. The battle must have a non-elimination objective and clear success/failure conditions.
- **Decision:** Primary objective: hold until civilians pass, disable equipment or capture quartermaster. Different objectives change later supply and evidence.
- **State:** Casualties, bridge condition, crossing control, prisoner status and refugee passage.
- **Failure recovery:** Tactical retreat leaves a recoverable contested crossing and a revised plan; do not silently mark success.
- **Exit:** The route to the next settlement opens or remains contested according to outcome.

#### `q_act3_price_of_passage` — The Price of Passage
- **Entry:** Redwater operation complete or recoverably failed.
- **Scene:** A local commander demands a village levy in exchange for safe passage.
- **Objectives:** Audit the levy; hear village representatives; trace the commander's private interest; negotiate terms.
- **Decision:** Refuse, accept a time-limited public toll, accept under public accounting or expose profiteering. Show food and trust consequences.
- **State:** Local obligations, supply route, public trust and commander status.
- **Exit:** Evidence points to a contradictory Codicil version in the Quillon archive.

### Act IV — Winter of Knives

#### `q_act4_quillon_archive` — The Quillon Archive
- **Entry:** Act III complete; archive lead verified.
- **Scene:** Archive custodians debate lawful preservation and public disclosure.
- **Approaches:** Invitation, legal petition, covert access or negotiated exchange. Each has a distinct cost and consequence.
- **Objectives:** Gain access; locate the relevant record; preserve its chain of custody; avoid damaging unrelated records.
- **Gameplay:** Investigation, social encounter or stealth supported by existing mechanics. Do not turn the archive into a generic enemy dungeon.
- **State:** Archive access route, custodian relations, record integrity and evidence chain.
- **Exit:** Contradictory Codicil text discovered.

#### `q_act4_missing_clause` — The Missing Clause
- **Entry:** Archive record recovered.
- **Scene:** The Codicil shows Edmer concealed a clause to protect a person/community from retaliation. Define the clause as a concrete Covenant obligation in authored dialogue/data before implementation.
- **Objectives:** Compare versions; identify who was protected; determine the risk of disclosure; consult affected people where possible.
- **Decision:** Publish full record, redact identifying details or submit to independent custodians first.
- **State:** Evidence completeness, privacy/safety risk, Edmer legacy interpretation and legitimacy.
- **Safeguard:** Edmer is neither flawless nor exposed as a simple villain. The consequences of concealment remain real.
- **Exit:** Company must decide how to handle disagreement over the next move.

#### `q_act4_company_divided` — The Company Divided
- **Entry:** Missing clause resolved.
- **Scene:** Bram, Sela and Wystan disagree on strategy for different defensible reasons.
- **Objectives:** Hear each companion's plan; identify shared concerns; choose a mission leader or mediate a joint plan.
- **Decision:** Support a defensible military position, prioritise witness agency, pursue mediation or allow a specialist to lead. No choice should arbitrarily cause betrayal.
- **State:** Company cohesion and relevant companion arc milestones; unlock a companion-led approach where justified.
- **Exit:** Maelor's offer arrives.

#### `q_act4_regent_offer` — The Regent's Offer
- **Entry:** Company division quest complete.
- **Scene:** Maelor offers limited amnesty, food/security guarantees and lawful hearing in exchange for surrendering the Codicil and abandoning public exposure.
- **Objectives:** Verify guarantees; identify neutral witnesses; hear Maelor's reasoning; decide whether to open talks.
- **Decision:** Accept talks, reject publicly, demand neutral witnesses or use the meeting to learn Maelor's fears. Negotiation is not surrender; rejection is not automatically virtue.
- **State:** `story.maelor_channel`, guarantee records, company response and later audience eligibility.
- **Exit:** Seven-House summit preparations begin.

### Act V — The Kindling

#### `q_act5_seven_tables` — Seven Tables
- **Entry:** Act IV complete; sufficient evidence to convene representatives.
- **Scene:** Representatives arrive with different mandates, grievances and conditions. Crownlands monarchy is separate from the Seven Houses. House Ysmark's seat remains unconfirmed; Brinegate is Tidebound Assembly territory.
- **Objectives:** Verify each representative's authority; set agenda; hear dissent; negotiate the Covenant clauses.
- **Decision:** Agenda priority: famine obligations, conscription limits, sanctuary, common-town appeal or a balanced package. A priority is not consent to the full settlement.
- **State:** Per-house commitment and ratification prerequisites; record dissent and conditions.
- **Exit:** Aurelmont crisis escalates.

#### `q_act5_city_under_strain` — The City Under Strain
- **Entry:** Seven Tables summit underway or adjourned.
- **Scene:** Aurelmont faces armed loyalists, frightened residents, disrupted food routes and opportunists using the secret faction's name.
- **Objectives:** Select city priority; evacuate or protect civilians; secure food route/hearing chamber/command network; coordinate with local responders.
- **Decision:** Prioritise evacuation, granaries, hearing chamber or command network. Each creates a vulnerability elsewhere; communicate trade-offs.
- **State:** Civilian harm, food access, city stability, summit safety and secret-order exposure.
- **Encounter:** Use objective-based tactical encounter(s) with clear phase transitions; exact encounter IDs must be validated against live data.
- **Exit:** The Last Audience becomes available.

#### `q_act5_last_audience` — The Last Audience
- **Entry:** City crisis resolved sufficiently for audience; Maelor channel may alter scene.
- **Scene:** Torren confronts Maelor. Maelor admits established orders and argues that disclosure at the wrong time risked famine, invasion and civil war.
- **Objectives:** Present evidence; hear Maelor's account; determine whether he will submit to lawful judgment; secure testimony or surrender terms.
- **Possible outcomes:** Trial/capture, negotiated surrender, exile under conditions, battle death or escape as a future threat. None erases responsibility.
- **State:** Maelor disposition, corroborated admissions, victims' claims and legal process.
- **Exit:** Council constitutional session.

#### `q_act5_council_of_seven` — The Council of Seven
- **Entry:** Last Audience complete; sufficient authenticated Codicil evidence.
- **Scene:** Houses and recognised communities debate transfer of the Crownlands' single-crown authority.
- **Objectives:** Authenticate Codicil; verify representative mandates; publish proposed Council charter; collect ratifications and conditions.
- **Decision:** Accept a bounded Council charter, amend representation/oversight or fail to secure ratification. Council powers must be explicit and accountable.
- **State:** Individual ratification records; no aggregate score may silently substitute for consent.
- **Safeguard:** The Council is a Crownlands constitutional settlement, not automatically a world government.
- **Exit:** Settlement choice determined by actual ratifications and prior commitments.

#### `q_act5_shape_of_peace` — The Shape of Peace
- **Entry:** Council session complete.
- **Scene:** Torren chooses among settlements that the recorded state makes legally and narratively available.
- **Options:** Reformed Crownlands monarchy; Council of Seven; voluntary plural compact; fractured peace; coercive victory with brittle legitimacy.
- **True-ending eligibility:** Only if the Council is constituted, required house/realm ratifications are present, Codicil evidence is authenticated and the settlement authorises the dormant imperial charter strictly for dissolution.
- **State:** Record settlement ID, legal authority, signatories, dissent, unresolved claims and whether true-ending sequence is authorised.
- **Exit:** Non-true endings proceed to their own complete epilogues. True-ending route starts Last Ember sequence.

### True ending and epilogue — The Last Ember

#### `q_epilogue_last_emperor_investiture` — The Last Emperor
- **Entry:** `story.true_ending_authorized == true`; Council charter and required ratifications validate.
- **Scene:** Restrained public investiture under dormant constitutional office. It is a temporary legal mandate, not conquest or restoration.
- **Objectives:** Review mandate; publicly accept limited term/purpose; record constitutional witnesses.
- **State:** Set `story.last_emperor_invested` only after validation; write immutable investiture chronicle record.
- **Safeguard:** No ordinary Emperor succession or permanent imperial throne.
- **Exit:** Dissolution charter is presented.

#### `q_epilogue_dissolution_charter` — The Last Charter
- **Entry:** Last Emperor investiture recorded.
- **Scene:** The player reviews the clauses ending the imperial office, central claim and residual institutions.
- **Objectives:** Confirm legal scope; list retained local laws; record claims/institutions to wind down; collect required signatures.
- **Decision:** Confirm charter clauses within the authorised mandate. No option may restore permanent imperial power.
- **State:** Set `story.empire_dissolved` only after the complete charter is signed; record date, witnesses, clauses and exceptions.
- **Exit:** Concord formation.

#### `q_epilogue_concord_of_free_realms` — A Concord, Not an Empire
- **Entry:** Dissolution charter enacted.
- **Scene:** Willing realms decide whether to sign and under what conditions.
- **Objectives:** Negotiate mutual aid, dispute arbitration, travel, sanctuary, famine obligations and limits on coercive levies; record refusal/neutrality.
- **Decision:** Each signatory accepts, qualifies or refuses. No forced membership or inferred consent.
- **State:** `story.concord_signatories`; create a compact record and unresolved-obligations list.
- **Exit:** Late-life sequence opens. Empire remains abolished regardless of Concord membership count.

#### `q_epilogue_late_years` — The Long Light
- **Entry:** Dissolution and Concord records complete.
- **Scene:** Authored vignettes over later years: return to Kaer Sethorn, receive companions, mediate a dispute, witness successes and failures, document unresolved obligations.
- **Objectives:** Complete required late-life scenes; choose public mediation, rebuilding, private life, mentoring or historical recordkeeping as scene priorities.
- **Gameplay:** Mostly narrative/cinematic with occasional small interactive decisions; do not simulate the full dynasty system early.
- **State:** Set late-life completion only when every mandatory vignette has been resolved. Record companion status and final relationships.
- **Exit:** Natural end-of-life scene becomes eligible; retirement/skip is not equivalent.

#### `q_epilogue_founder_chronicle` — The Founder Chronicle
- **Entry:** Late-life epilogue complete and protagonist death event explicitly recorded as `natural_old_age`.
- **Scene:** Quiet death and memorial. The Chronicle records the founder's life, ending, charter, signatories, companions, deeds, unresolved obligations and cause/age of death.
- **Validation:** Re-evaluate every unlock prerequisite from persisted source records. Never trust a UI flag alone.
- **State:** Create immutable Founder Chronicle; preserve completed campaign as read-only origin; create separate versioned generational save profile; unlock Chronicle of Houses.
- **Forbidden triggers:** battle death, scripted sacrifice, defeat, retirement, skipped epilogue, non-true ending, investiture without dissolution, dissolution without late-life completion.
- **Exit:** Transfer control to eligible descendant or lawful chosen/adopted successor according to the generational-mode succession design. If no candidate exists, resolve through the authored no-heir rule; do not invent a child.

## 3. Companion quest packets

Companion arcs should be optional but consequential. Availability may depend on recruitment, survival and chapter state; failure to complete an arc must not block the main story unless explicitly marked as a constitutional prerequisite (none of these personal arcs are).

| Quest ID | Character | Core objective | Meaningful resolution states |
|---|---|---|---|
| `q_companion_bram_weight_of_shield` | Bram Vosk | Find and hear a former unit whose orders caused civilian deaths; decide whether to testify, seek restitution or suppress the record. | Remains commander; trains at Kaer Sethorn; leaves to make amends; refuses political office. |
| `q_companion_sela_witness_who_chooses` | Sela Wrenfield | Protect displaced informants and let them control whether/how their testimony is used. | Independent investigator; Council recorder; scout captain; leaves if agency repeatedly violated. |
| `q_companion_wystan_mercy_measure` | Brother Wystan | Resolve a sanctuary abused by armed fugitives and denied to innocent families. | Establishes sanctuary; becomes mediator; returns to religious community; withdraws from public life. |

**Companion arc requirements:** each arc needs 3–5 scenes, at least one non-combat resolution, one consequence visible in the main campaign, a clear failure/abandonment outcome, and an epilogue callback. No arbitrary loyalty threshold should force betrayal. A companion may disagree, refuse a role or depart for an authored reason.

## 4. Dialogue and cinematics specification

For every scene, author:
1. **Scene header:** stable scene ID, location ID, chapter/quest, cast IDs, entry conditions and exit event.
2. **Dramatic intent:** what each speaker wants, fears and is unwilling to say.
3. **Player intent options:** concise choices expressing a motive; avoid fake choices that all produce identical text/state.
4. **Evidence context:** what Torren knows, what is hearsay and what remains unknown at this point.
5. **Delivery notes:** portrait/sprite expression, camera framing, timing, ambient sound and transition. Reuse the canonical character sprite/portrait identity; do not create inconsistent alternate portraits.
6. **State mutations:** explicit choice ID and state changes, validated against the shared narrative state contract.
7. **Skip/replay behaviour:** cinematics may be skipped without skipping mandatory state mutations; replaying a scene cannot duplicate rewards or choices.
8. **Accessibility:** readable text speed, pause/skip controls, touch-safe dialogue choices and subtitles for all essential audio cues.

Cinematics should be reserved for high-impact moments: estate attack, bridge operation transitions, missing-clause reveal, Aurelmont crisis, investiture, dissolution, late-life montage and founder death. Use in-engine staging where possible; do not require pre-rendered video or online assets.

## 5. Encounter and mini-game contract

- A quest may reference only an encounter ID present in validated live encounter data. Before implementation, search current JSON and scripts; if no matching encounter exists, mark the packet `encounter_pending` and author a separate encounter specification.
- Every battle has a briefing, primary objective, optional objective, failure condition, retreat/recovery route and aftermath. Elimination is not the default objective.
- Human factions, monsters, weapons, classes and region restrictions must use existing validated data IDs.
- A mini-game must be optional or clearly signposted, have touch-friendly controls, a finite session length, a narrative purpose and a reward that does not break the economy. Do not add a mini-game solely to pad quest count.
- Boss encounters must be telegraphed and fair; no unavoidable damage or hidden one-shot requirements. Story cinematics may precede/follow boss fights, but player agency and battle state must remain coherent.

## 6. Save compatibility, implementation order and acceptance

### 6.1 Save and migration

- Add only the minimum new persistent fields required by the first implemented vertical slice.
- Missing fields in old saves receive safe defaults; invalid IDs are rejected/logged without destroying the rest of the save.
- Persist quest stage, completed objectives, choice IDs, evidence provenance, companion arc milestones and once-only reward claims.
- Keep the Founder Chronicle and generational profile separate from the main campaign save. Completed campaign origin is read-only.
- Do not make a data migration depend on a network request.

### 6.2 Recommended vertical-slice order

1. **Slice A — Prologue:** implement `q_prologue_last_evening` through `q_prologue_first_account`, with two rescue routes, journal provenance and one replay-safe cinematic.
2. **Slice B — Act I:** implement Sallow Crossing and Winter Measure, proving resource consequences and a non-combat route.
3. **Slice C — Evidence/branching:** implement ledger, Orrowen hearing and Witness's Price; prove state-dependent dialogue and evidence reliability.
4. **Slice D — Tactical set-piece:** implement Redwater Bridge with objective-based battle, retreat/recovery and civilian outcome.
5. **Slice E — Companion arcs:** implement Bram, Sela and Wystan as separate optional quest chains.
6. **Slice F — Constitutional endgame:** implement Council ratification and ending eligibility before the Last Emperor sequence.
7. **Slice G — Founder gate:** implement investiture → dissolution → Concord → late-life epilogue → natural old-age death → immutable chronicle. Do not start Chronicle of Houses simulation until this gate passes tests.

### 6.3 Acceptance tests

- Every quest ID is unique; every referenced scene, character, location, item, encounter and flag resolves or is explicitly marked pending.
- Quest completion, rewards, evidence additions and choice recording are idempotent after save/load and repeated callbacks.
- Each quest can be entered only when prerequisites are met; no mandatory route is blocked by an optional companion quest.
- All choices have valid option IDs, visible costs and tested state mutations.
- Evidence stores provenance and distinguishes fact, testimony, hearsay and speculation.
- A recanted witness does not automatically invalidate prior corroborated evidence.
- Rescue outcomes do not remove every path to the main plot.
- Food allocation changes actual stores and later settlement state; no free resource generation.
- Redwater has at least one non-elimination objective and a recoverable failure path.
- Companion disagreement cannot create arbitrary betrayal from one numeric threshold.
- The public Covenant and secret faction remain distinct in data, UI and dialogue.
- Brinegate remains Tidebound Assembly territory; Ysmark seat stays unconfirmed.
- Only valid Council ratifications authorise the Last Emperor route.
- Emperor investiture alone does not unlock dynasty mode; dissolution alone does not unlock it; skipped epilogue does not unlock it.
- Only natural old-age death after all prior milestones unlocks Chronicle of Houses.
- Old saves load with safe defaults; no existing campaign state is overwritten.
- The whole feature works offline and uses the existing Godot architecture.

## 7. Authoring checklist for each new quest

Before a quest is considered ready for implementation, reviewers must be able to answer:
- What does the player want at the start, and what changes by the end?
- Which characters have agency in the scene?
- What does the player know, and how reliable is each piece of evidence?
- What are the meaningful approaches and their costs?
- What happens on success, partial success, retreat and failure?
- Which stable flags/records change, and why?
- Which earlier choice is recalled, and where will this quest be recalled later?
- Can the quest be completed/reloaded without duplicated rewards or broken saves?
- Does the quest preserve canon and avoid implying unimplemented systems are already live?

**Completion label:** A packet is `SPECIFIED` when all fields above are authored; `IMPLEMENTED` only when live Godot scenes/data/scripts exist; `VERIFIED` only when automated tests and relevant device QA support the claim.
