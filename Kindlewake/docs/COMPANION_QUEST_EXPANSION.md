# KindleWake — Recruitable Ally Companion Quest Expansion

**Status:** DESIGNED / REQUESTED. These are narrative and implementation specifications, not playable-content claims. This document extends `STORY_QUEST_SPECIFICATIONS.md` and Lore Bible §15. The current main-branch recruitment data was audited on 2026-11-10; IDs below match the recruitable character IDs found in `Kindlewake/data/characters.json`. Recheck the live roster before implementation.

## 1. Design goals and shared rules

The main campaign already has personal arcs for Bram Vosk, Sela Wrenfield and Brother Wystan, plus the regional Ilyra Venn/Maren Vey storyline. This expansion gives every other currently data-defined recruitable ally a personal questline, and gives Maren a dedicated playable quest packet that deepens her existing regional arc.

Companion quests are optional, character-led stories with consequences—not recruitment errands repeated after the ally joins. Recruitment and personal-arc completion are separate: an ally can join before, during or after the personal story depending on the existing recruitment condition. A missed or declined arc never blocks the main campaign, a House ratification or the true ending.

### Shared companion-arc contract

Each arc should contain 3–5 scenes, a clear personal question, at least one non-combat route, one tactical or interactive set-piece where appropriate, a meaningful choice, a visible main-campaign callback and an epilogue resolution. A character must retain agency and may disagree with Torren. Do not use a hidden loyalty threshold as the sole determinant of betrayal, departure or quest success.

- **Availability:** Require the character to be recruited and alive/available, plus the stated chapter or regional access. If the character is not recruited, use a short ambient mention or leave the arc dormant; never spawn a duplicate recruit.
- **Failure:** Use retreat, negotiation, partial success or a later recovery scene. No arc should softlock because an optional item, witness or battle objective was missed.
- **Rewards:** Prefer a character-specific technique, equipment recipe, keep service, tactical passive or relationship scene. Rewards must use existing item/skill systems and balanced values; mark any new item/skill as pending until its data definition exists.
- **State:** Store milestones and decisions under `story.companion_arc.<character_id>`; keep personal bond, loyalty, faction relations and House commitments separate.
- **Cinematics:** Keep scenes skippable and replay-safe. Reuse the canonical sprite/portrait identity for the character.
- **Chronicle gate:** These arcs may enrich the late-life epilogue and Founder Chronicle, but none unlocks Chronicle of Houses. The strict Last Emperor → formal Empire abolition → late-life epilogue → natural old-age death gate remains unchanged.
- **Scope:** Proposed quest IDs must be checked against all live quest data before implementation. Do not create parallel quest managers or assume proposed encounters/items/skills already exist.

## 2. New and expanded companion quest catalogue

| Character ID | Character | Quest ID | Questline title | Core theme |
|---|---|---|---|---|
| `lucan_thorne` | Lucan Thorne | `q_companion_lucan_last_flight` | The Last Flight | Duty versus inherited command |
| `old_brisa` | Old Brisa | `q_companion_brisa_hearth_of_names` | A Hearth of Names | Care, memory and community |
| `kestrel` | Kestrel | `q_companion_kestrel_no_master` | No Master's Shadow | Autonomy after coercion |
| `anselm_pike` | Anselm Pike | `q_companion_anselm_line_to_hold` | The Line We Hold | Honour beyond formation |
| `petra_quill` | Petra Quill | `q_companion_petra_bitter_draught` | The Bitter Draught | Medical ethics and scarcity |
| `dorian_vask` | Dorian Vask | `q_companion_dorian_unspent_bolt` | The Unspent Bolt | Accountability for a past shot |
| `edda_stonehand` | Edda Stonehand | `q_companion_edda_iron_and_ash` | Iron and Ash | Craft, labour and responsibility |
| `joss_harrow` | Joss Harrow | `q_companion_joss_debt_of_silence` | The Debt of Silence | Survival, theft and restitution |
| `isaure_vessmoor` | Lady Isaure Vessmoor | `q_companion_isaure_two_oaths` | Two Oaths, One Name | House duty and personal conscience |
| `bram_cullen` | Bram Cullen | `q_companion_bram_cullen_broken_chain` | The Broken Chain | Freedom from debt and violence |
| `verra_nightsong` | Verra Nightsong | `q_companion_verra_song_without_seal` | A Song Without a Seal | Art, propaganda and truth |
| `tomas_wren` | Tomas Wren | `q_companion_tomas_far_marker` | The Far Marker | Belonging and chosen family |
| `orlan_pike` | Orlan Pike | `q_companion_orlan_margin_of_truth` | In the Margin | Preserving dangerous knowledge |
| `sister_odaly` | Sister Odalys | `q_companion_odaly_open_door` | The Open Door | Sanctuary and institutional limits |
| `willem_roake` | Ser Willem Roake | `q_companion_willem_last_challenge` | The Last Challenge | Chivalry without vanity |
| `ysolde_marrow` | Ysolde Marrow | `q_companion_ysolde_names_in_salt` | Names in Salt | Coastal identity and political erasure |
| `garrick_holt` | Garrick Holt | `q_companion_garrick_spared_enemy` | The Man We Spared | Mercy, command and accountability |
| `corwin_brennhallow` | Lord Corwin Brennhallow | `q_companion_corwin_heirless_seal` | The Heirless Seal | Legitimacy and public obligation |
| `seraphine_tarnholt` | Seraphine Tarnholt | `q_companion_seraphine_measure_of_oaths` | The Measure of Oaths | Faith and institutional reform |
| `ilyan_voss` | Ilyan Voss | `q_companion_ilyan_silent_tower` | The Silent Tower | Knowledge, restraint and power |
| `maren_vey` | Maren Vey | `q_companion_maren_tideglass_wake` | The Tideglass Wake | Maritime memory and complicity |

## 3. Quest packets

### Lucan Thorne — The Last Flight
**ID:** `q_companion_lucan_last_flight`  
**Availability:** Lucan recruited; Orrowen favour route or equivalent introduction resolved; Act II onward.

- **Scene 1 — The Unsent Signal:** Lucan recognises an old ranger signal on a border post. He admits that his former patrol abandoned a hamlet after receiving contradictory orders. The player can ask for the full account privately or invite the affected villagers to speak first.
- **Scene 2 — Feathers in the Mud:** Track the patrol's route through a short field-navigation challenge. Recover a damaged signal case; optional clues reveal that the orders were altered after dispatch.
- **Scene 3 — The Empty Watch:** Find surviving patrol members. Resolve through testimony, a negotiated public hearing or a tactical defence when a frightened veteran panics. Do not force the veteran to fight to the death.
- **Decision:** Lucan can publish the full record, submit it to neutral custodians while protecting names, or keep it private and make restitution directly. Each route has a different cost to his reputation and the villagers' trust.
- **Resolution:** Lucan becomes a ranger captain, trains scouts at the keep, or leaves to rebuild the abandoned watch route. His choice changes later scouting dialogue and one campaign reconnaissance option.

### Old Brisa — A Hearth of Names
**ID:** `q_companion_brisa_hearth_of_names`  
**Availability:** Old Brisa recruited through the village quest; Act I onward.

- **Scene 1 — The Empty Cot:** Brisa discovers that a list of displaced families was discarded when a temporary infirmary closed. She remembers the patients but not every name.
- **Scene 2 — Names at the Mill:** Visit three households and reconcile conflicting accounts through conversation and a small record-matching activity. The player may use supplies to help one household immediately or preserve enough for the group.
- **Scene 3 — The Fever Cart:** A supply cart is intercepted. Choose escort, negotiation with the local reeve or a tactical rescue focused on recovering medicine rather than defeating every opponent.
- **Decision:** Establish a permanent keep infirmary ledger, return Brisa to village service, or create a rotating community care network. The decision must not make her the sole source of healing in the game.
- **Resolution:** Brisa's network provides a modest, balanced recovery service and a late-game memorial scene. The names recorded become part of the Founder Chronicle if the true-ending gate is later met.

### Kestrel — No Master's Shadow
**ID:** `q_companion_kestrel_no_master`  
**Availability:** Kestrel recruited through the hidden-location route; Act II onward.

- **Scene 1 — The Mark Beneath the Door:** Kestrel finds a familiar coded mark and refuses to explain it in front of the company. Torren can offer privacy, ask for a trusted companion to mediate or insist on an immediate account.
- **Scene 2 — The Safehouse That Wasn't:** Infiltrate or negotiate access to an abandoned safehouse. A compact stealth/patrol-reading sequence reveals that Kestrel once carried messages for a coercive network.
- **Scene 3 — Names for Sale:** The network offers to erase Kestrel's old identity in exchange for handing over a witness. The player can expose the offer, stage a false exchange or negotiate safe passage for the witness.
- **Decision:** Destroy the network's records, preserve evidence for a lawful hearing or let Kestrel decide what can be disclosed. Never compel Kestrel to recount trauma as the price of loyalty.
- **Resolution:** Kestrel becomes an independent intelligence operative, leaves to sever the network safely or remains with the company under a chosen name and boundaries. A later ambush or infiltration route changes accordingly.

### Anselm Pike — The Line We Hold
**ID:** `q_companion_anselm_line_to_hold`  
**Availability:** Anselm recruited through the barracks event; Act I onward.

- **Scene 1 — Muster Without Orders:** Anselm receives a muster notice from a former commander whose unit has been reduced to unpaid guards.
- **Scene 2 — The Broken Formation:** Inspect the abandoned drill ground. A tactical training mini-game asks the player to position a small squad to protect a retreat lane, with success based on coverage and safe withdrawal rather than kills.
- **Scene 3 — The Sergeant's Choice:** The former commander intends to seize a village storehouse to pay the soldiers. Resolve by offering a lawful muster contract, negotiating compensation or defeating the armed group while protecting civilians.
- **Decision:** Anselm may testify against the commander, help the soldiers enter lawful service or refuse to legitimise the unit. Each option records the soldiers' consent and outstanding wages.
- **Resolution:** Unlock a training-yard drill or a defensive formation lesson; Anselm may become instructor or remain a field lancer. No free army units are created.

### Petra Quill — The Bitter Draught
**ID:** `q_companion_petra_bitter_draught`  
**Availability:** Petra recruited through the plague-ward quest; Act I onward.

- **Scene 1 — The Ward Ledger:** Petra finds a treatment ledger with doses recorded but no patient outcomes. She fears that a respected physician concealed an unsafe trial.
- **Scene 2 — Three Bottles:** Investigate supply labels and compare symptoms in a non-combat diagnosis mini-game. All clues must be readable and mistakes recoverable.
- **Scene 3 — The Last Dose:** A settlement has enough medicine for only part of the ward. The player consults patients and caregivers before choosing triage criteria; no option should secretly guarantee a perfect result.
- **Decision:** Publish the treatment error and support the affected families, pursue a private restorative agreement or preserve the physician's identity while disclosing the risk. Medical facts cannot be altered by persuasion.
- **Resolution:** Petra establishes a transparent treatment protocol, becomes a travelling field medic or steps away from institutional medicine. Unlock a modest medical supply recipe only if its ingredients and balance are implemented.

### Dorian Vask — The Unspent Bolt
**ID:** `q_companion_dorian_unspent_bolt`  
**Availability:** Dorian recruited through negotiation; Act II onward.

- **Scene 1 — The Wrong Banner:** Dorian recognises the insignia of a convoy he once fired upon. The convoy may have been carrying civilians under a borrowed banner.
- **Scene 2 — Range of Memory:** Reconstruct the shot using witness positions, range markers and line-of-sight. The activity teaches tactical range and cover without rewriting what Dorian actually knew at the time.
- **Scene 3 — The Quartermaster's Account:** Find the officer who supplied the false identification. Dorian can confront him publicly, seek corroboration or refuse a staged confession.
- **Decision:** Dorian gives testimony, seeks restitution for survivors or declines public absolution and performs practical repair work. Survivors are not required to forgive him.
- **Resolution:** Dorian may become a disciplined marksman instructor, a field investigator or remain a quiet crossbowman. A later convoy encounter recognises the chosen response.

### Edda Stonehand — Iron and Ash
**ID:** `q_companion_edda_iron_and_ash`  
**Availability:** Edda recruited after the workshop rebuild; Act I onward.

- **Scene 1 — The Missing Tools:** Workshop workers report that specialised tools have disappeared. Edda suspects the tools were sold to pay an old labour debt.
- **Scene 2 — A Fair Measure:** Audit material stores and interview workers in an interactive crafting/economy sequence. The player must distinguish stolen stock from tools loaned with consent.
- **Scene 3 — The Furnace Bargain:** A former employer offers Edda ownership of the workshop if she signs away the workers' claims. Resolve through contract review, mediation or a defensive encounter when hired enforcers arrive.
- **Decision:** Edda can establish shared workshop rules, take individual ownership with binding worker protections or leave the keep to form an independent guild.
- **Resolution:** Unlock one balanced workshop service/recipe and a visible worker policy at Kaer Sethorn. The quest must not bypass existing construction costs.

### Joss Harrow — The Debt of Silence
**ID:** `q_companion_joss_debt_of_silence`  
**Availability:** Joss recruited through the tavern rumour; Act II onward.

- **Scene 1 — A Familiar Purse:** Joss recognises a stolen purse carried by a messenger. He claims it was payment for information that saved a child, but admits he kept the remainder.
- **Scene 2 — The Ledger Below:** Follow a smuggling account through a tavern cellar and a market contact. The player can investigate openly, sneak in or buy a copy without violence.
- **Scene 3 — The Names Owed:** Joss's former partners are selling identities of debtors and refugees. A timed rescue/escape sequence prioritises getting the named people out safely.
- **Decision:** Joss returns the money, trades the ledger for safe passage or exposes the network while accepting that some victims may reject his apology.
- **Resolution:** Joss becomes a reliable scout and quartermaster, leaves to repay victims or remains with the company under a restitution agreement. A later market contact reflects whether he made amends.

### Lady Isaure Vessmoor — Two Oaths, One Name
**ID:** `q_companion_isaure_two_oaths`  
**Availability:** Isaure recruited after the Vessmoor gate and duel; Act II onward.

- **Scene 1 — The Sealed Summons:** Isaure receives a summons from a Vessmoor relative demanding that she return and denounce the company.
- **Scene 2 — The Household Muster:** Travel to a Vessmoor holding and discover that retainers are divided between lawful duty and private loyalty. Use dialogue, document inspection or a non-lethal tactical challenge.
- **Scene 3 — The Gatehouse Duel:** Isaure's former mentor demands a duel to settle her perceived dishonour. The player may accept a formal duel, expose the mentor's forged order or arrange arbitration with witnesses.
- **Decision:** Isaure renews a limited House oath, renounces the claim to command or negotiates a written service compact. No branch grants the player control of House Vessmoor.
- **Resolution:** Isaure becomes a diplomatic cavalry envoy, returns as a local protector or remains a free agent. Vessmoor representatives later acknowledge her choice without automatically ratifying the Council.

### Bram Cullen — The Broken Chain
**ID:** `q_companion_bram_cullen_broken_chain`  
**Availability:** Bram Cullen recruited from the debtor's prison; distinguish him from Bram Vosk in all IDs, dialogue and UI.

- **Scene 1 — The Prisoner's Mark:** Bram Cullen discovers that a former jailer has transferred his debt to a private company. He fears the company will seize other prisoners.
- **Scene 2 — The Debt House:** Inspect contracts and interview former inmates. A document puzzle exposes compounded fees and falsified signatures.
- **Scene 3 — The Chain Yard:** Rescue debtors from a work gang through negotiation, stealth or a tactical extraction with a clear retreat route.
- **Decision:** Destroy the false debt records, submit them to a public tribunal or negotiate release while preserving evidence for later claims. Do not imply all debts are fraudulent.
- **Resolution:** Bram Cullen may become a prison-reform advocate, a free company berserker or leave to help former inmates. The journal and dialogue must always identify him as Bram Cullen, never Bram Vosk.

### Verra Nightsong — A Song Without a Seal
**ID:** `q_companion_verra_song_without_seal`  
**Availability:** Verra recruited through negotiation after Joss's recruitment condition; Act II onward.

- **Scene 1 — The Borrowed Verse:** Verra hears a song she wrote performed with altered words praising the secret Covenant faction.
- **Scene 2 — The Singer's Copy:** Trace the altered lyrics through a travelling troupe. A rhythm/memory mini-game identifies the original verses; it must be accessible without audio and offer a text alternative.
- **Scene 3 — The Public Performance:** The troupe is pressured to repeat the propaganda at a crowded gathering. Resolve by presenting the original, exposing the patron or arranging a performance that lets the troupe safely refuse.
- **Decision:** Verra publishes the original song with names, removes identifying details to protect the performers or writes a new piece that records the harm without becoming a political anthem.
- **Resolution:** Verra becomes a travelling chronicler, performs at the keep or leaves to rebuild the troupe. Her song can become an epilogue motif, but lyrics must be original.

### Tomas Wren — The Far Marker
**ID:** `q_companion_tomas_far_marker`  
**Availability:** Tomas recruited through his side quest; Act I onward.

- **Scene 1 — The Marker in the Fen:** Tomas recognises a boundary marker from the place he left behind. He has avoided speaking about why he ran.
- **Scene 2 — Tracks That Turn Back:** Follow old scout signs through a short navigation and observation sequence. Find evidence that his family sheltered deserters, but do not assume Tomas shared their choices.
- **Scene 3 — The Homeward Path:** Return to the settlement and discover that residents disagree about whether the family should be protected or prosecuted. Resolve through testimony, safe evacuation or a tactical defence.
- **Decision:** Tomas returns openly, helps the family relocate or remains away while sending aid. The choice is his after Torren lays out risks.
- **Resolution:** Tomas becomes a route-finder for the company, a local scout or a bridge between settlements. Later travel scenes reflect whether he has a home to return to.

### Orlan Pike — In the Margin
**ID:** `q_companion_orlan_margin_of_truth`  
**Availability:** Orlan recruited through the library; Act II onward.

- **Scene 1 — The Misbound Volume:** Orlan discovers that a catalogue entry was altered to hide a record of conscription limits.
- **Scene 2 — The Marginal Hand:** Compare handwriting, binding marks and duplicate copies in a library research puzzle. The source must establish provenance, not magically reveal the whole Codicil.
- **Scene 3 — The Archive's Price:** A custodian offers access in exchange for suppressing a politically dangerous annotation. The player may petition, negotiate reciprocal access or recover a copy through a stealth route.
- **Decision:** Publish the source, deposit it with independent custodians or redact vulnerable names while preserving the clause. Orlan must explain the long-term archival risks of each.
- **Resolution:** Orlan becomes an archivist for the Council, a travelling researcher or an independent keeper of disputed records. Unlock a codex entry and a later evidence-verification callback.

### Sister Odalys — The Open Door
**ID:** `q_companion_odaly_open_door`  
**Availability:** Sister Odalys recruited after the Tarnholt trial; Act II onward.

- **Scene 1 — The Sanctuary Bell:** Odalys receives word that a sanctuary has barred families after armed fugitives exploited its protection.
- **Scene 2 — The Rule of Shelter:** Hear residents, sanctuary keepers and threatened families separately. The player drafts temporary safety rules that distinguish protection from immunity for violence.
- **Scene 3 — At the Threshold:** Armed pursuers arrive. The encounter can be resolved through a negotiated surrender, escorted evacuation or tactical defence of the sanctuary perimeter.
- **Decision:** Odalys may support conditional sanctuary with due process, establish a neutral refuge network or return to her order to seek institutional reform.
- **Resolution:** Her choice changes sanctuary services and later dialogue on the public Covenant. It must not conflate the religious community with the secret faction that adopted the Covenant name.

### Ser Willem Roake — The Last Challenge
**ID:** `q_companion_willem_last_challenge`  
**Availability:** Willem recruited after his duel; Act II onward.

- **Scene 1 — The Challenge at Dawn:** Willem receives a challenge from a former rival who accuses him of winning their earlier duel through a technicality.
- **Scene 2 — Witnesses to Honour:** Interview the seconds and inspect the duel record. The player learns that the rival was protecting a younger squire from a politically arranged match.
- **Scene 3 — The Unarmed Yard:** Resolve through a formal rematch, a public correction of the record or a non-lethal sparring sequence where the rival can yield.
- **Decision:** Willem publicly admits the technicality, offers restitution to the squire or maintains the legal result while acknowledging its moral cost.
- **Resolution:** Willem becomes a mentor for young guards, a ceremonial champion or a wandering knight. His later advice on the Council concerns lawful process, not automatic endorsement of monarchy.

### Ysolde Marrow — Names in Salt
**ID:** `q_companion_ysolde_names_in_salt`  
**Availability:** Ysolde recruited through Ysmark politics; Act III onward and only when the relevant coastal region is available.

- **Scene 1 — The Salt Register:** Ysolde finds a coastal register that lists families under altered names after a past levy.
- **Scene 2 — Tide Marks:** Work with local record keepers to compare tide tables, harbour marks and family testimony. Keep Brinegate's political identity with the Tidebound Assembly; do not assign it as House Ysmark's seat.
- **Scene 3 — The Wharf Hearing:** A harbour official claims that restoring the names will destabilise local trade. The player can negotiate phased disclosure, protect vulnerable families or expose the official's private profiteering.
- **Decision:** Publish all verified names, use sealed testimony or allow each family to choose whether to restore its recorded name.
- **Resolution:** Ysolde becomes a coastal advocate, a House envoy or an independent keeper of family records. Her arc may improve maritime trust but cannot determine House Ysmark's unconfirmed seat.

### Garrick Holt — The Man We Spared
**ID:** `q_companion_garrick_spared_enemy`  
**Availability:** Garrick recruited after the spare-commander route; Act II onward.

- **Scene 1 — The Prisoner's Request:** Garrick learns that the commander he once spared has been accused of ordering reprisals.
- **Scene 2 — The Witnesses' Road:** Escort two witnesses who disagree about the commander's conduct. Protect them without forcing either to endorse Garrick's decision.
- **Scene 3 — The Hearing or the Hunt:** The commander flees before the hearing. Track and capture him, negotiate his surrender or defend the witnesses from his remaining soldiers.
- **Decision:** Garrick can testify to why he spared the commander, acknowledge the harm caused by misplaced trust or support a lawful trial without seeking revenge.
- **Resolution:** Garrick becomes a disciplined officer, resigns command to make restitution or remains a field veteran. The campaign records the difference between mercy and impunity.

### Lord Corwin Brennhallow — The Heirless Seal
**ID:** `q_companion_corwin_heirless_seal`  
**Availability:** Corwin recruited through the late Act IV route; only after his authored introduction and survival.

- **Scene 1 — The Seal Without an Heir:** Corwin reveals that a Brennhallow seal is being used to issue orders in the name of an absent successor.
- **Scene 2 — The Names on the Charter:** Audit the charter's witnesses and authority. The player can seek a neutral legal review, interview the household or confront the seal-bearer.
- **Scene 3 — The Hall of Retainers:** Retainers divide over whether Corwin should claim authority, relinquish it or submit the matter to a House hearing. Resolve with debate or a defensive battle if violence breaks out.
- **Decision:** Corwin submits his claim to review, renounces personal advantage or accepts a strictly temporary custodial role under public limits. No branch lets him unilaterally bind the Seven Houses.
- **Resolution:** Corwin may serve as a constitutional witness, return to private life or become a conditional House representative. His presence at the Council never substitutes for formal ratification.

### Seraphine Tarnholt — The Measure of Oaths
**ID:** `q_companion_seraphine_measure_of_oaths`  
**Availability:** Seraphine recruited through the late Act IV route; after the relevant Tarnholt introduction.

- **Scene 1 — The Unread Oath:** Seraphine discovers that recruits have been asked to swear to a document they were never allowed to read.
- **Scene 2 — The Quiet Chapter:** Investigate the order's records and speak with members who fear expulsion. A dialogue-led inquiry can establish whether the practice was isolated or institutional.
- **Scene 3 — The Chapter House:** Present the evidence to the order. The player may seek reform from within, establish an independent review or protect members who choose to leave.
- **Decision:** Seraphine renews a revised oath, refuses the institution's authority or remains while demanding transparent oversight.
- **Resolution:** She may become a reforming officer, an independent protector or a lay mediator. Keep the public Covenant compact separate from any secret faction using its name.

### Ilyan Voss — The Silent Tower
**ID:** `q_companion_ilyan_silent_tower`  
**Availability:** Ilyan recruited through the mage tower; Act III onward.

- **Scene 1 — The Tower's Missing Page:** Ilyan finds a page removed from a research record about a dangerous rune interaction.
- **Scene 2 — A Controlled Experiment:** Conduct a safe, turn-based puzzle that tests rune sequence, containment and resource limits. Failure causes a recoverable setback, never permanent loss of a character.
- **Scene 3 — The Apprentice's Warning:** A former apprentice has repeated the experiment without safeguards. Reach them through negotiation, rescue or a tactical encounter focused on disabling the apparatus.
- **Decision:** Destroy the research, seal it under shared oversight or publish a safe procedure while withholding dangerous details. Ilyan must explain the risks rather than treating secrecy as automatically virtuous.
- **Resolution:** Ilyan becomes a supervised researcher, a travelling instructor or a guardian of the sealed tower. Any new rune or skill reward is pending data authoring and balance review.

### Maren Vey — The Tideglass Wake
**ID:** `q_companion_maren_tideglass_wake`  
**Availability:** Maren recruited through the Tideglass Ledger; Thalassar/Brinegate Coast content accessible.

- **Scene 1 — The Ledger's Missing Page:** Maren reveals that the Tideglass Ledger omits a voyage carrying refugees and sealed cargo. She knows the route but not who altered the record.
- **Scene 2 — Soundings at Low Tide:** Use a navigation mini-game to plot a safe approach through shoals. The player can consult local pilots, inspect tide marks or pay for a chart; no single paid route is mandatory.
- **Scene 3 — The Wreck's Witness:** Reach the wreck and recover a sealed manifest. A cinematic reveals that the crew diverted the ship to avoid a blockade, but the cargo's owner later profited from the disappearance.
- **Decision:** Publish the manifest, protect the surviving crew while submitting evidence to neutral custodians or negotiate reparations with the affected families. Ilyra Venn's leadership remains a distinct part of the wider Beacon and the Tide storyline.
- **Resolution:** Maren becomes a trusted pilot, establishes a rescue route or leaves to document missing voyages. The outcome can grant a maritime passage contact or witness; Brinegate remains the Tidebound Assembly's seat, not House Ysmark's.

## 4. Integration and production order

1. **Roster validation:** Confirm each character ID still exists, is recruitable and has a stable recruitment condition. Confirm Bram Cullen and Bram Vosk remain distinct.
2. **Quest ID audit:** Search all live quest data and proposed specs for collisions. Preserve any existing live ID and document a mapping rather than duplicating it.
3. **Character-first vertical slice:** Implement one early recruit arc (Old Brisa or Edda) using existing quest/dialogue/save systems; then one stealth/investigation arc (Kestrel or Joss); then one later political arc (Isaure, Corwin or Seraphine).
4. **Shared framework:** Reuse the existing quest state, dialogue, battle and save systems. Do not build a separate companion quest manager.
5. **Presentation:** Use the same character sprite/portrait identity, expressions and nameplate across battle, dialogue, roster and journal. Keep mobile dialogue choices touch-safe and cinematics skippable.
6. **Testing:** Test recruited/not recruited, dead/unavailable, arc accepted/declined, partial success, retreat, save/load mid-quest, replayed scenes, and each ending callback. Verify no optional arc blocks the main story or Founder gate.

## 5. Acceptance checklist

- All 21 IDs in the catalogue resolve to current recruitable character records or are explicitly marked deferred if the roster changes.
- Every arc has 3–5 authored scenes, a non-combat approach, a meaningful choice, a recovery path and a main-story callback.
- No companion quest duplicates a recruitment event or creates duplicate characters.
- Bram Cullen and Bram Vosk are never conflated.
- No arc invents House Ysmark's seat or changes Brinegate's Tidebound Assembly status.
- Public Covenant and secret Covenant faction remain distinct.
- No personal quest is required for a campaign ending, Last Emperor investiture, Empire dissolution or Chronicle of Houses unlock.
- All new item, skill, service and encounter references are resolved before being marked implementation-ready.
- Quest completion and rewards are idempotent; old saves receive safe defaults.
- All content remains offline-first and uses existing Godot architecture.
- Status remains **SPECIFIED** until scenes/data/scripts exist; **IMPLEMENTED** only after source changes; **VERIFIED** only after automated tests and relevant device QA.
