# Kindlewake Android build and release workflow

Last workflow update: 2026-11-10. Canonical project: Godot 4.2+ under `Kindlewake/`.

## Release lanes

| Lane | Trigger | Signing | Output | Publishing |
|---|---|---|---|---|
| Development / CI | Push to any branch, PR to any branch, tag push, or manual dispatch | Existing sideload/test key configured for CI | `Kindlewake-APK` artifact + reports | Never publishes a production release |
| Production | Manual `Publish Android Production Release` dispatch for an existing `v*` tag | Private production keystore from protected GitHub Environment secrets | Production-signed APK, SHA-256 and manifest | Creates/updates the requested GitHub Release only after approval |

The CI workflow and production publishing workflow are intentionally separate. A tag push creates a verified build candidate artifact; it does **not** publish a production release automatically.

## Routine APK build

1. Push changes to the authorized working branch or open/update a pull request.
2. Open GitHub → Actions → **Build Android APK and Source Handoff**.
3. Wait for the `android-build` job. It checks that `project.godot` and the Android export preset use the same version, imports Godot, runs strict tests and the balance report, exports the APK, and verifies the APK archive, ARM64 library, signature and offline permission policy.
4. Download **Kindlewake-APK**. It contains:
   - `Kindlewake.apk`
   - `Kindlewake.apk.sha256`
   - `release-manifest.json` with source ref, commit SHA, version, application ID, artifact size and checksum.
5. Download **test-logs** if diagnosis is needed.
6. Download **Kindlewake-Source-Handoff-Parts** independently. This job runs even when Android build/test fails, so a failed build does not prevent the next AI session receiving the exact tracked source snapshot. Reassemble with `REASSEMBLE.txt` and verify `SHA256SUMS.txt`.

The source handoff uses `git ls-files` from the triggering checkout. It does not depend on a fixed branch name or a hard-coded list of feature files. New tracked files and folders are included automatically. Every part is at most 25,000,000 bytes (25 MB decimal).

## Production publishing setup — one-time repository configuration

Do not run production publishing until all of these are configured:

1. In GitHub repository Settings → Environments, create an environment named `android-production`.
2. The production workflow must first exist on the repository's default branch before GitHub exposes it for `workflow_dispatch`. This project keeps `main` untouched until the draft PR is explicitly approved and merged; therefore do not expect the production dispatch to be available while this workflow exists only on the feature branch.
3. Add required reviewers / deployment protection rules to that environment. The workflow references this environment; the approval rule is configured in GitHub settings, not in YAML.
4. Add these **environment secrets** to `android-production`:
   - `ANDROID_RELEASE_KEYSTORE_BASE64`: base64-encoded private `.keystore` or `.jks` file.
   - `ANDROID_RELEASE_KEY_ALIAS`: key alias.
   - `ANDROID_RELEASE_KEY_PASSWORD`: keystore/key password expected by the current builder.
   - `ANDROID_RELEASE_CERT_SHA256`: environment variable (not a secret) containing the expected SHA-256 fingerprint of the production signing certificate. The workflow compares the APK signer against it and refuses publication on mismatch.
5. Keep the private keystore and passwords out of Git, source ZIPs, issues, logs and chat. Do not use the public/test sideload key for Google Play or production distribution.
6. Keep a secure offline backup of the production keystore and its recovery information. Losing the signing identity can prevent users from installing updates signed with a different key.

To encode a keystore file:
- Linux/macOS: `base64 -w 0 release.keystore` (on macOS use `base64 < release.keystore | tr -d '\\n'`).
- PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes('release.keystore'))`.

The production workflow writes the decoded key only to the ephemeral GitHub runner's temporary directory and removes it when the runner is destroyed. It is not committed or uploaded as an artifact.

## Publishing a production APK

1. Create and push an immutable version tag that points to the reviewed release commit, for example `v0.10.0`.
2. Ensure `Kindlewake/project.godot` version and `Kindlewake/export_presets.cfg` `version/name` both equal the tag without the leading `v`.
3. Ensure Android `version/code` is greater than the previous published build. It is currently `1000` for version `0.10.0`; increment it for every subsequent store update. Do not reuse or decrease a published version code.
4. Open Actions → **Publish Android Production Release** → Run workflow.
5. Enter the exact existing tag and type `PUBLISH`. The `android-production` environment's required reviewers must approve deployment.
6. The workflow checks the exact tag, checks version consistency, imports the project, runs strict tests and balance report, builds with the protected production key, verifies the APK signature and offline permission policy, and creates a GitHub Release with the APK, checksum and manifest.
7. Inspect the release assets and manifest. Install and test on physical Android devices before broad distribution.

If the confirmation text is not exactly `PUBLISH`, the publishing job is rejected. If secrets or the protected environment are missing, the workflow fails closed.

## Versioning rules

- `project.godot` `config/version` and Android preset `version/name` must match.
- Android `version/code` is a monotonically increasing integer. It is not safely derived from semantic version text; bump it deliberately.
- The current project version is `0.10.0`; the Android preset was aligned to version name `0.10.0` and version code `1000`.
- CI fails early on project/export-preset version-name mismatch.
- A tag build is a candidate only. Production release creation requires the separate manual workflow and protected environment.

## Security and offline policy

- The game remains offline-first. Android `INTERNET` permission is forbidden; the build's APK verifier rejects it.
- The ordinary CI sideload key is for testing only. It is not the production signing identity.
- Production signing material must exist only in protected GitHub Environment secrets and the ephemeral runner during a release.
- Source handoffs exclude keystores, JKS, P12/PFX, PEM, private key files, common secret files and generated build/cache directories. Do not add credentials to tracked source.
- Never force-push or rewrite release tags. If a release is wrong, issue a new version tag and higher Android version code.

## Current limitations (do not overclaim)

- The current builder exports APK using Godot's Android export templates. It does **not** currently build or verify an Android App Bundle (AAB). Google Play AAB support requires a separately implemented and tested Gradle export path; do not label the APK as an AAB.
- CI success is not physical-device QA. Verify installation, launch, save/load, touch controls, orientation, rendering and performance on representative Android devices.
- The builder's Godot version and Android toolchain are defined by `Kindlewake/tools/build_apk.py`. Update and test them deliberately; do not silently upgrade the engine as part of a routine release.
- The existing test/sideload signing identity is not a substitute for a private production key.

## Troubleshooting

| Failure | Action |
|---|---|
| Version mismatch | Update `project.godot` and `export_presets.cfg` together; bump version code if this is a new distribution build. |
| Strict tests fail | Download `test-logs`, fix failures and push a new commit. |
| APK export/signature fails | Inspect `dist/logs/BUILD_SUMMARY.txt` and `dist/logs/export.txt`; do not bypass verification. |
| APK requests INTERNET | Treat as a release blocker; inspect the export preset and dependencies. |
| Production workflow says secrets are missing | Configure all three `android-production` environment secrets. |
| Production workflow starts without reviewer approval | Stop and configure required reviewers on the GitHub Environment before using it. |
| Existing app refuses update | Check that the same production signing identity was used and that version code increased. Do not tell users to uninstall if save preservation matters. |

## Build verification hardening

The local builder now treats APK permission inspection and signature verification as mandatory: missing `aapt2`, missing `apksigner`, or a failed inspection blocks the build. A non-zero balance report or reported `FAIL` / script / parse errors also blocks the strict build. The builder checks that `project.godot` `config/version` matches the Android preset `version/name`, including for local builds.

Production setup also requires the `ANDROID_RELEASE_CERT_SHA256` GitHub Environment variable (the expected certificate fingerprint, hexadecimal with or without colons). The release workflow compares the actual APK signer fingerprint against this value before creating the GitHub Release. Obtain the fingerprint from the production certificate/keystore and protect the signing identity; do not copy a fingerprint from an untrusted APK.


## Publishing safeguards

The production workflow refuses to publish if a GitHub Release already exists for the requested tag; published releases are not overwritten. GitHub only exposes a `workflow_dispatch` workflow after its YAML exists on the repository's default branch. This production workflow currently exists on `feature/rune-system-v1` only, so it will not be manually dispatchable until the reviewed PR is merged to the default branch. Do not merge PR #4 or modify `main` without explicit authorization.


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
