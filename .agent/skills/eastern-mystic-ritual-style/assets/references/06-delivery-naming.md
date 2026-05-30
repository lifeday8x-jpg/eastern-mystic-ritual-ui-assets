# 06 — Delivery Naming & Package Spec

> This reference defines file naming conventions and delivery structure for both modes.

---

## Naming Convention

### Pattern

```
{category}_{subject}_{variant}_{state}.png
```

| Segment | Required | Description | Examples |
|---------|----------|-------------|----------|
| `category` | ✅ | Asset family ID | `btn`, `card`, `bg`, `fx`, `overlay`, `device`, `portrait` |
| `subject` | ✅ | What this specific asset is | `primary`, `settlement`, `inkMountain`, `thunder`, `scan` |
| `variant` | ◻️ optional | Sub-variation or tier | `gold`, `silver`, `dark`, `wide` |
| `state` | ◻️ optional | Interactive state | `default`, `pressed`, `disabled`, `selected`, `hover` |

### Category Prefix Table

| Asset Family | Prefix | Example filename |
|-------------|--------|-----------------|
| button-set | `btn_` | `btn_primary_default.png` |
| result-card | `card_` | `card_settlement_victory.png` |
| background-plate | `bg_` | `bg_inkMountain_dawn.png` |
| energy-effect | `fx_` | `fx_thunder_burst.png` |
| decorative-overlay | `overlay_` | `overlay_brassRing_outer.png` |
| ritual-device | `device_` | `device_compass_base.png` |
| scan-overlay | `scan_` | `scan_palm_translucent.png` |
| character-portrait | `portrait_` | `portrait_priestess_idle.png` |
| main-screen | `screen_` | `screen_main_concept.png` |

### Naming Rules

1. **camelCase** for multi-word segments: `inkMountain`, `brassRing`, `energyBurst`
2. **No spaces, no Chinese characters** in filenames
3. **Layers** append `_layer{N}` or a semantic suffix:
   - `btn_primary_default_base.png` (opaque base plate)
   - `btn_primary_default_glow.png` (additive glow layer)
   - `btn_primary_default_icon.png` (icon cutout, transparent)
4. **Numbered variants** use zero-padded index: `fx_thunder_burst_01.png`, `fx_thunder_burst_02.png`
5. **State names** are fixed vocabulary:
   - `default` / `pressed` / `disabled` / `selected` / `hover` / `active`
   - Do not invent new state names without documenting them

---

## Delivery Package (Pipeline Mode)

When pipeline mode completes, the full deliverable set includes:

### Required Outputs

| # | Item | Format | Description |
|---|------|--------|-------------|
| 1 | **Style Bible Summary** | text in chat | Confirmed palette, materials, motifs, avoid-list |
| 2 | **Asset List** | text/table in chat | Every planned file, organized by category |
| 3 | **Generated Images** | `.png` files | All assets, named per convention above |
| 4 | **Layer Notes** | text per asset | Which layers were generated, blend mode notes |
| 5 | **Consistency Report** | text in chat | Checklist pass/fail summary, flagged items |

### Optional Outputs (if user requests)

| Item | When |
|------|------|
| Regeneration prompts | When flagged assets need redo |
| Negative prompt bank | When user wants to reuse constraints externally |
| Batch prompt list | When user wants raw prompts for external tools |
| Canvas size reference | When user needs exact dimensions per asset |

---

## Directory Structure (Recommended)

When generating a full batch, organize files as:

```
assets/image/{project_context}/
├── btn/
│   ├── btn_primary_default.png
│   ├── btn_primary_pressed.png
│   ├── btn_secondary_default.png
│   └── ...
├── card/
│   ├── card_settlement_victory.png
│   └── card_settlement_defeat.png
├── bg/
│   └── bg_inkMountain_dawn.png
├── fx/
│   ├── fx_thunder_burst_01.png
│   └── fx_water_ripple.png
├── overlay/
│   └── overlay_brassRing_outer.png
├── portrait/
│   └── portrait_priestess_idle.png
└── device/
    ├── device_compass_base.png
    └── device_compass_glow.png
```

> For single-asset mode, files go directly to `assets/image/` without subdirectories.

---

## Single-Asset Mode Naming

Even in single-asset mode, follow the naming pattern:

- Use the full `{category}_{subject}_{variant}_{state}.png` pattern
- The `name` parameter in `generate_image` should match: e.g., `btn_primary_default`
- This ensures consistency if user later transitions to pipeline mode

---

## Versioning

If regenerating an asset:
- Do NOT overwrite — timestamps in filename handle this automatically (tool appends `_YYYYMMDDHHMMSS`)
- In delivery notes, reference the latest timestamp as the "final" version
- Flag superseded versions explicitly so user knows which to discard
