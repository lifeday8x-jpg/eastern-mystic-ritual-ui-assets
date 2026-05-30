# Asset Types

> **Governing principle**: User controls structure, density, semantics, and layout.
> Skill controls style language, state completeness, readability, and asset cleanliness.

## main-screen

Purpose: first playable screen or key interaction concept.

### Layout zones (recommended defaults — user may override any)

| Zone | Default | Override notes |
|------|---------|---------------|
| Focal area (upper-center) | User's core interactive element | Position and scale adjustable |
| Control zone | Bottom 1/3, button/card placeholders | May move to top, sides, or full-screen interaction |
| Atmosphere layer (background) | Shanhai ink mountains & cloud sea | User may specify other scene moods |
| Ground/platform | Pale ritual stone platform | May omit — but if omitted, composition must still convey clear interaction focus and touch-layer hierarchy (avoid drifting into pure illustration) |

### Fixed constraints (non-negotiable)
- Mobile game screen composition — default 9:16 vertical; user may specify 16:9 horizontal or other ratios
- Eastern fantasy ritual aesthetic — material / motif language (not necessarily literal jade/brass/talisman everywhere, but the mood and craft sensibility must read as ritual)
- Preserve clear interactive zones (not blocked by decoration)
- No baked text
- Avoid: red-gold webgame excess, generic tarot, questionnaire cards, character poster composition

### Good prompt additions
- `[orientation, default: 9:16 vertical] mobile game UI concept`
- `readable touch zones`
- `layered interface, no text`
- `[user's layout preference]` (e.g. "full-screen interaction", "top control bar", "side panel")

## ritual-device

Purpose: reusable central interactive apparatus.

The user defines what this device is (scanner, divination table, alchemy furnace, star-reading instrument, contract altar, etc.). The style system provides the visual envelope.

Production constraints:
- Isolated object on transparent background.
- Generate front-facing and slightly top-down variants separately.
- Keep silhouette simple enough to mask.
- Material: follow style-profile material palette (default: jade, aged brass, teal glow, talisman motifs — but user may request variants within the eastern fantasy register).

## result-card

Purpose: post-interaction result display.

User defines:
- Information slots needed (title area, subtitle area, body text area,
  grade/rank badge, stats rows, imagery — any combination)
- Card hierarchy (single card, stacked cards, expandable)
- Content density (minimal zen vs. information-rich)

Skill provides:
- Frame material & border treatment (style-profile palette; default: celadon jade panel)
- Glow / accent layer for emphasis slots
- Translucent overlay option for depth
- Spacing rhythm and text-area proportion (mobile-readable)

Constraints:
- No baked text; use empty text areas / placeholder regions only
- Avoid horoscope/tarot card look unless explicitly requested
- Frame material follows style-profile defaults; user may override (e.g. darker stone, parchment, ink wash)

## button-set

Purpose: tappable UI controls.

User defines:
- Button types needed (primary CTA, secondary, ghost/text,
  icon-only, destructive — any subset)
- Layout pattern (single centered, dual side-by-side,
  vertical stack, floating FAB)
- Icon concepts (if any)

Skill provides:
- Material tone per semantic level (primary = jade glow,
  secondary = stone, ghost = transparent rim)
- Motif integration (style-profile default: flower knot, seal mark,
  elemental glyph — or user's custom icon)

State coverage is non-negotiable:
- Idle
- Active / Selected
- Disabled
- Pressed

Constraints:
- No baked text; use empty label areas or simple icon-only marks
- Icon style: simple, symbolic, readable at phone size
- Recommended canvas: horizontal strip (21:9 or 4:3) for multi-state sheets; 1:1 for single button

## decorative-overlay

Purpose: ornamental UI layers — rings, dials, loading/scanning animations, ambient decoration.

Examples (user picks what fits their game):
- Ring segments / rotating halos.
- Compass ticks / selection dials.
- Star node networks / constellation lines.
- Talisman glyph circles / seal patterns.
- Any repeating motif from style-profile.

Production constraints:
- Transparent background, centered square canvas.
- Keep as separate layers (compositable in-engine).
- Avoid overwhelming interactive elements beneath.

## energy-effect

Purpose: VFX source material.

Types:
- **thunder**: thin gold-white cracks, disciplined, not explosive.
- **wood**: green meridian vines, soft growth lines.
- **water**: ink ripple, moonlit waves, teal shimmer.
- **fire**: pale ritual flame, not orange inferno.
- **star**: star dust, constellation glints.
- **shadow**: ink veil, smoky brush stroke.

All effects should feel controlled and ritual, never chaotic or violent.

## background-plate

Purpose: reusable background/atmosphere layer.

Constraints:
- Keep separate from foreground UI (no strong focal objects in control zones).
- Leave primary interaction area uncluttered.
- Orientation follows main-screen setting (vertical or horizontal).
- Default mood: Shanhai ink mountains, cloud sea, mist — user may specify other eastern fantasy environments (night sky, ancient library, spirit realm, underwater palace, etc.).

## scan-overlay

Purpose: translucent scanning/reading layer.

The user defines what is being scanned (human body, artifact, creature, plant, terrain, etc.). The style system provides:

Requirements:
- Translucent, ethereal, glass-hologram quality.
- Visible internal structure (lines, nodes, energy points).
- Teal-white light on dark or transparent background.
- No medical/sci-fi look, no visible skeleton.
- Works as game overlay asset.

## character-portrait

Purpose: game-ready character standing art (立绘).

Production constraints:
- MUST use transparent background with clean silhouette edges.
- Full body visible head to feet, centered in frame.
- Spiritual energy must stay close to body (protect cutout edges).
- No environment elements, no ground shadow, no fog at edges.
- Refer to `references/character-portrait.md` for full prompt templates, anatomy negative lists, and cutout stability rules.
