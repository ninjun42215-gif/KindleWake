# KINDLEWAKE — NEXT AI START HERE

**Purpose:** Single-page orientation and decision record for the next AI. The user explicitly wants project context visible so the next AI does not ask them to repeat known information. Read this page and the master continuation prompt; inspect the repository rather than asking routine questions.

## Canonical facts

| Item | Current value |
|---|---|
| Game | KINDLEWAKE: THE SUNDERED VOW |
| Genre | Offline-first medieval tactical RPG |
| Engine | Godot 4.2+, GDScript, GL Compatibility |
| Repository | https://github.com/ninjun42215-gif/KindleWake |
| Active branch | `feature/rune-system-v1` |
| Snapshot branch head | `09c548d92d384b64ba1422f77601cea222753e2c` |
| Pull request | #4, draft; do not merge |
| Main | Do not modify or merge without explicit user authorization |
| Save format | Schema v3; preserve legacy sigil inventory/socket fields and aliases |
| Target | Android, touch-first, landscape-first; responsive portrait |
| Network | Offline-first; no accounts, cloud, multiplayer, server calls or Android INTERNET permission |

## Standing user instructions

1. Continue proactively when the user says “continue”; choose the next sensible roadmap task.
2. Do not ask for a project ZIP. Tracked `Kindlewake/` in this repository is canonical.
3. Do not ask routine questions about branch, engine, save schema, platform, art direction, workflow or packaging; decisions are documented here and in the GDD/master prompt.
4. Prefer complete, playable, tested implementation over placeholders or status-only replies.
5. Preserve existing systems and compatibility. Make small reviewable commits; never force-push.
6. PR #4 stays draft. Do not touch `main`.
7. Meaningful changes require GDD, session handoff, both continuation prompts and relevant README updates.
8. Every development session must leave a merge-ready source ZIP handoff split into numbered parts, each <=25,000,000 bytes (25 MB decimal), through the repository-wide GitHub Actions workflow. The workflow runs on all branches, tags, pull requests and manual dispatch; it packages all tracked repository files from the triggering ref, not a fixed branch/file list.
9. Every outside-AI contribution must first be preserved in a unique `Kindlewake/receiving/<date>-<contributor>-<topic>/` folder with a complete `HANDOFF.md`; split large ZIPs and include `REASSEMBLE.txt`. Review before integration.
10. Report validation accurately. CI success is not physical Android device QA.

## Implementation snapshot

Repository source and GDD/session handoff are authoritative. Summary:
- Tactical grid combat, charge-time turn order, terrain/cover/line-of-sight, status effects, battle rewards and four expanded maps.
- Overworld, settlements/interiors, campaign progression, NPC dialogue and regional vendors.
- Party/company management, recruitable heroes, class progression, skills, equipment and save/load.
- Rune library: 77 definitions (active, passive, unique and heirloom); cross-grade fusion; rune AP/mastery chance bonus; rune services and socket operations.
- Equipment enhancement to +15.
- Responsive title, overworld, party/company and battle HUD; mobile and portrait reflow.
- Original vector environment props, title illustration, rune atlas, UI ornaments and lightweight combat VFX.
- Hero/enemy sprite sheets still need a dedicated art/animation upgrade. Palette treatments and equipment/identity overlays are interim work, not bespoke per-class/per-species sprite-sheet replacements.

## Latest known CI checkpoint

- Branch head: `09c548d92d384b64ba1422f77601cea222753e2c`
- Build Android APK workflow run #282: https://github.com/ninjun42215-gif/KindleWake/actions/runs/42675923270
- Result: **completed / success**; `apk` job succeeded.
- Completed stages: Godot import + strict tests + balance report + APK build; APK upload; source handoff packaging; split handoff upload; test/build logs upload.
- Unexpired artifacts at snapshot time (expiry 2027-02-07):
  - `Kindlewake-APK`, ID `13700540809`
  - `Kindlewake-Source-Handoff-Parts`, ID `13699723324`
  - `test-logs`, ID `13699358976`
- Download via workflow page. Inspect every source part and verify each is <=25,000,000 bytes; do not infer individual part sizes from total artifact size.
- CI success does not establish physical-device visual/touch QA; that remains outstanding unless a later handoff records actual device testing.

## Immediate next actions — no clarification needed

1. Inspect the live working branch/ref and latest commit (never assume the branch name), then re-read this page, `docs/SESSION_HANDOFF.md`, `docs/GDD.md`, `README.md`, master continuation prompt and `receiving/README.md`.
2. Inspect current PR #4 status and latest workflow run before editing.
3. Inspect source/tests. Next major development priority: bespoke hero/enemy sprite sheets and animation sets (idle, walk, attack, cast, hurt, death), then cast/projectile/impact VFX and elemental rune effects. Preserve animation contracts or update importer, renderer and tests together.
4. Add missing regression coverage for rune/status/equipment/save/UI behavior. Verify fusion edge cases and save schema v3.
5. Continue HUD polish only where source inspection or reproducible tests show defects; cover compact landscape and portrait.
6. Run validation, fix failures, update docs, commit to feature branch and verify exact branch-head CI/artifacts.
7. Never claim phone testing unless an actual Android device was used.

## Detailed source of truth

- `CONTINUATION_PROMPT.md` (root): mandatory operating contract and complete AI workflow.
- `Kindlewake/docs/CONTINUATION_PROMPT.md`: synchronized in-project copy.
- `Kindlewake/docs/GDD.md`: game design, mechanics, world, narrative, UI and roadmap.
- `Kindlewake/docs/SESSION_HANDOFF.md`: chronological implementation, commits, validation evidence, limitations and next tasks.
- `Kindlewake/README.md`: setup, running/building and user-facing project information.
- `Kindlewake/receiving/README.md`: outside-AI contribution intake/reassembly/review/integration.
- `.github/workflows/build-apk.yml`: repository-wide CI validation, APK export and branch/ref-aware split source handoff. Triggers on all branch pushes, tag pushes, pull requests to any branch and manual dispatch; archive is built from `git ls-files` at the triggering commit and includes a ref/SHA metadata file plus SHA-256 verification.

## No-clarification defaults

Unless explicitly overridden by the user:
- Continue on `feature/rune-system-v1`; PR #4 stays draft; never modify `main`.
- Keep Godot 4.2+, GDScript, GL Compatibility, Android/offline-first.
- Keep save schema v3 and legacy aliases.
- Keep dark-medieval pixel-art / parchment / heraldic direction; create original assets or verify third-party license, attribution and redistribution rights.
- Keep touch targets usable, landscape-first and portrait-responsive.
- Put outside-AI work in `Kindlewake/receiving/` before review.
- Make small testable commits and produce split source handoff after every development session.
- If information exists in docs or source, inspect it instead of asking the user.
- Ask only for an essential product decision that cannot safely be inferred and would materially change implementation.

---
Living snapshot: refresh branch SHA, workflow evidence, artifacts, implementation status and next actions after meaningful updates. Never present stale checkpoint facts as current.


## Android release workflow update — 2026-11-10

- CI workflow `.github/workflows/build-apk.yml` now has separate `android-build` and `source-handoff` jobs. The source handoff is independent and still uploads when build/tests fail.
- APK artifacts include `Kindlewake.apk`, SHA-256 and `release-manifest.json` with ref/commit/version provenance. Test/build logs remain downloadable.
- Every branch, tag, PR target and manual dispatch uses the triggering checkout; the source handoff is generated from `git ls-files`, not a fixed feature-file list. Each split part is <=25,000,000 bytes.
- Tag pushes produce build candidates only. They do not publish production releases.
- `.github/workflows/publish-android-release.yml` is the separate manual production publisher. Before use, create the `android-production` GitHub Environment, configure required reviewers, add `ANDROID_RELEASE_KEYSTORE_BASE64`, `ANDROID_RELEASE_KEY_ALIAS`, and `ANDROID_RELEASE_KEY_PASSWORD` as environment secrets, and set `ANDROID_RELEASE_CERT_SHA256` as an environment variable. The workflow verifies the exact APK signing certificate against this fingerprint. Never commit the private production key.
- `project.godot` and Android export preset version names must match. Current version is `0.10.0`; Android version code is `1000` and must increase for every published update.
- Current builder supports APK export only, not AAB. CI does not prove physical-device QA. See `docs/ANDROID_RELEASE_WORKFLOW.md` for complete operating instructions.
- Workflow edits have been committed, but their new CI execution must be inspected on the exact latest branch-head SHA before calling this revision validated.


### Latest APK verification hardening

- Builder commit: `28d56c736af0007bd813a602a778fab38989d108`.
- Project/export version-name mismatch is rejected locally and in CI.
- Balance report failures now block strict builds.
- APK permission inspection (`aapt2`) and signature verification (`apksigner`) are mandatory; missing tools or failed checks block output.
- Production release workflow commit `86f4be7d863dd12daad65348e8cea0eb176ee775` pins the APK signer against `ANDROID_RELEASE_CERT_SHA256`.
- Re-run/inspect branch-head CI before claiming these changes validated.


### Production publishing safeguards and availability

- The publisher refuses to overwrite an existing GitHub Release for the same tag; create a new version tag for each release.
- GitHub only exposes `workflow_dispatch` workflows after their file exists on the default branch. This workflow currently exists on `feature/rune-system-v1` only and becomes manually runnable after reviewed merge to the default branch. Do not merge PR #4 or modify `main` without explicit user authorization.
- Configure the `android-production` environment, required reviewers, signing secrets and expected certificate fingerprint before production use.


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


## Current handoff pipeline upgrade — 2026-11-10
The source handoff is generated by Kindlewake/tools/source_handoff.py, tested by Kindlewake/tests/test_source_handoff.py, and uploaded as Kindlewake-Source-Handoff-Parts. Use AI_NEXT_SESSION.md, PARTS-MANIFEST.json, REASSEMBLE.txt and the internal file manifest. Always compare the handoff commit with the live branch head before continuing. The workflow final report provides next actions conditional on APK and handoff outcomes.


## Workflow result artifact — 2026-11-10
The result-report job now uploads a separate 90-day artifact named Kindlewake-Workflow-Report containing the exact source ref/SHA, APK and handoff job outcomes, expected artifacts, and conditional next-step recommendations. The Actions run summary mirrors this report. The source ZIP itself now also embeds REASSEMBLE.txt so the recovery instructions survive extraction. A receiving AI should inspect both the source ZIP metadata and the workflow report artifact; neither should be treated as proof for a different/newer commit.


The split artifact now also contains the exact source_handoff.py recovery helper beside the parts. PARTS-MANIFEST.json stores that helper's SHA-256, and reassembly refuses to run if the helper is missing or altered. This avoids the bootstrap problem of needing to extract the ZIP before obtaining the tool required to reassemble it. The test suite also asserts that the helper is present in the artifact.
