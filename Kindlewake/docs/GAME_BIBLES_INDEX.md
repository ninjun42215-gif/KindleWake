# KindleWake — Master Game Bibles Index
## Base44 reading order and source-of-truth map

This index gathers the separate bibles needed to understand and develop the game. It is deliberately modular: lore, mechanics, production quality, technical implementation and current status should not be collapsed into one enormous document.

## Read these first

1. **[Base44 Start Here](BASE44_START_HERE.md)** — repository rules, architecture constraints, safe workflow and reading order.
2. **[In-Depth Lore Bible](LORE_BIBLE.md)** — canon, story, history, characters, continents, factions, territories and regional bestiary direction.
3. **[Game Mechanics Bible](MECHANICS_BIBLE.md)** — campaign loop, combat formulas, CTB, terrain, progression, classes, skills, runes, traits, recruitment, platoons, kingdom/empire systems and mini-games.
4. **[Game Vision and Requirements](GAME_VISION_AND_REQUIREMENTS.md)** — what the owner wants the finished game to become and acceptance criteria.
5. **[Current Game State and Gap Analysis](CURRENT_GAME_STATE_AND_GAP_ANALYSIS.md)** — what is documented as current, what is unverified, limitations and next implementation priorities.

## Existing detailed bibles — preserve and use

| Document | What it governs | How Base44 should use it |
|---|---|---|
| [Game Design Document](GDD.md) | Detailed rules and historical design: core loop, combat, damage, turn order, classes, progression, recruitment, platoons, army battles, Kaer Sethorn, legacy mode, story, world, characters, sprites, mobile UI and offline architecture | Treat as the deep mechanical reference; inspect the relevant sections before changing a system. It contains historical notes, so verify current implementation. |
| [Premium Production Bible](PREMIUM_PRODUCTION_BIBLE.md) | Creative direction, emotional experience, narrative quality, premium visual/audio standards, mobile UX, chapter production and release guardrails | Treat as the quality bar for all content and presentation. |
| [Lore Bible](LORE_BIBLE.md) | World and narrative canon | Do not introduce contradictions or unapproved retcons. |
| [Mechanics Bible](MECHANICS_BIBLE.md) | Consolidated mechanics contracts and system interactions | Use for cross-system consistency; GDD remains the detailed formula/history reference. |
| [Vision and Requirements](GAME_VISION_AND_REQUIREMENTS.md) | Owner-requested features and intended final scope | Treat planned features as targets, not shipped claims. |
| [Current State and Gap Analysis](CURRENT_GAME_STATE_AND_GAP_ANALYSIS.md) | Implementation status and known gaps | Update after every meaningful code PR with exact evidence. |

## How to interpret status

Use four labels consistently:
- **VERIFIED IMPLEMENTED:** present in current main source and exercised by relevant tests.
- **IMPLEMENTED, NOT DEVICE-VERIFIED:** source/tests exist, but physical Android QA is outstanding.
- **DESIGNED / REQUESTED:** appears in a bible, roadmap or GDD, but runtime implementation is not verified.
- **BLOCKED / DEFERRED:** cannot ship until a dependency, licence, architecture or design decision is resolved.

A design document is never proof that a feature exists. A backend/data foundation is not the same as a finished player-facing system. A successful APK build is not proof of physical device QA.

## Architecture contract for Base44

KindleWake remains a Godot 4.2+ GDScript game with a fully offline local runtime and save system. Base44 is being used as a development assistant/basis; it must not convert the game into a Base44-hosted web app or replace the existing Godot project, JSON data, local saves, battle engine or offline play with cloud services.

Before implementation, inspect:
- `Kindlewake/project.godot`;
- `Kindlewake/data/` and all relevant JSON definitions;
- `Kindlewake/scripts/core/`, `scripts/battle/`, `scripts/ui/`;
- `Kindlewake/tests/`;
- the current exact main commit and open PRs;
- the relevant GDD, mechanics, lore and production sections.

For every change, provide a plan, modify the existing architecture, test it, preserve old saves, and update the current-state bible with exact commit and evidence.
