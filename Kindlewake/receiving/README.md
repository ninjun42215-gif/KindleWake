# Receiving folder — contributions from other AI tools

Place incoming contributions from another AI assistant in this folder before asking for integration.

## Accepted contents
- Source patches: `*.patch` or `*.diff`
- Asset bundles: `*.zip` (sprites, textures, audio, UI assets)
- Documentation: `*.md`, design notes, manifests and implementation plans
- Small standalone source files intended for review

## Required handoff note
Include a short `HANDOFF.md` with:
1. What was added or changed
2. Exact target paths and intended integration points
3. Engine/runtime assumptions and required plugins
4. Any new dependencies or licensing/attribution information
5. Tests performed and known limitations

## Integration rules
- Treat incoming files as untrusted proposals; review them before copying into production paths.
- Do not overwrite canonical game files blindly. Compare changes against the current feature branch and merge deliberately.
- Preserve Godot resource UIDs, scene references, naming conventions, save compatibility (schema v3), and existing sprite/frame contracts unless the integration updates all dependent code and tests.
- Do not include credentials, signing keys, private tokens, personal data, or generated build/cache directories.
- Keep original incoming bundles intact until integration is reviewed and tested.
- Run the strict Godot test/build pipeline after integration.

This folder is included in every source handoff archive so another AI or a future session has a predictable drop location.
