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
8. Every development session must leave a merge-ready source ZIP handoff split into numbered parts, each <=25,000,000 bytes (25 MB decimal), through GitHub Actions.
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

1. Re-read latest branch head, this page, `docs/SESSION_HANDOFF.md`, `docs/GDD.md`, `README.md`, master continuation prompt and `receiving/README.md`.
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
- `.github/workflows/build-apk.yml`: CI validation, APK export and split source handoff packaging.

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
