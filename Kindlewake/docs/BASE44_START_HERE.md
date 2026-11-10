# KindleWake — Base44 Project Bible (Start Here)

**Purpose:** This folder is the authoritative handoff for AI-assisted development of KindleWake. Read this file first, then the three companion documents:
1. [In-Depth Lore Bible](LORE_BIBLE.md)
2. [Intended Game Vision and Requirements](GAME_VISION_AND_REQUIREMENTS.md)
3. [Current Game State and Development Gap](CURRENT_GAME_STATE_AND_GAP_ANALYSIS.md)

The existing [Game Design Document](GDD.md) and [Premium Production Bible](PREMIUM_PRODUCTION_BIBLE.md) remain important detailed references. This new set does not replace implementation documentation; it reconciles the creative vision, player requests and verified current state for Base44.

## Authority and conflict rules

- Repository: `ninjun42215-gif/KindleWake`; canonical Godot project folder: `Kindlewake/`; default branch: `main`.
- Engine: Godot 4.2+, GDScript, GL Compatibility. The project is offline-first and mobile-oriented.
- Read the actual current `main` files before coding. Documentation can lag behind code. Treat runtime source, data files, tests and current CI evidence as the truth for what is implemented.
- Treat **CURRENT / VERIFIED** as shipped only when confirmed in the current source tree. Treat **DESIGNED / REQUESTED / FUTURE** as requirements, not completed features.
- If two documents conflict, prefer (1) current code and data, (2) tests and current CI, (3) the current-state report, (4) GDD and production bible, (5) older handoff notes. Report unresolved conflicts; do not silently invent a resolution.
- Never turn a concept, suggestion, old branch note or planned scene into a claim that it exists in the game.
- Do not delete or replace existing game systems to make a feature easier. Extend existing architecture and preserve existing content.

## Non-negotiable technical guardrails

- Fully offline: no account, backend, server, multiplayer, telemetry or required internet connection. Do not add Android INTERNET permission.
- Preserve all existing player saves and save schema compatibility. Any persistent-state change requires safe defaults/migration and regression tests.
- Keep data-driven content in the existing JSON/data architecture where appropriate. Reuse the current autoloads and systems rather than building parallel implementations.
- Maintain touch, keyboard and controller paths where the existing feature supports them. Respect portrait/landscape layouts, safe areas and readable touch targets.
- Use original KindleWake characters, prose, maps, sprites and music. Named inspirations are reference points for design quality/mechanics only; do not copy protected characters, stories, maps, art, music or dialogue.
- Unknown asset licences are not cleared. Do not bundle or redistribute assets with unverified rights.
- Work on a short-lived branch and submit one focused PR. Do not edit `main` directly. Do not merge automatically or bypass the established exact-head CI/review gates.
- Do not claim Android device QA based on headless tests or APK export.

## What the game is

KindleWake: **The Sundered Vow** is an offline-first, character-driven medieval fantasy tactical RPG. It is a company drama about people choosing to stand together after institutions fail them. The player-created heir of House Dunmarrow inherits a damaged legacy, a ruined keep and a mystery tied to the Covenant of Seven Flames. The campaign should grow from personal survival into a realm-wide political reckoning, with tactical battles, meaningful companions, recruitment, territorial politics and a headquarters that changes visibly.

## Required reading by task

| Task | Read first |
|---|---|
| Story, characters, world, factions, regions, monsters | `LORE_BIBLE.md` |
| New systems, feature requests, design expectations, acceptance criteria | `GAME_VISION_AND_REQUIREMENTS.md` |
| Bugs, existing systems, implemented vs missing, release gates | `CURRENT_GAME_STATE_AND_GAP_ANALYSIS.md` |
| Existing combat, classes, items, runes, detailed rules | `GDD.md` and actual `data/` + `scripts/` |
| Visual/audio/UX quality and production rules | `PREMIUM_PRODUCTION_BIBLE.md` |

## Base44 operating instructions

Before changing anything:
1. Inspect the current `main` tree, especially `Kindlewake/project.godot`, `Kindlewake/data/`, `Kindlewake/scripts/`, `Kindlewake/tests/`, and all relevant docs.
2. Identify the actual existing implementation and reuse it.
3. Produce a short implementation plan listing files to change, save impact, tests and acceptance criteria.
4. Make the smallest complete vertical slice. Do not scaffold dozens of disconnected placeholder systems.
5. Run the project’s strict headless tests, scene smoke tests, balance checks and Android export workflow where applicable.
6. Update the current-state report and handoff with exact facts, commit SHA, test evidence and known limitations.

**Never use Base44's own backend, authentication, hosting or cloud database as a replacement for the existing Godot/offline architecture.** Base44 is the assistant/development basis, not a reason to convert the game into an online web service.
