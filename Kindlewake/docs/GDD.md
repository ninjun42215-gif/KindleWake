# KINDLEWAKE: THE SUNDERED VOW — Game Design Document
Version 0.12.0 Brinegate Coast Expansion (released baseline) (data-driven protagonist creation foundation; character creation and original cast design; sprite source-pack integration; touch scrolling fix; shop compare and confirm; party screen redesign; towns and interiors; art pass; free-roam overworld; class skills; weapon skills; phone HUD rework; Milestone 2 in progress: equipment, character sheets, FF7-style EXP/AP/Sigil grinding, party screen and shop; Android APK pipeline; full class tree as data) · Engine: Godot 4.2+ (GDScript, GL Compatibility renderer) · Platforms: Android, iOS · Fully offline

> Inspiration only: tactical depth and mercenary management in the spirit of *Knights of Ages*, and recruitment/headquarters/platoon ideas in the spirit of *Suikoden II*. All characters, names, maps, story, art and music are original. Nothing is copied.

---

## 1. Game Overview

**Pitch.** You are the last heir of House Dunmarrow, a once-great noble house erased after your father was executed for treason. You inherit a ruined fortress, Kaer Sethorn, and a handful of loyal soldiers. Rebuild the keep, recruit knights and mercenaries, organise platoons, win tactical battles, and decide what Eldrimar becomes after its king's death.

**Design pillars**
1. **Every recruit matters.** Each character has a distinct class path, personality, platoon role and personal quest. No generic soldiers.
2. **Two scales of war.** Small grid battles (5–12 heroes per side) and large platoon battles (4–8 platoons per side). Heroes matter in both.
3. **A fortress that grows.** Sethorn visibly rebuilds, fills with people, and every facility has a gameplay function.
4. **Choices cost something.** Political decisions, loyalty, deaths and legacy carry across the campaign.
5. **Small phone, big depth.** Touch-first UI, short sessions (10–20 min per battle), fully offline, battery-conscious.

**Target:** core RPG/strategy players on mobile. Campaign 25–35 hours; New Game+ and Legacy Mode for replay.
**Tone:** dark medieval fantasy, muted palette, grounded politics, light low-magic fantasy (mages are rare and feared).
**Orientation:** landscape (1280×720 base, scales to any aspect ratio with safe-area margins).

---

## 2. Core Gameplay Loop

```
          ┌──────────────── Kaer Sethorn (HQ) ────────────────┐
          │ manage roster · platoons · gear · train · research    │
          └───────┬───────────────────────────────────▲───────────┘
                  │ pick mission (War Room / World Map)│ rewards, recruits, story
                  ▼                                    │
   Prepare squad / platoons ─► Battle (grid OR army) ─► Aftermath (casualties,
                                                        loot, loyalty, politics)
```

**Calendar.** The campaign runs on weeks (4 weeks = 1 month, 4 seasons). Travel, training and construction take weeks. Story missions have deadlines; side content is optional. Each week end: upkeep (gold + provisions), construction progress, training results, rumours refresh.

**Resources**
| Resource | Source | Spent on |
|---|---|---|
| Gold | missions, market, taxes | wages, gear, buildings, bribes |
| Provisions | farms/market/missions | weekly upkeep, army marches |
| Materials | missions, mines, salvage | buildings, forging, siege gear |
| Renown | story and politics | recruitment hall, nobles, promotions, endings |

**Session shape:** 1 HQ visit (3–5 min) → 1 battle (8–20 min) → aftermath/story (2–5 min). Autosave after every battle and at each week end.

---

## 3. Combat System (Tactical Grid Mode)

### 3.1 Battlefield
- Isometric (2:1) square grid. Maps 10×10 to 20×16. Each cell has **terrain** and **height** (0–4).
- Zoom and pan; tap a cell to preview, tap again (or press Confirm) to commit.
- Facing: each unit faces one of 4 directions; facing is set by its last move or attack.

### 3.2 Turn order (Charge-Time system)
Turn order is driven by Speed, not by "player phase / enemy phase".
- Each unit has a countdown `ctb`. The unit with the lowest `ctb` acts; all others subtract that amount.
- After a turn: `ctb = ACTION_BASE (1000) / SPD × mult`, where `mult` = 1.0 if the unit attacked or used a skill, 0.75 if it only moved, 0.5 if it only waited.
- Fatigue lowers effective SPD; Haste/Slow modify it. The HUD shows the next 8 turns.

### 3.3 Actions per turn
Move (up to `move` points, terrain cost) → then one of: Attack, Skill, Item, Wait. Move after acting is not allowed. Waiting lets the player choose facing.

### 3.4 Statistics
Base stats (all characters): **HP, MP, Strength (STR), Dexterity (DEX), Intelligence (INT), Vitality (VIT), Speed (SPD), Luck (LCK), Accuracy (ACC), Evasion (EVA), Leadership (LDR), Morale (MOR)**.

Typical level-1 ranges: HP 18–40, MP 0–30, STR/DEX/INT/VIT/SPD 4–14, LCK 3–12, ACC 70–90, EVA 5–25, LDR 1–12, MOR 40–70.

### 3.5 Damage formula (authoritative; implemented in `CombatCalc`)

```
attack_power  (physical) = weapon_power + STR + 0.25·DEX          (bows/crossbows: DEX instead of STR)
attack_power  (magic)    = spell_power  + 1.2·INT
defense       (physical) = armor_def   + 0.6·VIT
defense       (magic)    = armor_res   + 0.3·INT + 0.3·VIT

raw    = attack_power × skill_mult
base   = raw² / (raw + defense)                 # smooth, never negative, defense halves damage when equal to raw
damage = max(1, round(base × height × facing × flank × status × morale × crit × variance))

height   : +10% per level of height advantage (max +30%), −10% per level disadvantage (min −30%)
facing   : front 1.00 · side 1.10 · rear 1.25
flank    : +15% if an ally of the attacker is on the opposite side of the target
crit     : ×1.5 (Assassin backstab ×2.0)
variance : 0.95 – 1.05
morale   : MOR ≥ 80 → ×1.05 · MOR < 30 → ×0.85 · Routed → cannot attack
```

**Hit and critical chance**
```
hit%  = clamp(ACC + weapon_acc − EVA − terrain_cover − status_penalty, 10, 98)
crit% = clamp(5 + 0.5·LCK + 0.3·DEX + weapon_crit + (rear ? 10 : 0), 0, 60)
```

### 3.6 Ranges and weapon restrictions
| Weapon | Range | Notes |
|---|---|---|
| Sword/axe/mace | 1 | counter-attack chance on being hit in melee |
| Spear/lance | 1–2 | cavalry charge bonus (+10% per straight tile moved, max +30%) |
| Dagger | 1 | high crit, rear bonus |
| Bow | 2–5 | −10% hit if target in forest; +1 range from height ≥ 2 |
| Crossbow | 2–4 | ignores 20% armor; slow reload (mult 1.25 on ctb) |
| Staff/spells | 1–4 | magic damage, MP cost |
Melee cannot attack across impassable cells; ranged needs a clear line (blocked by walls, not by units).

### 3.7 Terrain
| Terrain | Move cost | Cover (−hit%) | Other |
|---|---|---|---|
| Grass | 1 | 0 | — |
| Road | 1 | 0 | cavalry +1 move |
| Forest | 2 | 15 | conceals: units are hidden beyond 2 tiles until they attack; fire spreads |
| Hill | 2 | 5 | height 1–2 |
| Shallow river/ford | 3 | 0 | −10% EVA; extinguishes fire |
| Deep water | ✗ | — | impassable (except flying/bridge) |
| Bridge | 1 | 0 | chokepoint |
| Ruins | 2 | 10 | |
| Wall/rock | ✗ | — | blocks movement and line of sight |
| Mud (rain) | 2 | 0 | −1 move for cavalry |
Height step rule: a unit can climb at most +1 height per move step (jump 1). Scouts/Thieves jump 2.

### 3.8 Status effects
Poison, Burn, Bleed (damage over time) · Chill (−SPD), Stun (skip turn), Slow, Haste · Blind (−hit), Silence (no spells) · Fear (−morale per turn) · Fortify, Inspire, Rally (buffs) · Exhausted (fatigue ≥ 80). Duration is counted in the affected unit's own turns.

### 3.9 Morale and fatigue
- **Morale (0–100):** rises when allies kill enemies, commander is alive, or Bard/Commander buffs are active; falls when allies die, when flanked, or when outnumbered. < 30 "Shaken" (−15% damage); 0 "Routed" (flees, cannot attack). Rally restores.
- **Fatigue (0–100):** +5 per tile moved over 3, +10 per heavy action; −10 per Wait; reset partially between battles. ≥ 50 reduces SPD and EVA by 10%; ≥ 80 "Exhausted".

### 3.10 Environmental conditions (per battle)
Clear · Rain (fire −30%, ranged −10 hit, mud) · Fog (vision radius 3) · Night (vision 4, thieves +crit) · Snow (move +1 on grass) · Wind (fire spreads one cell downwind per turn).

### 3.11 Victory and defeat
Victory: rout all enemies · defeat enemy commander · seize/hold a point for N turns · escort someone out · survive N turns.
Defeat: protagonist falls · all heroes fall · escort target dies · turn limit expires. Defeat offers retry or retreat to HQ with a penalty.

### 3.12 Auto Battle (added v0.2.1)
A player option that lets the battle AI play the player's units, for players who want to skip routine fights or watch the tactics play out.
- **Toggle:** a button labelled "Auto Battle: ON/OFF" in the battle HUD (top right, under Save/Load, full-width 56 px target). ON is shown in gold. The choice is stored as a setting (`[battle] auto_battle` in `user://settings.cfg`) and survives restarts of the app and of the battle.
- **Behaviour:** when ON, every player unit's turn is taken by the same scoring AI that drives the enemy, after the normal 0.6 s pause so the player can follow the action. Move/Attack/Skill/Wait/Confirm and map taps are disabled; Save and Load are disabled with a message ("Turn Auto Battle off to save/load").
- **Handing control back:** turning it OFF takes effect at the next unit's turn (the unit currently being decided is not interrupted mid-action). Turning it ON mid-turn drops any half-made selection; a unit that already moved this turn finishes by acting from where it stands, and a unit that already acted simply ends its turn.
- **Support AI:** a unit with a heal skill (currently Mend) heals the most badly hurt ally at or below 50% HP, moving to a safer cell within range if needed, before it considers attacking. No buff, debuff or item logic yet.
- **Rules unchanged:** Auto uses the same `BattleController` actions and formulas as manual play (no hidden bonuses or penalties). Later milestones: Auto must never spend consumables or recruit/story-critical choices without confirmation, and will gain a "stop when someone drops below X% HP" option.
- **Implementation:** `BattleAI.decide()` plans (move, attack | skill | wait); `BattleController.run_ai_turn(force)` executes it; `battle_scene.gd` decides who the AI controls (`_ai_controls`) and owns the toggle. Headless tests cover heal planning, part-played turns and the no-force guard.

---

### 3.13 Weapon skills (v0.5.5)
Skill type `strike` (data/skills.json): damage = weapon attack power x `mult` against **physical** defense, never misses, no facing/flank/height bonus, uses the caster's morale multiplier and skill-power mods. Power Strike (x1.5, 3 MP, range 1) for Torren and Bram; Aimed Shot (x1.4, 3 MP, range 2-4) for Sela. Since v0.5.6 they are granted by the class: `classes.json` has an optional `class_skills` map (skill id -> level needed). Warrior line (swordsman, knight, duelist, berserker, heavy_knight) gets Power Strike; ranged line (archer, crossbowman, longbow_master, sniper) gets Aimed Shot. `CharacterSheet.all_skills(items, sdefs, classes)` merges class skills, innate skills (characters.json) and sigil spells; enemies still use only their character-file skills. Promotion therefore keeps or changes skills automatically. `CombatCalc.skill_preview/skill_resolve` take an optional `weapon`; `CombatCalc.is_damage_skill()` covers spells and strikes. Auto Battle and the AI treat strikes like damage spells (the player units use them when they are the best option). UI: the Skill button shows the first usable skill with a `>` when there are several; tapping it again cycles through the skills and finally closes the mode.

## 4. Character Progression

### 4.1 Levels and experience
- Levels 1–250. Promotion remains tied to class tier milestones (10 / 20 / 30) and class-specific story requirements.
- `EXP to next = 80 + 20·level + max(0, level - 2)^2`. Early growth remains approachable; the quadratic tail makes later levels a long-term campaign achievement. Battle EXP is shared among surviving deployed heroes; reserve heroes receive 40% of a survivor's share.
- Each level grants class-based stat growth (probability per stat, 0–100%). Luck and Leadership grow slowly.

**Implemented in v0.3.0 (`CharacterSheet`, `PartyState`, `CombatCalc.kill_exp`)**
- `EXP to next = 80 + 20 × level + max(0, level - 2)^2`, level cap 250. Leftover EXP carries over; several level-ups can happen at once; no EXP is stored at the cap. Loaded character levels are clamped to 1–250.
- *Growth:* on each level-up every stat in the class's `growth` table (percent) gets one roll; success = +1 (HP: +2, MP: +1). If every roll fails, the class's strongest growth stat gains one point, so a level is never empty. Rolls use a seeded `RandomNumberGenerator` (deterministic in tests). HP gain per success is a tuning constant (`HP_GAIN`) to be set by the balance report.
- *Battle rewards (changed in v0.4.0, Final Fantasy VII rules):* see 4.6. The old participation/kill/victory EXP formula is gone; `CombatCalc.kill_exp` remains only as a per-unit statistic.

### 4.2 Class tree
| Branch | Tier 1 | Tier 2 | Tier 3 / Elite |
|---|---|---|---|
| Warrior | Swordsman | Knight, Duelist, Berserker | Heavy Knight |
| Cavalry | Cavalier | Lancer | Royal Cavalier → Paladin (needs faith/Priest bond) |
| Ranged | Archer | Crossbowman, Longbow Master | Sniper |
| Magic | Apprentice Mage | Fire Mage, Ice Mage | Battle Mage → High Sorcerer |
| Support | Priest | Cleric, Bard | Battle Medic |
| Specialist | Thief, Scout, Engineer | Assassin (from Thief) | Commander (unique, requires LDR ≥ 20 and a story flag) |

Promotion requirements combine **level + stat threshold + item/quest/facility** (e.g. Paladin: level 20 Royal Cavalier, Cleric bond, Tarnholt relic; Berserker: level 10 Swordsman with Fear status survived 3×). Characters keep learned skills after promotion.

**Implemented in v0.5.2 (`data/classes.json`, `CharacterSheet.promotion_options`)** — the whole tree above exists as data: 28 classes (4 tiers). A class record has `name, branch, tier (1-4), move, jump, growth {12 stats, chance 0-100 per level}, promotes_to`, and optionally `locked`, `story_only`, `requires` (text).
- **Rules:** a hero may promote when `level >= 10 x current tier` (tier 1 → 2 at level 10, 2 → 3 at 20, 3 → 4 at 30), into a class that exists in data and is **not `locked`**. Every promotion goes up exactly one tier inside the same branch (a test enforces this, and that every class can be reached).
- **`locked`** (Berserker: survive Fear 3×; Paladin: Cleric bond + Tarnholt relic) means the extra requirement cannot be checked yet (needs status effects, bonds, relics), so the class is never offered. **`story_only`** (Commander: LDR ≥ 20 + story flag) means nothing promotes into it; the story grants it. Both lift when the mechanism exists.
- **Open decision:** the example above says Paladin needs "level 20 Royal Cavalier", but the generic gate makes Royal Cavalier tier 3 (level 20 to reach, level 30 to leave). The data follows the generic gate until the Paladin quest is built.
- **Display names** (data only, easy to change): Swordsman Bladesworn → Knight Vowguard (→ Heavy Knight Ironvow), Duelist Quillon, Berserker Wrathbound · Cavalier Outrider → Lancer Spearrider → Royal Cavalier Crownrider → Paladin Oathwarden · Archer Reedrunner → Crossbowman Quarrelman / Longbow Master Yewmaster → Sniper Longsight · Apprentice Mage Candlemage → Fire Mage Emberist / Ice Mage Frostweaver → Battle Mage Spellblade → High Sorcerer Archsorcerer · Priest Wickkeeper → Cleric Lanternbearer (→ Battle Medic Fieldmender) / Bard Songkeeper · Thief Cutpurse → Assassin Nightknife, Scout Trailscout, Engineer Wallwright, Commander Marshal.
- **Movement:** cavalry classes move 6 (Paladin 5), Heavy Knight 3, Duelist/Bard/Longbow Master/Thief/Assassin 5, Scout 6; Thief, Scout and Assassin jump 2 (section 3); everyone else moves 4 and jumps 1.
- **Not yet done:** class skills (skills v1), class/weapon restrictions, the extra promotion requirements above. Battle sprites: the five original classes keep their drawn glyphs; every other class gets one placeholder glyph per branch (`_draw_branch_glyph`).

### 4.3 Skills
Each class teaches 3–5 skills (active and passive) plus 1 signature skill per tier. Characters also carry 1–2 **unique abilities** from their personal quest. Skill categories: attack, buff/debuff, mobility, command (platoon-wide), passive.

### 4.4 Equipment
Slots: Weapon, Off-hand, Armor, Helm, Accessory ×2. Rarity: Common, Fine, Masterwork, Heirloom (unique, character-bound, grows with the owner). Equipment changes stats and the paper-doll sprite layers (helm, armor, weapon, cape).
Blacksmith upgrades items by +1…+5 using materials; Heirlooms upgrade through story steps.

**Implemented in v0.3.0 (`data/items.json`, `CharacterSheet`, `PartyState`)**
- Item record: `name, slot (weapon|offhand|armor|helm|accessory), rarity (common|fine|masterwork|heirloom), price`, plus `weapon_id` (links to `weapons.json`), `armor_def`, `armor_res`, `bonus {stat: ±n}`, `two_handed`, `bound_to` (heirloom owner).
- Character slots: `weapon, offhand, armor, helm, accessory1, accessory2`. Accessories fit either accessory slot.
- Rules: the item must be in the shared inventory; equipping swaps the old item back into the inventory; a two-handed weapon needs an empty off-hand and blocks the off-hand while wielded; an heirloom can only be worn by its `bound_to` character. Not yet enforced: class/weapon-type restrictions, stat requirements, +1…+5 blacksmith upgrades, heirloom growth.
- Totals: base stats + every item `bonus`; defense = sum of item `armor_def`/`armor_res`. Characters in `characters.json` that have an `equipment` block derive weapon and armor from it (the old `armor_def`/`armor_res`/`weapon_id` fields are then only fallbacks for generic enemies). The four starting heroes' gear was chosen so their v0.2 totals are unchanged (a test guards this).
- The battle code is untouched by gear: `GameData.as_db()` / `PartyState.battle_db()` resolve each character through its sheet and `BattleUnit.create()` reads the result.

### 4.5 Economy and balance principles
- No grinding: story and side quests supply enough EXP; optional battles scale slightly with party level.
- Wages scale with level/rarity, so a bloated roster is costly; platoon upkeep matters.
- Every class has a counter: heavy armor beats bows but loses to mages and crossbows; cavalry beats archers/mages but loses to spears in forest/ford; mages are fragile and slow.
- Budget target: player gear power grows ~12%/chapter; enemy power ~10%/chapter plus authored spikes at set-piece battles.
- Balance is validated with the headless battle simulator planned for Milestone 2.

### 4.6 Campaign rewards, AP, gold and Sigils (FF7-inspired)

**Rewards.** Every enemy has a fixed `reward` block in `characters.json` (`exp`, `ap`, `gold`; commanders pay more). Defaults when missing: EXP `15 + 5 × level`, AP `2 + level`, gold `5 + 3 × level`, all doubled for a commander.
- Only **defeated** enemies pay. Winning by killing the chief while others live does not pay for the survivors.
- **EXP** of all defeated enemies is added up and split equally between the player units still standing (rounded down, at least 1). **AP** is paid in full to each survivor. **Gold** goes to the party.
- A fallen hero gets nothing; a **defeat pays nothing**. Undeployed roster members get 40% of one survivor's EXP share and no AP.
- Test battle (Prologue map): 250 EXP, 44 AP, 162 gold in total; with four survivors that is 62 EXP and 44 AP each, so a level costs about 2 battles at level 2 and about 6 at level 10.

**Sockets.** Weapons and armor carry 1-4 sockets (`sockets`), some in **linked pairs** (`links`), and an AP multiplier (`ap_mult` x1-x3; better gear levels sigils faster). Changing to a piece with fewer sockets returns the extra sigils to the bag.

**Sigils** (`data/sigils.json`; Materia equivalent). Each has an AP threshold list; level = 1 + thresholds reached; at the last threshold it is **mastered**, stops growing and **forges one fresh level-1 copy** into the bag (the classic grind loop).
| Kind | Effect | Examples |
|---|---|---|
| magic | grants skills, cumulative per level | Mending (Mend, Greater, Radiant), Embers (Ember Bolt, Ember Storm) |
| support | acts on the sigil in the linked socket | Resonance (+10/20/35% skill power), Tutor (+25/50/100% AP to the linked sigil) |
| stat | passive numbers for the current level, usually with a trade-off | Vigor (+HP%, -MP%), Might (+STR, -INT), Bulwark (+VIT, -SPD), Fleetness (+SPD) |
| independent | party-wide reward bonuses | Veteran's Mark (+EXP%), Coin Eye (+gold%) |
AP gained per sigil = battle AP x weapon/armor `ap_mult` x (100 + linked Tutor %) / 100, rounded up. Heroes no longer have innate spells: Brother Wystan's Mend comes from a Sigil of Mending in his mace.

**World encounters, not a grind mode.** There is no separate Skirmish or Story Battle selection on the results screen. Weighted enemy patrols can ambush the company while travelling through dangerous regions; authored battles are entered through campaign locations, dungeons, gates and story events. Victory rewards support the journey, while exploration, recruitment, side quests and regional milestones carry the narrative forward.

**Offensive magic (new skill type `damage`).** Never misses; damage = `base_damage((power + 1.2 x INT) x resonance, magic defense) x morale x variance`; costs MP; targets enemies in range 2-4. The AI casts damage skills when their score beats the best weapon attack. Skill preview appears in the info panel.

**Frost (v0.5.0).** Sigil of Frost (350 g; AP 70 / 220 / 520): Frost Shard at Lv1 (power 6, 3 MP, range 2-5), Frost Lance at Lv3 (power 11, 7 MP, range 2-5); both are `damage` skills like Ember Bolt, with longer reach and a different MP/power curve.

**Not implemented yet:** Limit-Break-style special attacks, party-wide sigil bonuses outside battle, summon-type sigils, class/weapon-type restrictions, sigil sale price that scales with level.

### 4.7 Party screen, shop and pre-battle panel (v0.5.0)
**Pre-battle panel.** Every battle now opens paused on a briefing panel (title, briefing text, gold) with two buttons: **Begin Battle** and **Party, Gear and Shop**. Closing the party screen rebuilds the battle from the party's current sheets, so gear and sigil changes apply immediately. The results screen offers Company management and Continue Journey; there are no separate grind or story-mode buttons. Loading a save is allowed while the panel is open.

**Party screen** (`PartyScreen`, built entirely in code, touch-sized buttons, landscape 1280x720). Left column: roster. Centre: the selected hero's character sheet (HP/MP, ATK, DEF, RES, ACC, EVA, CRIT, SPD, MOV, weapon range, the ten base stats with the gear bonus shown separately, skills with power and MP cost, EXP bar, promotion buttons when available). Right panel, three tabs:
| Tab | What it does |
|---|---|
| Equipment | Six slots. Tap a slot to see the bag items that fit it, each with a live stat delta ("ATK +3, DEF +1"; items that cannot be worn show the reason). Unequip returns the item to the bag. |
| Sigils | Weapon and armor sockets drawn as buttons ("Embers Lv2 / 35/70 AP"), linked sockets joined by "=", header with socket count and AP multiplier. Tap a socket for the sigil's level, AP to next level, effect and linked Tutor bonus; Remove, or choose another sigil from the bag. |
| Shop | Buy / Sell toggle. Stock from `data/shop.json` (Sethorn Market Stall: 19 items, 11 sigils). |

**v0.7.1 redesign (UX pass).** The first Party screen was cramped on a real phone (screenshot from the user: the Gold label wrapped one letter per line, the top bar ate half the height, and the three panels were squeezed into the lower half). New layout, same rules and same public API (`setup`, `open`, `close`, `closed`, `_on_*` handlers, `builds`, `message`, `changed`):
- **Top bar** (62 px): title, a Gold chip (never wraps) and a Close button. The phone Back button / Esc also closes the screen.
- **Roster**: one card per hero with a level badge, name, class and a green PROMOTE tag when a promotion is available; the selected card has a gold frame.
- **Sheet**: `<` and `>` buttons step through the roster without scrolling the list; EXP bar; HP/MP and nine combat numbers as stat tiles; the ten base stats as tiles that turn green or red when gear adds or removes points; skills as small boxes (name, then description); promotion buttons.
- **Equipment tab**: six slot cards (slot, item name in its rarity colour, item numbers); tap a slot to open the choices below it, each with its stat change in green (better) and red (worse), blocked items dimmed with the reason; Unequip; a read-only **Bag** list; "Open the Shop" shortcut when nothing fits.
- **Sigils tab**: socket cards with a level and AP line; the choices panel shows the sigil's level, effect and linked Tutor bonus, Remove, and the bag sigils as cards.
- **Shop tab**: Buy / Sell as segmented buttons; price on the right of each card (red with "need N more" when you cannot afford it). **Compare before buying:** tapping a gear card opens a panel with the stat change (green/red) if the selected hero wore it, in every slot it fits (both accessory slots), what it would replace, the reason when it cannot be used, and one line per other hero (`<` `>` on the sheet changes who is compared). Sigil cards show the effect and AP line. **Every buy and sell needs a Confirm press:** the opened card shows Cancel and a Confirm button ("Confirm: buy for 60 g" / "Confirm: sell for 30 g"; when gold is short the button is disabled and says how much is missing). State: `shop_pick`; handlers `_on_shop_pick`, `_on_confirm_buy`, `_on_confirm_sell_item`, `_on_confirm_sell_sigil`. The direct `_on_buy` / `_on_sell_item` / `_on_sell_sigil` handlers still act at once, so older tests are unchanged.
- **Message banner**: always visible; shows a hint for the current tab, a green line after a successful action and a red line after a refusal.
- **Scroll positions** of the roster, the sheet and the right panel are kept across rebuilds (equipping no longer throws you back to the top).
- **Touch scrolling (v0.7.3):** every card (roster, slots, gear choices, sockets, sigils, shop) is a `TapCard` (`scripts/ui/tap_card.gd`), not a Button. A Button swallows a finger drag that starts on it, so lists of full-width buttons were hard to scroll. A TapCard taps on a short press and scrolls the nearest ScrollContainer when the finger moves more than 12 px (the tap is cancelled); the mouse wheel works too. Panels, tiles and boxes are set to ignore the mouse after each build (`_relax_mouse`) so a drag that starts on them also scrolls. The few plain buttons left inside lists (Unequip, Cancel / Confirm, Promote, Remove) still take the drag.
- Colours, sizes and fonts are constants at the top of `scripts/ui/party_screen.gd`; `ItemInfo.delta_parts()` feeds the green/red deltas. Designed for 1280x720 and wider (minimum widths 250 + 400 + 460). Not run in Godot: check the layout on the phone.

**Shop rules** (`ShopSystem`, static; every call returns "" on success or a short reason). Buy price is the item's `price`; sell price is a flat 50% (`sell_ratio`). Only bag items can be sold (equipped items are not in the bag). Heirlooms and bound items can never be sold. Sigils sell at a flat price whatever their level, so a mastered sigil is worth the same as a fresh one; the real value of a sigil is the AP and the mastery copy.

**Tools.** `tools/gd_static_check.py` is a Python linter for the GDScript and JSON (no Godot needed). `tests/balance_report.gd` runs the AI against itself for every enemy group and a 60-battle grind curve (see SESSION_HANDOFF v0.5.0).


### 4.8 Protagonist creation foundation (v0.7.6)
The creator is being implemented as a data-driven setup for the campaign's protagonist (the existing `torren` identity remains the stable save/roster id). `data/character_creation.json` defines:
- Name (2–24 characters), presentation, face, hair, skin and build presets.
- Three origins: Fallen Heir (+1 LDR; Dunmarrow claim / sealed legacy tags), Border Ward (+1 VIT; marches-raised / roadwise tags), and Court Exile (+1 INT; court-educated / political-memory tags).
- Eight starting disciplines mapped to existing tier-one classes: Bladesworn, Outrider, Reedrunner, Candlemage, Wickkeeper, Cutpurse, Trailscout and Wallwright.
- Weapon preference choices constrained by the selected discipline.
- Four temperaments: Steadfast (+2 MOR), Keen (+2 ACC), Resolute (+1 VIT, +2 HP), and Cunning (+1 LCK, +1 EVA).

`CharacterCreation` (`scripts/core/character_creation.gd`) validates a profile against the data and builds a fresh protagonist definition from the existing Torren base definition. Origin and temperament bonuses are applied to base stats; creator choices are retained in a `creation` metadata block; the original source definition is not mutated. `GameData` loads the creator options, and headless tests cover defaults, valid creation, class selection, stat effects, incompatible weapon preferences, invalid names and source immutability.

**Scope of v0.7.6 (historical; superseded by section 4.9):** this checkpoint contained only the reusable data/rules foundation. The visual creator, campaign hookup and save migration were added in v0.7.7. Portrait/body sprite layers and gameplay use of origin tags remain unimplemented. Godot runtime execution remains unverified.


### 4.9 Interactive protagonist creator (v0.7.7)
The overworld HUD now has a **New Chronicle** entry point. It opens `CharacterCreator.tscn` as a touch-first overlay, leaving the current overworld in place until the player confirms or backs out. The creator exposes name, presentation, face, hair, skin, build, origin, starting discipline, compatible weapon preference and temperament. Invalid names or incompatible choices disable **Begin Chronicle** and show the reason.

A live geometric bust (`CharacterPreview`) reflects skin, hair, face preset, build, presentation silhouette and origin palette. The presentation choice subtly changes the jaw silhouette; weathered, soft, scarred and sharp face presets use distinct facial linework. This is a UI preview only; it is not a production portrait or sprite layer. The side summary shows presentation, build, origin, discipline, weapon preference and the origin/temperament stat bonuses. Discipline changes automatically move the weapon preference to the first compatible choice when necessary.

On confirmation, `GameState.new_game(profile)` validates and builds a fresh Torren definition from the original character data, then initializes the usual four-member starting party through `PartyState`. The protagonist's stable roster/save id remains `torren`; only that member's name, class, house, base stats and creator metadata change. Companions, shared inventory, gold and starting sigils remain from `campaign_start.json`. Back cancels without replacing the current in-memory party. Confirming a new chronicle replaces the in-memory party but does not delete existing save files.

Battle manual saves and autosaves now include `creation_profile`. `SaveSystem.SAVE_VERSION` is 2; the v1→v2 migration adds an empty profile while preserving the existing battle and party payload. The saved `PartyState` already retains the protagonist's selected name, class and base stats. Creator choices are preserved separately so appearance and origin choices can be reconstructed. Weapon preference now selects the protagonist’s equipped common starting weapon: sword, axe, spear, bow, crossbow, staff, mace or dagger. The selected item is stored on the protagonist equipment block and the exact item id is retained in creator metadata. All eight preferences use the same common-tier starting budget; the existing shared inventory and companion loadouts remain unchanged. Origin tags are recorded but do not yet trigger story branches. World position/location and the full campaign still are not independently saved outside the existing battle save flow.

**v0.7.8 preview polish:** presentation now affects the geometric head/jaw silhouette, and all four face presets have distinct facial details. A headless test guards the presentation silhouette mapping.

**v0.7.9 weapon-preference loadouts:** every compatible creator weapon preference now equips a matching common-tier weapon on the protagonist. Added spear, crossbow, staff and dagger definitions/items; sword, axe, bow and mace reuse existing common gear. The selected item is retained in creator metadata. Companion loadouts and shared starting inventory remain unchanged. Runtime balance and Godot tests are still pending.

**Validation status:** `python3 -I tools/gd_static_check.py` reports 0 errors / 0 warnings and `python3 tools/build_apk.py --check` passes the offline preflight. The GDScript suite includes creator campaign/save/migration checks and a preview mapping check, but it has not been executed because no Godot binary is available. Scene import, rendering, touch layout and in-game flow remain unverified.

---

## 5. Recruitment System

### v0.11.0 — Recruitment and loyalty foundation
All 24 Wave-1 named characters now have data definitions (four starting members and 20 recruitable profiles). The six original recruit definitions were aligned to their intended classes and weapons; fourteen additional recruits were added. Six muster halls expose the full Wave-1 roster. Recruitment is data-driven and checks duplicate state, gold cost, required world flags and companion prerequisites before adding a character and recording the one-time recruitment flag. The party screen displays a 0–100 loyalty value and its bond band. Save schema v4 persists loyalty and migrates schema-v3 members to neutral 50.

**Still outstanding:** authored personal quest chains, the Act II duel and Act IV unlock event, weekly wages/calendar, loyalty gains/losses from story and battle events, and desertion at the end of a week. The three Act IV recruits remain gated by `act_4_unlocked`; do not claim their story content is playable yet.

**Target roster:** 80 recruitable characters (1 protagonist + 79), delivered progressively (24 in Milestones 3–4, +56 by Milestone 7). Roster list in section 12.

**Character data schema** (`data/characters.json`):
`id, name, portrait, sprite_set, personality[], backstory, class_id, level, stats{}, growth{}, preferred_weapons[], abilities[], recruit{method, conditions, quest_id}, relationships[{id, type, value}], loyalty, morale, dialogue_set, events[], house, age, birth_year, traits[]`

**Recruitment methods**
| Method | Example |
|---|---|
| Story | Joined during a chapter |
| Side quest | Rescue a smith from a creditor |
| Battle victory | Win a map without losing a hero |
| Defeated commander | Spare a rival knight instead of executing |
| Political negotiation | Win a noble house's favour (Renown + reputation check) |
| Rescue prisoner | Break out of a dungeon |
| Personal mission | Finish their quest chain |
| Hidden location | Explore ruins on the world map |
| HQ facility | Tavern rumours, Recruitment Hall, Library, Siege Workshop |

**Loyalty (0–100):** raised by fair pay, victories together, personal events, gifts; lowered by deaths of friends, unpaid wages, ordering morally opposed actions. Loyalty < 25 → may desert at week end; ≥ 80 unlocks the character's final ability/ending epilogue.
**Relationships:** pairs/groups with Bond levels grant battle bonuses when adjacent (e.g. Sela + Bram: +5% hit when adjacent).

---

## 6. Platoon and Army Management

### 6.1 Platoon types
Infantry · Heavy Knight · Cavalry · Archer · Mage · Reconnaissance · Medical · Siege · Elite Guard · Mixed Mercenary.

### 6.2 Platoon structure
- **Size:** 3–9 heroes. Each platoon also has a **troop count** (abstract soldiers, 40–150) that fights alongside the heroes in army battles and is replenished at Barracks.
- **Slots:** Commander (1), Vanguard (1–2), Flank (1–2), Rearguard (1), Support (1–2), Specialist (0–2).
- **Fields:** name, emblem, commander, members, composition, combat strength, morale, leadership, movement, specialisation, formation, equipment, experience, loyalty.

### 6.3 Two separate aptitudes
Every character has **Fighting Power (FP)** and **Command Aptitude (CA)**:
```
FP = 0.4·STR + 0.2·DEX + 0.2·VIT + 0.1·SPD + 0.1·level   (magic users use INT in place of STR)
CA = 1.2·LDR + 0.3·INT + 0.2·command_experience + trait_bonus
```
A famous swordsman may have FP 40, CA 8 — a great duelist and a poor commander. A retired strategist may have FP 12, CA 35. Position effectiveness multiplies the contribution: Commander slot weights CA ×1.0 and FP ×0.2; Vanguard weights FP ×1.0; Support weights INT/skills; etc.

### 6.4 Platoon statistics
```
combat_strength = Σ(member_FP × slot_weight × class_synergy) × formation_mult × (1 + 0.01·CA_commander)
leadership      = CA_commander + 0.25 · Σ CA_officers
morale          = avg(member MOR) + commander_CA/5 + loyalty_bonus
movement        = slowest member (cavalry +2, heavy armor −1)
specialisation  = platoon type; +10–20% effect when ≥ 60% of members match the type
```

### 6.5 Formations
Line (balanced) · Wedge (charge +, defence −) · Shield Wall (defence +, mobility −) · Square (no weak facing) · Skirmish (ranged +, melee −) · Column (movement +) · Crescent (flank +) · Loose (anti-magic/archer).

### 6.6 Management actions (Barracks UI)
Create/disband, rename, appoint commander, drag-and-drop members between slots, assign specialists, promote officers (grants CA), set formation, train (Training Ground), inspect any member. Warnings appear for invalid compositions (e.g. no commander).

---

## 7. Large-Scale Army Battles

A separate mode on a coarse 16×10 grid (hills, forests, rivers, walls). Each platoon is a token with troops, morale, cohesion and stamina.

**Turn structure: Order Phase → Resolve Phase**
1. *Order phase:* player and AI queue one order per platoon: Advance, Charge, Hold, Volley, Cast, Rally, Retreat, Flank, Use Commander Ability.
2. *Resolve phase:* orders resolve by platoon movement speed; contact triggers an engagement.

**Engagement resolution (simplified)**
```
power      = combat_strength × order_mult × formation_mult × terrain_mult × facing_mult × charge_mult
casualties = troops_def × clamp(power_att / (power_att + power_def) − 0.35, 0.02, 0.5)   # attacker side shown, symmetric for defender
morale hit = casualties% × 0.5 + (flanked ? 10 : 0) + (commander_down ? 25 : 0)
```
- Platoons whose morale ≤ 0 **break** and flee; broken platoons can be routed down for extra casualties.
- Heroes inside a platoon can fall: roll "Grievous Wound" (retreat, injury) or death (if permadeath is enabled; protagonist is protected by "Last Stand").
- **Commander abilities** use Command Points (CP): Rally, Forced March, Hold the Line, Volley Order, Heroic Charge, Fire Arrows, Inspire. Cooldowns apply.
- **Pivotal Engagements:** at key spots (bridge, gate, enemy general) the player can enter Grid Mode with the heroes of the platoons involved; the result modifies the army battle.
- **Siege:** gates, walls, siege weapons (ladder, ram, ballista, trebuchet), defenders gain wall cover; engineers/Siege platoons change the pace.

**Strategic consequences:** casualties reduce troop pools, victories shift territory and house reputation, routed enemy commanders can be recruited or executed (affecting loyalty and story).

---

## 8. Castle Headquarters — Kaer Sethorn

The player starts with ruins; facilities are unlocked by story chapters and Renown, built with gold/materials/weeks. The keep art changes by tiers (ruin → patched → restored → proud), and NPC population grows (soldiers drilling, merchants, children).

| Facility | Unlock | Function (level 1 → 3) |
|---|---|---|
| Barracks | Prologue | Manage roster and platoons; capacity 3→6 platoons; troop replenishment |
| Training Ground | Ch. 1 | Weekly training: +EXP or skill practice; platoon drills raise cohesion |
| Blacksmith | Ch. 1 | Repair/upgrade gear +1…+5; unlock Fine → Masterwork crafting |
| Infirmary | Ch. 1 | Heals wounded between battles; prevents lasting injuries; Battle Medic synergy |
| Tavern | Ch. 1 | Rumours → recruitment leads, side quests; hire mercenaries |
| Market | Ch. 2 | Buy/sell, caravans, seasonal stock |
| Recruitment Hall | Ch. 2 | Spend Renown to approach nobles/commanders; hire troops |
| War Room | Ch. 2 | Missions, strategic map, scouting reports, army battle prep |
| Stable | Ch. 3 | Cavalry units, mounts, speed upgrades |
| Library | Ch. 3 | Research tree: tactics, logistics, medicine, siegecraft |
| Mage Tower | Ch. 4 | Spell research, enchant gear, mage recruits |
| Siege Workshop | Ch. 4 | Build ballistae/rams/trebuchets for army and siege battles |
| Residential Quarters | Ch. 2 | Housing for family, marriage, heirs, mentors (Legacy Mode) |

Weekly upkeep scales with buildings and roster. Raids on the keep can occur as optional defence battles.

---

## 9. Generational System (Legacy Mode — optional)

Toggle at New Game (and later in Options for future events). When off, characters do not age or die of age; battle death still follows the permadeath setting.

- **Ageing:** time advances by the campaign calendar. Stats peak at ages 25–40; physical stats decline gradually after 50, INT/LDR keep rising.
- **Marriage and children:** available to eligible characters with a high Bond and Residential Quarters. The protagonist's marriage affects house alliances.
- **Heirs:** a child reaches age 16 after ~16 in-game years. The Chronicle chapters after Act III can skip time in jumps of 2–5 years, so the player does not wait in real time.
- **Inheritance:** an heir receives (a) stat bonuses from both parents (~20% of parental growth), (b) up to 2 learned skills chosen from parents, (c) 1 inherited trait, (d) family relationships (loyalties and grudges), and (e) a chance at a **Bloodline Ability** unique to the family.
- **Retire and mentor:** aged characters retire from combat but remain at HQ as **Mentors**, granting EXP/skill bonuses to a chosen student or platoon.
- **Death and legacy:** a hero's death (battle or age) creates a **Legacy entry** (memorial in the keep's Hall, an Heirloom to pass on, relationship effects). If the protagonist dies with no heir, the campaign ends.
- **Not mandatory:** only the Dunmarrow line and selected characters can have heirs. Non-family characters are optionally generational.

---

## 10. Main Storyline

**Setting:** Eldrimar, a feudal kingdom founded on the *Covenant of the Seven Flames*, sworn by seven great houses to protect the throne. King Osric IV has died suddenly. The seventh house, **Dunmarrow**, the Oath's keeper, was destroyed when Lord Edmer Dunmarrow was executed for treason weeks earlier.

**The secret.** Dying and without a strong heir, Osric wrote a **Hidden Codicil** dissolving the single crown into a council of the seven houses. Edmer, the keeper, held the sealed Hidden Codicil. Lord Regent **Maelor Brennhallow**, believing only a strong crown prevents civil war, had Edmer executed and the Hidden Codicil suppressed. He is not a villain: he is trying to save the realm in a way that he knows is a lie.

**Structure (prologue + 5 acts + epilogue)**
| Act | Title | Beats |
|---|---|---|
| Prologue | Smoke on the Wind | Torren, Bram, Sela and Brother Wystan escape the burning estate, reach Kaer Sethorn, fight roadwolves (tutorial battle). |
| I | Cold Hearth | Rebuild the keep; first recruits; tax collectors; discover Edmer's letter naming a missing witness. |
| II | Broken Seals | Travel to Orrowen and Ysmark; witnesses; the first army battle; join or oppose a house. |
| III | The River Campaign | Vessmoor duel, Tarnholt trial, siege of Brinegate; war escalates; time skip in Legacy Mode. |
| IV | Winter of Knives | Betrayals; Quillon's library holds the Hidden Codicil's seal; loyalties tested; a beloved ally may fall. |
| V | The Kindling | Final campaign for Aurelmont; the Hidden Codicil is read, burned, or weaponised; choose the realm's future. |
| Epilogue | The Chronicle | Outcomes by faction reputation, loyalty, deaths and heirs. |

**Multiple endings**
1. **Restored Crown:** Dunmarrow takes the throne (high Renown, Brennhallow defeated).
2. **Council of Seven:** follow the Hidden Codicil (alliances with most houses).
3. **Iron Regency:** side with Brennhallow (stability, cost in freedom).
4. **Mercenary Principality:** carve out your own domain (independent route).
5. **Embers:** destroy the Hidden Codicil and let the realm burn (dark route).
6. **Legacy ending:** an heir completes what the protagonist could not (Legacy Mode).

**Antagonists are not purely evil:** Brennhallow (order at any cost), Ysmark's Lady Sabela (profit as peace), Tarnholt's Archprelate Anselm (faith used as a leash), Vessmoor's Lord Casimir (honour that kills).

---

## 11. World and Faction Design

**Regions:** Sethmarch (home, Kaer Sethorn) · Orrowen Weald (forest, yeomen) · Ysmark Coast (Brinegate, ports) · Vessmoor Plains (Cindermead, horse-lords) · Quillon Heights (tower-city, scholars) · Tarnholt Cloisters (monasteries, relic roads) · Brennhallow Highlands (Brennhold, fortress marches) · Aurelmont (capital).

| House | Seat | Identity | Strengths | Heraldry | Recruits |
|---|---|---|---|---|---|
| Brennhallow | Brennhold | Order, discipline, regency | Heavy knights, siege | Iron tower on black | Knights, engineers |
| Ysmark | Brinegate | Trade, ships, money | Gold, spies, crossbows | Silver scales on blue | Bards, thieves, crossbowmen |
| Quillon | Quillon Tower | Knowledge, magic, secrecy | Mages, research | Open book and star on violet | Mages, scholars |
| Vessmoor | Cindermead | Honour, horses, duels | Cavalry | Red horse on gold | Cavaliers, duelists |
| Tarnholt | Cloisters | Faith, healing, relics | Priests, paladins | White flame on grey | Clerics, medics, paladins |
| Orrowen | Orrowen Hall | Yeomen, forests, freedom | Archers, scouts | Green oak on brown | Archers, scouts |
| Dunmarrow (fallen) | Sethorn | Keepers of the Oath | — | Burned crown on charcoal | Player's house |

**Reputation (−100…+100) per house** gates quests, recruitment and endings. Each major decision shifts relations between houses (e.g. sparing a Brennhallow commander raises Tarnholt's opinion and lowers Vessmoor's).

---

### 11.1 Overworld: the Sallow Marches (v0.6.0, Milestone 7 first step)
**What "open world" means here:** a free-roam overworld, not a seamless 3D-style open world. The player walks anywhere on a 64x48 tile map (48 px tiles, top-down), battles stay on the tactical grid. `data/world.json` holds the seed, size, places and roads; `WorldMap` (scripts/world/world_map.gd) generates land from deterministic value noise (water, ford, grass, forest, hill, mountain; roads and bridges carved between places; a meadow cleared around each place; mountain wall at the edge). Same seed = same land.
- **Movement:** tap to walk to a spot, hold and drag to steer; collision uses the four corners of the walker. Speed by terrain: road 1.4, bridge 1.2, grass 1.0, hill 0.7, forest 0.6, ford 0.5, water and mountain blocked.
- **Ambushes:** walking outside the safe radius (5 tiles around the keep and villages) adds distance x terrain danger (forest 1.6, ford 1.2, grass/hill 1.0, road/bridge 0.3). When the total passes a random threshold (900-1800) a roadwolf skirmish starts (`EncounterBuilder`), then the battle scene opens; "Back to the World" returns to the same spot.
- **Places** (`kind`): keep and village open Party, Gear and Shop; ruin gives a one-time gold purse; camp starts the story battle (`battle_01`) and shows as cleared after a victory (`GameState.world_flags`).
- **HUD:** top-left region/terrain/gold, top-right Party, bottom-left minimap with places and the player dot, bottom-centre "Enter <place>" prompt, top-centre ambush banner. Safe-area inset as in the battle HUD.
- **Hand-over:** `GameState.start_battle_from_world(def)` + `take_pending_battle()`; `GameState.world_pos` remembers where the player stood.
- **Not yet:** full free-roam campaign saving/loading, day/night, weather, roaming patrols, fog of war, independent regional maps, travel time in weeks and the HQ screen. SaveSystem v3 now carries regional flags and overworld hand-off context inside battle saves only (section 11.5).

### 11.2 Towns and building interiors (v0.7.0)
Entering a place with a `town` on the overworld opens its own map (`Location.tscn`, `location_scene.gd`); walking into a door opens the building interior (a new map, same scene); walking onto the town's exit (E, south edge) returns to the overworld just south of the place. Maps live in `data/locations.json` as rows of characters (legend in `scripts/world/local_map.gd`: grass, path, wood floor, carpet, stone wall, tree, fence, pond, roofs, building front, doors 1-4, exit E, bed, shelf, counter, table, hearth, barrel, pillar, banner, crate). Each map has `entry`, `doors` (target map + spawn cell) and `spots` (people and objects).
- **Maps now:** Sallow Crossing (inn The Ford and Flagon, Oswin's Goods shop, Elder Hale's house) and Kaer Sethorn (Great Hall, Barracks). 7 maps in total.
- **Spots:** `text` (talk: rumours and hints), `party` (opens Party, Gear and Shop). The shop counter and the war table in the Great Hall are the two places where the party screen opens. **The overworld Party button was removed**: managing the company now needs a town.
- **Controls and look:** same tap and drag walking as the overworld, collision on tiles, camera clamped to the map (interiors are zoomed to fit), NPCs are the Soldier sprite tinted per person, a gold marker floats over every spot, the prompt button says Talk to / Use plus the name.
- **Adding a map:** add rows, doors and spots to `locations.json`, give the overworld place a `town` id. `LocalMap.validate()` (run by the tests) checks size, tiles, doors, spawns, reachability and return doors.
- **Not yet:** saving the current town and house, day/night, separate shop stock per town, quest chains from NPCs, more Kaer Sethorn facilities and full campaign save/load. Inn rest and recruitment are now implemented in the Sethmarch Frontier (section 11.5).

### 11.3 Four-continent campaign and travel progression (v0.7.12 design foundation)
The campaign spans four large continents connected through a gradually expanding travel network. This is a regional world-map structure rather than one enormous seamless map: each region is a free-roam field map with its own towns, dungeons, roads, encounter tables and exits. The player sees a compact route map when choosing a known destination, then explores the region on foot when arriving. This keeps the FFVII-style sense of crossing a vast world while preserving Suikoden-II-like town, recruitment and story hubs.

| Continent | Campaign role | First access | Core identity |
|---|---|---|---|
| Eldrimar | Crown Continent; starting homeland and main political conflict | Act I | Sethmarch, Orrowen Weald, Vessmoor Plains, Quillon Heights, Tarnholt Cloisters, Brennhallow Highlands and Aurelmont |
| Thalassar | Shattered Isles; naval routes, ports and wreck-dives | Act II, after securing passage | Brinegate Coast, Isles of Vey and Kelpward Reach |
| Varakhan | Red Expanse; caravan routes, steppe clans and buried empires | Act III, after a charter | Serekh Desert, Kharad Steppe and Obsidian Crown |
| Nhalor | Far North; frozen roads, giant ruins and the late-game revelation | Act IV, after opening the northern pass | Skeld Tundra, Aurora Reach and Old Nhal |

**Travel ladder:** (1) walking and roads inside the starting region; (2) carts and guarded road convoys between nearby regions; (3) river barges and ferries for controlled crossings; (4) charter ships for Thalassar and coastal optional landfalls; (5) caravan charters for Varakhan; (6) mountain pass opening for Nhalor; (7) a late-game airship linking discovered sky docks. New transport expands the map but never skips undiscovered destinations, story gates or required character/quest flags. Travel consumes campaign time only after the calendar and world-save systems are implemented; until then it must not silently advance weeks.

**Region content targets:** each major region should have one primary hub town, two or more secondary settlements, at least two authored dungeons, one optional landmark, one recruit or companion quest, one regional conflict and one route-gate quest. Towns are functional hubs (inn/rest, market, recruitment/dialogue, local quest board) rather than decorative stops. Dungeons need a distinct traversal gimmick, a meaningful reward, a boss or climax, and a return/exit path.

**Data blueprint:** `data/continents.json` records the four continents, 16 subregions, 40+ named settlement/dungeon hooks, travel modes and route gates. It is content planning data only: current runtime still uses `data/world.json` and `data/locations.json`. Do not present a listed destination as playable until its map, encounter set, quest flags, entry/exit links and regression tests exist. Keep the Sallow Marches as the playable starting slice.

**Save/travel rules:** future campaign persistence must store continent id, region id, local map id, player tile, discovered route nodes, unlocked transport tiers, visited landmarks, dungeon completion flags and travel-calendar state. Implement this as an explicit campaign-save schema and migration. SaveSystem v4 carries regional context and character loyalty, but it is not a replacement for the full campaign calendar, local town/interior position, route discovery and quest-state persistence described above. Preserve sequential migration from v1 and v2. Fast travel is available only between discovered hubs and must preserve the party's current roster/equipment.

**Originality guardrail:** use only broad genre-level conventions (regional world maps, vehicles, ports, recruitment hubs and gated exploration). All geography, routes, characters, quests, visual designs and story beats remain original.

### 11.4 Sethmarch first regional expansion (v0.7.13)
The playable Sallow Marches overworld gained three road-connected ruin landmarks: Sunken Tollhouse (45 gold), Hollowroot Warren (originally 75 gold) and Warden's Barrow (90 gold). The first implementation used one-time `kind: ruin` searches. In v0.7.14, Hollowroot Warren is upgraded to a traversable dungeon with a 120-gold cache and a boss; its former surface-search reward is superseded. Sunken Tollhouse and Warden's Barrow remain searchable landmarks.

### 11.5 The Sethmarch Frontier: Orrowen and Vessmoor (v0.7.14)
The first expanded regional network is now connected to the existing Sallow Crossing field map. The player can follow the Greenward Gate north-east into **Orrowen Weald** or the Vessmoor Causeway south-east into **Vessmoor Plains**. Interacting with either arch records a one-time passage flag, while the roads remain physically continuous on the same 64×48 Eldrimar overworld; no disconnected map hop interrupts the journey. The overworld HUD names the current subregion.

**Road network and settlements**
- Orrowen: Thornmere (regional hub), Foxglove and Elderbough. The roads branch from the Greenward Gate and continue between each settlement and the Bell Under Leaves dungeon.
- Vessmoor: Cindermead (regional hub), Redwater and Milefort. The Vessmoor Causeway links the settlements and the Kingsroad Catacombs.
- Sethmarch's existing Sallow Crossing, Kaer Sethorn, Old Watchtower, Roadwolf Camp, Sunken Tollhouse and Warden's Barrow remain in place. The two searchable ruins retain their one-time rewards; Hollowroot Warren is upgraded into a traversable dungeon.

**Functional town services**
- Each of the six new settlements has its own town map and inn, market and muster-hall interiors.
- Inns charge 20 gold and restore the company's morale to 70 before the next battle.
- Markets open the existing Party, Gear and Shop screen, reusing shared inventory and stock rules.
- Recruitment halls offer one named recruit each: Lucan Thorne, Old Brisa, Kestrel, Anselm Pike, Petra Quill and Dorian Vask. Recruitment adds the character to the live PartyState roster and marks a one-time world flag.
- Town doors lead to their own interiors; the town exit returns to the overworld.

**Dungeons, bosses and rewards**
- Hollowroot Warren, The Bell Under Leaves and Kingsroad Catacombs each have a distinct explorable local map, a one-time treasure cache and a boss encounter.
- Boss battles use dedicated data files, named boss characters and dungeon-specific victory reports. Victory writes the dungeon's clear flag; treasure caches pay 120 gold once each. Enemy EXP/AP/gold still flows through the existing battle reward system.
- The dungeon entrance on the overworld opens the corresponding dungeon map; the player must explore to the cache and guardian rather than trigger a battle from the world-map marker.

**Persistence and validation boundary**
- SaveSystem v3 adds regional world flags, overworld position and the from-world hand-off to existing battle save/autosave payloads. Sequential v1→v2→v3 migration preserves existing party and battle data.
- This is not yet the full free-roam campaign save system: town position, current interior, calendar, quest state and automatic overworld saves remain future work. Recruit and dungeon flags are held in memory until a battle save is written; a dedicated campaign save/load UI is still required.
- Regression assertions now cover the new road graph, dungeon map/battle references and dungeon map presence. Per the user's instruction, do not run Godot import, the headless test suite, balance simulation or device tests until explicitly requested. No runtime validation is claimed.

## 12. Character Roster

**Wave 1 (24 named characters; designed for Milestones 3–4).** Wave 2 (+56) is designed during Milestone 7 using the slot framework below.

| # | Name | Class (start) | Origin | Hook / personality | Recruitment |
|---|---|---|---|---|---|
| 1 | Torren Dunmarrow | Swordsman → Commander | Dunmarrow | Protagonist; guilt and duty; name/appearance selectable | Start |
| 2 | Sir Bram Vosk | Knight | Dunmarrow | Veteran retainer, stern, loyal, secretly guilty | Start |
| 3 | Sela Wrenfield | Archer | Orrowen | Wry poacher turned scout | Start |
| 4 | Brother Wystan | Priest | Tarnholt | Gentle novice who is losing faith | Start |
| 5 | Edda Stonehand | Engineer | Brennhallow | Gruff siege-wright, hates waste | Rebuild workshop |
| 6 | Joss Harrow | Thief | Ysmark | Charming smuggler, low loyalty | Tavern rumour |
| 7 | Lady Isaure Vessmoor | Cavalier | Vessmoor | Proud disinherited heir | Act II duel |
| 8 | Bram Cullen | Berserker | Neutral | Ex-pit fighter, gentle off-field | Rescue from debtors' prison |
| 9 | Verra Nightsong | Bard | Ysmark | Spy-minstrel, double agent | Negotiation |
| 10 | Tomas Wren | Scout | Neutral | Teen messenger, fearless, impulsive | Side quest |
| 11 | Orlan Pike | Fire Mage | Quillon | Exiled professor, absent-minded | Library |
| 12 | Sister Odalys | Cleric | Tarnholt | Ex-inquisitor seeking atonement | Tarnholt trial |
| 13 | Dorian Vask | Crossbowman | Neutral | Mercenary captain, pragmatic | Negotiation |
| 14 | Ysolde Marrow | Ice Mage | Ysmark | Merchant daughter, strategic mind | Ysmark politics |
| 15 | Garrick Holt | Heavy Knight | Brennhallow | Defeated commander, rigid honour | Spare after battle |
| 16 | Petra Quill | Battle Medic | Neutral | Field surgeon, blunt | Plague ward quest |
| 17 | Kestrel | Assassin | Unknown | Silent, bound by old contract | Hidden location |
| 18 | Lucan Thorne | Longbow Master | Orrowen | Yeoman lord, steady | Orrowen favour |
| 19 | Ser Willem Roake | Duelist | Vessmoor | Honour-bound, loses duel gracefully | Duel |
| 20 | Anselm Pike | Lancer | Neutral | Veteran sergeant, cynical father figure | Barracks event |
| 21 | Old Brisa | Cleric | Neutral | Herbalist, village elder | Village quest |
| 22 | Lord Corwin Brennhallow | Knight | Brennhallow | Regent's son, conflicted | Late Act IV |
| 23 | Seraphine Tarnholt | Paladin | Tarnholt | Saint-in-waiting, doubts miracles | Act IV |
| 24 | Ilyan Voss | Battle Mage | Quillon | Ex-guard of the tower, loyal | Mage Tower |

**Wave 2 slot framework (56):** ~8 per house (6 houses = 48) + 8 neutral/hidden wanderers. Slot template: class family, rarity, recruitment method, personal quest, relationship edges, one Heirloom candidate. Rarity: Common 55% · Fine 30% · Rare 12% · Legendary 3%.

**Distinctness rules:** every character has (a) a unique active ability, (b) one personality-driven dialogue branch set, (c) a platoon-role preference, (d) a relationship with ≥ 2 others.

---

## 13. Sprite and Animation Specifications

**Visual direction:** dark medieval fantasy, muted palette, hand-drawn pixel art (no AI/ripped assets); distinct silhouettes by class (helm shapes, weapons, capes).

| Item | Spec |
|---|---|
| Tile | 64×32 px isometric diamond; height step = 16 px |
| Unit sprite canvas | 48×48 px, feet anchored at bottom-centre, 2 art directions (SE, NE) mirrored for SW, NW |
| Portrait | authored 128×128 px, shown at 2×; 4 expressions (neutral, happy, angry, sad) for key characters |
| Large unit (cavalry) | 64×64 px canvas |
| Platoon token (army mode) | 32×32 px banner/emblem + 8 troop dots |
| UI icons | 24×24 px class and status icons |
| Palette | master palette of 32 colours; per-faction hue-swap shader |

**Animation sets (frames @ fps)**
| Animation | Frames | FPS | Loop |
|---|---|---|---|
| Idle | 4 | 6 | yes |
| Walk | 6 | 10 | yes |
| Attack (melee) | 5 | 12 | no |
| Attack (ranged/draw) | 6 | 12 | no |
| Defend / block | 3 | 10 | no |
| Hit | 2 | 10 | no |
| Cast | 6 | 10 | no |
| Victory | 6 | 8 | yes |
| Defeat / death | 5 | 8 | no |

**Paper-doll layers:** body, hair, armor, helm, weapon, off-hand, cape; each layer shares the same animation timings so any equipment combination works.

**Master palette (starter 16 of 32):** `#0e1213 #1d2a27 #2f4a38 #40714f #6f8f5a #a2a678 #d5c897 #efe3bd #5b4636 #8a6b4a #b78b52 #3e4552 #6a7380 #9aa3a8 #8c2f2a #c4642d`.

**Environment tiles:** grass, forest, road, river, bridge, hill, ruins, castle floor/wall/gate, village, fortress. **UI:** parchment panels, heraldic frames, class icons, platoon emblems, battle HUD, recruitment/headquarters/world-map screens.

**Naming:** `unit_<id>_<anim>_<dir>.png`, atlas per character, `tile_<terrain>_<variant>.png`, `portrait_<id>_<expr>.png`, `icon_<name>.png`. Assets live under `assets/` (sprites, tiles, ui, audio).

---

## 14. Mobile UI Design

- **Layout:** landscape 1280×720 base, `canvas_items` stretch, `keep` aspect with safe-area margins; minimum touch target 48 dp (about 9 mm), spacing ≥ 8 dp; text ≥ 16 px at base size.
- **Battle HUD:** top bar (turn timeline of 8 portraits, weather icon), left panel (selected unit: name, class, HP/MP, morale, status icons), bottom-right action buttons (Move / Attack / Skill / Item / Wait) and Confirm/Cancel, top-right Menu (zoom, Save, Load) with the Auto Battle toggle directly beneath it (section 3.12). Attack preview badge shows hit %, damage range and flank/rear/height icons.
- **Gestures:** tap = select/preview; second tap or Confirm = commit; long press = inspect; drag = pan; pinch = zoom; two-finger tap = cancel. All gestures have on-screen alternatives (zoom ± buttons).
- **Management screens:** card-based roster lists, drag-and-drop platoon editor with large slots, bottom-sheet inspectors, tabs for Stats / Equipment / Skills / Relationships.
- **Screens:** Title, Save Slots, HQ map, Barracks, Platoon Editor, Character Sheet, Equipment, Blacksmith, Market, Recruitment Hall, War Room (world map), Dialogue, Battle HUD, Army Battle HUD, Results, Options.
- **Implemented in v0.5.0:** the pre-battle panel (Begin Battle / Party, Gear and Shop) and the combined Party screen (roster, character sheet, Equipment / Sigils / Shop tabs); see section 4.7. Until the HQ exists these are reached from the pre-battle panel and the results screen. The party screen is untested on a real touch device.
- **Accessibility and battery:** colour-blind-safe markers (shape + colour), text scale 100–150%, haptics toggle, Auto Battle toggle, 30/60 fps toggle, battery saver (30 fps, reduced particles), no background processing while paused.

---

### 14.1 Battle HUD layout (v0.5.4)
Base 1280x720, landscape, everything inside `hud_root` which is inset by the phone safe area (notch, rounded corners; zero on desktop). Minimums: body text 18-22 px, buttons 64-84 px high (about 7-8 mm on a phone). Panels are parchment-dark with a gold border.
- Top-left: unit card (name, class, HP/MP, ATK/DEF/SPD/MOV, weapon, terrain). Top-centre: turn order (8 cells, 62x50). Top-right: `-` `+` `Menu`, and the Auto Battle toggle. `Menu` opens a popup with Save, Load, Close.
- Bottom-left: battle log (4 lines). Bottom-right: Move, Attack, Skill, Wait / End (4 buttons only). Bottom-centre: preview panel (move cost, hit/crit/damage, flank/rear/height tags) with big Confirm and Cancel under it.
- Result and pre-battle overlays: the text scrolls inside a fixed-height box and the buttons sit in a grid under it, so they can never be pushed off screen.
- Non-interactive panels ignore touches, so the map can be dragged and tapped underneath them. In-world unit names, HP bars and damage numbers are larger.

### 14.2 Art direction and assets (v0.6.1)
**Direction (from the owner's reference images):** pixel-art medieval tactics. Readable silhouettes, muted earthy ground colours, strong team colours (player blue, enemy red), heavy-armour knights with shields, chunky buildings with clear roofs, a battered low-fantasy mood (Battle Brothers / Tiny Swords / classic HoMM feel). References are for style only; nothing was copied from them.
**In the game now:** `Art` (scripts/ui/art.gd) loads sprites with a fallback to the old drawn shapes. Battle: Tiny RPG Soldier (player side) and Orc (enemy side), idle/walk/attack/hurt animations (attack and hurt play on `unit_acted`), team-colour ring under each unit, sprites flip with the facing. Overworld: the Soldier walks; trees, rocks and the keep, village, ruin and camp are sprites rendered from the 3D packs by `tools/render_sprites.py`, drawn back to front.
**Licences:** see assets/art/CREDITS.md. Nature kit is CC0; the voxel buildings and the Tiny RPG sheet have no licence file and must be checked before release; Modern Interiors (non-commercial, no edits) is not used.
**Ideas taken from the references, not built yet:** a Choose Formation screen before battle (wedge, battle line, vanguard variants, delegate to captains); one sprite set per class (knight with shield, archer, mage, cleric, cavalry) instead of Soldier for everyone; a cliff and water edge on the overworld; isometric terrain blocks with height shading in battle; ruined-building and camp props for ambush sites.

## 15. Offline Technical Architecture

**Engine:** Godot 4.2+, GDScript, GL Compatibility renderer (broadest mobile support). The exported Android manifest must **not** request the INTERNET permission, which guarantees there is no network usage.

**Autoloads (singletons):** `GameData` (read-only database), `SaveSystem` (slots/integrity), later `GameState` (runtime campaign state), `EventBus` (signals), `Audio`, `Settings`. (Until the `Settings` autoload exists, the battle scene reads and writes `user://settings.cfg` itself with `ConfigFile`; currently only `[battle] auto_battle`. Move this into `Settings` in Milestone 9/10.)

**Static helper classes (v0.5.0, no autoloads, so tests can use them directly):** `EncounterBuilder` (skirmish groups), `ShopSystem` (buy/sell rules), `ItemInfo` (text for stats, items, sigils, skills and stat deltas). `PartyScreen` reads no autoloads: its caller passes the party, the database and the shop through `setup()`.

**Runtime state (v0.3.0):** `PartyState` (roster of `CharacterSheet`s, shared inventory, gold; pure data, headless-testable) is owned by the `GameState` autoload. Save payload is now `{ battle, party }`; saves without `party` (v0.2) still load and keep the current party. `campaign_start.json` defines the starting party, gold and inventory.

**Data-driven content (all local JSON, loaded at boot):** `classes.json`, `terrain.json`, `weapons.json`, `characters.json`, `battles/*.json`, later `items.json`, `skills.json`, `quests.json`, `dialogue/*.json`, `platoons.json`, `facilities.json`. Strings are keyed for later localisation.

**Folder structure**
```
Kindlewake/
├─ project.godot
├─ export_presets.cfg   Android export preset (APK)
├─ Build_APK.bat    double-click to build dist/Kindlewake.apk (Windows)
├─ Main.tscn
├─ README.md
├─ .github/workflows/build-apk.yml   cloud APK build
├─ docs/            GDD.md, SESSION_HANDOFF.md, CONTINUATION_PROMPT.md, BUILD_APK.md
├─ data/            classes, terrain, weapons, skills, characters, items, sigils, encounters, shop, campaign_start (.json), battles/*.json
├─ scripts/
│  ├─ core/         game_data.gd, save_system.gd, game_state.gd (autoloads); character_sheet.gd, party_state.gd, shop_system.gd, item_info.gd, encounter_builder.gd
│  ├─ battle/       battle_map.gd, battle_unit.gd, combat_calc.gd, turn_queue.gd, battle_ai.gd, battle_controller.gd
│  └─ ui/           battle_scene.gd, party_screen.gd
├─ scenes/          (later: hq, platoon, world_map, army_battle)
├─ assets/          icons/ (launcher icons); later: sprites, tiles, ui, audio
├─ tools/           gd_static_check.py (linter), build_apk.py + build_apk.sh (APK builder), make_icon.py, keys/ (sideload signing key)
└─ tests/           run_tests.gd, balance_report.gd
```

**Save system**
- Slots: 3 manual + 2 rotating autosaves (A/B) + 1 quicksave.
- File format (`user://saves/slot_N.save`): JSON envelope `{ meta{save_version, game_version, saved_at, summary}, payload (string), checksum (SHA-256 of payload) }`. The payload is stored as a **string** so the checksum is stable across JSON number round-trips.
- Atomic write: write to `.tmp`, verify, then rename; the previous file becomes `.bak`. On corrupt load, fall back to `.bak`.
- Versioning: `save_version` integer + migration functions `migrate_vN_to_vN+1`.
- Autosave: after each battle, on entering HQ, at week end, and on `NOTIFICATION_APPLICATION_PAUSED` / focus-out.
- Deterministic combat: the battle RNG seed is part of battle state for reproducible tests and replays.

**Performance:** draw with `_draw()` or TileMap/Sprite atlases; redraw only on change (`queue_redraw()`); no per-frame allocations in AI or pathfinding; cap FPS at 30 in battery-saver mode; keep pathfinding on maps ≤ 20×16 (Dijkstra is sufficient).

**Export:** Android (arm64-v8a, Gradle build or APK) · iOS (requires macOS + Xcode). Both use the Compatibility renderer, ETC2/ASTC textures, landscape orientation, and no network permissions.

### 15.1 Android installer (APK) pipeline (added v0.5.1)
- **Run-page report (v0.5.3):** when `GITHUB_STEP_SUMMARY` is set (GitHub Actions) the builder appends a "Kindlewake build report" to the run page: build summary, every `FAIL` / `SCRIPT ERROR` / `Parse Error` line with Godot's `at:` location, the last 40 lines of `run_tests.txt` (which end with `Checks: N   Failures: M`), import errors, and on a failed build the tail of `export.txt`. Outside GitHub nothing changes.
- **Deliverable:** `dist/Kindlewake.apk`, a signed release-mode APK (package `com.kindlewake.game`, arm64-v8a + armeabi-v7a, landscape on either side via orientation 4, immersive mode, app category Game). The file name never carries a version; the version (`version/name` 0.5.1, `version/code` 501) lives in `export_presets.cfg`.
- **Offline rule enforced by the build:** the preset requests no permissions, and the build script runs `aapt2 dump permissions` on the finished APK and **fails if `android.permission.INTERNET` appears**. The preflight also rejects any network class (`HTTPRequest`, `WebSocketPeer`, `StreamPeerTCP`, `ENet*`, `OS.shell_open`...) in `scripts/`.
- **Project settings required for export:** `rendering/textures/vram_compression/import_etc2_astc=true` (Godot refuses Android exports without it), `config/icon` plus the three launcher icons in `assets/icons/` (192 px main, 432 px adaptive foreground and background; generated by `tools/make_icon.py`).
- **Preset (`export_presets.cfg`, preset "Android"):** export templates (no Gradle), `include_filter="*.json"` so every data file is packed, `exclude_filter` drops `tests/`, `tools/`, `docs/`, `.github/`, markdown, scripts and keys from the APK.
- **Signing:** every build uses `tools/keys/kindlewake-sideload.keystore` (committed on purpose, public password, like Android's debug key) so updates install over older builds. It must not be used for Google Play; a private release key is supplied through `KINDLEWAKE_KEYSTORE`, `KINDLEWAKE_KEY_ALIAS`, `KINDLEWAKE_KEY_PASS`.
- **One-command build:** `Build_APK.bat` (Windows) / `tools/build_apk.sh` (Linux) call `tools/build_apk.py`, which downloads and caches JDK 17, the Android SDK (platform-tools, build-tools 34.0.0, android-34), Godot 4.2.2 and its templates in `~/.kindlewake_build`, imports the project, runs `tests/run_tests.gd` (logged, non-blocking unless `--strict`), exports the APK, and verifies size, native libraries, signature and permissions. Logs: `dist/logs/` (`BUILD_SUMMARY.txt`). `python tools/build_apk.py --check` runs the offline preflight only.
- **Cloud build:** `.github/workflows/build-apk.yml` runs the same script on GitHub Actions (manual run or a `v*` tag) and uploads the APK and the test logs; tag builds attach the APK to the release.
- **Install and troubleshooting:** `docs/BUILD_APK.md`. iOS stays out of scope until Milestone 10 (needs macOS and Xcode).
- **Known limits:** Godot 4.2.2 templates are not 16 KB page-size ready (rebuild with `--godot 4.5` if a very new phone objects); no `.aab` for Google Play yet (needs the Gradle build); the pipeline has not yet been run against the real downloads.

---

## 16. Development Roadmap

| # | Milestone | Exit criteria |
|---|---|---|
| 1 | Playable tactical combat prototype | Data-driven grid battle: CTB turns, A*/Dijkstra movement, ranges, hit/crit, flank/height/terrain, AI, victory/defeat, touch input, save/load slot with checksum, headless tests |
| 2 | Stats, classes, leveling, equipment | Full stat sheet, class data, EXP/level-up, promotion, equipment slots, skills v1, battle simulator for balance |
| 3 | Recruitment and character management | 24 Wave-1 definitions, 20 recruit profiles, cost/prerequisite checks, duplicate-safe joins, loyalty persistence/display; personal quests and calendar-driven loyalty events remain in progress |
| 4 | Platoon creation and assignment | Platoon editor (drag-and-drop), FP/CA formulas, formations |
| 5 | Army battles | Order/Resolve phases, morale, commander abilities, siege basics |
| 6 | Castle HQ | Facilities, weekly calendar, resources, upkeep |
| 7 | World map and campaign | Map nodes, Acts I–V, dialogue, quests, house reputation, Wave-2 roster |
| 8 | Generational progression | Ageing, marriage, heirs, mentors, legacy |
| 9 | Complete offline save/load | Slots, autosave, migration, integrity UI, interruption tests |
| 10 | Polish and deployment | Final sprites/animation, SFX/music, performance, store builds (sideload APK pipeline exists since v0.5.1; still open: private release key, `.aab`, 16 KB page-size Godot, iOS) |

---

## 17. Minimum Viable Playable Prototype (MVP)

One authored map with terrain/height, 3 player heroes vs 3 enemies, 3 classes (Knight, Archer, Cleric) plus enemy Roadreaver/Bowman, CTB turn order with timeline, move/attack/wait, ranged attacks, hit/crit/flank/height/terrain mechanics, simple but non-trivial AI, victory/defeat result screen, touch-friendly controls with zoom, and a checksummed local save/load slot. Placeholder shape art with no external assets. This is Milestone 1.

---

## Appendix A — Risks and mitigations
| Risk | Mitigation |
|---|---|
| Scope too large | Strict milestones; MVP first; data-driven content so more heroes cost data, not code |
| Art volume (80 characters) | Paper-doll layered sprites and palette swaps; portraits prioritised for key characters |
| Balance | Headless battle simulator; formulas live in one file (`CombatCalc`) |
| Mobile UX | Gesture alternatives; early device testing; large touch targets |
| Save corruption | Atomic writes, checksums, `.bak` fallback, versioned migrations |
| Copyright | Original IP only; no reproduction of inspiration games |

---

## Appendix B — Naming bible (v0.4.0)
Generic names were replaced with original ones. Display names only changed for classes/items; their ids stay (`swordsman`, `knight`, ...).
| Old | New |
|---|---|
| Crowns of Ash: The Broken Oath | Kindlewake: The Sundered Vow |
| Valtherion / Highcrown / Ashmarch | Eldrimar / Aurelmont / Sethmarch |
| Oath of Seven Crowns / Testament | Covenant of the Seven Flames / Hidden Codicil |
| House Ashvale / Rowan Ashvale / Cinderwatch Keep | House Dunmarrow / Torren Dunmarrow / Kaer Sethorn |
| Halvard, Marrowen, Ostrel, Draycott, Veyra, Thornwick | Brennhallow, Ysmark, Quillon, Vessmoor, Tarnholt, Orrowen |
| King Aldemar IV / Lord Garran / Regent Hadrian | King Osric IV / Lord Edmer / Regent Maelor |
| Alden Brask / Mira Fenwick / Brother Cal | Sir Bram Vosk / Sela Wrenfield / Brother Wystan |
| Bandits, Raider, Bandit Chief | Roadwolves, Roadwolf Reaver, Hask Gravelteeth |
| Swordsman / Knight / Archer / Cleric / Raider (classes) | Bladesworn / Vowguard / Reedrunner / Lanternbearer / Roadreaver |
| Items (arming sword, kite shield, ...) | Wayfarer Blade, Hound-Crest Shield, Tanner's Cuirass, Vesper Robe, ... (see `items.json`) |
Pending: the 60-100 character roster in section 12 still has placeholder-style names for most non-house-linked entries; a second naming pass is planned.

---

## ### Sprite source-pack integration (v0.7.4)
The supplied sprite bundle is preserved as 26 nested source ZIPs in `assets/optional_sprite_packs/`. These packs are source material only: they are not yet imported into Godot scenes, and no asset is considered cleared for production use until its license/credit requirements and visual suitability are reviewed. Approved assets should be selectively moved/imported into the existing `assets/art/` layout with credits recorded.

Revision log

| Version | Change |
|---|---|
| 0.2 | Complete 17-section GDD, Milestone 1 rebuilt as a modular data-driven project (untested in Godot). |
| 0.2.1 | Added section 3.12 Auto Battle; heal support in the AI; HUD, accessibility and settings notes updated. |
| 0.3.0 | Milestone 2 step 1: items and equipment slots, character sheets with derived stats, EXP/levels/promotion, persistent party (`GameState`), EXP on the results screen, kill-EXP tracking. Sections 4.1, 4.2, 4.4 and 15 updated. |
| 0.4.0 | Full rename of world, houses, characters, enemies, classes and items (Appendix B). New grind system modelled on FF7: fixed enemy EXP/AP/gold, EXP split among survivors, Sigils (Materia) with sockets, links, AP levels, mastery copies, support/stat/independent kinds, offensive magic, repeatable Skirmish battles (section 4.6). Sections 4.1 updated. |
| 0.5.0 | Party screen (roster, character sheet, Equipment / Sigils / Shop tabs), pre-battle panel, `ShopSystem` and `data/shop.json`, Sigil of Frost with Frost Shard / Frost Lance, `EncounterBuilder`, `ItemInfo`, `tools/gd_static_check.py`, `tests/balance_report.gd`. New section 4.7; sections 4.6, 14 and 15 updated. Written and statically checked only; not yet run in Godot. |
| 0.5.1 | Android packaging: `export_presets.cfg` (APK, no permissions), launcher icons, `import_etc2_astc`, landscape either side, sideload signing key, `tools/build_apk.py` one-command builder with offline preflight and INTERNET-permission guard, `Build_APK.bat`, GitHub Actions workflow, `docs/BUILD_APK.md`. New section 15.1; roadmap row 10 and the folder structure updated. Game code and save format unchanged. Pipeline checked offline only; not yet run against real downloads or Godot. |
| 0.5.2 | Milestone 2: the full class tree from section 4.2 as data (28 classes, tiers 1-4) with growth tables, move/jump, `locked` / `story_only` / `requires` fields; promotion skips locked classes; placeholder battle glyph per branch; new `_test_class_tree()` and updated promotion tests; version code 502. Written and statically checked only; not yet run in Godot. |
| 0.5.3 | Tooling only: on GitHub Actions `tools/build_apk.py` now writes a "Kindlewake build report" (build summary, test problems with their `at:` lines, last 40 test lines, import and export errors) to the run page, so results can be read without downloading logs; section 15.1 and `docs/BUILD_APK.md` updated; version code 503. No game code changed. |
| 0.5.4 | Phone HUD rework (14.1): larger text and buttons, safe-area inset, Menu popup for Save/Load, separate preview + Confirm/Cancel panel, scrollable result/pre-battle overlays, bigger in-world labels. Not run in Godot. |
| 0.5.5 | Weapon skills (3.13): `strike` type, Power Strike and Aimed Shot, skill cycling in the HUD, new `_test_weapon_skills()`. Not run in Godot; hero win rates need a balance run. |
| 0.5.6 | Class-granted skills (`class_skills`, 3.13); heroes' skills removed from characters.json; new tests. Not run in Godot. |
| 0.6.0 | Free-roam overworld (11.1): `WorldMap`, `world.json`, `World.tscn` as main scene, ambushes, places, minimap, battle hand-over and return, `_test_world()`. Not run in Godot. |
| 0.6.1 | Art pass (14.2): Soldier/Orc animated sprites, rendered tree/rock/building sprites, `Art` helper, CREDITS. Not run in Godot. |
| 0.7.0 | Towns and interiors (11.2): `LocalMap`, `locations.json`, `Location.tscn`, doors, spots, overworld Party button removed, `_test_locations()`. Not run in Godot. |
| 0.7.1 | Party screen redesign (4.7): fixed the wrapped Gold label, card-based roster / gear / sigils / shop, stat tiles, green/red gear deltas, Bag list, sell confirmation, message banner, Back button, kept scroll positions. `ItemInfo.delta_parts`. Not run in Godot. |
| 0.7.2 | Shop: compare gear with what each hero wears before buying, Confirm / Cancel for every buy and sell (replaces the second-tap sell), `shop_pick`, new tests. Not run in Godot. |
| 0.7.9 | Weapon-preference starting loadouts (4.9): every compatible preference equips a matching common-tier weapon; added spear, crossbow, staff and dagger data; expanded creator regression coverage; save metadata and project version advanced. Static checker and Android offline preflight pass; Godot runtime not run. |
| 0.7.11 | Repository import completed: four upload shards reconstructed the full `Kindlewake/` tree and optional sprite archive; GitHub Actions static checker passed (27 files/classes, 0 errors, 0 warnings) and Android offline preflight passed. Delivery instructions now specify direct-file commits only. No gameplay code, data, save schema, or Godot project version changed. |
| 0.7.10 | Repository delivery/tooling only: documented extracted `Kindlewake/` as the GitHub source of truth, replaced routine ZIP handoff with four phone-upload shards for the one-time import, and documented direct-file commits thereafter. No gameplay code, data, save schema, or Godot project version changed. |
| 0.7.8 | Creator preview polish (4.9): presentation-sensitive head silhouette and distinct weathered / soft / scarred / sharp facial details; added a preview mapping regression test; synchronized save metadata game version and checkpoint documentation. Static checker and Android offline preflight pass; Godot runtime not run. |
| 0.7.7 | Interactive protagonist creator: touch-first overlay, geometric live preview, validated confirm/back, GameState/PartyState initialization with stable `torren` id and unchanged companions, creator profile in battle saves, v1→v2 save migration and tests. Static check and APK preflight pass; Godot runtime not run. |
| 0.7.6 | Protagonist creator foundation: `data/character_creation.json`, `CharacterCreation` profile validation/definition builder, `GameData` loading, tests for valid/invalid profiles, class/origin/temperament effects and immutability. Creator scene, campaign hookup and save migration remain pending; not run in Godot. |
| 0.7.3 | Touch scrolling fix: `TapCard` replaces buttons as list cards (drag scrolls, tap selects), panels no longer swallow touches, tests for tap vs drag; linter knows PanelContainer subclasses. Not run in Godot. |
| 0.9.0 | Title screen (New Chronicle, Continue, Load Game, Settings), campaign-level save/autosave, region-limited market stock, steep rarity-based equipment prices and moderated high-tier defense stats. Godot validation pending. |\n| 0.7.14 | Sethmarch Frontier: connected Orrowen/Vessmoor roads; six towns with inns, markets and recruitment halls; three explorable dungeons with named bosses and one-time caches; regional battle-save flags and SaveSystem v3 migration; regression assertions added. Godot tests deferred; no runtime validation claimed. |


| 0.9.0 (validation follow-up, 2026-11-09) | Corrected the starter-shop purchase regression test to buy the stocked Sigil of Mending rather than the unstocked Sigil of Frost. No gameplay code, balance data, save schema or project version changed. The original CI failure was a test fixture mismatch; rerun status is recorded in SESSION_HANDOFF. |


## 4.10 Rune system — grades, specialists and fusion

The legacy Sigil feature is renamed in player-facing UI and content to **Runes**. Existing v0.9.0 saves retain their sigil_inv and socket fields; GameData exposes the same definitions under both runes and the compatibility key sigils, so existing inventories are not discarded. New definitions live in data/runes.json.

The current library contains **77 rune definitions** across Flame, Frost, Mending/Vitality, Storm, Earth, Wind, Holy, Shadow, Arcane and Fortune families. By kind, it includes 23 magic, 43 passive, 3 support, 6 stat and 2 independent runes. Seven definitions carry the unique flag and five carry the heirloom flag; these flags overlap the kind counts. Passive runes contribute their current-level `mods` while socketed; magic runes grant cumulative skills at AP thresholds; support runes enhance linked sockets; independent runes contribute campaign/reward modifiers. Six fusion grades are supported: Common, Uncommon, Rare, Epic, Legendary and Mythical. Fusion consumes three copies of the same rune ID; input grades may be mixed. The target grade is one step above the greater of the floored average input-grade index and the rune's starting-grade index minus one. Base success chances for the target grade are 70%, 55%, 40%, 25% and 12%; each input rune's mastery level increases the chance, capped at 95%. Success returns one target-grade rune; failure returns one surviving rune at the highest input grade. Grade scaling improves magic/support power and passive modifiers (5 percentage points per grade above the rune's starting grade). Unique and heirloom runes cannot be sold or fused; heirloom-tagged runes are protected legacy items.

Runes are not part of universal stock. They are sold only by named regional rune merchants through explicit runes stock lists: Oswin at Sallow Crossing, and selected specialists in Thornmere, Foxglove, Elderbough, Cindermead, Redwater and Milefort.

Rune combat effects are data-driven: Flame can Burn, Frost can Chill, Storm can Shock and skip a turn, Holy can Expose armor, Shadow drains life, and Mending applies regeneration. Status effects tick on the affected unit's turn. Battle popups display the applied effect. The original rune atlas is an 10-type × 6-grade SVG sprite sheet at assets/art/runes/rune_atlas.svg, used by rune inventory/socket UI.

Legacy sigil_* script entry points remain internal compatibility wrappers during this transition. New player-facing text, shop stock, data, fusion, and asset naming use Rune terminology.

| 0.9.1-rune-system | Renamed sigils to runes in player-facing systems; added six rune families, six grades, chance-based three-to-one fusion, specialist-only regional rune shops, grade scaling, elemental status effects and original rune atlas. CI validation passed on 2026-11-09: Godot 4.2.2 import succeeded without script or parse errors; 312 strict checks passed with zero failures; balance report passed; signed Android APK exported for arm64-v8a and armeabi-v7a. Device playtesting remains pending. |
| 0.10.5-verification-audit | Audited 0.10.1–0.10.4 source implementation, test coverage, current-main APK and portable source handoff; no gameplay/version/save-schema change. |
| 0.11.0 | Recruitment v1: complete 24-character Wave-1 data roster; add 14 recruit profiles and 14 town-hall placements; align six existing recruits to their GDD classes; add prerequisite/cost/duplicate-safe recruitment rules, 0–100 loyalty, party-screen bond display and save schema v4 migration. |


### 14.3 Responsive mobile HUD pass (2026-11-10)
- Battle HUD now uses tighter viewport-relative widths for the selected-unit card, combat log, preview panel and action stack on compact landscape screens. Confirm/Cancel retain large touch targets while their labels scale down with the viewport.
- Overworld COMPANY and SAVE controls now resize independently for compact screens; save remains a dedicated, reachable action.
- Company management now chooses its stacked layout from the actual viewport orientation, not width alone. Narrow landscape phones keep the three panes side-by-side with scaled minimum widths; portrait layouts stack roster, character sheet and gear/rune/shop panes vertically. The header title, gold chip and Close button also compact together.
- These changes preserve the existing battle rules, save payloads, party APIs and rune/gear behavior. Validate actual safe-area, notch, scrolling and touch interaction on physical devices; CI cannot replace that check.

| 0.10.1-mobile-ui | Responsive battle HUD, overworld save/company controls and party management layout for compact landscape/portrait viewports; physical-device validation pending. |


### 14.4 Mobile layout refinements and validation
- Portrait company management uses full-height tabs (Company / Hero / Gear & Runes) so all work areas remain reachable without a clipped outer stack. Narrow landscape uses proportional three-column panes; desktop retains wider proportions.
- The company screen uses a safe 1280×720 design fallback when constructed outside the SceneTree for headless UI tests; live screens use the actual viewport. This avoids viewport-access errors in the UI smoke test.
- Overworld and town interaction panels, prompt buttons and action buttons resize from the current viewport. Battle compact actions and preview are separated to opposite lower corners; timeline/log are hidden when the compact HUD cannot safely display them.
- Validation on commit 99fcc28dd37652c293eaf240ec017500bbd698e6: Godot 4.2.2 build workflow 42672539871 completed successfully; strict suite 333 checks / 0 failures; balance report completed; signed Android APK exported and verified. No physical-device test has been performed.

| 0.10.2-mobile-ui | Portrait company tabs, narrow-landscape proportional panes, viewport-safe party tests and responsive town/overworld interaction controls; CI validated on 2026-11-10. |

### 14.5 Tactical unit identity art pass (2026-11-10)
- Battle units retain the existing animated Soldier/Orc base sheets and frame timing, while the renderer adds original class-specific equipment overlays for Knight, Swordsman, Archer, Cleric, Roadreaver, Cavalry and magic classes.
- Enemy identity marks now add further silhouette cues for commanders, shamans, wraiths, skeletons, ranged scouts and heavy brutes, including subtle animated aura pulses for spectral and magic archetypes.
- The pass is presentation-only: no combat stats, turn logic, unit data, animation frame contracts or save schema changed. It is an incremental readability improvement, not a replacement for dedicated per-character/per-species sprite sheets.

| 0.10.3-battle-identity-art | Added class-specific hero equipment and enemy archetype silhouette overlays on existing animated battle sprites; current-head CI validation pending. |

### 14.6 External AI contribution intake and portable handoffs (2026-11-10)
- Added `receiving/` as the dedicated intake folder for patches, source files, documentation and asset bundles supplied by other AI assistants. Its README defines a HANDOFF.md manifest, review/licensing requirements and safe integration rules.
- Android CI now packages the source tree and project handoff documents into one ZIP, then divides that ZIP into binary chunks no larger than 25 MB each. CI uploads the numbered parts and a reassembly guide as `Kindlewake-Source-Handoff-Parts`.
- The original project remains the canonical source; split ZIP parts are transport-only and must be reassembled before extraction or merging.
- No save schema or runtime gameplay behavior is changed by this delivery packaging.

| 0.10.4-external-intake-handoff | Added an external AI receiving folder and CI-generated source handoff parts capped at 25 MB each; branch-head Android CI pending. |


## Revision audit — 2026-11-10 (documentation reconciliation; no app version bump)
- Confirmed live `project.godot` remains `0.10.0`; Android export metadata is `0.10.0` / code `1000`; `SaveSystem.GAME_VERSION` is `0.10.0` and `SAVE_VERSION` remains `3`.
- The existing 0.10.1–0.10.4 entries above are retained as implementation/revision notes. They are not treated as a released semantic-version change until their source files, tests and exact-head CI evidence are audited.
- PR #16 merged the save game-version metadata synchronization fix at main commit `843d21be5b201b95736e98a38f0485274e5dcc03`.
- Current-main post-merge APK and fresh source-handoff artifact were not verified during this audit. Do not reuse older artifact links as if they match this SHA.
- No gameplay behavior or save schema changed in this documentation reconciliation.


## PR #17 handoff verification — 2026-11-10
- PR #17 documentation reconciliation merged automatically at main commit `843d21be5b201b95736e98a38f0485274e5dcc03`; the merge tree is the tested PR source tree `91660c021144b53719e5cca43de6b3d946f2880b`.
- Exact-head checks passed: Android build (342 checks, 0 failures, balance report passed, signed APK exported), Version Sync, Workflow YAML Lint and Project Health Audit. Safe Auto Merge run `42708329157` succeeded.
- The source handoff workflow generated 177 tracked files in four verified parts (each <=25,000,000 bytes). Reconstructed archive SHA-256: `aba0eea9f02f0ca1c96be8ac91259cef50ba6c71145cca41c349ec5f4d76d976`.
- Build logs showed transient global-class registration compile errors on the first import scan; the clean second scan succeeded and tests/build passed. This remains a technical follow-up, not a suppressed failure.
- This was documentation-only; project version remains 0.10.0 and save schema remains 3.


## 14.7 Verification audit — 2026-11-10 (no app version bump)

- 0.10.1–0.10.2 responsive layout implementation is present in `scripts/ui/battle_scene.gd`, `party_screen.gd`, `world_scene.gd` and `location_scene.gd`: safe-area insets, viewport-based control sizing, compact HUD behavior, portrait company tabs and proportional landscape panes. Headless coverage verifies party-screen construction and tap-versus-drag behavior, but there is no automated viewport/orientation matrix or screenshot regression suite. Physical-device validation remains required.
- 0.10.3 battle identity presentation is present in `battle_scene.gd`: class-specific equipment silhouettes, enemy archetype marks and animated magic/spectral accents over the shared animated base sprites. No dedicated automated visual assertion or per-device rendering test was found; treat this as implemented presentation code, not art-complete validation.
- 0.10.4 external intake and portable handoff are present: `receiving/README.md`, `tools/source_handoff.py`, `tests/test_source_handoff.py` and `.github/workflows/manual-source-handoff.yml`. The handoff workflow passed and produced a verified 177-file snapshot.
- Current main `d25ac6840ab0cdcc339b6fa89ed4ef42dec917dc` has the same Git tree as tested PR head `769022ebee463a35af95e4cd9dfcab7a55e89cb7`. Build run `42711243963` passed with Godot 4.2.2, 342 checks / 0 failures, balance report and signed APK export. The APK requests no Android permissions. Build artifacts and hashes are recorded in `docs/SESSION_HANDOFF.md`.
- Build logs retain a transient first-import global-class resolution warning and ObjectDB/resource cleanup warnings; the final strict suite and export succeeded. Investigate these warnings separately rather than misreporting them as test failures.
- Project version remains `0.10.0`, Android code `1000`, and save schema `3`. This audit does not change gameplay, save data or release version.


### 14.8 Recruitment and company-bond UI (v0.11.0)
The character sheet includes a Company bond tile with a loyalty value and readable state (Fractured, Wary, Committed or Steadfast). Muster-hall recruit prompts show the authored gold cost or the first unmet prerequisite; successful recruitment records a one-time flag and shows the recruit's starting loyalty. This is a foundation only: there is not yet a calendar-driven desertion or event-based loyalty loop.


## Opening prologue — Smoke on the Wind (implementation slice)

- New campaigns route from the protagonist creator into `Prologue.tscn` before entering the Sallow Marches. Existing Continue/Load flows remain unchanged.
- The east-gallery scene presents the burning estate, the archive survivors and the sealed household record through authored dialogue from Bram, Sela and Wystan.
- The player chooses to rescue the people, recover the record, or split the company and attempt both. `PrologueSystem` records explicit campaign flags (`prologue_decision`, `prologue_people_saved`, `prologue_record_saved`, `prologue_company_split`, `chapter`) without changing the save schema.
- First overworld arrival displays a one-time companion acknowledgement based on the selected outcome. Existing campaign serialization preserves these flags.
- Headless regression assertions cover all three outcomes, preservation of pre-existing world flags, acknowledgement text and invalid choices.
- Scope boundary: this is the first playable narrative decision and consequence hand-off, **not** the complete 45–60 minute vertical slice. Escape traversal/battle, persistent journal, first keep restoration decision and first investigation remain future work. No third-party art/audio is introduced.


## Opening-hour playable slice — courtyard escape

- After choosing the east-gallery consequence, the player now enters `Escape.tscn` rather than jumping directly to the overworld.
- The courtyard traversal is touch-first: tap the ground to guide the company through a burning, collapsing estate court to the postern gate. The scene communicates the selected rescue/record outcome in its companion narration.
- Reaching the gate starts a dedicated tactical encounter, `east_gallery_escape`, built by deep-copying the canonical `battle_01` definition and replacing its battlefield, deployment, briefing and victory/defeat text. Canonical battle data is never mutated.
- The tactical battle has a distinct courtyard layout and four enemy raiders including a commander. The existing turn-based combat, equipment, rune, party, reward and result systems are reused. Escape victory writes `east_gallery_escaped`; defeat returns the player to the traversal for another attempt. The escape battle cannot be fled.
- On returning to the overworld after victory, the company receives a one-time authored acknowledgement and the campaign is saved.
- Regression tests cover battle identity, persistent victory flag, authored text, map dimensions, unit deployment, canonical-data immutability and controller setup.
- Scope boundary: this completes the opening prologue decision -> traversal -> tactical escape hand-off, not the entire 45–60 minute vertical slice. The persistent journal, first keep restoration decision, investigation, expanded cinematic scenes and physical Android-device QA remain future work.


## Global world expansion — The Sevenfold World

The campaign now has a seven-continent world atlas above the existing regional overworld, preserving the original four-continent blueprint and expanding it with three new continents. The seven are Eldrimar (The Sundered Crown), Thalassar (The Shattered Isles), Varakhan (The Red Expanse), Nhalor (The Far North), Veyrwood (The Verdant Expanse), Asterreach (The Stormforged Coast) and Ilyr (The Far Lantern). Eldrimar remains the current playable continent, and the 64×48 Sethmarch Frontier remains intact as its first detailed regional map.

Every continent has a capital, ruling power, climate, cultural identity, political conflict, signature locations, at least four named regional territories, campaign hook and original normalized map silhouette. The original region, town, dungeon and route-gate blueprint for Eldrimar, Thalassar, Varakhan and Nhalor is preserved. The new Veyrwood, Asterreach and Ilyr regions extend the same data-driven structure. A shared mystery about seven deliberately unbound covenant seals connects the continents without erasing their local politics or character-driven conflicts.

The World Atlas is reachable from the overworld HUD. Players can inspect all seven continents and their lore. On the 0.11.0 main baseline, Eldrimar/Sethmarch is the only playable regional overworld. The merged 0.12.0 release adds the first Thalassar region, Brinegate Coast, behind the Tidebound sea-charter story flag; it does not make the remaining continents or Thalassar's later regions explorable. The atlas is a navigable campaign overview, **not a claim that all seven continents are already explorable**. Existing Sethmarch positions and saves remain supported.


## 17. Premium production and regional expansion milestone

The creative north star, narrative architecture, companion writing standard, long-session pacing, touch UX requirements, visual identity, audio direction and definition-of-done gates are specified in [PREMIUM_PRODUCTION_BIBLE.md](PREMIUM_PRODUCTION_BIBLE.md). This is a production standard, not a claim that every proposed asset or campaign scene is already shipped.

**Released scope (PR #28; merged into main at v0.12.0):** the first cross-continent playable expansion is **Thalassar — Brinegate Coast**. The candidate adds a separate 64×48 generated coastal overworld with Brinegate harbour, Saltmere, Lantern Quay, the Old Beacon Vault, the Northstar Wreck and Tideglass Grotto. It reuses the existing touch overworld, town/interior, tactical battle, recruitment and campaign-save systems rather than creating a disconnected demo.

The route is earned in Eldrimar: after the Dunmarrow escape, the player can speak to the Tidebound Envoy near Sallow Crossing and accept the sea charter. The atlas then offers a real sail-to-Brinegate transition. Region positions are stored independently, so returning to Sethmarch does not overwrite the harbour position. Existing schema-4 saves default to Sethmarch and retain their old coordinates; the new fields are optional and do not require a schema bump.

The Brinegate story loop is: meet Captain Ilyra Venn → investigate the darkened beacon → explore Tideglass Grotto → open the keeper's strongbox to recover the ledger → defeat the Reef Warden → return to Ilyra and choose whether to publish the scraped Seven Flames oath or keep it private for a 60-gold patron payment. Each outcome is persistent and mutually exclusive. Maren Vey, a pilot/recruit, becomes available only after both the ledger is found and the grotto guardian is defeated. The region uses a coastal palette, tide shimmer, original harbour-marker drawing and touch-sized interaction panels.

**Definition of done:** verify every road and location connection, all town/dungeon maps, encounter roster and rewards, charter unlock, both ledger outcomes, recruitment prerequisites, old-save restoration, region switching, autosave/load, strict tests, balance simulation and Android export. The candidate is not complete until those checks pass on one exact PR head and physical Android QA is recorded separately. Later Thalassar regions and dungeons remain future content.


## Exploration and control upgrade (0.12.0 candidate)

The campaign overworld is a continuous wraparound surface: east-to-west, west-to-east, north-to-south and south-to-north transitions are traversable, with toroidal terrain sampling, shortest-path navigation, seam-aware landmarks and normalized saved coordinates. Settlements and dungeons remain enclosed authored maps. Exploration supports controller left stick/D-pad movement, A to interact and B to run; keyboard arrows/WASD, E and Shift; Android virtual stick and a persistent RUN toggle. Direct movement coexists with tap-to-move. Run speed targets 1.6× walking speed and retains collision and door/exit checks. The merged code passed its recorded Godot/Android CI gate; physical-device QA remains a separate requirement.


## 18. Chapter I input and chronicle creator reliability pass (0.12.0 maintenance)

**Merged PR:** [#30](https://github.com/ninjun42215-gif/KindleWake/pull/30)  
**Status:** implementation merged in PR #30; Godot/Android CI passed on runtime-code commit `b2598c3c8620a701d1fabd84394ec5cbb7449451`; physical-device verification remains pending. No game-version or save-schema change.

- Chapter I courtyard movement is handled in the root Control's `_gui_input`, so the full-rect Control no longer prevents taps from reaching `_unhandled_input` (which is not dispatched after GUI handling consumes the event). Mouse drag and touch drag also update the movement target.
- Movement destinations are constrained to a responsive playable rectangle that excludes the objective and instruction panels. The postern is positioned below the objective panel and the party reaches it within a 120px radius.
- The title screen creates the protagonist creator as a full-screen overlay rather than a child of the constrained title-card VBox. Cancel removes the overlay and restores the menu.
- On narrow portrait viewports, the live portrait and concise character summary remain above the scrollable creator form. Desktop preview/form arrangement is retained; narrow landscape remains scrollable.
- `tests/run_tests.gd` covers gate placement and tap-bound clamping at 360×800, 390×844, 1280×720 and 800×360. `tests/scene_smoke_test.gd` loads every authored `.tscn` resource headlessly; the APK builder runs it after editor import and before gameplay tests/export.

**CI evidence:** run #633 passed Godot 4.2.2 import (clean retry), 8/8 scene smoke loads, 427 strict checks with 0 failures, balance report and signed 40.8 MB APK export with no Android permissions. APK artifact `13724652587`. The first editor import scan still logs transient global-class registration errors before its clean retry; ObjectDB/resource-cleanup warnings remain non-failing. **QA still required:** verify creator and Chapter I gameplay on a 20:9 Android phone in portrait and landscape. CI does not replace device QA.
## 19. Campaign factions, diplomacy and territorial state (next playable-system foundation)

**Implementation branch:** `feature/campaign-factions-diplomacy` (PR pending). This is a data/runtime foundation, not a finished kingdom-management UI or a claim that the player can already wage a full strategic war.

- Adds authored political factions for the seven-continent setting: the Crownlands and six Eldrimar houses (including the fallen House Dunmarrow and House Ysmark), the Tidebound Assembly, Nine Wells Compact, Hearthfjord Jarldoms, Lantern Synod, Thorn Courts, Free Ranger Lodges, Meridian League, Independent Sky Monasteries and Covenant of the Seven Flames.
- Adds a region-to-faction starting affiliation for every named atlas region. Sethmarch is explicitly marked contested under the Dunmarrow claim; affiliations remain data-driven and can be changed by authored campaign outcomes.
- Adds bounded faction relations (-100 to +100), neutral/non-aggression/trade-pact/alliance/war diplomatic states, a trust threshold for alliances, validated territory transfers and a bounded campaign event history.
- New campaigns initialize political state. Campaign saves persist it as an optional payload field; older schema-4 saves receive safe defaults on load. Save schema and project version remain unchanged.
- Exposes GameState methods for story, quest and battle systems to adjust relations, set diplomatic states and transfer known atlas regions. No automatic wars, random coups, fabricated quest consequences or player-facing diplomacy screen are introduced in this foundation.

**Validation:** code head `f7b31035e4651a4a6854cc5ad644beff88c2148b` passed Godot 4.2.2 import (clean retry), 8/8 scene smoke loads, 447 strict checks / 0 failures, balance report and signed Android APK export (arm64-v8a + armeabi-v7a; no requested permissions). Version Sync #188, Workflow YAML Lint #666 and Project Health Audit #458 passed. APK artifact `13733346417`; test logs `13732869336`. Any later documentation-only head still requires the repository's exact-head gate. Physical Android QA remains separate and unperformed. Future work: player-facing diplomacy UI, faction missions, treaties with authored costs, war campaigns, recruitment consequences and strategic territory operations.


## 20. Regional Trading and Merchant Economy

- Adds a data-driven commodity catalogue covering frontier food, coastal provisions, timber, ore, herbs, textiles, crafted goods, luxuries and rune materials.
- Eight market profiles have distinct regional supply advantages and prices: Brinegate specializes in salt, fish and pearls; Thornmere in grain and wool; Foxglove in herbs and leather; Elderbough in timber, honey and wine; Cindermead in ore and weapon components; Redwater in amber and dyestuff; Milefort in military supplies; Sethmarch acts as a mixed crossroads.
- `TradeSystem` supports market quotes, quantity-based buying and selling, stock depletion/restocking through player sales, local demand pressure, cargo weight/capacity and deterministic regional price movement.
- Cargo is stored in the existing party inventory. Market stock, demand, transaction count and trade totals are persisted as an optional campaign payload field. Existing schema-4 saves receive a clean default trade state.
- `GameState.trade_buy()`, `trade_sell()` and `trade_quotes()` expose the active region's market rules to town/market UI. Save schema and game version remain unchanged.
- This PR establishes the content and rules foundation. A dedicated merchant UI, caravan routes/events, tariffs, trade contracts, smuggling and merchant-guild progression remain follow-up implementation work.
