# Layer Separation Specs

> **Core rule**: anything that might be edited, replaced, repositioned, or localized later must not be baked into a single composite image.

---

## Universal Rules (apply to ALL asset types)

1. **No baked text.** Leave empty label areas or placeholder regions. Text is rendered by the game engine.
2. **Icons and buttons are separate assets.** Never bake a button onto a card or screen.
3. **Characters and backgrounds are separate.** Never composite a character into a scene.
4. **Glow/effects and base are separate.** Effects are blended at runtime (alpha or additive).
5. **Shadows are separate.** Drop shadows should be their own layer for repositioning.
6. **Frequently reused elements get their own file.** If it appears in 2+ places, it's a standalone asset.
7. **Output transparent PNG** unless the asset is a background plate or requires black-background additive blending.

---

## Per-Asset-Type Layer Breakdown

### main-screen

Main screen is a **concept reference only** — not directly used as game art. Its purpose is to lock visual direction. If user needs production assets from it, split into:

| Layer | Separate asset? | Notes |
|-------|----------------|-------|
| Background atmosphere | Yes → `background-plate` | Reusable, parallax-ready |
| Ground / platform | Yes | If present |
| Central device | Yes → `ritual-device` | Isolated transparent PNG |
| Decorative rings / overlays | Yes → `decorative-overlay` | Compositable layers |
| Button placeholders | Yes → `button-set` | Never bake into concept |
| Card placeholders | Yes → `result-card` | Never bake into concept |

### ritual-device

Typically delivered as a single isolated asset, but can split further if needed:

| Layer | When to separate |
|-------|-----------------|
| Device body | Always (the main deliverable) |
| Inner glow / aperture light | If user needs to animate or toggle it |
| Rotating ring / dial | If user needs rotation animation |
| Particle / energy layer | If user needs dynamic VFX overlay |

**Minimum delivery**: 1 transparent PNG (device body with baked subtle glow).
**Full delivery**: body + glow + ring + particle as separate PNGs.

### result-card

| Layer | Separate? | Reason |
|-------|-----------|--------|
| Card base (background panel) | Yes | Reused across all result types |
| Card frame / border | Yes | May change per rarity or grade |
| Badge / rank emblem area | Yes | Swapped per result |
| Reward item slots | Yes (each) | Different items per result |
| Glow / highlight accent | Yes | Color varies by element/rarity |
| Character overlay | Yes | Different character per result |
| Shadow | Yes | Repositionable |
| Text areas | Empty | Engine renders text |

**Minimum delivery**: base + frame + glow (3 PNGs).
**Full delivery**: all rows above as separate PNGs.

### button-set

| Layer | Separate? | Reason |
|-------|-----------|--------|
| Button background/base | Yes (per state) | State-specific appearance |
| Border / stroke | Optional | If border changes per state |
| Icon | Yes | Swappable, reusable |
| Label area | Empty | Engine renders text |
| Highlight / pressed shadow | Yes | Runtime state feedback |

**Minimum delivery**: button_base (per state) + icon (separate).
**Practical shortcut**: one sprite sheet with all states in a row, plus separate icon.

### decorative-overlay

Always delivered as individual transparent PNGs. Each overlay is one layer — they are composited at runtime.

### energy-effect

Layer separation follows background mode rules:

| VFX type | Background | Blend mode | Layer notes |
|----------|-----------|------------|-------------|
| trail, projectile, cast | Transparent | Alpha | Single PNG per effect |
| aura, ground area, impact glow, UI glow | Solid black | Additive/Screen | Single PNG, no alpha needed |
| Compound effect (e.g. cast + trail) | Split into parts | Mixed | One PNG per sub-effect |

**Never combine** multiple effect types into one image. A "fireball" = cast_charge.png + projectile.png + impact.png (3 files).

### background-plate

Delivered as a single opaque PNG. No layer separation needed (it IS the bottom layer).

Exception: if parallax is planned, split into:
- Far layer (sky / distant mountains)
- Mid layer (clouds / mist)
- Near layer (foreground elements)

### scan-overlay

Single transparent PNG. The scan subject IS the layer — it gets composited over the game scene at runtime.

If the scan has multiple phases (outline → fill → detail), generate each phase as a separate PNG.

### character-portrait

| Layer | Separate? | Reason |
|-------|-----------|--------|
| Character body (main) | Yes | The core deliverable |
| Held weapon / prop | Optional | If user needs to swap weapons |
| Aura / spiritual energy | Yes | Animated or toggled at runtime |
| Ground shadow | Yes | Repositioned per scene |

**Minimum delivery**: 1 transparent PNG (character body, energy kept tight to silhouette).
**Full delivery**: body + weapon + aura + shadow.

---

## Decision Shortcut

When unsure whether to separate a layer, ask:

> "Will this element ever be changed, moved, toggled, swapped, animated, or localized independently?"

If yes → separate layer.
If no → can stay baked.

---

## Prompt Language for Layer Separation

When generating assets that need separation, append to prompt:

```
isolated [element name], transparent background, clean edges, no other elements,
no text, no shadow (generate shadow separately if needed),
game production asset, single layer only
```

When generating a "family" of layers for one screen, generate each member as its own image call — never ask for "all layers in one image".
