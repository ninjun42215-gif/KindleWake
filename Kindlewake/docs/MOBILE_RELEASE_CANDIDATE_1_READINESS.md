# KindleWake Mobile Release Candidate 1 — Readiness Plan

**Status:** DEVELOPMENT CANDIDATE — NOT A PUBLIC/STORE RELEASE  
**Reviewed:** 2026-11-17  
**Project:** KindleWake — The Sundered Vow  
**Engine:** Godot 4.2.2 · **App version:** 0.12.0 · **Android version code:** 1200 · **Save schema:** 4  
**Working branch:** `feature/complete-portrait-coverage-audit`  
**Reviewed branch head:** `a5d845164b10de2de2270636c8b13aacea4baee6`  
**Default branch:** `main` at `8c512a063f6ef63c88f33489d118cad6b0a29c6c`

This document is the release gate checklist. A green CI build is necessary but does not mean that all art, campaign content, physical-device behaviour, signing, or store-release requirements are complete.

## 1. Verified at the reviewed branch head

| Check | Result | Evidence |
|---|---|---|
| Godot project import | PASS | Android workflow run [44011454711](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44011454711) |
| Headless scene smoke test | PASS | Same run |
| Strict automated test suite | PASS | Same run |
| Balance report requested by CI | PASS | Same run |
| Android APK export and artifact upload | PASS | Same run |
| Android emulator install and launch | PASS | Same run; job step succeeded |
| Portrait registry structural audit | PASS | [44011454802](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44011454802) |
| Project Health Audit | PASS | [44011454717](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44011454717) |
| Workflow YAML lint | PASS | [44011454723](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44011454723) |
| Source handoff snapshot | PASS | [44011454689](https://github.com/ninjun42215-gif/KindleWake/actions/runs/44011454689) |

**Interpretation:** CI proves that this commit can be imported, tested, exported, installed and launched in the configured emulator. It does not prove a complete playthrough, correct rendering on the owner's phone, long-session stability, production signing, or artistic completeness.

## 2. Release blockers and required work

### A. Physical Android QA — BLOCKING

CI emulator success is not a substitute for the actual target device. Before RC1 is accepted, install the exact candidate APK on the target phone and record the result for each item:

- [ ] Confirm Android version, device model, available storage and free RAM.
- [ ] Install cleanly; verify package name `com.kindlewake.game`, app icon and displayed version.
- [ ] Launch from the launcher repeatedly; verify no black screen, crash, stuck loading state or missing resources.
- [ ] Complete Title Screen → New Game → **Choose Your Lead** → every creator section → Begin Chronicle.
- [ ] On the creator, test every portrait/presentation option, all choice controls, name validation, attribute allocation, scrolling, keyboard appearance and confirm/back actions.
- [ ] Rotate only if rotation is an intended supported mode; otherwise confirm orientation remains stable.
- [ ] Test touch targets near screen edges, scrolling, safe areas, system bars, notches/cutouts and Android Back.
- [ ] Play a representative exploration segment, enter/leave a town, open party/equipment/shop/quest panels and complete at least one battle.
- [ ] Save manually, trigger autosave, force-close/relaunch, load each available slot and verify party, protagonist, inventory, world flags and position.
- [ ] Background/resume during exploration, creator, dialogue and battle; verify no lost or duplicated actions.
- [ ] Run a 30–60 minute session; check heat, battery use, memory growth, frame pacing and crashes.
- [ ] Test low-storage and interrupted-save behaviour where practical; verify the previous good save is not destroyed.
- [ ] Capture screenshots and Android logcat for failures. Record pass/fail, device, OS, APK SHA-256 and steps to reproduce.

**Acceptance:** no crash, softlock, save corruption, clipped mandatory controls, inaccessible creator actions, or unrecoverable progression loss.

### B. Portrait and character art — BLOCKING for the requested art-complete release

The portrait audit is intentionally incomplete. It tracks 48 character definitions, 157 NPC dialogue/event spots and 3 named royal story figures (208 records total). The inspected portrait directory contains only 12 legacy SVG portraits. Those are not approved individually art-directed painterly portraits.

- [ ] Create original, licensed, individually art-directed portrait assets for the 24 Wave 1 named roster, Wave 2 recruits, other named story figures and required bosses.
- [ ] Create reviewed faction/role/variant families for humanoid enemies, creatures and recurring NPC professions.
- [ ] Define and approve protagonist creator appearance coverage. The current finite gallery does not cover every selectable appearance combination.
- [ ] Review each assignment for identity, age, presentation, faction, clothing, equipment, cultural distinction and consistency.
- [ ] Replace any procedural/geometric or generic fallback that would be visible in the final art-complete build.
- [ ] Verify all registry references resolve, no unintended duplicate identities exist, no orphan art ships and every UI surface uses the shared resolver.
- [ ] Run visual review on device at normal play size and in creator, party/status, dialogue, battle, shop and quest contexts.

Do not mark portrait coverage complete based only on registry/file existence tests. Artistic review and identity approval are separate acceptance steps.

### C. Campaign, world and progression acceptance

Run a content audit against the current authoritative `Kindlewake/docs/GDD.md`, not the archived root `GDD_Kindlewake.md`.

- [ ] Verify the intended four-continent world structure, map boundaries, regions, settlements, dungeons, landmarks and discoverability.
- [ ] Verify travel links, gates, transport unlocks, travel costs/time and return routes; no inaccessible or stranded locations.
- [ ] Play every main-act critical path from a fresh save through the current campaign ending; confirm quest flags and transitions.
- [ ] Test recruitment availability, one-time rewards, mutually exclusive choices, defeat/retry and party limits.
- [ ] Verify level cap 250, XP curve, stat growth, skill unlocks, equipment progression and enemy scaling with automated simulations plus representative play.
- [ ] Check that progression is challenging without requiring repetitive menu-labelled “grinding” or story-mode buttons contrary to the intended organic progression.
- [ ] Verify tactical combat: turn order, movement/pathfinding, targeting, range/line of sight, statuses, AI, victory/defeat and battle aftermath.
- [ ] Check economy and all currencies/resources for softlocks, runaway inflation, impossible costs and duplicate rewards.
- [ ] Verify every ending/major decision and chronicle/legacy outcome that the current scope promises.
- [ ] Keep unimplemented systems and future content clearly labelled; do not imply a complete four-continent campaign if only some regions are playable.

### D. Save integrity and migration — BLOCKING

- [ ] Test fresh save creation, multiple slots, overwrite confirmation, delete confirmation and corrupted/missing save recovery.
- [ ] Test migration from every supported prior schema through schema 4.
- [ ] Verify load after app update and after interrupted writes; preserve a recoverable previous save.
- [ ] Verify protagonist creation, recruited roster, equipment, inventory, quest/world flags, travel location, holdings, campaign calendar and chronicle state survive round trips.
- [ ] Verify autosave does not occur in an unsafe intermediate battle/transition state.
- [ ] Confirm uninstall/backup behaviour is deliberate and documented; the current export preset disables Android user-data backup and uninstall retention.
- [ ] Add regression fixtures for legacy saves before changing the schema. Never silently reset an old campaign to make a migration pass.

### E. Android build, signing and distribution — BLOCKING for public release

- [x] CI APK export, signature verification and offline permission check on the reviewed candidate.
- [ ] Decide whether distribution is sideload-only or Google Play.
- [ ] Create a private production keystore; store it only in a protected GitHub Environment, never in the repository or chat.
- [ ] Verify production certificate fingerprint and create secure offline backups of the keystore and recovery information.
- [ ] Keep the CI sideload/test key separate from the production signing identity.
- [ ] Increment Android version code for every distributed update; never reuse a published code.
- [ ] If publishing to Google Play, implement and test an Android App Bundle (AAB) path; the current builder exports APK, not AAB.
- [ ] Review package identity, app label, icon/adaptive icon, orientation, supported Android API range, permissions and privacy/data disclosures.
- [ ] Generate a release manifest and SHA-256 checksum; retain source SHA, workflow run and test reports with the artifact.
- [ ] Perform a final clean install and upgrade install using the production-signed artifact before distribution.

### F. Asset, privacy and legal review

- [ ] Recheck `Kindlewake/data/asset_provenance.json` and `assets/art/CREDITS.md` against every asset actually shipped.
- [ ] Confirm all third-party terms permit the intended distribution; retain attribution/notice files as required.
- [ ] Do not redistribute source asset packs standalone where their terms prohibit it.
- [ ] Confirm the APK has no INTERNET permission or unexpected network/account/analytics code; investigate any new permission.
- [ ] Review fonts, icons, sound, music, portrait art, logos and store screenshots for ownership/permission.
- [ ] Prepare privacy policy/store declarations appropriate to the actual data collected. Do not claim “collects no data” without verifying SDKs and platform behaviour.

### G. UX, accessibility and performance

- [ ] Validate readable text at system font scaling and supported display sizes.
- [ ] Verify minimum touch targets, focus order, clear selection states, confirmation for destructive actions and useful error messages.
- [ ] Check contrast for text, selected/unselected states, disabled controls and combat status indicators.
- [ ] Verify UI scaling and scroll behaviour in creator, party, inventory, shop, map, realm/holdings, dialogue and battle.
- [ ] Profile texture memory, scene load times, save/load times and frame pacing on low-, mid- and high-range devices.
- [ ] Check battery/thermal behaviour in long battles and busy settlements.
- [ ] Add a lightweight in-game version/build identifier and a support diagnostic screen only if it does not compromise offline/privacy constraints.

## 3. Branch and integration safety

At this review, `feature/complete-portrait-coverage-audit` is **61 commits ahead and 5 commits behind** `main` (merge-base `b874936960b20ce536dcc385579152a659130020`). It is therefore diverged, even though the current tree comparison identifies a focused set of portrait-related file changes.

- [ ] Reconcile the five newer mainline commits with this feature branch.
- [ ] Re-run the complete CI suite on the reconciled exact SHA.
- [ ] Review the resulting diff for unrelated changes and generated files.
- [ ] Open/update a draft PR against main and review all changed files.
- [ ] Merge only after exact-SHA checks pass and the PR is explicitly approved.

**Do not force-push, bulk-merge this branch, or merge it to `main` as a shortcut.** The default branch was not modified by this checkpoint.

## 4. RC1 exit criteria

RC1 may be called a candidate only when all of the following are true:

1. The reconciled source branch has a clean, reviewed diff and all required CI checks pass on the exact head SHA.
2. The physical-device QA sheet is completed on the target phone with no critical/high severity defects.
3. New Game → creator → campaign start, save/load, battle and travel pass end-to-end on device.
4. Save migration and recovery tests pass for all supported schema versions.
5. The promised campaign/world scope is playable and all critical paths are verified.
6. Portrait/art coverage is either approved for the intended release scope or explicitly excluded from the release promise. For an art-complete release, every required identity must be individually reviewed.
7. Production signing, asset provenance, permissions and distribution requirements are satisfied.
8. The final release artifact has a recorded SHA-256, manifest, source commit and reproducible build record.

## 5. Current decision

**Current decision: NOT RELEASE-READY.** The reviewed commit is a successful CI/emulator build candidate, not a public release candidate. The largest unresolved gates are physical-device QA, portrait artwork/approval, complete campaign/world acceptance, save migration/recovery verification, branch reconciliation and production signing/distribution setup.

## 6. Test record template

Copy this section for each physical-device test:

- Device/model:
- Android version:
- Display resolution / refresh rate:
- Free storage / RAM:
- APK version / version code:
- Source commit:
- APK SHA-256:
- Date:
- Tester:
- Test case:
- Result (PASS / FAIL / BLOCKED):
- Evidence (screenshot/logcat):
- Defect / reproduction steps:
