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
