# Session handoff — Rune System v1 (CI validated)

- Project version: v0.9.1, save schema 3; based on v0.9.0 campaign checkpoint. source repository ninjun42215-gif/KindleWake.
- Feature branch: feature/rune-system-v1.
- Latest validated commit: c643c8fc20b1f96ebaa8aadb2f54d7330fa8b59e (project version 0.9.1).
- Scope: replace player-facing Sigils with Runes while preserving old save inventory/socket fields and script aliases; add rune types, grade ladder, fusion, specialist regional shops, rune status effects, combat popups and original atlas.
- New data: data/runes.json (17 runes) and additional storm/holy/shadow spells in data/skills.json.
- Fusion: 3 identical id+grade; success chances 70/55/40/25/12% for Uncommon through Mythical; consumes 3 and returns 1 higher-grade rune on success or 1 original-grade rune on failure.
- Regional vendors: Sallow Crossing, Thornmere, Foxglove, Elderbough, Cindermead, Redwater, Milefort. Each has explicit rune stock; no universal rune catalogue.
- Status effects: burn damage, chill speed penalty, shock turn skip, exposed defense reduction, regen, shadow life drain. Battle popups show applied effects.
- Sprite atlas: assets/art/runes/rune_atlas.svg, 10 types × 6 grades; original SVG artwork.
- Existing saves remain compatible: party inventory persists under legacy sigil_inv and existing socket keys; GameData exposes runes plus legacy sigils keys.
- Internal grade bonuses apply only above each rune's configured starting grade, preserving the original v0.9.0 stat/AP/support balance.

## CI validation — passed
- Workflow run #42646097605 — https://github.com/ninjun42215-gif/KindleWake/actions/runs/42646097605
- Godot 4.2.2 import: exit 0; no script errors or parse errors.
- Strict automated suite: 312 checks, 0 failures.
- Balance report: exit 0.
- Android APK: signed successfully, 41.1 MB, arm64-v8a + armeabi-v7a.
- Requested Android permissions: none.
- APK SHA-256: 2d538df60d8c8f762923b838a020228b3b046f09cd176701a880740bcd15489e
- Build artifact is attached to the workflow run above.
- Remaining non-failing warnings: ObjectDB instances leaked / Resources still in use at headless process exit. Investigate separately.
- No physical Android device test has been performed.

## Itch.io asset review
- Reviewed Foozle's Pixel Magic Effects pack: 10 animated 32×32 spell effects with icons; page states CC0 1.0 and permits commercial use and modification. Candidate for the next battle VFX pass; not yet imported into the repository. Source: https://foozlecc.itch.io/pixel-magic-sprite-effects
- Keep third-party archives source-only until the actual archive, frame layout and import scale are checked.

## Next actions
1. Open/review the draft PR from feature/rune-system-v1 into main; do not merge until review.
2. Install the APK on Android and verify portrait/landscape, touch layout, rune socket UI, Forge, shops, save/load and rune battle effects.
3. Add animated cast/impact VFX using a reviewed CC0 pack or original animations; current rune atlas and status popups are in place, but per-element animated VFX are not yet integrated.
4. Add explicit tests for Burn/Chill/Shock/Exposed/Regeneration turn behavior and grade-scaling effects.
5. Review regional rune merchant placement, stock and prices; verify access gates match the intended story progression.
6. Retire internal sigil_* identifiers only after a dedicated save migration and full compatibility test.


## v0.10.0 scope added
- Expanded rune database to 70+ entries including active spells, passive stat runes, unique and heirloom runes.
- Cross-grade fusion: any three copies of the same rune can be combined; average grade determines target tier and rune AP level adds up to +25 percentage points to the success chance.
- Heirloom runes are bound and cannot be fused; unique runes are rare and marked unique.
- Rune removal and replacement require a rune-service flag, granted by the magic-rune specialist or blacksmith service.
- Equipment enhancement data persists per character/slot; enhancement cap +15; each level scales equipped item bonuses and armor by 5%, weapon enhancement also adds 5% weapon power per level.
- Title screen has an Exit Game confirmation.
- NPC dialogue pages expanded in Sallow Crossing and Kaer Sethorn; Oswin and Master Smith Rurik are rune-service locations.
- Device playtest pending; re-run CI after this feature batch.


## v0.10.0 — Rune Mastery & World Expansion
- Rune library: 77 definitions including 23 active magic, 43 passive, legacy support/stat types, 7 unique and 5 heirloom entries.
- Cross-grade fusion: any three copies of one rune; average grade determines next target tier; rune AP mastery adds up to +25 percentage points. Failed fusion returns one rune.
- Unique and heirloom runes are not sellable/fusible; boss battles reward Dragon, Worldtree, Starfall and Sundered Oath runes.
- Socket insertion, removal and transfer require a magic-rune specialist or blacksmith. Oswin and Master Smith Rurik are designated service NPCs.
- Equipment enhancement persists per character/slot to +15; each level scales equipment bonuses/armor and weapon power by 5%; cost increases quadratically. UI is exposed at Rurik's smithy.
- Four battle maps expanded to 16×14 and tailored to river crossing, deep forest marsh, highland snowfield and ashen ruins; new terrain costs/cover/LOS rules and visual accents.
- Title screen Exit Game confirmation and expanded NPC dialogue for Sallow Crossing and Kaer Sethorn.
- Project version 0.10.0; save schema remains 3. Legacy `sigil_inv` and socket fields intentionally retained.
- CI for this batch is pending. No Android device test has been performed.


## Visual art pass — original environment and UI assets
- Added `assets/art/props/field_props.svg`, a 4×4 atlas of 16 original props: arch, broken column, rune stone, torch, reeds, crystals, grave marker, banner, mushrooms, stump, barrel, crate, campfire, frost pine, statue and flowers.
- Added `assets/art/ui/title_illustration.svg` as a new painted-style landscape backdrop and `ornament_divider.svg` as a reusable fantasy divider.
- `Art.draw_prop()` now loads atlas cells. Tactical battle tiles use terrain-matched props (forest trees, marsh reeds, snow pines, ash campfires, ruin columns and cliff crystals); town tiles receive stallside crates, barrels, torches, banners, columns and sparse flowers.
- These are original project-authored vector assets; no unverified third-party pack was imported in this pass. Existing unit sprite sheets remain in place and should receive a separate animation/character-art upgrade pass.
- CI validation for this asset pass is still running; prior v0.10.0 CI runs had two balance/stat test failures, so do not call the latest branch build verified until a current run completes.


## 2026-11-10 continuation — Godot script registration fixes
- CI run `42650643361` confirmed that `CharacterSheetScript` was not a registered global class inside `character_sheet.gd`; the file declares `class_name CharacterSheet`. `with_item()` now uses the registered `CharacterSheet` class for its copy factory.
- `PartyStateScript` was likewise unresolved inside `party_state.gd`; `from_dict()` now instantiates the current script through `load("res://scripts/core/party_state.gd").new()` with an explicit `PartyState` type annotation to avoid inference failure.
- Commits: `cd30afb04731446e8a5c93fdb2af1e045b70eff9` and `35a8e1c9f546f3f1eddbafd4ea84c47a98d83528` on `feature/rune-system-v1`.
- Latest build run for `35a8e1c9f546f3f1eddbafd4ea84c47a98d83528`: `42666872518` (in progress at handoff). Do not claim the APK is current or validated until this run completes successfully.
- Next visual task: integrate the existing hero battle sprite feature pack if compatible with the current project; upgrade enemies beyond the existing Soldier/Orc idle/walk/attack/hurt/death strips, add distinct silhouettes and spell/impact effects. Preserve existing frame contracts in `scripts/ui/art.gd`; verify third-party licences before redistribution.
- `main` remains untouched; PR #4 remains draft and unmerged.


## Build validation update — 2026-11-10
- Successful Android build run: `42666872518` — https://github.com/ninjun42215-gif/KindleWake/actions/runs/42666872518
- Validated commit: `35a8e1c9f546f3f1eddbafd4ea84c47a98d83528` (the two GDScript fixes are included).
- Godot import passed; strict automated tests: **333 checks, 0 failures**; balance report passed; signed Android APK exported and verified.
- APK size: 41.2 MB. Actions artifact: `Kindlewake-APK` (artifact ID `13697765975`, expires 2027-02-07). Artifact ZIP SHA-256: `6547d22563f0ae1082968ece261891bd188a92246d01f797fd8eb628f9eea088`.
- This validates the project code at `35a8e1c`; the subsequent commits only append handoff documentation. No physical Android device test has been performed.


## 2026-11-10 — Battle sprite identity pass
- Commit `21c1702bd012b8ca0bd0bc51e5a0b6b9dae46c2c` adds class-aware palette variation to battle sprites: knight, swordsman, archer, cleric and roadreaver player units now read with distinct color treatments while retaining the existing Soldier animation strips.
- Enemy sprite treatment now keys off character ID/display name for boss/chieftain, bow/scout, shaman/mage, wraith/spectre, skeleton/bone and brute/ogre/troll archetypes. Each receives a matching palette and small screen-space identity marks; default enemies retain a restrained green tint.
- Hurt tint blends over each palette, and all existing idle/walk/attack/hurt/death frame contracts remain unchanged. This is an interim renderer-level art pass, not a replacement for bespoke frame-by-frame hero/monster sprite sheets.
- CI run `42667953445` for this commit was queued at handoff. Do not mark this pass build-validated or publish a new APK until that exact commit's workflow succeeds.
- Next: add original dedicated enemy and hero sprite sheets plus cast/impact animations; verify on device after CI.


## 2026-11-10 — Responsive UI/HUD implementation
- feature/rune-system-v1 commits: battle HUD 95d5ef7, overworld HUD 5383461, party layout ea6868c.
- Battle HUD: reduced viewport-relative unit card/log/preview widths on compact landscape screens; scaled action button widths/heights and Confirm/Cancel text while preserving large touch targets and existing anchors/safe-area handling.
- Overworld HUD: COMPANY and SAVE now have independent responsive sizing; SAVE is a persistent member reference so its dimensions/font can be updated after viewport changes.
- Party screen: compact mode now depends on orientation (stack only when portrait/narrow aspect); compact landscape retains three visible columns with proportional minimum widths. Header title, gold chip and Close button scale down together.
- No combat, economy, rune, equipment, save schema or progression rules were changed. This is a layout-focused pass.
- Validation: prior sprite identity commit 21c1702bd012b8ca0bd0bc51e5a0b6b9dae46c2c passed Android workflow 42667953445. The new UI commits require their own workflow run; do not claim them validated or distribute a new APK until the exact latest branch commit passes import, strict tests, balance report and APK verification.
- Physical Android touch/safe-area testing remains outstanding. Check 16:9 and narrow landscape, portrait party management, gesture/map input behind HUD panels, save confirmation, and scroll restoration.


## 2026-11-10 — UI/HUD responsive pass and combat feedback
- Party management now switches from the desktop three-column roster/sheet/tabs layout to a vertical, scrollable mobile layout below 1050px; panel minimum widths no longer force horizontal clipping. Attribute tiles reduce to three columns and the header/tabs use compact sizing.
- Battle HUD now reflows for narrow and portrait viewports: turn timeline and battle log are hidden when space is constrained, unit info/menu/action/preview controls scale down and reposition, and result/pre-battle panels are bounded to the viewport. Safe-area insets remain applied.
- Title menu panel and heading now fit narrow phone widths without forcing a 440px panel off-screen.
- Added lightweight vector combat VFX for melee hit slashes, elemental/status impact bursts and healing rings/particles. Effects are time-limited and use draw primitives rather than extra textures to keep mobile rendering inexpensive.
- Commits: party responsive layout `c50bea8`, battle HUD reflow `ab0e668`, title fit `d5b07d6`, compact party header/tabs `079510f`, combat VFX `e55242d`.
- Latest branch head: `e55242d78643bd3dde56e3bafdc623a4dfa6479e`. Android workflow run `42671737916` was queued at handoff; do not claim this combined UI/VFX batch passed until this exact head is validated.
- Remaining art work: bespoke per-class hero sprite sheets and per-species enemy sprite sheets are still not present; current battle sprites use the existing Soldier/Orc animation strips with tint/identity accents. Device visual testing remains required.
- `main` untouched; PR #4 remains open and draft.


## 2026-11-10 — Mobile UI/HUD finalization and CI validation
- Final UI code head validated: 99fcc28dd37652c293eaf240ec017500bbd698e6 on feature/rune-system-v1.
- Battle HUD responsive pass: compact selected-unit/log/preview widths, scaled touch controls, preview and action controls separated for narrow layouts, timeline/log hidden when there is insufficient space, safe-area insets retained.
- Overworld/town HUD: responsive company/save buttons, resized place/NPC interaction panels, viewport-scaled action buttons and prompts.
- Company management: portrait uses full-height Company / Hero / Gear & Runes tabs; narrow landscape uses proportional three-pane columns; desktop keeps a balanced wider layout. Headless smoke tests use a design-size fallback until the Control enters the SceneTree.
- Original lightweight combat feedback: vector slash impacts, elemental/status bursts and healing rings/particles; effects expire quickly and use no additional textures.
- Compile/test fixes: removed duplicate compact flag in battle HUD; removed unsafe get_viewport_rect() calls from party screen when the Control is outside the SceneTree.
- Validation: workflow 42672539871 — Godot 4.2.2, strict tests **333 checks / 0 failures**, balance report completed, signed Android APK exported and verified (arm64-v8a + armeabi-v7a; no requested permissions). Artifact: Kindlewake-APK, ID 13699850975, expires 2027-02-07. Artifact ZIP SHA-256: 1246feb4c56cdcf738c3299b0f01ab842506847604f8d07d3f5a194b35defab7. Workflow URL: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42672539871.
- Note: first editor scan emits transient class-registration errors; the build script performs a clean second scan, after which strict tests pass and the APK export succeeds. Existing non-blocking JSON-corruption test log and ObjectDB/resource cleanup warnings remain.
- Still required: install and visually test the APK on a physical Android device at 16:9 and narrow landscape, plus portrait company tabs, notches/safe areas, scrolling, and touch hit targets. CI does not prove visual correctness on-device.
- main remains untouched; PR #4 remains draft and unmerged.


## 2026-11-10 continuation — tactical sprite identity pass
- Commit `4ddbd7db598ea44520502c3c33309a1a95c38245` adds original class-specific equipment overlays for Knight, Swordsman, Archer, Cleric, Roadreaver, Cavalry and magic classes, plus stronger enemy identity marks for commanders, shamans, wraiths, skeletons, scouts and brutes.
- Existing 100px Soldier/Orc sprite sheet frame contracts, animation timing, battle rules and save schema are unchanged. This is an incremental overlay pass, not the planned dedicated hero/enemy sprite-sheet replacement.
- Current-head Android CI was triggered by the push; do not claim validation until the run completes successfully.
- Next: inspect the current-head CI result; fix any parser/import/test/balance/export failures. Then implement dedicated original hero and enemy sheets, followed by cast/projectile/impact/death animations. Keep third-party packs source-only until licensing and frame layout are verified. `main` remains untouched; PR #4 remains draft.

## 2026-11-10 continuation — rune inventory transaction safety
- Verified the previous checkpoint build (workflow 42673117006, commit 202ffd1) completed successfully: strict tests, balance report and Android APK export/upload all passed.
- Fixed rune socket operations in `PartyState`: invalid group/socket/index, unknown rune and missing service access are now rejected before `fit_sockets()` can normalize or mutate the socket arrays and bag. This prevents a failed UI action from silently ejecting runes from overflow sockets.
- Added regression checks for invalid socket selection, missing service access and invalid removal groups; rejected operations must leave the rune bag and socket state unchanged.
- Added direct combat-rule checks confirming Chill applies a 20% effective-speed penalty and Exposed reduces physical defense by 20%.
- Commits: transactional socket fix `173a33649b5f6537392c9ba15ffb55af4b75f3a9`; socket regression tests `43de6c5f1fba56218820eebec9b9cc581b590a28`; Chill/Exposed combat tests `acdd739fb8c6681bc43a1160c2b44220f550847d`.
- CI for the new commits is queued/in progress at handoff; do not claim these changes passed until the latest branch-head workflow completes.
- The last verified APK artifact remains available from workflow 42673117006 until 2027-02-07; it predates the rune transaction fix and should not be treated as containing these latest changes.
- Next development: inspect the latest CI results, then proceed with dedicated hero/enemy sprite assets and animation integration. Preserve existing frame contracts, save schema v3, PR #4 draft state and untouched `main`.

## 2026-11-10 continuation — status readability and socket test fixture
- Battle sprite presentation now draws compact colored status pips for Burn, Chill, Shock, Regen and Exposed, with a +N overflow indicator when a unit carries more than four statuses.
- The first socket regression CI run correctly exposed a test-fixture issue: Torren's sockets had not been normalized before the test deliberately added an overflow rune. The fixture now calls `fit_sockets(items)` before adding that extra instance; the production transactional validation remains unchanged.
- Added direct checks for Chill's 20% effective-speed penalty and Exposed's 20% physical-defense reduction.
- Latest source commits include status pips `83ceb66d2a992b9ed4f2659c5da11333e854bc4f` and corrected socket fixture `b4335e394ea526bd626760db9a9d14e758e6b668`.
- Earlier CI attempts before the fixture correction reported 3 test failures in the newly added overflow checks. The corrected branch-head build must pass before this batch is considered validated.

## 2026-11-10 continuation — downloadable source handoff automation
- Updated `.github/workflows/build-apk.yml` to publish a second artifact named `Kindlewake-Source-Handoff` alongside the Android APK.
- The archive includes the extracted Godot project, the root GDD and continuation prompt, and root `Feature_*.zip` patch packs. It excludes generated `.godot`/dist content and `Kindlewake/tools/keys` so signing material is not copied into the handoff bundle.
- This makes each successful Android CI build produce both an installable APK and a merge-ready source snapshot for the next development session.
- Workflow change commit: `b933d62d1771f4d9c8fc7ff0822975cf1a221cd9`. Current branch-head CI is queued; no claim of artifact creation until the workflow completes.

## 2026-11-10 continuation — external AI receiving folder and split handoff packages
- Added `Kindlewake/receiving/README.md` as the standard drop location for patches, asset ZIPs, source files and documentation supplied by other AI assistants.
- The receiving guide requires a HANDOFF.md, target paths, dependencies, test notes and licensing details; it warns against blindly overwriting canonical files or including secrets/build caches.
- Changed the Android CI handoff packaging: it now creates the source ZIP, splits it into consecutive binary parts each no larger than 25 MB (25,000,000 bytes), and uploads the parts plus a reassembly guide as `Kindlewake-Source-Handoff-Parts`.
- Reassemble on Linux/macOS with `cat Kindlewake-Source-Handoff.zip.part* > Kindlewake-Source-Handoff.zip`, then validate using `unzip -t`. Every part must be present and kept in the same folder.
- Receiving folder and split packaging are committed on the feature branch. Await the new workflow before claiming the split artifact is downloadable.
- Size cap clarification: each chunk is limited to exactly 25,000,000 bytes (decimal 25 MB), not 25 MiB.


## 2026-11-10 — Next-AI visibility and no-clarification guide
- Added `Kindlewake/docs/NEXT_AI_START_HERE.md` as the concise orientation page: canonical branch/platform/save/network constraints, standing user instructions, current implementation snapshot, latest known CI/artifact evidence, next tasks, source-of-truth document map and explicit defaults.
- Updated both root and in-project continuation prompts to require reading this guide first and include it in the mandatory startup reading order.
- Current documentation commit chain: start guide `d92a49f13fedfd6703c5e7d85acd54e2bfeca058`; root prompt `fd5218322d75ce4e1775be3dddad8b29280ea445`; in-project prompt `f1e6934fc4b14117d4dfb521cc715c277b45baf9`.
- Latest verified build checkpoint before these documentation-only commits: branch head `09c548d92d384b64ba1422f77601cea222753e2c`, workflow #282 `42675923270`, completed successfully. Artifacts: `Kindlewake-APK` ID `13700540809`; `Kindlewake-Source-Handoff-Parts` ID `13699723324`; `test-logs` ID `13699358976`. Workflow: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42675923270.
- The above CI run predates this documentation commit chain. A fresh branch-head workflow must complete before calling the latest documentation snapshot packaged or validated. No physical Android device QA is claimed.
- Next AI: follow `docs/NEXT_AI_START_HERE.md` and the master continuation prompt; do not ask the user to repeat documented decisions. Verify current branch head and CI before further work.


## 2026-11-10 — Repository-wide, branch-independent source handoff
- Reworked `.github/workflows/build-apk.yml` so CI is no longer restricted to a hard-coded branch list. It triggers on pushes to **all branches**, tag pushes, pull requests targeting any branch, and manual dispatch.
- The source package is generated from `git ls-files` in the exact triggering checkout. New tracked files, folders, renamed paths and future feature additions are included automatically; the archive is no longer limited to `Kindlewake/`, selected root documents or a fixed `Feature_*.zip` pattern.
- The package records repository, ref, commit SHA, event and workflow run in `HANDOFF-METADATA.txt`; parts are split at 25,000,000 bytes maximum and the artifact includes `REASSEMBLE.txt` and `SHA256SUMS.txt`.
- Generated caches/build outputs and known signing/secret file patterns are excluded. If new secret formats or generated folders are introduced, review the workflow's exclusion rules. This is a tracked-source handoff, not a backup of untracked local files, Git history, GitHub Actions secrets or build caches.
- Artifact name remains `Kindlewake-Source-Handoff-Parts`; APK artifact remains `Kindlewake-APK`. Each workflow run belongs to the triggering ref; verify the run's commit SHA before using its artifacts.
- Workflow change commit: `4afdbe988833618c8698ad5b3378c57a1d4ab461`. Documentation commits follow on the current feature branch. A fresh run on the final documentation head is required before claiming this generalized workflow has passed end-to-end.
- PR #4 remains draft; `main` was not modified. No physical Android device QA is claimed.


## 2026-11-10 — Generalized Android build and release workflow

- Updated `.github/workflows/build-apk.yml` (commit `66a0b234d85ed8bc8315c14a42cd20314ea93164`): split Android validation/build and source handoff into independent jobs. Source handoff is no longer blocked by APK/test failures. APK artifact includes the installer, SHA-256 and a source/version provenance manifest. Build cache key includes runner OS and builder-script hash. CI checks that project and Android preset version names match.
- Added `.github/workflows/publish-android-release.yml` (commit `c10c38f7d7d15198c688311ebf63598aaa1012e5`): production publishing is manual, requires the exact existing `v*` tag and explicit `PUBLISH` confirmation, uses the `android-production` GitHub Environment, reads the private keystore only from environment secrets, runs strict tests/balance checks and publishes APK + checksum + manifest. Configure required reviewers, the three documented environment secrets and the expected certificate fingerprint before using it. A follow-up security commit `86f4be7d863dd12daad65348e8cea0eb176ee775` pins the built APK's signing certificate to `ANDROID_RELEASE_CERT_SHA256` and refuses publication on mismatch.
- Aligned `export_presets.cfg` to project version `0.10.0` and Android version code `1000` (commit `ee9033d00cc8ec6f5c8f5d37d0fc221580c2ea0a`). The code is a deliberate monotonic bump from the previous preset value; increment it for each later published build.
- Added `docs/ANDROID_RELEASE_WORKFLOW.md` (commit `48be6216af5d6fa7336ff1ac19997d6a6beebeeb`) covering routine CI, production environment setup, secrets, release steps, versioning, security, limitations and troubleshooting.
- Important: these workflow changes have not yet been validated by a new GitHub Actions run in this handoff. Verify the newest branch-head run and its `Kindlewake-APK`, `Kindlewake-Source-Handoff-Parts`, and `test-logs` artifacts. Do not claim AAB support or physical-device QA; neither is provided by this workflow revision.


## 2026-11-10 — APK verification hardening

- Updated `Kindlewake/tools/build_apk.py` in commit `28d56c736af0007bd813a602a778fab38989d108`.
- Local preflight now checks that `project.godot` `config/version` matches Android preset `version/name`.
- Balance report failures and reported `FAIL`, script errors or parse errors now block the strict build rather than being recorded as non-fatal output.
- APK verification now fails closed if `aapt2` cannot inspect permissions or `apksigner` cannot verify the APK. A missing verification tool is no longer downgraded to a warning.
- Production publishing pins the signer fingerprint through `ANDROID_RELEASE_CERT_SHA256`; workflow commit `86f4be7d863dd12daad65348e8cea0eb176ee775` refuses to publish if the APK certificate does not match.
- These changes still require a new branch-head GitHub Actions run. Do not claim the modified builder/workflows passed until that run completes and its artifacts are inspected.


## Release safety / availability note

- Production workflow commit `b9b8216fececc479ca9b7a5fe41b2138f6121fb4` refuses to overwrite an existing GitHub Release for the same tag; use a new version tag for every new published release.
- GitHub exposes `workflow_dispatch` only after a workflow file exists on the default branch. `.github/workflows/publish-android-release.yml` is currently on `feature/rune-system-v1` only. It is intentionally not available for manual dispatch until the reviewed PR is merged to the default branch. Do not merge PR #4 or modify `main` without explicit authorization.
- No production environment/secrets have been configured by this change; setup remains a GitHub repository administrator action.


## Verified AI handoff pipeline (required)
- Use Kindlewake/tools/source_handoff.py as the canonical portable handoff utility; do not duplicate ad-hoc ZIP splitting code inside workflows.
- The repository-wide CI packages the exact triggering Git checkout using git ls-files -z, so new/renamed/deleted tracked paths and all branches/PR refs/tags are handled without hard-coded feature lists. The ZIP is a source snapshot, not a Git clone: it intentionally omits Git history, untracked/ignored files, build outputs, caches, symlinks and sensitive key/credential formats. Inspect exclusion rules when adding new secret formats.
- Each archive includes HANDOFF-METADATA.json (repo/ref/commit/event/run), FILE-MANIFEST.json (per-file size and SHA-256 plus excluded paths/reasons), and AI_NEXT_SESSION.md (first actions, authority rules and stale-snapshot warning).
- Partitioning is binary and sequential: Kindlewake-Source-Handoff.zip.part001, .part002, etc. Each part must be <=25,000,000 bytes decimal. PARTS-MANIFEST.json records exact ordered names, byte sizes, per-part hashes, total archive size and archive SHA-256. SHA256SUMS.txt is a human-readable checksum companion.
- The artifact also includes REASSEMBLE.txt. Download every artifact file into one folder; never extract individual parts. Run the helper's reassemble command, then verify --extract-to into a new empty directory. It detects missing/extra/corrupt parts, checks reconstructed archive checksum and ZIP CRC, verifies every tracked file against the internal inventory, rejects path traversal, and refuses extraction over a non-empty directory.
- Supported recovery environments: Linux, macOS, Android Termux and Windows PowerShell with Python 3. The guide also provides a manual concatenation fallback; helper-based verification remains mandatory.
- Kindlewake-Source-Handoff-Parts must be uploaded independently of APK success. Never claim it is ready unless artifact upload succeeds and the part manifest confirms every part is within the byte limit.
- CI now publishes a final workflow result report with exact ref/SHA, job outcomes, artifact expectations and conditional next-step recommendations. For APK success, verify manifest/checksum then proceed to physical-device QA; for APK failure, inspect the first failing step and test logs; for handoff failure, fix packaging before treating the snapshot as transferable.
- Every receiving AI must read AI_NEXT_SESSION.md plus repository continuation/GDD/session docs, compare snapshot metadata to the live GitHub branch head, inspect latest CI run/PR state, and then act. Do not treat the ZIP as more authoritative than the live repository.
- After every meaningful implementation, record exact changed paths, commit, tests/results, limitations, artifacts and next priorities in SESSION_HANDOFF.md; produce a fresh verified split handoff from the new commit. Recommend the next action based on evidence, not generic boilerplate. Never modify main, merge PRs, or publish production releases without explicit authorization.


## 2026-11-10 — Verified AI handoff and result-driven workflow upgrade
- Added Kindlewake/tools/source_handoff.py with pack, reassemble and verify commands; standard-library only.
- Source packaging inventories tracked files, records per-file SHA-256 and size, records exclusions, embeds exact repo/ref/commit/event/run metadata and a generated AI_NEXT_SESSION.md.
- Binary partitioning remains capped at 25,000,000 bytes per part. PARTS-MANIFEST.json includes ordered part names, sizes and individual hashes plus whole-archive size/hash; SHA256SUMS.txt is included.
- Recovery checks missing/extra parts, size, hashes, reconstructed ZIP integrity and every tracked file; safe extraction rejects traversal paths and non-empty destination folders. Instructions cover Windows PowerShell, Linux, macOS and Android Termux.
- Added Kindlewake/tests/test_source_handoff.py for round-trip packing/reassembly/extraction, missing-part rejection and ZIP traversal rejection.
- Updated .github/workflows/build-apk.yml: handoff tests and packaging run independently of APK success; added a final result-report job with outcome-aware recommendations.
- Validation status: GitHub Actions must run against the resulting branch-head commit; do not claim the new packer/tests pass until that run succeeds. Physical Android device QA remains separate.
- Next: inspect the new CI run and uploaded manifest/artifacts; fix any script or YAML errors; verify every part limit and round-trip; then test a handoff download/reconstruction on a second environment. Keep main untouched and PR #4 draft.


## Workflow result artifact — 2026-11-10
The result-report job now uploads a separate 90-day artifact named Kindlewake-Workflow-Report containing the exact source ref/SHA, APK and handoff job outcomes, expected artifacts, and conditional next-step recommendations. The Actions run summary mirrors this report. The source ZIP itself now also embeds REASSEMBLE.txt so the recovery instructions survive extraction. A receiving AI should inspect both the source ZIP metadata and the workflow report artifact; neither should be treated as proof for a different/newer commit.


The split artifact now also contains the exact source_handoff.py recovery helper beside the parts. PARTS-MANIFEST.json stores that helper's SHA-256, and reassembly refuses to run if the helper is missing or altered. This avoids the bootstrap problem of needing to extract the ZIP before obtaining the tool required to reassemble it. The test suite also asserts that the helper is present in the artifact.
