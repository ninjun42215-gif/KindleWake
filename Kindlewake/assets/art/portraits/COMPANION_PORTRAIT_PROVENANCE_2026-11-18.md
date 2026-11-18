# Companion portrait provenance — 18 November 2026

## Ilyan Voss
- Runtime file: `assets/art/portraits/ilyan_voss.svg`
- Stable character ID: `ilyan_voss`
- Format and canvas: original SVG, 512 × 512
- Authorship: KindleWake project, authored in this repository for this character
- Licence: original project content; no third-party source image, font, brush pack, external package or copied game artwork
- Design basis: former Silent Tower guard and loyal House Quillon battle mage; ash-dark cropped hair, greying temples, weathered face, tower-guard mantle, steel and muted bronze details
- Runtime identity: the portrait resolver in the parent companion-identity branch prefers this exact character-ID SVG before the shared legacy `courtier` portrait

## Maren Vey
- Runtime file: `assets/art/portraits/maren_vey.svg`
- Stable character ID: `maren_vey`
- Format and canvas: original SVG, 512 × 512
- Authorship: KindleWake project, authored in this repository for this character
- Licence: original project content; no third-party source image, font, brush pack, external package or copied game artwork
- Design basis: Thalassar pilot and archer; wind-tied auburn hair, coastal weathering, practical leather harness, tideglass pendant and beacon/water background; muted brown armour echoes her existing roster-atlas cell
- Runtime identity: the portrait resolver in the parent companion-identity branch prefers this exact character-ID SVG before the shared legacy `ash_scout` portrait

## Import and performance
- Both assets use inline paths, gradients and vector geometry only; there are no external references, filters, embedded raster images, scripts or fonts.
- The 512 × 512 source is intentionally vector so Godot can import it at the actual display size. The 76 × 76 Companion Chronicle thumbnail is the current target, not a claim that these are final high-resolution painterly masters.
- A 512 × 512 RGBA8 raster would be 1 MiB per image before compression/mipmaps; this is only a planning estimate. Actual Godot import size, GPU residency and Android frame pacing have not been measured.
- SVG XML parsing and 512 px / 76 px raster previews were checked locally with CairoSVG. Godot editor import and physical Android rendering remain pending.

## Art status
These are original, character-specific vector concept portraits to close the two missing companion identity slots. They are not final painterly semi-realistic masters. Keep the approved portrait pipeline direction: believable adult anatomy, distinct facial structure, material separation, controlled light and sprite-compatible silhouette. Replace these concepts only with approved art that preserves each stable character identity.
