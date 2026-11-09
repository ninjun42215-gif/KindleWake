> **CONSOLIDATED 0.12.0 DEVELOPMENT CANDIDATE — 2026-11-10:** Canonical repository `ninjun42215-gif/KindleWake`; verified `main` baseline is `eb589c08b40b639a83b45bcc8d10718fd8223d7a`, game/Android version `0.11.0 / 1100`, save schema `4`. All new work is isolated on `docs/authoritative-live-handoff-2026-11-10` and consolidated in **one** PR: [#28](https://github.com/ninjun42215-gif/KindleWake/pull/28). Main and its APK have not been changed by this candidate. Do not build, distribute or describe a new APK as released until the full candidate passes CI and the one PR is merged.
>
> **Candidate upgrade:** project version `0.12.0`, Android version code `1200`, save schema remains `4` (new region fields are additive and legacy schema-4 saves default safely to Sethmarch). The candidate now adds a four-direction wraparound campaign world (shortest-path seam navigation, seamless terrain sampling, seam-aware landmarks and canonical save coordinates) plus controller/keyboard/touch-stick movement, A/E interaction and sprint (B/Shift or RUN toggle) in the overworld, towns and dungeons. The branch now contains the approved [Premium Production Bible](Kindlewake/docs/PREMIUM_PRODUCTION_BIBLE.md), a separate 64×48 Brinegate Coast overworld, Brinegate/Saltmere/Lantern Quay town maps, Tideglass Grotto dungeon and tactical battle, the Tidebound sea-charter unlock from Eldrimar, region-specific coastal rendering, Maren Vey recruitment, a persistent ledger quest with public/private outcomes, per-region save positions, and automated tests for map connectivity, recruitment, quest idempotency and old-save restoration.
>
> **Implementation honesty:** these features exist on the candidate branch but are not yet CI-validated or merged. The rest of Thalassar (Isles of Vey, Kelpward Reach and Deepwake Reach), the Wreck-King's Hold and Old Beacon Vault are still future content; do not present all seven continents as explorable. The production bible is a quality standard, not proof that every proposed portrait, animation, audio cue or asset pack has shipped. Unknown third-party asset licences remain a release blocker.
>
> **Single-delivery rule:** keep improving this same branch and PR #28; do not create separate feature PRs or run an APK release for partial work. Before merge, validate Godot import, the full strict test suite, battle simulation/balance, Android export, YAML lint, version sync and project health on the exact final PR head SHA. Fix failures, refresh the handoff, mark this PR ready, and use the exact-head safe merge guard. Physical Android QA remains separate from CI. The game remains fully offline and must not request INTERNET permission.


---



# KindleWake — Next AI Start Here

**Repository:** `ninjun42215-gif/KindleWake`  
**Project directory:** `Kindlewake/`  
**Live main:** `b982f2f665ab9ecf8b3862ca676d61dac55fde96` (tree identical to baseline `eb589c08b40b639a83b45bcc8d10718fd8223d7a`)  
**Active candidate:** PR [#28](https://github.com/ninjun42215-gif/KindleWake/pull/28), branch `docs/authoritative-live-handoff-2026-11-10`; refresh its head SHA and checks before acting.  
**Main version:** `0.11.0` · **Android code:** `1100` · **Save schema:** `4`  
**Candidate version:** `0.12.0` · **Android code:** `1200` · **Save schema:** `4`  
**Timezone:** Asia/Manila (UTC+08:00)

## Start here — no user re-explanation required

1. Read `Kindlewake/docs/SESSION_HANDOFF.md`, `Kindlewake/docs/GDD.md`, `Kindlewake/docs/CONTINUATION_PROMPT.md`, `Kindlewake/docs/VERSIONING.md` and `Kindlewake/docs/SAFE_AUTO_MERGE.md`.
2. Inspect the live `main` SHA, branches, open PRs and exact-head CI before editing. The SHA above is the inspected checkpoint, not a substitute for a live check.
3. The canonical source is the ordinary tracked files under `Kindlewake/`. Do not ask the user for a master project ZIP.
4. Use a feature/workflow branch and PR. Never write directly to main or force-push. Allow automatic merge only after all required exact-SHA checks pass and GitHub reports the PR is mergeable.
5. Always preserve offline-only behavior, save compatibility, asset provenance and the current version source of truth.

## Current facts

- PR #28 is the single consolidated candidate. Continue on its existing branch; do not create another feature PR for this delivery.
- The candidate contains the Brinegate Coast vertical slice, world-wrap logic, controller/touch exploration controls, premium shared exploration theme and refreshed production/handoff documentation.
- The campaign overworld is toroidal; towns and dungeons remain bounded authored maps.
- Candidate validation must be checked against the exact latest PR head. A successful older head does not validate a newer commit.
- Do not merge a draft or a failing/incomplete head. Mark PR #28 ready only after final tests and checks pass, then merge with the exact-head SHA guard.
- Physical Android QA remains outstanding. CI success is not evidence of testing on a physical controller or phone.
- Asset redistribution/licence review remains a release gate for any third-party pack.


## Latest verified CI and handoff

- PR #17 merged by `github-actions[bot]` at `843d21be5b201b95736e98a38f0485274e5dcc03` after all four exact-SHA checks passed on `91660c021144b53719e5cca43de6b3d946f2880b`.
- Build Android APK run `42708085011`: 342 strict checks, 0 failures; balance report passed; signed 41.2 MB APK, arm64-v8a + armeabi-v7a, no permissions. APK artifact `13715145936`; logs artifact `13715305665`.
- Version Sync `42708084633`, Workflow YAML Lint `42708084644`, Project Health Audit `42708084771`: all passed.
- Safe Auto Merge run `42708329157` succeeded.
- Source handoff run `42708064822`, artifact `13714701100`: 177 tracked files, four verified parts, reconstructed archive SHA-256 `aba0eea9f02f0ca1c96be8ac91259cef50ba6c71145cca41c349ec5f4d76d976`. The PR head source tree was merged unchanged into main.
- The first Godot import produced transient global-class registration errors; the build script's clean second scan succeeded, then all 342 checks passed and APK export succeeded. Investigate this import warning separately.

## Next work — execute, do not merely propose

1. Audit GDD `0.10.1`–`0.10.4`: responsive UI, battle identity overlays, receiving intake and portable handoff packaging. Inspect actual files and tests; report exact evidence and gaps.
2. Verify or trigger a strict Godot import/test/balance/APK build on current main.
3. Locate the source handoff workflow, generate an artifact for the exact current source SHA and verify its SHA-256 manifest and each part is at most 25 MB.
4. Choose the next highest-value campaign feature from the GDD based on the audit; implement a complete, tested vertical slice rather than adding disconnected systems.
5. Update GDD, README, session handoff and continuation prompts in the same PR.

## Fixed product constraints

- Godot 4.2+, GDScript, GL Compatibility, touch-first landscape/mobile support.
- Fully offline: no accounts, servers, multiplayer or INTERNET permission.
- Original KindleWake IP only. Preserve existing lore, systems and save migrations.
- Do not claim runtime/device testing without evidence.
- Keep restricted/uncertain assets out of release builds until licence provenance is clear.

## Automation and merge safety

Required checks for a merge: Build Android APK, Version Sync, Workflow YAML Lint and Project Health Audit on the **same exact PR head SHA**. The merge must reject stale heads, missing/failed checks, drafts, conflicts, wrong base branches and ambiguous PR discovery. Use expected-head-SHA REST merge; never bypass the gate for convenience.

## Links

- Main: https://github.com/ninjun42215-gif/KindleWake/tree/main
- Actions: https://github.com/ninjun42215-gif/KindleWake/actions
- PR #16: https://github.com/ninjun42215-gif/KindleWake/pull/16
- PR #14: https://github.com/ninjun42215-gif/KindleWake/pull/14
