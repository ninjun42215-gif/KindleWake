# Safe automatic integration

The `.github/workflows/safe-auto-merge.yml` workflow merges only after the same exact pull-request head SHA has passed the repository's core checks and every additional PR-triggered workflow discovered for that SHA.

## Merge gate

1. The workflow discovers the repository's current default branch at runtime. It does not assume the branch is named `main`.
2. It finds exactly one open PR whose head SHA matches the completed workflow run. Ambiguous matches are rejected.
3. The PR must target the current default branch, be ready for review, and be reported mergeable by GitHub.
4. These four core checks are always required:
   - `Build Android APK`
   - `Synchronize Project Version`
   - `Workflow YAML Lint`
   - `Project Health Audit`
5. Every additional `pull_request` workflow run discovered for that exact SHA is also required to complete successfully. Adding a feature-specific PR workflow therefore adds it to the gate automatically; no second hard-coded workflow-name list needs updating.
6. The gate waits for all required workflows, keeps the latest attempt per workflow, and requires the discovered run set to remain stable across repeated polls.
7. Immediately before merging, it rechecks draft state, mergeability, default-branch target and exact head SHA. The REST merge request includes the expected SHA; a concurrent push is rejected.

The privileged `workflow_run` job is intentionally kicked off by completion of **Build Android APK**. This is a stable sentinel, not an exhaustive check list: once started, the gate discovers all PR-triggered workflows for the exact head SHA and requires them all to pass. New feature-specific PR workflows therefore join the gate automatically without needing to be added to the kickoff list. Keeping an explicit kickoff also prevents the merge workflow from being treated as a push workflow.

The privileged `workflow_run` job does not check out or execute pull-request code. It uses GitHub's Actions REST API because workflow-run jobs do not have local Git metadata. It fails closed on missing core checks, failed or incomplete workflows, stale heads, conflicts, drafts, ambiguous PR discovery, or timeouts.

## Required repository configuration

Enable **Allow auto-merge** if native auto-merge is used elsewhere. Configure branch protection/rulesets on the repository's current default branch to require the appropriate core status checks and require branches to be up to date before merging. Keep force pushes and branch deletion disabled on the protected default branch.

The GitHub connection used to edit repository files cannot administer branch protection/rulesets. An owner must verify these settings in GitHub repository Settings → Rules → Rulesets (or Branches → Branch protection rules). The workflow's explicit gate does not replace repository-level protections; direct UI/API merges may bypass this automation if protections are absent.

## Extending the project

- New feature workflows should use a `pull_request` trigger when their result must gate merges. Their runs are discovered and included automatically for the matching head SHA.
- Keep the four core workflow names stable, or update the core list in this workflow when intentionally renaming one.
- A workflow that does not run for a PR (for example, dispatch-only or push-only automation) cannot be treated as a PR check and is not included.
- Keep branch target selection tied to the repository default branch. If the project intentionally adopts multiple protected release targets, add an explicit allowlist and matching branch rules rather than silently permitting arbitrary target branches.

## Release blockers

Physical-device QA, asset-rights review, release signing and other non-CI requirements remain separate release gates. A green CI build is not proof of physical-device compatibility or asset redistribution permission.


### No-checkout GitHub CLI context
Both privileged steps set `GH_REPO: ${{ github.repository }}` explicitly. The final merge call also passes `--repo` and uses the same repository-qualified REST endpoint. This is required because `workflow_run` jobs intentionally do not check out a repository and must never depend on a local Git remote.
