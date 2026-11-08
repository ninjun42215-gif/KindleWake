Version 0.9.2 (two additional named recruitment stories and two more character portraits; seven character portraits and a portrait-led Recruitment Hall; four hero portraits and the first named recruitment story slice added; source-level room transition regression guard retained; room_swirl_transition: procedural radial spiral wipe for room/site exits and dungeon encounters; watchtower_site: two-room explorable Old Watchtower site at the existing Sethmarch ruin; world_map_polish: deterministic terrain detail, connected roads and bridges, settlement plinths and label plaques; town_buildings: authored settlement silhouettes for all 23 inhabited places; room_resume: persist the current pre-rendered site, room and hero cell in world saves; Home Continue/Load and world Load resume the room; room transitions, app pause and chest rewards autosave; home_screen steps 1-4 complete; persistent settings and generated placeholder audio; feature story_gates step 4: closed-gate markers, bump hints, place actions and Journal overlay; step 3: sealed map boundaries and requirement-gated road corridors; step 2: progression rules and quest journal state; step 1: generated boundary overlay and seven gate definitions; feature pre_rendered_rooms: heroes drawn in battle; feature character_select: character select, lead choice, unique hero designs; feature party_ui: Party screen redesign, shop compare and Confirm, touch scrolling; v0.7.0 Eldrimar: 50x world, town-only shops, view-only company screen outside towns, 2D sprites from voxel packs; v0.6.0 free-roam overworld; class skills; weapon skills; phone HUD rework; Milestone 2 in progress: equipment, character sheets, FF7-style EXP/AP/Sigil grinding, party screen and shop; Android APK pipeline; full class tree as data) · Engine: Godot 4.2+ (GDScript, GL Compatibility renderer) · Platforms: Android, iOS · Fully offline

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
- Levels 1–30. Promotion offered at level 10 (tier 2) and level 20 (tier 3) when requirements are met.
- `EXP to next = 80 + 20·level` (flat-ish to avoid grinding). Battle EXP is shared: acting units earn full EXP; bench units earn 40% of the battle total so reserves stay relevant.
- Each level grants class-based stat growth (probability per stat, 0–100%). Luck and Leadership grow slowly.

**Implemented in v0.3.0 (`CharacterSheet`, `PartyState`, `CombatCalc.kill_exp`)**
- `EXP to next = 80 + 20 × level`, level cap 30. Leftover EXP carries over; several level-ups can happen at once; no EXP is stored at the cap.
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

### 4.6 Grinding system: EXP, AP, gold and Sigils (v0.4.0, modelled on Final Fantasy VII)

**Rewards.** Every enemy has a fixed `reward` block in `characters.json` (`exp`, `ap`, `gold`; commanders pay more). Defaults when missing: EXP `15 + 5 × level`, AP `2 + level`, gold `5 + 3 × level`, all doubled for a commander.
- Only **defeated** enemies pay. Winning by killing the chief while others live does not pay for the survivors.
- **EXP** of all defeated enemies is added up and split equally between the player units still standing (rounded down, at least 1). **AP** is paid in full to each survivor. **Gold** goes to the party.
- A fallen hero gets nothing; a **defeat pays nothing**. Undeployed roster members get 40% of one survivor's EXP share and no AP.
- Test battle (Prologue map): 250 EXP, 44 AP, 162 gold in total; with four survivors that is 62 EXP and 44 AP each, so a level costs about 2 battles at level 2 and about 4-5 at level 10.

**Sockets.** Weapons and armor carry 1-4 sockets (`sockets`), some in **linked pairs** (`links`), and an AP multiplier (`ap_mult` x1-x3; better gear levels sigils faster). Changing to a piece with fewer sockets returns the extra sigils to the bag.

**Sigils** (`data/sigils.json`; Materia equivalent). Each has an AP threshold list; level = 1 + thresholds reached; at the last threshold it is **mastered**, stops growing and **forges one fresh level-1 copy** into the bag (the classic grind loop).
| Kind | Effect | Examples |
|---|---|---|
| magic | grants skills, cumulative per level | Mending (Mend, Greater, Radiant), Embers (Ember Bolt, Ember Storm) |
| support | acts on the sigil in the linked socket | Resonance (+10/20/35% skill power), Tutor (+25/50/100% AP to the linked sigil) |
| stat | passive numbers for the current level, usually with a trade-off | Vigor (+HP%, -MP%), Might (+STR, -INT), Bulwark (+VIT, -SPD), Fleetness (+SPD) |
| independent | party-wide reward bonuses | Veteran's Mark (+EXP%), Coin Eye (+gold%) |
AP gained per sigil = battle AP x weapon/armor `ap_mult` x (100 + linked Tutor %) / 100, rounded up. Heroes no longer have innate spells: Brother Wystan's Mend comes from a Sigil of Mending in his mace.

**Repeatable fights.** Roadside Skirmish (`data/encounters.json`): the story map with a weighted-random enemy group, offered on the results screen as "Skirmish (grind for EXP / AP / gold)". It is the equivalent of FF7 random encounters; later maps get their own tables.

**Offensive magic (new skill type `damage`).** Never misses; damage = `base_damage((power + 1.2 x INT) x resonance, magic defense) x morale x variance`; costs MP; targets enemies in range 2-4. The AI casts damage skills when their score beats the best weapon attack. Skill preview appears in the info panel.

**Frost (v0.5.0).** Sigil of Frost (350 g; AP 70 / 220 / 520): Frost Shard at Lv1 (power 6, 3 MP, range 2-5), Frost Lance at Lv3 (power 11, 7 MP, range 2-5); both are `damage` skills like Ember Bolt, with longer reach and a different MP/power curve.

**Not implemented yet:** Limit-Break-style special attacks, party-wide sigil bonuses outside battle, summon-type sigils, class/weapon-type restrictions, sigil sale price that scales with level.

### 4.7 Party screen, shop and pre-battle panel (v0.5.0)
**Pre-battle panel.** Every battle now opens paused on a briefing panel (title, briefing text, gold) with two buttons: **Begin Battle** and **Party, Gear and Shop**. Closing the party screen rebuilds the battle from the party's current sheets, so gear and sigil changes apply immediately. The results screen has the same Party button. Loading a save is allowed while the panel is open.

**Party screen** (`PartyScreen`, built entirely in code, touch-sized buttons, landscape 1280x720). Left column: roster. Centre: the selected hero's character sheet (HP/MP, ATK, DEF, RES, ACC, EVA, CRIT, SPD, MOV, weapon range, the ten base stats with the gear bonus shown separately, skills with power and MP cost, EXP bar, promotion buttons when available). Right panel, three tabs:
| Tab | What it does |
|---|---|
| Equipment | Six slots. Tap a slot to see the bag items that fit it, each with a live stat delta ("ATK +3, DEF +1"; items that cannot be worn show the reason). Unequip returns the item to the bag. |
| Sigils | Weapon and armor sockets drawn as buttons ("Embers Lv2 / 35/70 AP"), linked sockets joined by "=", header with socket count and AP multiplier. Tap a socket for the sigil's level, AP to next level, effect and linked Tutor bonus; Remove, or choose another sigil from the bag. |
| Shop | Buy / Sell toggle. Stock from `data/shop.json` (Sethorn Market Stall: 19 items, 11 sigils). |

**Shop rules** (`ShopSystem`, static; every call returns "" on success or a short reason). Buy price is the item's `price`; sell price is a flat 50% (`sell_ratio`). Only bag items can be sold (equipped items are not in the bag). Heirlooms and bound items can never be sold. Sigils sell at a flat price whatever their level, so a mastered sigil is worth the same as a fresh one; the real value of a sigil is the AP and the mastery copy.

**Tools.** `tools/gd_static_check.py` is a Python linter for the GDScript and JSON (no Godot needed). `tests/balance_report.gd` runs the AI against itself for every enemy group and a 60-battle grind curve (see SESSION_HANDOFF v0.5.0).

**Town-only rules (v0.7.0).** Buying, selling, changing gear, sockets and class promotion work **only inside towns**. `PartyScreen.setup(party, db, shop, can_edit)`: with `can_edit = false` (the Company button in the wilderness, "View Company" before and after a battle) the screen is **view-only**: slots and sockets are disabled, a banner explains why, and every mutating handler returns early. The **Shop tab appears only when the town has a shop** (`has_shop()`, `tab_ids()`); a shop is one entry of `data/shops.json` with `"place"` (the town), `price_mult` (frontier prices: home 1.0, deadliest region 1.15, `ShopSystem.buy_price`, never below 0.5) and `sell_ratio` (selling pays that share of the LIST price). `GameData.shops_at(place_id)` lists the shops of a place (empty for camps, ruins and unknown places). A town may have no shop or several; the 23 towns of v0.7.0 have 1 to 3 each (41 shops, regional stock). Header bug fixed: the character header was one long line that wrapped and overlapped; `_label_line` now gives it a fixed 60 px row.

**Layout (feature party_ui).** Top bar (62 px): title, a Gold chip that never wraps, Close; the phone Back button / Esc also closes the screen. Roster: one card per hero (level badge, name, class, green PROMOTE tag). Sheet: `<` `>` buttons step through the roster; EXP bar; HP/MP and nine combat numbers as stat tiles; the ten base stats as tiles that turn green or red when gear adds or removes points; skills as small boxes; promotion buttons (a note in view-only mode). Equipment tab: six slot cards (slot, item name in its rarity colour, item numbers); tapping a slot opens the choices below it, each with its stat change in green (better) and red (worse), blocked items dimmed with the reason, Unequip, a read-only Bag list, an "Open the Shop" shortcut only where the town has a shop. Sigils tab: socket cards with level and AP; the choices panel shows level, effect, the linked Tutor bonus, Remove and the bag sigils as cards. Message banner: always visible; a hint for the tab, green after something worked, red after a refusal, and in view-only mode the line "View only. Change gear, sigils and rank inside a town." Scroll positions of the roster, sheet and right panel are kept across rebuilds. Colours and sizes are constants at the top of `party_screen.gd`.

**Shop: compare before buying, confirm every buy and sell.** Tapping a gear card opens it (state `shop_pick`, e.g. `buy:item:mace`, `sell:item:mace`, `sell:sigil:0`): the stat change (green/red) if the selected hero wore it, in every slot it fits (both accessory slots), what it would replace, the reason when it cannot be used, and one line per other hero (`<` `>` on the sheet changes who is compared). Sigil cards show effect and AP line. The opened card shows Cancel and a Confirm button ("Confirm: buy for 60 g", "Confirm: sell for 30 g"; when gold is short it is disabled and says how much is missing). Handlers: `_on_shop_pick`, `_on_confirm_buy`, `_on_confirm_sell_item`, `_on_confirm_sell_sigil`; the direct `_on_buy` / `_on_sell_item` / `_on_sell_sigil` still act at once (tests use them). Prices use the town's `price_mult` and the section header shows it ("prices +25%").

**Touch scrolling.** Every card is a `TapCard`, not a Button (a Button swallows a finger drag that starts on it). After each build `_relax_mouse` sets every non-interactive Control to ignore the mouse so a drag that starts on a tile or a gap also scrolls. Plain buttons left inside lists (Unequip, Cancel / Confirm, Promote, Remove) still take a drag that starts on them.

### 4.5 Economy and balance principles
- No grinding: story and side quests supply enough EXP; optional battles scale slightly with party level.
- Wages scale with level/rarity, so a bloated roster is costly; platoon upkeep matters.
- Every class has a counter: heavy armor beats bows but loses to mages and crossbows; cavalry beats archers/mages but loses to spears in forest/ford; mages are fragile and slow.
- Budget target: player gear power grows ~12%/chapter; enemy power ~10%/chapter plus authored spikes at set-piece battles.
- Balance is validated with the headless battle simulator planned for Milestone 2.

---

## 5. Recruitment System

**Target roster:** 80 recruitable characters (1 protagonist + 79), delivered progressively (24 in Milestones 3–4, +56 by Milestone 7). Roster list in section 12.

**Implemented slice (v0.9.1):** `data/recruits.json` defines named companions with a character ID, story text, rumour, and requirement flags. The first authored lead is Hask Gravelteeth: winning `battle_01` sets `defeated_hask`; a Recruitment leads action at any town then offers his personal story and invite. Accepting adds his existing character definition to `PartyState`, marks `recruited_hask_gravelteeth`, and autosaves. This reuses the current roster/save model and adds no save-schema migration. It is a first vertical slice only; reputation, duel chains, recruitment costs, loyalty, relationships and the wider roster remain planned.

**Portrait presentation (v0.9.1):** original 512×512 portraits for Torren, Bram, Sela, Brother Wystan and Hask Gravelteeth are shown on the character-select profile and Party roster/sheet. New companions can use the portrait path convention `res://assets/portraits/<character_id>.png`; missing portraits fall back to the supplied Soldier sprite until art is authored.

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

### 11.1 Overworld: Eldrimar (v0.7.0; first version v0.6.0, Milestone 7 first step)
**What "open world" means here:** a free-roam overworld, not a seamless 3D-style open world. The player walks anywhere on a **452 x 340 tile map (153,680 tiles, 50 times the area of the v0.6.0 map of 64 x 48)**, 48 px tiles, top-down; battles stay on the tactical grid. Built for weeks of play: eight regions of rising danger, 39 places, 41 shops, 7 enemy camps and 9 ruins.
- **Data:** `data/world.json` (name, size, `start`, `safe_radius` 6, ambush thresholds 1000-2000, 8 `regions` with tier / rumours / label centre, 39 `places`, roads) and `data/world_map.json` (the baked land: two base64 byte layers, terrain and region, one byte per tile). `WorldMap.from_data` decodes it; the old noise generator stays for small test maps. Both files are produced by `tools/make_world.py` (run it, then `tools/make_content.py`); every place is checked to be reachable on foot from Kaer Sethorn.
- **Terrain** (speed / danger): road 1.4 / 0.3, bridge 1.2 / 0.3, grass 1.0 / 1.0, dry steppe 0.9 / 1.0, snow 0.75 / 1.2, hill 0.7 / 1.0, forest 0.6 / 1.6, marsh 0.55 / 1.3, ford 0.5 / 1.2; deep water and mountains block. Mountains are drawn as rocks (see 13.6).
- **Regions** (danger tier 1 easy to 5 deadly; drives enemies, ambush frequency and shop prices):

| Region | Tier | Places | Camps | Look |
|---|---|---|---|---|
| Sethmarch (home) | 1 | Kaer Sethorn keep, Crossing, Marrowmill, 2 ruins | Roadwolf Camp | thatch roofs |
| Orrowen Weald | 2 | Orrowen Hall (city), Thornwick, Yewgate, 1 ruin | none | thatch |
| Ysmark Coast | 2 | Brinegate (city), Salt Market, Gullrock, 1 ruin | Smugglers' Cove | thatch, ports charge least |
| Aurelmont | 3 | Aurelmont (city), Kingsway, Harrowgate, 1 ruin | Deserters' Camp | stone |
| Vessmoor Plains | 3 | Cindermead (city), Dustwell, Saddleback, 1 ruin | Sandjackal Camp | **sand** (original adobe colours) |
| Tarnholt Cloisters | 4 | Tarnholt Abbey (city), Candlemere, Saints' Vale, 1 ruin | none | stone |
| Quillon Heights | 4 | Quillon Tower (city), Starwick, Inkwell, 1 ruin | Flamebearer Camp | stone |
| Brennhallow Highlands | 5 | Brennhold (city), Ironford, 1 ruin | Greenhood Camp, Blackcrag Fastness | slate |

- **Movement:** tap to walk to a spot, hold and drag to steer; collision uses the four corners of the walker; the camera follows with smoothing.
- **Ambushes:** outside the safe radius (6 tiles around any keep, city, town or village) walking adds distance x terrain danger; at the threshold (1000-2000, 6% sooner per tier above 1) the region's own enemies attack. The battle is fought on a **12 x 10 patch cut from the overworld around the party** (`WorldMap.battle_patch`, one world tile = one battle tile), so a fight in a forest is fought in a forest. `EncounterBuilder._assemble` flattens the start cells and `_ensure_path` carves a ford or path if a river or cliff would cut the sides off. Each region has four weighted enemy groups (`data/encounters.json` "regions"); battle terrain gained sand, snow and marsh (`data/terrain.json`).
- **Camps:** a fixed fight with a named chief (`"camps"` in encounters.json: Hask Gravelteeth, Red Hallam, Marl Tidewick, Sergeant Odo Vell, Rukh Dustmane, Cinder Prophet Ismay, Castellan Brask Hollin). A victory sets `cleared_<id>`; the camp is drawn as cleared afterwards. **Ruins** pay a one-time purse and sometimes an item (`looted_<id>`).
- **Towns** (keep, city, town, village): "Shop: <name>" buttons (one per shop in that place, `GameData.shops_at(place_id)`), "Party and Gear", "Tavern rumours" (regional lines). **Camps and ruins have no shop, and neither does the wilderness** (see 4.7).
- **Discovery:** a place is drawn and named on the map only after the party came within 13 tiles of it (`seen_<id>`); the world map (Map button or tap the minimap) shows region names, discovered places and the player.
- **HUD:** top-left region / danger / terrain / gold; top-right Map, Company (view-only), Menu (Save, Load); bottom-left minimap (one pixel per 2 x 2 tiles); bottom-centre "Enter <place>"; top-centre banner for ambushes and discoveries. The Party screen sits on its own CanvasLayer (layer 20) so the HUD can never draw over it. Safe-area inset on both layers.
- **Saves:** payload `{"kind":"world","party":...,"world":{"pos":[x,y],"flags":{...}}}`; slots `world`, `auto_a`, `auto_b`, `1`; the newest wins at start ("Continue"). Autosave on entering a town, after a battle and when the app is paused. **Defeat:** the party loses 10% of its gold and wakes at Kaer Sethorn (the story is never blocked).
- **Hand-over:** `GameState.start_battle_from_world(def, place_id)` + `take_pending_battle()`; `GameState.world_pos` remembers where the player stood; the battle scene returns with "Back to the World".
- **Not yet:** day/night, weather, roaming enemies, fog of war, travel time in weeks, the HQ screen, interiors (medieval interior tiles will come from the user's next asset pack), recruitment in towns.

### 11.3 Story gates and travel (v0.7.9, feature `story_gates`; engine review pending)
**Implemented:** `tools/make_gates.py` generates `data/world_gates.json` with 927 compressed boundary runs, seven progression gates, place-action metadata and two journal quests. `WorldStory` evaluates flag, negated-flag, item and gold requirements. `WorldMap` now overlays sealed boundaries as mountains and derives a continuous short corridor through each gate's boundary from the baked region layer. Gate corridors restore their original walkable terrain only while the gate requirement is met; all other boundary cells remain blocked. `WorldMap.set_story_state()` refreshes the overlay after campaign flags or party inventory/gold change. The world scene supplies `GameState.world_flags` and the live party at map creation. The original `world.json` and `world_map.json` remain unchanged; save flags retain their existing names and format.
**Offline coverage:** tests assert only Sethmarch and Orrowen are reachable with all gates closed, every place is reachable when all seven gate requirements are met, and refreshing story state opens a pass without rebuilding the map. Static check is clean. **Not run in Godot:** engine import, headless suite and visual movement have not been verified. Step 4 adds gate visuals, bump hints, place-action buttons and the Journal UI. Step 5 finalizes documentation, static validation, checkpoint and the merge-ready `Feature_story_gates.zip`. In-engine layout/input review remains; see `docs/features/story_gates.md` and `docs/WIP.md`.' 
Some regions can only be entered through quests. Sealed region borders are mountain walls; the only way through is a pass on an existing road, closed by a gate (barricade, ward, iron gate, toll bar) until its requirements are met (flags such as `cleared_roadwolf_camp`, `lucan_oath`, `toll_paid`; `item:id`; `gold:N`). Free regions: Sethmarch and Orrowen. Ladder: Sethmarch -> Ysmark (Roadwolf camp), Orrowen -> Aurelmont (Lucan's oath), Ysmark -> Aurelmont (toll), Aurelmont -> Vessmoor (deserters), Aurelmont -> Tarnholt (pilgrim seal), Vessmoor -> Quillon (sandjackals), Tarnholt -> Brennhallow (Flamebearer camp). A closed gate shows its hint when the party bumps into it; the Journal lists open quests and barred ways. Implemented as an overlay file `data/world_gates.json` made by `tools/make_gates.py`, so the baked world is untouched. Details and steps: `docs/features/story_gates.md`. Fast travel between settlements is done (11.14). Later: horse and ship, fog-of-war map.


**World UI integration (v0.7.8):** closed corridor cells receive a red crossed-gate marker; colliding with a closed gate displays its authored hint. Place panels expose the Orrowen oath, Brinegate 150-gold toll and Kingsway pilgrim-seal actions only when requirements pass. Successful actions set the existing `GameState.world_flags`, refresh `WorldMap` with the live party, and autosave. The top HUD Journal lists quests after their first flag and marks completed quests. In-engine placement, touch interaction and layout still require verification.

### 11.5 Settlement silhouettes (v0.8.5, feature `town_buildings`)
**Goal:** make the 23 inhabited settlements visually distinct on the free-roam map, using only the supplied voxel-building renders already in the project.
- **Data:** `data/town_buildings.json` stores a hand-authored layout for each keep, city, town and village. Each place entry defines a short style label, palette and 3-7 sprite placements (`sprite`, `x`, `y`) relative to its world-map marker.
- **Rendering:** `GameData.town_buildings` loads the JSON at startup. `WorldScene._draw_place()` uses the place-specific layout and palette when present, while retaining `PLACE_LAYOUT` as a fallback for legacy/custom settlement data and fallback shapes when a texture is missing.
- **Distinct silhouettes:** Kaer Sethorn, Orrowen Hall, Brennhold, Tarnholt Abbey, Quillon Tower, Aurelmont, Cindermead and Brinegate receive landmark compositions; smaller villages, coaching inns, markets, forge towns and fishing settlements have different authored clusters.
- **Validation:** `tools/make_town_buildings.py` regenerates the JSON deterministically from its authored layout table and checks every settlement, palette and referenced PNG. `_test_town_buildings()` covers all 23 settlement records and the accepted sprite/palette schema.
- **Scope:** this is overworld settlement art only. It does not add explorable town interiors, new voxel models, collision, shops or NPCs. The supplied voxel packs' licences remain unverified; see `docs/ASSETS.md`. Godot scene import, visual scale/overlap and phone readability still need in-engine review.

### 11.6 Overworld presentation polish (v0.8.6, feature `world_map_polish`)
**Goal:** give the free-roam Eldrimar map a richer, readable JRPG overworld presentation without changing its 452 × 340 baked terrain, movement rules, encounter balance, story gates or offline data.
- **Terrain dressing:** `WorldScene._draw_tile()` adds stable, cell-seeded ground flecks, layered forest canopies and trunks, hill contour lines, water/ford ripples, marsh reeds, sand striations and snow flecks. Every detail is derived from `WorldMap.hash01(x, y, layer)`, so it does not flicker or depend on runtime random state.
- **Road readability:** road cells draw connected, outlined paths using adjacent ROAD/BRIDGE cells; bridge tiles receive a distinct timber deck and cross-planks. This is a rendering overlay only: `WorldMap` passability, terrain IDs, encounter danger and battle-map conversion are unchanged.
- **Landmarks:** discovered settlements receive a subdued ground plinth and gold-toned ring beneath their authored building composition. Name plaques improve contrast and keep labels legible against terrain. Existing palette overrides, discovery rules, sprites and fallback drawings remain intact.
- **Performance and assets:** decoration is drawn only for visible cells in the existing camera viewport. No new textures, external calls, permissions or licensed assets are introduced. Rendering uses existing CanvasItem primitives and deterministic hash values.
- **Validation:** `python3 -I tools/gd_static_check.py` and `python3 -I tools/build_apk.py --check` pass. Godot import, headless tests, frame-time, overlap and phone readability have not been verified because Godot is unavailable in this environment.

### 11.4 Pre-rendered rooms, keeps and dungeons (v0.7.4, feature `pre_rendered_rooms`)
**Goal:** the Final Fantasy VII recipe for places you walk into: a fixed pre-rendered picture, a small hero on a hidden walk grid, props that pass in front of him, screen-to-screen room changes, random encounters in dungeons.
- **Source art:** nine voxel room models (Boss Room, Dragon Room, Garden, King's Throne, Princess Chamber, Stairs, Thirsty Corridor, Trapped Room, Treasure), 50 x 50 x 50 voxels each, rendered by `tools/build_scenes.py` into 404 x 448 backgrounds (true 2:1 dimetric, rotation 2, ambient occlusion) plus occluder slices. Licence of the packs is unverified (`docs/ASSETS.md`).
- **Data:** `data/rooms.json` (generated: projection, 50 x 50 walk grid, base-36 floor heights, slice placement) and `data/sites.json` (authored: a *site* is a keep or dungeon made of rooms; each room has `room` model, `spawn`, `exits` with rectangles and target spawn cells, `spots`, optional `enc` [min, max] cells between encounters). A place in `data/world.json` with `"site": "<id>"` gets an *Enter* button on the overworld.
- **Spots:** `text` (people, inscriptions), `party` (war table: gear and sigils, view of the company), `chest` (one-time loot, `chest_id`, `gold`, `items`, flag `chest:<site>:<room>:<id>` in `world_flags`), `battle` (a boss: `battle`, `clear_flag`; stays dead; `requires_flag` shows things only after a flag).
- **Sites now:** `keep` (Kaer Sethorn: Great Hall, Lord's Chamber), `hollow` (Beneath Dunmarrow Barrow, 7 rooms, boss the Hollow Warden on `battle_02`, encounter table `skirmish_hollow`) and `watchtower` (the Old Watchtower ruin: two connected rooms using the existing corridor and stairs renders).
- **Rules:** `RoomMap` (pure logic) projects cells to pixels, unprojects taps, routes with BFS plus line-of-sight smoothing, finds exits, and `validate()` checks every site (used by `_test_rooms`). Walk speed 11 cells per second; random encounters need 110 to 260 cells of walking; the spring room is safe.
- **Hand-over:** `GameState.pending_site/room/spawn`, `start_battle_from_room`, `return_from_battle`; a battle started in a room returns to the same room and cell.
- **Room persistence (v0.8.4, feature `room_resume`):** the world-save payload has an optional `world.room` object (`site`, `room`, `cell:[x,y]`). Old saves without it remain valid. Entering/changing rooms and opening a chest autosaves; app pause records the live cell and autosaves. Home Continue/Load and world Load route to `Room.tscn` when the saved site/room exists, otherwise to `World.tscn`. Leaving a site clears the room marker and autosaves the overworld state. This stores the room and hero cell, not a live movement route or transient panel state.
- **Not yet:** a swirl transition, light effects, buildings of towns drawn from the voxel sets, more sites (Ancient Temple, Rock Statues, Cosmic Portal models are unused), town interiors (older line, `town_interiors` pack).

### 11.7 The Old Watchtower (v0.8.7, feature `watchtower_site`)
**Goal:** extend the explorable overworld with a compact, optional location while the engine-review environment remains unavailable.
- **World link:** the existing Sethmarch ruin `watch` now points to site `watchtower`; the ruin keeps its existing one-time overworld search reward and can also be entered.
- **Rooms:** `lower` / The Fallen Watch uses the existing Thirsty Corridor render; `crown` / The Upper Watch uses the existing Stairs render. Exit pads connect the two rooms and return the party to the world.
- **Content:** the Muster Roll and Signal Brazier provide short lore; the Watch Captain's Lockbox grants 65 gold once, using a unique chest ID.
- **Validation:** `_test_rooms()` now asserts the site loads, has two rooms and is linked from the overworld place. The existing `RoomMap.validate()` covers the room geometry, reachable exits/spawns/spots and connected room graph. A Python parity check of those walk-grid rules passed for all 3 sites / 11 rooms.
- **Scope and risks:** reuses the already included room renders; no new art or save fields. The voxel-pack licence remains unverified (`docs/ASSETS.md`). Godot import, test execution, transition/chest persistence and phone visuals remain unverified.



### 11.8 Room transition polish (v0.8.8, feature `room_swirl_transition`)
The room scene's full-screen transition overlay uses `assets/shaders/room_swirl.gdshader`, a procedural radial spiral wipe with a deep-ink field and restrained ember/gold glints. `RoomScene._fade()` tweens the shader progress value; the existing room-exit and random-encounter callbacks retain their ordering. The destination room is loaded while the wipe is fully closed, then revealed with the reverse wipe. The same full-close transition precedes leaving a site or entering a battle. A missing shader material falls back to invoking the transition callback so navigation does not stall. No texture assets, save fields or online dependencies are added. Godot shader compilation, visual quality, timing and mobile performance remain unverified.

### 11.12 Recruitment profile cards (v0.9.3)

Recruitment Hall cards now include authored origin, personal-quest title, a compact combat-stat preview (level, HP, STR, DEX, INT and SPD), and an explicit readable condition line while a lead is locked. These fields are data-driven in `data/recruits.json`; combat values are read from the recruit's existing `data/characters.json` definition. This is presentation-only: requirement tokens, roster insertion, duplicate prevention, recruited flags and autosave remain unchanged. Tests verify each named recruit has origin, personal-quest and condition copy. Static checks only; Godot layout, scrolling, portrait crop and touch behavior remain unverified.

### 11.11 Recruitment expansion (v0.9.2)

Edda Stonehand is a Wallwright from Brennhallow whose lead appears after visiting Ironford (`seen_ironford`). Joss Harrow is a Cutpurse whose lead appears after searching the Wreck of the Gilded Hind (`looted_gilded_hind`). Their `data/recruits.json` entries carry distinct `town_contact` and `hidden_location` methods, rumours, histories and joining lines; their complete combat definitions live in `data/characters.json`. Both use the existing requirement evaluator, party roster insertion, recruitment flag and autosave path. No save schema or network permission changed. Distinct portraits for Edda and Joss are now present at `assets/portraits/edda_stonehand.png` and `assets/portraits/joss_harrow.png`, using the shared 512×512 portrait convention.

### 11.9 Recruitment Hall and character portraits (v0.9.1)

The town tavern's Recruitment leads action now opens a portrait-led Recruitment Hall. Each visible candidate is a framed card with a large character portrait, name, class, personal story or rumour, and a clear state. An unlocked candidate also shows their joining line and an Invite button; a locked lead explains that its story condition is not yet met. Already-recruited characters are hidden. The Back action returns to the town panel.

Portraits are original generated art stored in `assets/portraits/`: Torren, Sela, Brother Wystan and Hask Gravelteeth were added; Bram's existing portrait is retained. The Company roster already reads `assets/portraits/<character_id>.png`, so the new protagonist portraits appear there without changing party rules. Recruitment remains data-driven through `data/recruits.json`; Hask's existing `defeated_hask` requirement, party membership check, recruitment flag and world autosave are unchanged. No save schema, network permission or online dependency was added.

**Verification:** source-level static check and data validation only. Godot import, runtime layout, portrait crop quality and touch interaction have not been reviewed in-engine or on a phone.

### 11.10 Room transition source regression guard (v0.8.9)
`tools/check_room_transition.py` verifies the source-level contract between `assets/shaders/room_swirl.gdshader` and `RoomScene`: CanvasItem shader/progress/alpha output, shader resource loading, initial parameter value, material assignment, tween property, missing-material callback fallback, room/site exit wipe, destination reveal and dungeon-encounter wipe. `tools/checkpoint.py` runs this check and records its result; a failed check makes the checkpoint fail. This is deliberately a source-wiring check only: it does not parse or compile Godot shader code, execute scenes, measure frame time or assess visual quality. Godot import, headless tests and phone review remain required. No game behavior, save schema, assets, permissions or network code change.

### 11.13 Asset library, music and credits (v0.9.4)
All user-supplied packs are stored in the project and credited; the creator is Jose Basinillo Jr. and the game is for private use. Sprite and tile packs live in `assets/library/` (ignored by Godot until promoted with `tools/promote_asset.py`); music is converted to OGG in `assets/audio/music/` and `AudioManager.start_music(context)` plays the track that `data/audio.json` assigns to `home`, `world`, `battle` or `room`, falling back to the generated drone when a file is missing. `data/credits.json` is the single source for `CREDITS.md` and for the Home screen Credits dialog (`HomeScene.credits_text()`); `tools/credits.py check` verifies it. Tests: `_test_credits_and_audio`. Not run in Godot: music loop flag and volume balance need a listen on the phone.

### 11.14 Waystone fast travel (v0.9.5)
FF7 and Suikoden II travel idea, kept small: a waystone stands at the gate of every settlement. From inside a settlement's safe ground the Map panel's **Fast Travel** button lists every settlement already seen (`seen_<id>`), nearest first, with its price and distance. A town behind a shut story gate is "cut off" (the check is a flood fill over the live map, so a waystone never skips a gate), and a trip the party cannot pay for is disabled. Price: 3 gold per 10 tiles of straight-line distance, a multiple of 5, between 10 and 120, the same both ways (`data/travel.json`). Arrival uses a short black wipe, resets the ambush counter, charges the fare and autosaves. No save-schema change. Logic: `scripts/world/fast_travel.gd`; offline check: `tools/check_fast_travel.py`; details: `docs/features/fast_travel.md`. Later: horse and ship (`transports`), fog-of-war map (`map_fog`).

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

### 13.6 Pre-rendered voxel sprites for the overworld (v0.7.0)
The user supplied MagicaVoxel `.obj` building packs (8 buildings) and a rock pack. Godot's 2D renderer cannot draw `.obj` and loading 3D models on a phone wastes battery, so `tools/render_voxels.py` draws each model **once** with a small software rasteriser (orthographic three-quarter view, yaw 38 deg, pitch 32 deg, flat shading, 1 px dark outline) into PNGs under `assets/sprites/world/`. Names: `<model>_<palette>.png` (tiny, small1, small3, small4, large1, tall1-3; palettes stone, thatch, slate, sand) and `rock<0-9>_<grey|sand>.png`. Palette swap is by palette index at render time: **stone / thatch / slate** are medieval recolours for the Marches; **sand** keeps the original adobe colours for Vessmoor. Sprite heights: tiny 64 px, small 84, large 118, tall 150-170, rocks about 54 px wide. `world_scene.gd` composes each place from `PLACE_LAYOUT` (village 3 buildings, town 4, city 5, keep 4, ruin ruins and rocks) and falls back to drawn shapes when a PNG is missing. The Tiny RPG Soldier idle/walk sheets (100 x 100 frames) are the overworld walker. Sources and licence notes: `docs/ASSETS.md`. The HoMM-style reference images the user attached are **reference only** and are not used (original-IP rule).

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

### 14.3 Character select and hero designs (v0.7.2, feature `character_select`)
**Flow.** Start menu -> New Game -> `CharacterSelect.tscn` (`scripts/ui/start_scene.gd` wires it to the autoloads) -> `GameState.begin_campaign(lead_id, appearance)` -> `World.tscn`. `CharacterSelect` (`scripts/ui/character_select.gd`) reads no autoloads (`setup(looks, start, characters, classes)`), so the headless tests build it. Layout (1280x720, phone safe-area insets): left a stage with the four protagonists in the starting-party order (tap to select; the selected one is drawn larger on a gold card and plays its attack every 3.4 s); right a parchment panel with name, class | house | level, tagline, combat role, design note, six stat tiles (HP, STR, DEX, VIT, SPD, EVA) and one 76 px Begin button. Torren also has Hair and Scarf rows with `<` `>` buttons.
**What the choice does.** The chosen hero is the **lead**: the walker on the overworld and first in the roster (`HeroLooks.roster_with_lead_first`). It changes no stats, story or battle rule; Torren stays the story's protagonist. `lead_id` and Torren's `appearance` are saved in the world save payload (`"look"`; saves without it load with the defaults).
**Rules (pure code).** `scripts/core/hero_looks.gd` over `data/looks.json`: sprite kind per hero (`torren_<hair>_<scarf>`, `bram`, `sela`, `wystan`; others keep the Soldier), draw scale, accent colour, validation (unknown values fall back to the defaults), wrap-around option stepping, valid lead. `scripts/core/hero_art.gd` (`HeroArt`) loads and draws the 100x100 frame strips and falls back to the Soldier when a sheet is missing.
**Design rules** (silhouette first, 2-3 colours per character, one signature accent, size difference carries meaning).
| Hero | Silhouette | Palette and accent | Size | Own animation |
|---|---|---|---|---|
| Torren Dunmarrow | bare head, windswept tuft, scarf with a swaying tail | charcoal gambeson; accent ember orange (also gilt, ash); hair raven / chestnut / ash-blond | 1.00 | recoloured sword attack |
| Sir Bram Vosk | plumed great helm, broad pauldrons, grey beard | polished steel, bone-white tabard; accent oxblood plume | 1.12 | recoloured sword attack |
| Sela Wrenfield | pointed hood, auburn braid, long bow at the back | forest green hood, leather jerkin; accent green | 0.96 | bow draw and release (synthesised) |
| Brother Wystan | bare tonsured crown, lantern staff taller than the head | vesper-indigo robe; accent amber lantern | 1.00 | lantern flare (synthesised) |
**Art pipeline.** `tools/make_hero_sprites.py` (Pillow + numpy) recolours and adds pixels to the Tiny RPG Soldier sheets kept in `tools/sprite_src/`, writes 12 sheet sets (60 PNGs) to `assets/sprites/characters/heroes/` with the Soldier's frame layout (idle 6, walk 8, attack 6, hurt 4, death 4). Overlays follow the helmet position of each frame; the two fallen death frames are only recoloured. Previews: `docs/hero_designs.png`, `docs/torren_colourways.png`.
**In battle (v0.7.3, feature `hero_battle_sprites`).** Player units are drawn with their hero sprite: idle loop, walk while moving, attack when they act, hurt flash when hit, blue team ring, per-hero size; enemies and units without a sheet keep the drawn figure. The battle scene redraws about 14 times a second for the idle animation (`ANIM_REDRAW_STEP`). No death animation yet.
**Known limits.** Recolour-and-overlay on a 17x21 px base, not new hand-drawn art; equipment is not shown (Torren has an iron cap in the data but is drawn bare-headed) until the paper-doll layers of section 13 exist; no portraits; name not selectable; no Back button on the select screen; enemies still draw shapes (no Orc sheet in this line). The paid full Tiny RPG pack (20 characters incl. Knight, Archer, Priest) could give hand-drawn Bram/Sela/Wystan, but its frame layouts were not seen. Not run in Godot.

### 14.4 Home screen (v0.8.3, feature `home_screen`, step 4/4)
`Home.tscn` is the application entry scene. The first screen presents the Kindlewake title, **Continue** (newest recognized save), **Load Game** (explicit slot picker) and **New Game** with a confirmation dialog. New Game opens the existing `CharacterSelect.tscn`, preserving lead selection and Torren's appearance choice.

`SlotPicker` presents manual slots (`world`, `1`, `2`, `3`) and rotating autosaves (`auto_a`, `auto_b`), including save summary and timestamp. Empty slots are disabled for loading; overwriting an occupied manual slot requires confirmation. The world-menu Save and Load controls use this picker. The existing autosave rotation, local checksummed/atomic save envelope and world payload format are unchanged. Battle payloads are identified and skipped/refused rather than misapplied as world saves; load them from the battle HUD.

**Settings and audio (step 3/4).** `SettingsStore` (`scripts/core/settings_store.gd`) stores master/music/SFX volume, screen-shake preference and battle Auto Battle in local `user://settings.cfg`; it is independent of campaign save payloads and clamps volume to 0-1. `AudioManager` (`scripts/core/audio_manager.gd`) creates Music and SFX buses and synthesizes a quiet ambient loop, UI preview tone and gate-open chime in memory. No audio assets or network access are required. The reusable `SettingsPanel` exposes master/music/SFX sliders from Home and the world menu. Battle Auto Battle now uses the shared store while retaining its existing `[battle] auto_battle` key.

**Navigation completion (step 4/4).** The legacy Continue/New Game boot overlay has been removed from `world_scene.gd`. `Home.tscn` is the sole campaign entry point; Continue, Load Game, confirmed New Game and Settings are handled there. The world menu remains focused on in-world Save, Load and Settings. App pause now updates the world position and autosaves without relying on the obsolete boot flag. A regression test checks the configured Home entry scene, required scene resources and removal of the old overlay. The `home_screen` feature is implementation-complete; Godot import, runtime scene transitions, audio playback, visual layout and touch interaction remain unverified.

## 15. Offline Technical Architecture

**Engine:** Godot 4.2+, GDScript, GL Compatibility renderer (broadest mobile support). The exported Android manifest must **not** request the INTERNET permission, which guarantees there is no network usage.

**Autoloads (singletons):** `SettingsStore` (offline user preferences), `AudioManager` (generated local audio and buses), `GameData` (read-only database), `SaveSystem` (slots/integrity), and `GameState` (runtime campaign state). Battle Auto Battle preference is stored by `SettingsStore` alongside volume values in `user://settings.cfg`.

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

### 15.2 Checkpoints and feature packs (added v0.7.0)
- `python3 -I tools/checkpoint.py --note "..." [--done]` makes the project downloadable and resumable at any time: it runs the static check and the JSON check (recorded, not blocking), writes `docs/CHECKPOINT.md` (status WIP or RELEASE, version, results, note, `docs/WIP.md`, merged features), builds `Kindlewake_Project.zip` (one top-level `Kindlewake/` folder, needed by the phone build workflow) and copies `GDD_Kindlewake.md` and `CONTINUATION_PROMPT.md` beside it (default `/mnt/user-data/outputs`). Fixed names, no versions in names.
- `python3 -I tools/merge_features.py pack|apply|list` builds and merges `Feature_<id>.zip` packs so features can be developed in separate sessions: new files are added, untouched files fast-forward, `data/*.json` is merged three ways by key (lists of `{"id":...}` by id), anything else changed on both sides is a conflict that never overwrites (the incoming copy is saved as `<file>.incoming`). Dry run by default, backups in `.merge_backup/<id>/`, merged features recorded in `docs/FEATURES.json`. Tested offline with a demo pack (add, merge, conflict, repeat refusal).

## 16. Development Roadmap

| # | Milestone | Exit criteria |
|---|---|---|
| 1 | Playable tactical combat prototype | Data-driven grid battle: CTB turns, A*/Dijkstra movement, ranges, hit/crit, flank/height/terrain, AI, victory/defeat, touch input, save/load slot with checksum, headless tests |
| 2 | Stats, classes, leveling, equipment | Full stat sheet, class data, EXP/level-up, promotion, equipment slots, skills v1, battle simulator for balance |
| 3 | Recruitment and character management | Roster UI, 24 Wave-1 characters with data, recruitment flags/quests, loyalty |
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

## Revision log

| Version | Change |
|---|---|
| 0.9.5 | Feature `fast_travel`: waystone fast travel between seen settlements from inside a settlement's safe ground, priced by distance (`data/travel.json`), blocked by shut story gates, with a Fast Travel button and Waystone panel on the Map, a black wipe on arrival and an autosave. New `FastTravel` logic class, `tools/check_fast_travel.py` (offline, mutation-tested) and `_test_fast_travel()`. No save-schema change. Not run in Godot. |
| 0.9.4 | Asset library (17 sprite and tile packs), 40 OGG music tracks wired per scene through `data/audio.json`, credits for all packs (`data/credits.json`, `CREDITS.md`, Home Credits dialog; creator Jose Basinillo Jr.), `tools/credits.py`, `tools/promote_asset.py`. Not run in Godot. |
| 0.9.3 | Enriches portrait-led Recruitment Hall cards with origin, personal quest, combat-stat preview and authored locked-condition copy for Hask, Edda and Joss. No recruitment rule or save schema change. Static checks only; Godot layout/runtime review pending. |
| 0.9.2 | Adds Edda Stonehand and Joss Harrow as named recruits with distinct Ironford-visit and Gilded-Hind-loot unlock paths, full character data, authored stories and individual portraits. Static checks only; Godot runtime remains unverified. |
| 0.9.1 | Adds original character portraits and a portrait-led Recruitment Hall card UI; preserves existing recruitment conditions and autosave. Not run in Godot. |
| 0.9.0 | Adds four original 512×512 hero portraits to character select and Party UI; introduces data-driven named recruitment leads (`data/recruits.json`) and the first story recruit, Hask Gravelteeth, unlocked by winning `battle_01` and invited from town Recruitment leads. Recruitment is added to the existing party roster/save model; no save schema change. Static checks only; Godot UI/runtime review remains. |
| 0.8.9 | Adds `tools/check_room_transition.py` and makes `tools/checkpoint.py` run/record the shader-to-RoomScene source wiring regression guard; no gameplay or save-schema changes. Source-only check passes; Godot compilation/runtime review remains required. |
| 0.8.8 | Feature `room_swirl_transition`: adds a procedural radial spiral shader wipe to room exits and dungeon encounters, preserving existing transition callbacks and autosave flow; no new assets or save fields. Static checks and offline preflight pass; Godot shader compilation and phone visuals not run. |
| 0.8.7 | Feature `watchtower_site`: links the existing Old Watchtower ruin to a two-room explorable site using existing corridor/stairs renders; adds lore spots and a one-time 65-gold chest; extends `_test_rooms()`. Corrects Godot project and Android export version metadata to 0.8.7; save schema unchanged. Python walk-grid parity validation passes for 3 sites / 11 rooms; Godot import/tests/visual review not run. |
| 0.8.6 | Feature `world_map_polish`: deterministic terrain dressing, connected road/bridge rendering, settlement plinths and readable label plaques in `WorldScene`; no world data, movement, save payload or asset changes. Static checker clean and APK preflight passes; Godot import/tests/visual performance not run. |
| 0.8.5 | Feature `town_buildings`: added authored `data/town_buildings.json` silhouettes for all 23 settlements, loaded by `GameData` and rendered per place in the overworld with palette and legacy fallbacks; added deterministic generator/checker and `_test_town_buildings()`. Static checker 0 errors/0 warnings, generator check passes, 20 JSON files valid and APK preflight passes; Godot visual review/headless tests not run. |
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
| 0.7.0 | Eldrimar (11.1): 452 x 340 baked world (50x area), 8 regions of tiers 1-5, 39 places, 7 camps, 9 ruins, regional ambush groups fought on 12 x 10 patches cut from the map, discovery, world map, world saves, defeat penalty; shops only in towns (4.7: per-town stock, `price_mult`, `shops_at`), view-only Company screen outside towns, header fix; voxel buildings and rocks pre-rendered to 2D (13.6) with a medieval recolour and sand for Vessmoor, Tiny RPG Soldier as walker; `tools/checkpoint.py` and `tools/merge_features.py` (15.2); tests rewritten for all of it. Not run in Godot. |
| 0.7.1 | Feature party_ui: Party screen redesign (cards, stat tiles, green/red gear deltas, Bag list, message banner, Back button, kept scroll), shop compare-before-buy and Confirm on every buy and sell, `TapCard` touch scrolling, `ItemInfo.delta_parts`; keeps the v0.7.0 view-only and per-town shop rules. Not run in Godot. |
| 0.7.2-wip | Checkpoint: plan for quest-locked passes (section 11.3, feature `story_gates`), reference world prototype in `tools/prototypes/eldrimar2/`. No game code changed. |
| 0.7.2 | Feature character_select (14.3): New Game opens a character select; choose a lead among the four protagonists (walker + roster order), Torren's hair and scarf colour selectable; unique sprite design per hero (12 generated sheet sets, `tools/make_hero_sprites.py`); `HeroLooks`, `HeroArt`, `data/looks.json`; lead and colours saved in the world save. Tiny RPG sheet licence confirmed from the author's page (edit freely, no resale/redistribution). Not run in Godot. |
| 0.7.3 | Feature hero_battle_sprites (14.3): player units are drawn with their hero sprites in battle (idle, walk, attack, hurt), labels shared with the drawn figures, `HeroArt` tests. Not run in Godot. |
| 0.7.5 | Story gates step 1: generated `data/world_gates.json` overlay from the baked Eldrimar map, with 927 boundary runs, seven gates, place actions and two quest definitions (`tools/make_gates.py`). Runtime movement not yet integrated. |
| 0.7.6 | Story gates step 2: added `WorldStory` requirement evaluation, gate state, quest state and journal-line helpers; tests for flags, negated flags, items, gold and quest progress. |
| 0.7.7 | Story gates step 3: `WorldMap` overlays sealed region boundaries as mountain barriers and opens continuous authored road corridors only when gate requirements pass; offline reachability checks added. |
| 0.7.8 | Story gates step 4: world-scene closed-gate markers and bump hints; Orrowen oath, Brinegate toll and Kingsway pilgrim-seal actions; refresh/autosave; Journal overlay. Engine visual/input review remains. |
| 0.7.9 | Story gates step 5: finalized feature documentation, WIP and handoff; static checker 0 errors/0 warnings, gate generator check passes, all 19 JSON data files valid; created merge-ready `Feature_story_gates.zip` against v0.7.4. Not run in Godot. |
| 0.8.0 | Feature `home_screen` step 1/4: added `Home.tscn` and `HomeScene`; Continue restores the newest existing save, New Game confirms then opens the existing character select; main scene now starts at Home. Static checker clean; not run in Godot. |
| 0.8.1 | Feature `home_screen` step 2/4: added reusable manual/autosave `SlotPicker`, Home Load Game, world-menu manual Save and explicit Load, overwrite confirmation and save-slot ID tests. Preserves rotating autosaves and save payload format. Static checker clean; Godot tests/layout not run. |
| 0.8.2 | Feature `home_screen` step 3/4: persistent offline `SettingsStore`, generated placeholder `AudioManager`, shared battle Auto Battle preference, SettingsPanel on Home and world menu, and settings persistence tests. Static checker clean; Godot import/tests/audio/touch review not run. |
| 0.8.3 | Home screen feature `home_screen` step 4/4: removed the legacy world boot overlay and duplicate Continue/New Game flow; Home is the sole entry point, world pause autosaves without the legacy boot flag, and navigation regression checks were added. Feature implementation complete; Godot review pending. |
| 0.8.4 | Feature `room_resume`: world saves optionally persist the current pre-rendered site, room and hero cell; Home Continue/Load and world Load resume that room; room entry/transition, chest rewards and app pause autosave; leaving a site clears the room marker. Old saves without `world.room` remain compatible. Added save-payload coverage. Static checker clean; Godot tests and runtime resume flow not run. |
| 0.7.4 | Feature pre_rendered_rooms (11.4): FF7-style pre-rendered rooms from nine voxel room models (`tools/vox_iso.py`, `tools/build_scenes.py`, `data/rooms.json`, `data/sites.json`), `RoomMap`, `Room.tscn`, Kaer Sethorn keep (Great Hall, Lord's Chamber) and the 7-room dungeon Beneath Dunmarrow Barrow with chests, random encounters, boss `battle_02` and `skirmish_hollow`; battles return to the room. Not run in Godot. |
