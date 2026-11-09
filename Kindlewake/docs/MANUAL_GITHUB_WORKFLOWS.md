# Manual GitHub Workflows — Kindlewake

These workflows are designed for use directly from GitHub Actions. They do not require ChatGPT or another AI assistant. All manual workflows are available from the repository's Actions tab after their workflow files exist on the repository's default branch.

## Launching a workflow

1. Open the Kindlewake GitHub repository and select **Actions**.
2. Choose the workflow from the left sidebar.
3. Select **Run workflow**.
4. Choose the branch and inputs described below.
5. Open the run summary and download its artifact report when the run finishes.

A workflow file added only to a feature branch may run on push or pull-request events, but a new workflow_dispatch workflow generally must first be present on the default branch before GitHub exposes it for manual dispatch. Review and merge the pull request before expecting these new manual tools to appear.

## Available manual tools

### 1. Build Android APK and Source Handoff

File: .github/workflows/build-apk.yml

Use this for complete strict project validation, Android APK candidate build, logs, and a portable source handoff. It can also be launched manually for the selected branch. An APK is uploaded only when the strict build succeeds. A successful CI build is not a substitute for installing and testing on a real Android device.

Outputs:
- Kindlewake-APK (only on success)
- test-logs
- Kindlewake-Source-Handoff-Parts
- Kindlewake-Workflow-Report

### 2. Repository Organizer and Structure Audit

File: .github/workflows/repository-organizer.yml

Inputs:
- base_branch: exact branch snapshot to inspect
- mode: audit (default, read-only) or organize
- confirmation: for organize mode, enter exactly CREATE ORGANIZATION PR

Audit mode reports structure and safe documentation moves without changing files. Organize mode runs only on a new maintenance branch, stages the permitted moves and opens a draft PR. It never commits directly to the selected base branch.

Current automatic move rule:
- Standalone Markdown files directly inside Kindlewake/ move into Kindlewake/docs/.
- README and policy/entry-point files remain at the project root.
- Destination collisions stop the operation and are reported.

Protected from automatic relocation:
- project.godot and export_presets.cfg
- GDScript/source code, scenes, resources and UID/resource references
- assets, data, tests, addons and plugins
- optional asset archives and build/release configuration

This conservative boundary is intentional: moving Godot resources can break res:// paths, UID references, imports and scene dependencies. To broaden the rules, update repository_organizer.py and its tests first; do not use a blind extension-based move.

Output: Kindlewake-Organization-Report.

### 3. Safe Branch Integration (Prepare Review PR)

File: .github/workflows/safe-branch-integration.yml

Inputs:
- source_branch: branch containing the changes to integrate
- target_branch: destination branch (normally main)
- confirmation: when target_branch is main, enter exactly PREPARE PR FOR main

What it does:
1. Fetches the exact source and target refs.
2. Creates an isolated integration branch from the current target head.
3. Attempts a non-fast-forward merge on that isolated branch.
4. If conflicts occur, records conflicting paths and aborts the merge candidate.
5. If conflict-free, runs source-handoff tests and Android offline preflight.
6. Pushes only the isolated integration branch and opens a draft PR against the chosen target.

It NEVER pushes to, resets, force-pushes, or merges directly into the target branch. Review the PR diff, wait for all PR CI checks, resolve review feedback, and perform the final merge manually through GitHub. Device/gameplay review is still required for changes that affect the game.

Output: Kindlewake-Safe-Merge-Report and a draft PR when all preparation checks pass.

### 4. Branch Hygiene and Cleanup Recommendations

File: .github/workflows/branch-hygiene.yml

Inputs:
- base_branch: branch used to check whether other branches have been integrated
- stale_days: age threshold for review recommendations (default 60)

The report lists remote branches, latest commit, age, whether each branch is already merged into the selected base, and a suggested next action. It is read-only. It never deletes branches or changes refs. Verify that a branch is no longer needed before deleting it manually.

Output: Kindlewake-Branch-Hygiene-Report.

### 5. Manual Full Repository Backup

File: .github/workflows/manual-full-backup.yml

Inputs:
- snapshot_branch: branch whose checked-out tracked files become the portable source snapshot
- include_all_git_refs: include all fetched branches and tags in the Git bundle (default true)

The artifact contains:
- verified split source handoff parts (each <=25,000,000 bytes)
- the self-contained recovery helper and reassembly instructions
- a Git bundle containing repository history and refs
- BACKUP-MANIFEST.json and SHA256SUMS.txt

Verify checksums before restoring. Restore a Git bundle into a new repository or temporary clone first; never overwrite the working copy as the first recovery attempt. A full-history Git bundle may contain secrets that were committed in the past. Keep it private and do not publish it.

Output: Kindlewake-Full-Backup.

### 6. Production Android Release

File: .github/workflows/publish-android-release.yml

This is a separate protected release process. It requires an exact version tag, explicit publish confirmation, protected android-production environment approval, and configured signing secrets/certificate fingerprint. Do not use it for routine APK testing. Never commit signing keys or passwords.

## Recommended manual operating routine

- Before risky work: run Manual Full Repository Backup.
- Before moving or reorganizing files: run Repository Organizer in audit mode; inspect the report; then rerun with organize mode if the moves are appropriate.
- Before cleaning branches: run Branch Hygiene and inspect the report. Delete branches manually only after checking open PRs and backup needs.
- Before integrating a feature: run Safe Branch Integration with the source branch and main as target; inspect the draft PR and require CI/review before merging.
- Before distributing an APK: run Build Android APK and Source Handoff, verify its checksum/manifest, then install and test on a physical device.
- After meaningful changes: generate a fresh source handoff and update SESSION_HANDOFF.md and CONTINUATION_PROMPT.md.

## Safety guarantees and limits

- No manual maintenance workflow silently merges into main.
- Organizer apply mode uses a separate branch and draft PR.
- Branch cleanup is report-only.
- Backups and handoffs are tied to exact refs and commits.
- CI success, merge conflict-free status, and APK export do not prove real-device gameplay quality.
- These workflows do not replace human review of file moves, branch diffs, licensing, gameplay, or production release approval.
