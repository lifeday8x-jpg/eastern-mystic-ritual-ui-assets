# Mobile Game Adaptation

## Concept vs Game Screen

Concept art can be dense and atmospheric. A mobile game screen must be tappable, readable, and decomposable into reusable layers.

Before accepting an image, check:

- Is the core object readable at phone size?
- Does the lower UI zone have enough empty room?
- Can buttons be separated from the background?
- Are glyphs decorative rather than required text?
- Can the background, device, buttons, glow, and result card become layers?
- Does the screen communicate "ritual instrument" within one second?

## Recommended Canvases

- Full vertical screen: `1080x1920`, `1242x2208`, or generation-friendly `1024x1792`.
- Square UI elements: `1024x1024` or `2048x2048`.
- Buttons/icons: `512x512`, transparent PNG.
- Wide background plates: generate wider than needed if parallax is planned.

## Layer Split

For implementation, split into:

- Background (ink mountains / environment).
- Ritual platform/stage.
- Central device body.
- Device lens/mirror/aperture.
- Inner scan overlay.
- Rotating ring/ornament overlays.
- Button/card base.
- Icons/glyphs.
- Glow and particle effects.
- Result card frame.

## Phone Usability Rules

- Keep primary interaction targets visually larger than 80 px in a 1080-wide mockup.
- Avoid thin essential details below 2 px.
- Reserve safe margins near top and bottom.
- Do not bake final text into generated images; render text in the game engine.
- Prefer plain ornamental panels where live text will be placed.

## Regeneration Advice

If output feels too much like concept art:

- Regenerate the background without foreground UI.
- Regenerate the device as an isolated asset.
- Regenerate buttons/cards as separate transparent PNG assets.
- Recompose in the game engine or design tool.

If output feels too much like a generic app:

- Increase apparatus dominance.
- Add ritual rings, scanning overlays, and platform depth.
- Remove ordinary card stacks, checkboxes, generic form UI, and chat-like panels.
