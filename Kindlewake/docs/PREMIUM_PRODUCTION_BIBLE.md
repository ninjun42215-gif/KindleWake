# KindleWake — Premium Production Bible
**Creative direction:** *The Sundered Vow*  
**Status:** Approved design direction; implementation is staged through small, testable vertical slices.  
**Source baseline:** main `6379826a992e67a2abd92a9a795d97cb1022e4ca`, game version 0.11.0.  
**Production principle:** pursue the emotional clarity, authored detail and interface confidence of a premium console RPG, scaled intelligently for an offline-first mobile game. This is a quality target, not a claim about budget or completed content.

---

## 1. The promise to the player

KindleWake is not a generic medieval tactics game with a large roster. It is a **company drama about people who choose to stand together after institutions fail them**.

The player fantasy:
- Begin with a handful of survivors and a ruined keep.
- Build a company whose members have distinct voices, loyalties, rivalries, skills and histories.
- Make battlefield decisions that matter after the victory screen.
- Turn a local survival struggle into a realm-wide political reckoning.
- Return to a headquarters that visibly changes because of the player's decisions.
- Finish a long session feeling that a chapter of a personal chronicle has advanced—not that a checklist has been emptied.

**North-star test:** if a feature does not strengthen character attachment, tactical expression, world believability, player clarity or campaign consequence, it is not a priority.

## 2. Story reframe — The Sundered Vow

### Logline
When the keeper of the Covenant of Seven Flames is executed as a traitor, his last surviving heir inherits a ruined fortress and a sealed oath. To learn why the kingdom's founding promise was broken, the heir must gather the people the crown discarded—and decide whether a realm built on a lie can be repaired without becoming another lie.

### The emotional engine
The mystery is not simply “who killed the king?” It is **what kind of peace deserves to survive, and who has been forced to pay for it?**

The Seven Houses publicly claim that their Covenant protects the realm. In truth, each house has preserved a different fragment of the original oath and quietly edited the parts that inconvenience it. The Hidden Codicil does not merely transfer power away from the crown. It records the original terms of the Covenant, including the obligations the great houses abandoned: shared grain reserves, limits on conscription, sanctuary for displaced families, and a binding right of appeal for common towns.

Edmer Dunmarrow was executed because he intended to reveal not one royal secret but a system of broken promises. Regent Maelor Brennhallow suppressed the Codicil because he believes exposing the truth during a succession crisis will trigger famine, invasion and civil war. His fear is credible. His methods are indefensible.

### The protagonist
The player-created heir is not a predestined saviour. They begin with an inherited name, incomplete memories, a small group of witnesses and no automatic claim to moral authority. Character-creation choices should alter:
- the opening memory and one personal dialogue exchange;
- one early contact or starting advantage;
- how two companions initially interpret the protagonist;
- one later resolution option or epilogue detail.

Choices must be authored, visible in the moment and remembered. Never promise a branching consequence that the game does not track.

### The central cast — dramatic functions
- **Torren Dunmarrow:** the burden of inheritance. His arc is from “I must restore what was taken” to “I must decide what deserves to be restored.” His defining flaw is confusing duty with self-erasure.
- **Bram Vosk:** the cost of loyalty. A veteran who believes practical protection matters more than clean hands. His arc tests whether loyalty means obedience or the courage to disagree.
- **Sela Wrenfield:** the truth that power edits. A scout who knows how ordinary people survive official stories. Her arc moves from distrustful witness to someone willing to be publicly accountable for what she knows.
- **Brother Wystan:** faith after institutional failure. He has not lost belief; he has lost certainty that the powerful speak for it. His choices distinguish mercy from surrender.
- **Maelor Brennhallow:** the antagonist who can explain every terrible decision. He should save lives in one chapter and destroy them in another. Never make him secretly evil for convenience.
- **The recruited company:** not a collection screen. Every recruit needs a want, a fear, a contradiction, a relationship pressure point and a reason to stay or leave.

## 3. Campaign structure — chapter rhythm and reversals

The current prologue + five-act structure remains. Each act should follow: **personal problem → local investigation → tactical operation → irreversible choice → quiet aftermath → new question**.

| Chapter | Dramatic promise | Set piece | End-of-chapter reversal |
|---|---|---|---|
| Prologue — Smoke on the Wind | Escape is not victory | The Dunmarrow estate burns while two exits compete: save people or recover the sealed household record | The record is incomplete; someone inside the household altered it before the fire |
| I — Cold Hearth | Can strangers become a company? | Defend Sallow Crossing's winter stores; choose who receives the last convoy | The raiders were paid to seize a ledger, not food |
| II — Broken Seals | Every house remembers a different Covenant | Public hearing at Orrowen; an ambush during a diplomatic escort | A witness recants because their family is being held |
| III — The River Campaign | Winning territory can lose the people in it | A multi-stage bridge/river operation with a tactical objective beyond killing | The “enemy” supply route is carrying refugees under a false banner |
| IV — Winter of Knives | Loyalty is not the same as agreement | Infiltrate the Quillon archive while the company fractures over the plan | The Codicil proves Edmer concealed one clause to protect someone |
| V — The Kindling | The truth does not choose the future for you | Multi-front assault on Aurelmont with a playable decisive engagement | Maelor offers a real settlement, but it requires the protagonist to surrender personal power |
| Epilogue — The Chronicle | What remains after victory? | A quiet return through the rebuilt keep | The company tells the story differently depending on who was heard, lost, forgiven or left behind |

### Rules for memorable twists
1. Plant evidence at least one chapter before its explanation.
2. Let a twist change the meaning of an earlier scene, not erase it.
3. Give the player enough information to understand the risk before choosing.
4. Never make an ally betray the player solely because a hidden loyalty number crossed a threshold.
5. The antagonist's best argument must be strongest immediately before the final choice.
6. End chapters on a human consequence and a forward question, not only a larger enemy.

## 4. The first-hour experience

The opening hour is the most important quality gate. It must teach the game's emotional and mechanical language without a wall of text.

1. **Cold open (0–5 min):** a short playable escape, no lore dump. Let the player choose which person or evidence to save. Use a restrained, readable cinematic composition.
2. **First battle (5–15 min):** teach move, attack, facing and one terrain advantage. One objective is to reach the bridge with survivors, not wipe every enemy.
3. **First quiet scene (15–20 min):** the four companions disagree about what was lost. The player chooses a response; each companion reacts in their own voice.
4. **Arrival at Kaer Sethorn (20–30 min):** show the keep in its damaged state. The player can inspect three memorable details: the burned oath hall, the empty memorial wall and the blocked well.
5. **First company decision (30–40 min):** choose between repairing the infirmary, barracks or storehouse first. Each gives a clear immediate benefit and a visible environmental change.
6. **First recruitment (40–50 min):** meet a recruit through a short authored scene and a practical dilemma, not a generic “join?” prompt.
7. **First chapter hook (50–60 min):** a ledger page reveals that the roadwolves were searching for a witness. Offer a clear next objective and one optional lead.

Keep the opening skippable after the first completion. Preserve the choice outcomes in the campaign save.

## 5. Character writing standard

Every named recruit receives a compact character dossier before dialogue is written:

- **Surface want:** what they say they want.
- **Private need:** what would actually help them grow.
- **Wound:** the event or belief that shapes their choices.
- **Contradiction:** the thing they do that conflicts with their self-image.
- **Voice:** sentence length, vocabulary, humour, metaphor and what they refuse to say.
- **Relationship triangle:** one ally, one friction point and one person they misunderstand.
- **Personal quest:** three beats—invitation, complication, resolution—with a player decision.
- **Battle identity:** role, signature move, tactical strength, weakness and battlefield barks.
- **Keep contribution:** a visible or mechanical contribution to the growing headquarters.
- **Resolution:** a clear state for loyal, estranged, absent or lost outcomes.

**Dialogue rules**
- Prefer specific observations over generic fantasy declarations.
- Use silence, interruption and subtext; do not make every character eloquent.
- No character explains lore they would not naturally know.
- Keep mobile dialogue panels to short, readable chunks; split long speeches into beats.
- Add speaker portraits, expression changes and a distinct text cadence before adding voice acting.
- Avoid repetitive combat barks. Use contextual lines for low HP, ally rescue, rivalry, boss encounters and chapter events, with cooldowns.

## 6. Choices and consequence architecture

Use a small, reliable set of explicit campaign facts rather than dozens of fragile hidden branches.

Suggested state groups:
- `story.chapter`, `story.flags`, `story.decisions`
- `houses.reputation` per house
- `company.loyalty` per character (existing v0.11.0 system)
- `company.relationships` for authored pairs
- `world.region_flags`, `world.dungeon_flags`
- `chronicle.memorials` and `chronicle.epilogue_tags`

Every major decision should affect at least two of: a character relationship, a house reputation, a resource or facility, a future mission modifier, a recruitment/personal quest, an epilogue tag. Consequences must be signposted through dialogue, journal updates or a visible reaction. Do not silently punish the player with arbitrary desertion.

**Choice quality checklist**
- Are the options genuinely different in values, not “good / evil / sarcastic”?
- Does each option have an understandable immediate cost?
- Does a later scene acknowledge the decision?
- Can the player inspect the resulting journal entry?
- Is there a non-optimal but emotionally valid outcome?
- Does the choice avoid soft-locking the main campaign?

## 7. Session-length and long-run engagement

Target a satisfying 45–90 minute play session without artificial compulsion. Long sessions should emerge from meaningful adjacent activities:
- a story operation;
- the aftermath and companion conversation;
- one optional exploration lead or dungeon;
- company management and equipment planning;
- a short personal quest or recruitment opportunity;
- a natural save-and-stop point.

**Healthy engagement rules**
- No energy timers, stamina walls, forced login streaks, loot-box pressure, manipulative scarcity or punitive offline timers.
- No daily chores that expire while the player is away.
- Use clear chapter objectives, optional rumours and a “continue next” marker.
- Every 10–15 minutes, provide a meaningful player decision or a change in tactical context—not a pop-up.
- Use chapter-end autosaves and a one-tap “Resume Chronicle” path.
- Offer a concise “Since your last visit” recap after a long break.
- Make grinding unnecessary. Optional encounters should reward mastery, lore, resources or alternate tactics—not mandatory repetition.
- Give the player control over battle speed, combat text density, auto-battle and tutorial reminders.

## 8. UX quality bar

### Navigation
- One consistent primary action per screen; Back/Close always stays in the same predictable location.
- Preserve the last selected hero, tab, scroll position and map zoom when returning from a sub-screen.
- Use breadcrumbs or a clear location title for nested menus.
- Never hide a destructive action behind an ambiguous icon.

### Touch and readability
- Primary touch targets: 52–64 dp where practical; never make essential actions depend on precision tapping.
- Respect display cutouts and safe areas in both landscape and portrait.
- Scale text from a readable baseline; avoid shrinking labels to fit. Reflow or scroll instead.
- Provide contrast-safe colours, icon + text status labels and colour-blind-safe rarity distinctions.
- Make drag interactions optional; provide tap alternatives for every important action.
- Avoid modal stacks. Prefer one clear panel with a visible back path.

### Battle clarity
- Before committing: show hit chance, expected damage range, status chance, counter risk and relevant terrain/facing modifiers.
- Explain why an action is unavailable.
- Clearly distinguish selected, reachable, threatened, targetable and objective tiles.
- Provide undo before confirmation where the rules permit it.
- Keep the timeline readable; allow the player to inspect upcoming enemy intent when supported.
- After battle, summarize casualties, rewards, loyalty changes, objective results and new story flags in one coherent aftermath.

### Save trust
- Autosave at safe chapter/battle boundaries, never during a partially written state.
- Keep rotating backups and checksums; show the save timestamp and chapter.
- Explain version migration and preserve old saves through explicit tests.
- Pause safely when the app backgrounds; never require a network connection.

## 9. Visual identity and asset production bible

### Art direction
**Mood:** painterly medieval realism translated into crisp, readable 2D/isometric game art. Weathered materials, strong silhouettes, restrained saturation, warm human interiors against cold political exteriors. Avoid generic stock fantasy, noisy texture overlays and random mismatched asset packs.

**Palette families**
- Dunmarrow: ash charcoal, faded ivory, ember copper.
- Brennhallow: iron black, cold steel, disciplined crimson.
- Orrowen: deep leaf green, bark brown, pale moss.
- Ysmark: sea slate, salt white, aged brass.
- Vessmoor: sun-baked ochre, horsehide red, grass gold.
- Quillon: ink violet, parchment, muted starlight.
- Tarnholt: candle ivory, weathered stone, restrained sacred gold.

### Asset tiers
1. **Hero assets:** protagonist portraits, 24 core recruit portraits, faction leaders and major antagonists. Consistent lighting, face proportions, expression sets and naming.
2. **Gameplay sprites:** readable unit silhouettes, class/equipment overlays, enemy archetypes, hit/guard/cast/fall states, consistent pixel scale and animation timing.
3. **Environment kits:** modular walls, floors, roofs, doors, windows, props, foliage, rocks, water edges, bridges, interior furniture and faction-specific variants.
4. **Battle readability:** terrain overlays, objective markers, range/cover/height cues, status icons, damage and healing feedback.
5. **UI system:** coherent icon family, frame borders, button states, rarity treatments, portraits, parchment/map panels, typography hierarchy.
6. **Atmosphere:** weather, fog, embers, dust, leaves, torchlight, water shimmer and subtle ambient animation. Effects must never obscure tactical information.

### Production specifications
- Establish one pixel-density and tile-size standard per asset family; no arbitrary scaling of sprites with different source resolutions.
- Use transparent PNG for raster sprites and SVG for scalable UI/icon assets where practical.
- Maintain sprite sheets with documented frame size, frame order, pivot, animation rate and collision footprint.
- Create normal/pressed/disabled/focused states for every important UI control.
- Use nine-slice panels for scalable dialogue, menus and cards.
- Use a small number of coherent material palettes rather than per-asset colour improvisation.
- All assets need provenance metadata: source, author, licence, attribution, modification rights, redistribution rights and intended use.
- Assets with unknown or incompatible rights remain excluded from release builds. The voxel pack and optional sprite bundles are not production-cleared until documented.

### Environment storytelling
Every hub should show its history through props and NPC routines:
- Kaer Sethorn: patched banners, missing stones, a half-restored memorial, smoke from the kitchen, visible construction progress.
- Sallow Crossing: flood marks, repaired carts, a notice board with changing rumours, guards who react to road safety.
- Orrowen: coppiced trees, bowyer workshops, trail markers and signs of contested land.
- Vessmoor: horse yards, mile stones, weathered duel posts and grain wagons.
- Dungeons: one strong visual motif, a traversal mechanic, environmental clues and a boss arena that tells the location's story.

## 10. Audio and presentation

- Give each major house a short original musical motif that can be arranged for town, battle and aftermath.
- Use adaptive layers: quiet exploration, tension, battle, victory and grief. Do not abruptly restart music on scene transitions.
- Establish a consistent sound language for selection, confirmation, invalid action, hit, armour, critical, healing, status, objective and chapter reveal.
- Keep master/music/SFX sliders separate; include mute and reduced-flash options.
- Reserve silence for major revelations. Do not fill every moment with UI sounds.
- If voice work is unavailable, use excellent portraits, expression changes, text pacing and authored music rather than low-quality placeholder voice.

## 11. Quality gates — definition of done

A feature is not “premium” because it has more content. It is done when:
- the player understands its purpose without external explanation;
- it is accessible by touch and readable at supported phone sizes;
- it has a clear success/failure/empty/loading state where relevant;
- it preserves save compatibility or includes a tested migration;
- it has regression tests for the new behavior;
- it fits the art, writing and sound direction;
- it has asset provenance and no unverified third-party content;
- it does not introduce mandatory grind or offline-time punishment;
- it passes Godot import, strict tests, balance report and Android export;
- physical-device QA is separately recorded rather than implied by CI.

## 12. Recommended implementation sequence

Do not attempt a whole-game rewrite. Build a complete vertical slice, then scale the proven pattern.

**P0 — Story truth and onboarding**
1. Reconcile the opening story with the current playable campaign and actual flags.
2. Implement the first-hour sequence as a playable prologue/Chapter I vertical slice.
3. Add a persistent journal with main objective, optional leads, decisions and discovered lore.
4. Add dialogue presentation with portraits, expression states, speaker names and choice history.
5. Add a chapter recap and “Resume Chronicle” flow.

**P1 — Character attachment**
1. Author the four starting companions' three-beat personal quests.
2. Add recruit dossiers and contextual battle barks for the first 24 named characters.
3. Make loyalty changes event-driven and visible; no opaque threshold desertion.
4. Add relationship scenes and a memorial/chronicle view.

**P2 — World and asset quality**
1. Create a production-cleared art kit for Sethorn and Sallow Crossing first.
2. Replace placeholders by coherent modular environment pieces and character portraits.
3. Add faction-specific props, weather and ambient effects.
4. Add original house motifs and layered ambience.

**P3 — Campaign depth**
1. Add repeatable but non-mandatory side content with authored variations.
2. Implement house reputation and consequence tags only when used by a scene or mission.
3. Expand regional travel after the first region's story, save and UX loops are stable.
4. Add New Game+ / Legacy content only after the main campaign is complete and tested.

**First vertical-slice acceptance criteria**
- 45–60 minutes of coherent play from escape to first keep decision and the first road investigation.
- At least 3 meaningful choices with visible immediate and later acknowledgement.
- Four companion voices distinguishable without name labels.
- One tactical mission with a non-elimination objective and terrain teaching.
- One recruit introduction that feels like a scene, not a database transaction.
- Journal, recap, autosave and resume all work offline.
- No soft-locks; all choices have a viable continuation.
- Tests cover story flags, save/load and migration; physical-device test covers touch, readability, safe areas and performance.

---

## 13. Sample opening scene — tone reference

**Scene: The east gallery, Dunmarrow estate. The roof is burning. Rain strikes the stained-glass oath window.**

**Bram:** “The west stair is gone. We have one clean passage, and it is closing.”

**Sela:** “Not clean. There are people behind the archive door.”

**Wystan:** “And the household record. If it burns, Edmer dies a traitor in every telling.”

**Bram:** “He is dead already. The living are asking us to choose.”

**Choice A — “Get the people out. The record can wait.”**  
Bram approves the clarity. Sela remembers who was left behind in the archive corridor. The opening rescue route is easier; the first clue must be recovered later.

**Choice B — “Take the record. We need the truth.”**  
Sela approves the purpose but warns that a name is not worth a life. The company escapes with the record fragment; a later scene acknowledges the people who were not reached.

**Choice C — “Split. No one gets left if we move together.”**  
Requires the protagonist's selected discipline or a companion support check. The escape is harder and costs a resource, but both the people and the fragment can be saved if the tactical objective is completed.

The scene must not secretly grade the player as good or evil. Each path creates a different burden and a later opportunity to respond.

---

## 14. Non-negotiable production guardrails

- Original characters, dialogue, maps, music and visual designs only.
- No unlicensed asset packs in distributable builds.
- Fully offline; no account, server, telemetry or internet permission requirement.
- Respect the current save schema and add migrations with tests for any persistent-state change.
- No monetisation-driven retention systems. The game earns long sessions through authored depth and player agency.
- Never claim a scene, sprite, feature or device test is complete until it exists in the repository and passes its relevant checks.
