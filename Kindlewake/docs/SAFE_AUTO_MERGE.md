# Safe automatic integration

The `.github/workflows/safe-auto-merge.yml` workflow enables GitHub native auto-merge only when all of these conditions hold for the **same exact pull-request head SHA**:

1. The PR targets `main` and is no longer a draft.
2. GitHub reports the PR mergeable (no merge conflict).
3. **Build Android APK** succeeds for the PR, including Godot import, strict tests, balance checks and Android export.
4. **Synchronize Project Version** succeeds for the PR.
5. The PR head has not changed since those checks completed.

The workflow then requests GitHub native auto-merge using squash. GitHub's own branch rules and required checks remain authoritative; the workflow does not force-push, resolve conflicts, dismiss reviews, or bypass protections. If a condition is missing or ambiguous, it fails closed and does not merge.

## Required repository configuration

Enable **Allow auto-merge** in repository settings. Configure a `main` branch ruleset/branch protection requiring these exact checks:

- `Build Android APK / apk`
- `Synchronize Project Version / Keep README and Android export version aligned`

Require branches to be up to date before merging. Do not require an approval from the PR author themselves. Keep force pushes and branch deletion disabled on `main`.

The GitHub connection used to update files cannot administer branch protection/rulesets. An owner must apply these settings in GitHub repository Settings → Rules → Rulesets (or Branches → Branch protection rules). Until those settings exist, the workflow still performs its explicit same-SHA checks, but direct UI/API merges may bypass this automation.

## Intentional blockers

- Draft PRs never auto-merge.
- PRs with conflicts or stale check results never auto-merge.
- Device/gameplay QA, asset-rights review, release signing, and other non-CI requirements remain explicit release gates. A green CI build is not proof of physical-device compatibility.
- Never use this workflow to merge a release/tag or a PR targeting a branch other than `main`.
