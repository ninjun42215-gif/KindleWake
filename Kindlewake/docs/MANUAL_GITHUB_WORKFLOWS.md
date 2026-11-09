# Manual GitHub Workflows — Kindlewake

These tools are launched directly from GitHub Actions and do not require ChatGPT or another AI assistant.

## How to launch

1. Open the repository and select Actions.
2. Choose the workflow from the left sidebar.
3. Select Run workflow.
4. Select the branch and fill in the requested inputs.
5. Read the run summary and download its artifact.

New workflow_dispatch workflows become available for manual launch after their YAML files are merged into the repository default branch. The PR for this toolbox is separate from the Rune System feature PR.

## Available workflows

### 1. Build Android APK

File: .github/workflows/build-apk.yml

Use the existing Build Android APK workflow for strict validation, Android APK export and logs. Select the branch in the Actions UI. The APK is uploaded only if the build succeeds. A successful cloud build is not physical-device QA.

Artifacts: Kindlewake-APK and test-logs.

### 2. Manual Source Handoff Snapshot

File: .github/workflows/manual-source-handoff.yml

Use this when you need a portable source snapshot without building an APK. It runs automatically on pushes to main, feature/* and workflow/* branches, and can also be launched manually from Actions. It packages the exact checked-out commit, inventories tracked files, hashes each file and splits the ZIP into parts no larger than 25,000,000 bytes.

Artifacts (30-day retention): Kindlewake-Manual-Source-Handoff, including source_handoff.py, PARTS-MANIFEST.json, SHA256SUMS.txt, REASSEMBLE.txt and the split archive parts.

Download every file into one folder. Do not extract the parts individually. Run the included recovery helper to reassemble and verify the ZIP, then extract into a new empty directory.

### 3. Repository Organizer and Structure Audit

File: .github/workflows/repository-organizer.yml

Inputs:
- base_branch: branch snapshot to inspect
- mode: audit (default, read-only) or organize
- confirmation: for organize mode, enter exactly CREATE ORGANIZATION PR

Audit mode inventories tracked files by category and reports recommendations without changing files. Organize mode uses a separate maintenance branch and opens a draft PR. It never commits directly to the selected base branch.

Current automatic move rule:
- Standalone Markdown files directly inside Kindlewake/ move into Kindlewake/docs/.
- README and policy/entry-point files stay at the project root.
- Destination collisions stop the operation and are reported.

Protected from automatic relocation:
- project.godot and export_presets.cfg
- GDScript/source code, scenes, resources and UID/resource references
- assets, data, tests, addons and plugins
- optional asset archives and build/release configuration

This conservative boundary is intentional: moving Godot resources can break res:// paths, UID references, imports and scene dependencies. Expand the rules only after reviewing references and adding tests. The organizer's report includes category counts and file inventory so future placement rules can be reviewed safely.

Artifact: Kindlewake-Organization-Report.

### 4. Safe Branch Integration (Prepare Review PR)

File: .github/workflows/safe-branch-integration.yml

Inputs:
- source_branch: branch containing the changes to integrate
- target_branch: destination branch (normally main)
- confirmation: when target_branch is main, enter exactly PREPARE PR FOR main

The workflow:
1. Fetches the exact source and target refs.
2. Checks whether the source is already contained in the target.
3. Creates an isolated integration branch from the current target head.
4. Attempts a non-fast-forward merge on that isolated branch.
5. If conflicts occur, records conflicting paths and aborts the candidate.
6. If conflict-free, runs source-handoff and organizer tests plus Android offline preflight.
7. Pushes only the isolated integration branch and opens a draft PR against the chosen target.

It never pushes to, resets, force-pushes or merges directly into the target branch. Review the PR diff, wait for PR CI checks, resolve feedback and perform the final merge manually through GitHub. Device/gameplay review remains necessary for game changes.

Artifact: Kindlewake-Safe-Merge-Report.

### 5. Branch Hygiene and Cleanup Recommendations

File: .github/workflows/branch-hygiene.yml

Inputs:
- base_branch: branch used to determine whether other branches have been integrated
- stale_days: age threshold for review recommendations (default 60)

The report lists remote branches, latest commit, age, whether each branch is already merged into the selected base, and a suggested next action. It is read-only and never deletes remote branches. Verify open PRs, backup needs and ownership before deleting a branch manually.

Artifact: Kindlewake-Branch-Hygiene-Report.

### 6. Manual Full Repository Backup

File: .github/workflows/manual-full-backup.yml

Inputs:
- snapshot_branch: branch whose tracked files become the portable source snapshot
- include_all_git_refs: include all fetched branches and tags in the Git bundle (default true)

The artifact contains:
- verified split source handoff parts (each <=25,000,000 bytes)
- the self-contained recovery helper and reassembly instructions
- a Git bundle containing repository history and refs
- BACKUP-MANIFEST.json and SHA256SUMS.txt

Verify checksums before restoring. Restore a Git bundle into a new repository or temporary clone first; never overwrite the working copy as the first recovery attempt. A full-history bundle may contain secrets committed in the past. Keep it private and never publish it.

Artifact: Kindlewake-Full-Backup.

### 8. Project Health Audit

File: .github/workflows/project-health-audit.yml

Run this on demand from Actions or allow it to run on pushes and pull requests. It creates JSON and Markdown reports containing JSON parse failures, project inventory, version drift, missing asset-credit/provenance documentation, unverified licence markers, used-but-unverified asset packs, rune definition count and kind totals, malformed rune entries, and nested workflow-directory warnings. Invalid JSON, malformed provenance/rune entries fail the workflow; advisory findings remain warnings by default. Use `python3 Kindlewake/tools/project_health_audit.py --root . --output health-audit --fail-on-warnings` for a strict pre-release gate that also fails on warnings. See `Kindlewake/docs/PROJECT_HEALTH_AUDIT.md` for interpretation and release-readiness limits.

The inactive legacy duplicate at Kindlewake/.github/workflows/build-apk.yml was removed; active workflows belong only under the repository-root .github/workflows/ directory. The audit is read-only and deliberately does not claim to validate GDScript semantics, import/render scenes, test saves in Godot, clear asset licenses, or certify Android device compatibility.

Artifact: Kindlewake-Project-Health-Audit.

### 7. Workflow YAML Lint

File: .github/workflows/workflow-lint.yml

Runs on pushes, pull requests and manual dispatch. It parses every workflow YAML file, runs the source-handoff, organizer and project-health audit tests, executes the read-only health audit, and smoke-tests the read-only branch hygiene report. This validates YAML syntax and those utility scripts, not every GitHub Actions semantic, permission or runtime rule.

## Repository protection — configure once in GitHub settings

The main branch was observed as unprotected during the repository review. The GitHub connector available to this workflow can inspect repository state but does not expose a branch-protection write operation, so protection has not been enabled automatically.

In GitHub, open Settings → Branches (or Rules → Rulesets) and create a rule targeting `main`:
- Require a pull request before merging; require at least one approval if a second reviewer is available.
- Require status checks: Workflow YAML Lint and the required Build Android APK validation checks after confirming their exact check names from a successful run.
- Require branches to be up to date before merging.
- Block force pushes and branch deletion.
- Require conversation resolution.
- Do not require signed commits unless signing is configured for every contributor.
- Keep administrators subject to the rule where practical; use an explicit emergency bypass only if needed.

Do not make every optional audit a required check until its baseline warnings are resolved. Require deterministic correctness checks, not advisory reports.

## Recommended routine

- Before risky work: run Manual Full Repository Backup.
- Before moving files: run Repository Organizer in audit mode, inspect the report, then rerun in organize mode if appropriate.
- Before cleaning branches: run Branch Hygiene and inspect the report. Delete branches manually only after checking open PRs and backup needs.
- Before integrating a feature: run Safe Branch Integration with the feature branch as source and main as target. Review the draft PR and require CI/review before merging.
- Before distributing an APK: run Build Android APK, verify the artifact, then install and test on a physical device.
- Before a broad maintenance pass: run Project Health Audit and resolve errors before interpreting warnings.\n- When handing work to another person or AI: run Manual Source Handoff Snapshot and give them the exact commit and recovery instructions.

## Safety guarantees and limits

- No maintenance workflow silently merges into main.
- Organizer apply mode uses a separate branch and draft PR.
- Branch cleanup is report-only.
- Backups and handoffs are tied to exact refs and commits.
- CI success, conflict-free merge status and APK export do not prove real-device gameplay quality.
- Human review remains required for file moves, branch diffs, licensing, gameplay and release approval.
