# Visual/content handoff — 2026-11-27 UI audio feedback cues

## Repository and branch

- Repository: ninjun42215-gif/KindleWake
- Project: Kindlewake/
- Branch: art/original-ui-audio-cues-2026-11-27
- Base: main at 13f66ec19476c9af5ed2b5c81af95e4d8a026876
- Runtime target: Godot 4.2.2, GL Compatibility, Android, offline-first.
- Dedicated audio/UX slice; no active art or core PR currently owns scripts/core/kw.gd or tests/scene_smoke_test.gd.
- Main remains unchanged. Do not merge automatically.

## Live-state inspection

- Main has the KW global presentation autoload with persistent SFX enablement, Master volume, haptics, reduced motion, a button-down feedback hook, an AudioStreamPlayer for future music and a cached OGG-only SFX loader.
- Main had no assets/audio/ directory or runtime SFX files, so the default ui_tap call was silent.
- Existing title settings already expose Master volume, haptics, reduce motion and UI sound effects. The implementation reuses those controls and the existing user://settings.cfg contract.
- Open visual PRs cover battlefield VFX/surface details, world cartography, title artwork, trade goods, settlement architecture, portraits, equipment and enemy heraldry. This branch avoids their files. Core PR #184 changes companion quest normalization and its own test; it does not touch the KW audio layer or scene smoke test.

## Delivered vertical slice

- Added four original short UI cues: ui_tap, ui_confirm, ui_back and ui_toggle.
- WAV source is generated procedurally from simple oscillators and low-level deterministic noise, with short fades. No external recordings, packs, libraries, fonts or unclear-rights assets are used.
- Extended KW's resolver to prefer WAV and retain OGG fallback; decoded streams are cached once.
- Added semantic button feedback: CheckButton → toggle; back/cancel/close/return/no → back; common affirmative and transaction actions → confirm; remaining buttons → tap.
- Existing haptic and press-scale feedback remain unchanged. Existing SFX toggle and Master bus slider continue to control the sounds.
- Extended the headless scene smoke test to load the actual KW resolver, validate all four imported WAV streams and check the semantic button mappings.

## Audio and performance budget

- All files are mono PCM16 at 24 kHz. Durations: tap 85 ms, confirm 245 ms, back 205 ms, toggle 115 ms.
- Four files total approximately 32 KiB. Each decoded stream is cached; no looping source, streaming music, DSP plugin, shader or per-frame processing is added.
- This is a source/PCM estimate. Godot import artifacts, Android mixer allocations, latency and physical-device output remain to be measured.
- No project version, save data/schema, permissions, campaign rules, battle rules, story or gameplay data changed.

## Verification

- Source and WAVs are committed together.
- The scene smoke test now checks AudioStreamWAV, 24 kHz, mono, non-empty PCM, 50–300 ms duration, and button-classification mapping.
- Exact-head CI must run after the PR is opened: Godot 4.2.2 import, scene smoke, strict core suite, Project Health, YAML Lint, Version Sync and Android export.
- Headless resource validation does not prove audible playback, perceived mix, speaker quality, audio latency or no clipping on a real phone.
- Required manual QA: listen on at least one Android phone and headphones; test Master volume at 0/low/full, SFX toggle off/on, rapid taps, repeated transitions, haptic toggle and reduced-motion mode.
- Physical-device mixer latency and actual memory are outstanding. Do not claim audio/device verification from CI alone.

## Next audio work

1. Add a proper SFX bus only if the existing Master-only routing and settings UX are intentionally extended with migration-safe preferences.
2. Compose original short title/house motifs as separate work after confirming scene transitions and music lifecycle; do not abruptly restart on scene changes.
3. Add ambient region layers and adaptive tension/battle/victory/aftermath arrangements with a documented loudness and loop policy.
4. Add battle-specific hit/armour/heal/status/objective cues only after mapping existing event signals and reduced-flash/reduced-audio accessibility behavior.