# KINDLEWAKE — MASTER CONTINUATION PROMPT FOR THE NEXT AI

> **Read this first.** This file is the operating contract for every future AI session. Then read `Kindlewake/docs/NEXT_AI_START_HERE.md` for the concise project snapshot, explicit user decisions, current known CI/artifact checkpoint and no-clarification defaults. The GitHub repository is the source of truth; the session handoff and GDD contain the detailed game history and design.

## 1. Project identity and source of truth
- Game: **KINDLEWAKE: THE SUNDERED VOW**, an offline-first medieval tactical RPG built with Godot 4 / GDScript.
- Repository: https://github.com/ninjun42215-gif/KindleWake
- Current work normally continues on `feature/rune-system-v1`, but inspect the repository's live refs before every session; do not assume a branch name. The CI handoff workflow automatically runs for pushes to every branch, every tag, pull requests targeting any branch, and manual dispatch.
- **PR #4 must remain draft and unmerged. Do not modify or merge `main` without explicit user authorization.**
- Canonical project source: tracked files under `Kindlewake/` in the repository. Do not ask the user to upload a master project ZIP.
- Save compatibility: schema v3. Preserve legacy save fields and compatibility aliases unless a deliberate migration is designed, tested and documented.
- The project is offline-first. Do not add accounts, cloud services, multiplayer, server calls or Android INTERNET permission.

## 2. Mandatory first actions in every new session
1. Inspect the current branch/ref, latest commit SHA and remote branches; continue on the user's active working branch unless a newer project instruction says otherwise. Never assume a branch name or stale checkpoint SHA.
2. Read, in order:
   - `Kindlewake/docs/NEXT_AI_START_HERE.md`
   - `Kindlewake/docs/SESSION_HANDOFF.md`
   - `Kindlewake/docs/GDD.md`
   - `Kindlewake/README.md`
   - this root `CONTINUATION_PROMPT.md`
   - `Kindlewake/receiving/README.md`
3. Inspect recent commits, PR #4 status and the latest **Build Android APK** workflow run. Confirm its head SHA matches the branch head before calling that build current.
4. Inspect actual files and tests before editing. Preserve existing work; make small, reviewable commits. Never force-push or blindly replace the project tree.
5. If any information conflicts, trust the latest repository code and latest successful CI for implementation facts; reconcile the docs and record the correction. This prompt is a workflow contract, not a substitute for inspecting the current branch.

## 3. Game design and engineering constraints
- Engine: Godot 4.2+, standard GDScript, GL Compatibility; landscape-first and touch-first, with responsive portrait support where applicable.
- Art: original dark-medieval pixel-art identity, muted palette, parchment UI and heraldry. Do not copy protected game assets.
- Maintain data-driven content, modular code, stable scene/resource paths and Godot resource UIDs.
- Preserve existing animation/frame contracts unless importer, renderer and tests are updated together.
- Do not import third-party art until the exact source, license, attribution and redistribution/modification rights are checked and recorded in `assets/art/CREDITS.md`.
- Keep UI controls reachable on compact landscape and portrait screens; do not sacrifice essential actions to hide overflow.
- Preserve save schema v3 compatibility. Any schema change needs sequential migrations and regression tests for old saves.
- Prefer a small, complete, playable and tested feature over broad placeholder content. No pseudocode or empty placeholders for requested implementation.

## 4. Current project context
The detailed feature inventory, architecture, narrative, maps, economy, systems and historical implementation notes are in `Kindlewake/docs/GDD.md` and `Kindlewake/docs/SESSION_HANDOFF.md`. Read them rather than relying on stale chat memory.

Known major systems include the overworld, towns/interiors, tactical battles, recruitable party, class progression, equipment, rune library/fusion/passives/unique/heirloom runes, rune services, +15 equipment enhancement, regional merchants, save/load, title/creator flows, mobile HUD and original environment/UI assets. Existing hero/enemy sprite sheets and renderer overlays are not yet equivalent to a complete bespoke per-class/per-species animation library; consult the latest handoff for remaining art work.

Do not assume any feature is complete or validated solely because it is described here. Verify the current source and exact CI run.

## 5. Required development and validation loop
For each meaningful feature:
1. Inspect existing implementation and identify affected data, scripts, scenes, save fields, UI and tests.
2. Implement the complete feature in the correct canonical paths; do not leave half-wired UI or dead data.
3. Add/update regression tests for behavior, edge cases, save compatibility and UI contracts where testable.
4. Run available local checks, including `python3 -I tools/gd_static_check.py` and `python3 tools/build_apk.py --check` from `Kindlewake/`.
5. When authorized/available, run Godot import, strict headless tests, balance report and Android export. Use the repository's CI workflow when local Godot/Android tooling is unavailable.
6. Inspect logs and fix all failures before moving on. Distinguish static checks, CI runtime tests, APK export and physical-device QA. Never claim a phone test unless it was actually performed.
7. Update all required documentation (below) and commit to the current authorized working branch; do not switch branches or target `main` without explicit authorization.
8. Verify the resulting CI run belongs to the new branch-head SHA and confirm the artifacts exist.

## 6. Mandatory documentation updates
Whenever code, assets, data, tests or design changes:
- Update `Kindlewake/docs/GDD.md`: design/implementation details and a dated revision-log entry.
- Update `Kindlewake/docs/SESSION_HANDOFF.md`: exact changes, paths, commit SHA, tests and results, known limitations, next concrete tasks and exact CI run/artifact links.
- Update `Kindlewake/docs/CONTINUATION_PROMPT.md` and this root `CONTINUATION_PROMPT.md`: current state, constraints and next tasks; remove obsolete or contradictory instructions.
- Update `Kindlewake/README.md` when user-facing setup, controls, features or workflow changes.
- Keep `Kindlewake/receiving/README.md` accurate when intake rules change.
Commit these updates together with the relevant work. Never leave the next AI to infer what was done or whether it passed.

## 7. External AI contributions — receiving folder procedure
The dedicated intake directory is **`Kindlewake/receiving/`**. The folder is included in every source handoff ZIP.

When another AI assistant produces code, assets, documents or a patch:
1. Preserve the original output as an incoming contribution under a uniquely named folder, e.g. `Kindlewake/receiving/2026-11-10-ai-name-rune-vfx/`. Do not overwrite another contribution.
2. Include a `HANDOFF.md` in that folder. It must state: summary; exact intended target paths; file inventory; Godot/runtime assumptions; dependencies; license/source/attribution and redistribution rights; tests performed with actual results; known limitations; and any manual import steps.
3. For a small bundle, place its original ZIP or patch and `HANDOFF.md` in that folder. For a larger bundle, split the ZIP into sequential binary parts named `contribution.zip.part001`, `part002`, etc. **Every part must be <=25,000,000 bytes (25 MB decimal).** Include a `REASSEMBLE.txt` with exact commands for Windows and Linux/macOS.
4. Commit and push the incoming contribution (including every part and both instruction files) to the current authorized working branch. Do not leave the only copy in chat, a temporary workspace or an unlinked cloud file. Never commit credentials, private tokens, signing keys or personal data.
5. Reassemble all parts in numeric order inside the receiving subfolder, verify the reconstructed ZIP with `unzip -t` or 7-Zip, then extract it into a separate review subfolder. Keep the original parts/ZIP intact until review is complete.
6. Review every file before integration. Check for malware, unexpected executables, licensing, asset dimensions/frame layout, Godot compatibility, resource UIDs, references, save schema and conflicts. Do not blindly copy/overwrite incoming files.
7. Integrate approved changes into canonical `Kindlewake/` paths, add/update tests and documentation, run the validation loop, and commit the integration. Mark the intake folder's HANDOFF.md with accepted/rejected/deferred status and the integration commit.
8. Keep the original contribution in `receiving/` as provenance unless the user explicitly asks to remove it. Do not let unreviewed incoming files be loaded by the game at runtime.

### Required HANDOFF.md template
```md
# Contribution handoff
- Contributor/AI:
- Date:
- Summary:
- Intended target paths:
- Included files:
- Engine/version and assumptions:
- Dependencies/plugins:
- Asset source and license:
- Attribution and redistribution rights:
- Tests run and exact results:
- Known limitations/risks:
- Manual integration steps:
- Status: awaiting review
```

## 8. Mandatory ZIP handoff for every future session
The user requires a ready-to-download source handoff after development. **Every future AI session that changes the project must leave the next session with a merge-ready ZIP handoff split into parts.**
- The generalized GitHub Actions workflow `.github/workflows/build-apk.yml` packages the **complete tracked repository snapshot** from the exact triggering checkout using `git ls-files` (not a hard-coded folder/file list). It therefore follows newly added/renamed/deleted tracked files and works on every branch, tag, pull-request merge ref and manually selected ref. It excludes generated caches/build outputs and signing/secret material; inspect/update the exclusion rules if the repository adds a new sensitive-file format.
- Triggers: pushes to all branches, pushes of tags, pull requests targeting any branch, and manual `workflow_dispatch`. Artifact name: **`Kindlewake-Source-Handoff-Parts`**; it contains numbered parts, `REASSEMBLE.txt` and `SHA256SUMS.txt`. Each run records repository, ref, commit SHA, event and run ID inside `HANDOFF-METADATA.txt`.
- Every part must be **<=25,000,000 bytes (25 MB decimal)**. Never use 25 MiB as the limit.
- The archive includes `Kindlewake/receiving/`, so reviewed or pending incoming contributions and their HANDOFF instructions travel with the project.
- After pushing changes, wait for CI, inspect the exact branch-head run, and verify both `Kindlewake-APK` and `Kindlewake-Source-Handoff-Parts` artifacts exist. Check individual part sizes and verify the reconstructed ZIP if possible.
- If CI packaging fails, fix the workflow and rerun it. Do not tell the user a handoff is ready until the artifact is present and verified.
- Do not treat split parts as separate ZIPs. The next AI must download **all** parts, keep them together, concatenate in numeric order, test the reconstructed ZIP, then extract it. The GitHub repository remains canonical; the archive is the portable handoff copy.

Linux/macOS:
```sh
cat Kindlewake-Source-Handoff.zip.part* > Kindlewake-Source-Handoff.zip
unzip -t Kindlewake-Source-Handoff.zip
unzip Kindlewake-Source-Handoff.zip
```

Windows PowerShell (run in the folder containing the parts):
```powershell
$parts = Get-ChildItem 'Kindlewake-Source-Handoff.zip.part*' | Sort-Object Name
$out = [System.IO.File]::Create('Kindlewake-Source-Handoff.zip')
try { foreach ($part in $parts) { $input = [System.IO.File]::OpenRead($part.FullName); try { $input.CopyTo($out) } finally { $input.Dispose() } } } finally { $out.Dispose() }
7z t Kindlewake-Source-Handoff.zip
```
If 7-Zip is unavailable, use another ZIP integrity checker after reassembly.

## 9. Stop/handoff checklist — mandatory before ending a session
- [ ] All intended source changes are committed to the current authorized working branch; the handoff run's commit SHA matches that branch/ref.
- [ ] PR #4 is still draft/unmerged; `main` was not modified.
- [ ] GDD, session handoff, both continuation prompts and README are synchronized.
- [ ] Incoming AI contributions are in `Kindlewake/receiving/` with HANDOFF.md and reassembly notes when needed.
- [ ] Static checks, Godot tests, balance report and Android build are reported accurately (passed/failed/not run).
- [ ] Latest branch-head GitHub Actions run completed successfully.
- [ ] `Kindlewake-Source-Handoff-Parts` artifact exists; all parts are <=25,000,000 bytes; reconstruction/integrity was verified.
- [ ] APK artifact exists if the Android workflow succeeded; do not claim device testing without a real device.
- [ ] Session handoff states exact commit SHA, workflow URL, artifact names/IDs/expiry, test counts and next tasks.
- [ ] Final user message says what changed, what passed, what remains unverified, and where to get the handoff.

## 10. Working style
Be proactive and implementation-focused. The user often says “continue” to authorize the next sensible development step. Do useful repository work rather than returning status-only updates. Do not ask the user to repeat project context that is already in these files. Ask only when an essential product decision or authorization is missing. Lead with completed work and the next action; be concise but specific and honest.


## Android build/release operating contract

- Read `docs/ANDROID_RELEASE_WORKFLOW.md` before changing APK/Android release automation.
- Routine CI lives in `.github/workflows/build-apk.yml`; it validates/builds APK and packages the tracked source handoff in independent jobs. The handoff must remain available even when APK build/tests fail.
- CI must remain ref-aware for all branches, tags, pull requests and manual dispatch; never hardcode the active branch or feature-file list.
- Tag builds are candidates only. Production publishing is separate in `.github/workflows/publish-android-release.yml` and must remain manual/protected by the `android-production` environment. GitHub exposes its manual dispatch only after that workflow exists on the default branch; do not merge PR #4 or modify `main` without authorization. The publisher must refuse to overwrite an existing release tag.
- Never put a private production signing key or password in Git. Production secrets are `ANDROID_RELEASE_KEYSTORE_BASE64`, `ANDROID_RELEASE_KEY_ALIAS`, and `ANDROID_RELEASE_KEY_PASSWORD` in the protected GitHub Environment.
- Pin the expected production signer with the `ANDROID_RELEASE_CERT_SHA256` environment variable; the publisher rejects a different APK certificate.
- Keep `project.godot` version and Android preset `version/name` synchronized. Android `version/code` must increase monotonically. Current checkpoint: project version `0.10.0`, Android version code `1000`.
- Current builder exports APK only. Do not claim AAB support until a Gradle/AAB path is implemented and tested. CI success is not physical-device QA.
- Inspect the exact current branch-head Actions run and artifacts after every workflow change; this documentation update does not itself prove the workflow passed.

- Builder and CI fail closed when the balance report fails, APK permissions cannot be inspected, the signature cannot be verified, or project/export version names differ. Production publishing additionally pins the expected certificate using `ANDROID_RELEASE_CERT_SHA256`.


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


## Workflow result artifact — 2026-11-10
The result-report job now uploads a separate 90-day artifact named Kindlewake-Workflow-Report containing the exact source ref/SHA, APK and handoff job outcomes, expected artifacts, and conditional next-step recommendations. The Actions run summary mirrors this report. The source ZIP itself now also embeds REASSEMBLE.txt so the recovery instructions survive extraction. A receiving AI should inspect both the source ZIP metadata and the workflow report artifact; neither should be treated as proof for a different/newer commit.


The split artifact now also contains the exact source_handoff.py recovery helper beside the parts. PARTS-MANIFEST.json stores that helper's SHA-256, and reassembly refuses to run if the helper is missing or altered. This avoids the bootstrap problem of needing to extract the ZIP before obtaining the tool required to reassemble it. The test suite also asserts that the helper is present in the artifact.


## Manual GitHub workflows
See docs/MANUAL_GITHUB_WORKFLOWS.md for user-operated Actions workflows: repository organizer/audit, safe branch integration, branch hygiene, full repository backup, APK/source handoff and protected Android release. These are intended to work without an AI assistant. New workflow_dispatch files must be merged into the repository default branch before GitHub exposes them for manual launch.


## Latest manual workflow implementation checkpoint — 2026-11-10
The manual workflow set now includes:
- Repository Organizer and Structure Audit: inventories tracked files by category; reports safe placement recommendations; only moves standalone Markdown docs from Kindlewake/ to Kindlewake/docs/ after explicit confirmation, on a maintenance branch, with a draft PR. Never moves Godot code/resources/assets/data/tests/addons/project settings.
- Safe Branch Integration: arbitrary source/target refs; detects already-integrated sources; creates an isolated merge candidate; reports and aborts conflicts; runs source handoff and organizer tests plus offline Android preflight; opens a draft PR only. It never writes to the target branch or auto-merges main.
- Branch Hygiene: reports remote branch age and whether merged into chosen base; read-only, no deletion.
- Manual Full Repository Backup: portable split source handoff plus verified Git bundle of all fetched refs/tags; the bundle may include previously committed secrets and must remain private.
- Added repository_organizer.py, branch_hygiene.py, and test_repository_organizer.py.
- Updated Build Android APK and Source Handoff to run the organizer boundary tests and corrected the source-handoff summary output so it no longer references an undefined REPORT_PATH.
- Manual workflow instructions: docs/MANUAL_GITHUB_WORKFLOWS.md.
- Current PR #4 remains a draft against main. The feature branch is 287 commits ahead and 0 behind at the time of this checkpoint. No merge to main was performed.
- New manual workflow files are present only on the feature branch until PR review/merge. GitHub generally exposes workflow_dispatch in the Actions UI only after the workflow file exists on the default branch. Do not merge automatically.
- Validation is pending: wait for the updated PR CI run and test each manual workflow after the YAML is available on the default branch. Do not claim the new manual workflows have passed yet.


Workflow CI also now has a dedicated workflow-lint job. It parses every YAML file in .github/workflows before relying on the manual maintenance workflows, and its result is included in the portable Kindlewake-Workflow-Report.


## CI follow-up — source handoff test fixture correction
GitHub Actions run 42681992335 (commit 142cc330012b4b279eb137d5e? ) failed the source-handoff test job because test_missing_part_is_rejected used a legacy parts manifest without the newly required recovery_tool metadata. The production verifier correctly rejected the incomplete fixture before checking missing parts. The test fixture has now been updated to copy source_handoff.py and include its SHA-256 in recovery_tool, so the test can exercise the intended missing-part validation. Updated fixture commits: feature branch fc250b1ae2f12aa859f63767def36ef3c36945dd; standalone manual toolbox branch 4721e40200a3b3fa339068b37074a2571ba51f99. This is a test-fixture correction, not a relaxation of archive verification. Re-run/inspect CI before claiming the source handoff or new manual workflows are validated. The APK job in run 42681992335 was cancelled after the source-handoff failure; no APK artifact was produced by that run.
