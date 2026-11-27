# KindleWake original UI audio cues

Status: runtime-integrated first audio tranche
Engine target: Godot 4.2.2 · GL Compatibility · Android
Source: original procedural synthesis authored for this repository; no sampled recordings, third-party libraries, fonts, packs or external audio files.

## Cue inventory

| Stable ID | Intended interaction | Duration | Format |
|---|---|---:|---|
| ui_tap | Ordinary button press | 85 ms | 24 kHz mono PCM16 WAV |
| ui_confirm | Continue, new/load game, save, buy/sell and affirmative actions | 245 ms | 24 kHz mono PCM16 WAV |
| ui_back | Back, cancel, close, return and negative actions | 205 ms | 24 kHz mono PCM16 WAV |
| ui_toggle | CheckButton/settings toggle | 115 ms | 24 kHz mono PCM16 WAV |

The cues are deliberately brief, restrained and low-peak. A 4 ms attack and 12 ms tail prevent hard waveform edges. They are not loops and are not intended to compete with dialogue or future score.

## Runtime contract

- KW classifies button labels in its existing global node-added hook. CheckButtons use ui_toggle; navigation labels use ui_back; common affirmative/action labels use ui_confirm; all other buttons retain ui_tap.
- KW.sfx_enabled remains the persistent user opt-out. The existing Master bus volume slider controls their audible level.
- KW._load_sfx_stream caches each decoded stream once. KW.sfx creates a short-lived player per event and frees it on completion.
- WAV is preferred for these tiny lossless PCM cues; the existing OGG path remains supported as a fallback for future effects.
- No audio bus, project setting, permission, save schema or gameplay system is added or changed.

## Budget and import

The four PCM files total approximately 32 KiB on disk. Each is mono, 16-bit, 24,000 samples/second, with no loop points. Uncompressed decoded PCM is the same order as the source file size. This is a source-size and PCM budget, not a measured Android mixer/driver allocation.

Godot's normal WAV importer handles these resources; no external decoder, script plugin or import preset is required. The headless scene smoke test checks each imported stream's type, rate, channel count, duration and non-empty sample data.

## Deliberate exclusions

This tranche does not add a title theme, regional/house motifs, ambient loops, battle music, voice, or third-party sound packs. Adaptive score work should follow a separate motif and transition-lifecycle review; do not imply all audio production is complete.