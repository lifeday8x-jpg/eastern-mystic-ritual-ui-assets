# Consistency Checklist

> Run this after generating a batch of assets. In single-asset mode, spot-check the first 3 items.

---

## Visual Consistency

| # | Check | Pass? |
|---|-------|-------|
| 1 | **Palette family**: all assets use the same color family (celadon/teal, ink gray, mist white, brass gold)? No rogue saturated colors? | |
| 2 | **Line weight**: ornamental lines, borders, and filigree have consistent thickness across assets? | |
| 3 | **Corner radius / shape language**: buttons, cards, panels share the same roundness and bevel style? | |
| 4 | **Lighting direction**: consistent light source across all assets (default: soft top-center, slight warm)? | |
| 5 | **Texture / detail density**: no asset is significantly more detailed or more flat than others? | |
| 6 | **Material rendering**: jade reads as jade, brass reads as brass, stone reads as stone — consistently across all assets? | |
| 7 | **Shadow softness**: drop shadows have the same blur and opacity across comparable elements? | |
| 8 | **Perspective / camera angle**: all flat UI assets are truly flat (no accidental 3D tilt)? Devices match expected angle? | |

## Character Consistency (if applicable)

| # | Check | Pass? |
|---|-------|-------|
| 9 | **Proportions**: all characters share the same head-to-body ratio and stylization level? | |
| 10 | **Line style**: same outline treatment (ink weight, clean vs. sketchy)? | |
| 11 | **Rendering style**: same shading method (soft painted, cel, etc.)? No mix of photorealistic and anime? | |

## Production Quality

| # | Check | Pass? |
|---|-------|-------|
| 12 | **No baked text**: no readable characters, letters, numbers, or text-like marks in any asset? | |
| 13 | **Clean edges**: transparent-background assets have crisp silhouettes, no halo or fringe? | |
| 14 | **Layer separation**: assets that should be separate ARE separate (not composited into one image)? | |
| 15 | **Correct background mode**: glow effects on black, hard-edge assets on transparent? | |
| 16 | **Readable at target size**: UI elements are clear at phone resolution, not too detailed to shrink? | |

## Mood / Style Guard

| # | Check | Pass? |
|---|-------|-------|
| 17 | **No red-gold webgame**: nothing reads as cheap browser MMO aesthetic? | |
| 18 | **No tarot / horoscope**: result cards don't accidentally look like fortune-telling cards? | |
| 19 | **No sci-fi medical**: scan overlays feel mystical, not clinical? | |
| 20 | **Ritual mood intact**: overall feeling is "mysterious instrument", not "app UI" or "poster"? | |

---

## Failure Response

If any check fails:

1. Identify which asset(s) break consistency.
2. Note what specifically is wrong (e.g. "button border is 2x thicker than card border").
3. Regenerate the weak asset with adjusted prompt.
4. Re-run relevant checks on the new version.

In pipeline mode, report failures to user before final delivery.
In single-asset mode, self-correct silently if possible, or flag to user if regeneration is needed.
