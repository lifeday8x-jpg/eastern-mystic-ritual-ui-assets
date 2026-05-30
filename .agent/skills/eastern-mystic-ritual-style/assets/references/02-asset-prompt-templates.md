# Prompt Patterns

All templates use `[bracketed]` placeholders for user-specific content. Style constraints (materials, mood, avoid list) are fixed.

---

## Full Screen Concept

```text
[orientation, default: vertical 9:16] mobile game UI concept, [user's core interaction description],
eastern fantasy ritual style, [user's focal element/scene] [placement, default: centered on pale ritual platform],
[background, default: Shanhai ink mountains and cloud sea], calm immortal fantasy mood,
eastern fantasy material / motif language, fine gold talisman arcs and star chart lines,
[control zone, default: lower third reserved for large jade interaction buttons], readable game interface composition,
no text, avoid questionnaire cards, avoid red gold webgame style, avoid generic tarot, avoid character poster
```

Bracketed defaults apply when user does not specify. If ground/platform is omitted, ensure composition still reads as interactive UI (clear focal point + touch hierarchy), not pure illustration.

## Ritual Artifact (法器 / Isolated)

```text
isolated front-facing [user's artifact name],
[form, default: symmetrical ritual instrument],
[material, default: jade and aged brass],
[user's artifact-specific details],
[accent glow, default: pale teal inner glow],
[surface motif, default: fine talisman glyph engraving],
game asset, transparent background, centered, clean edges,
no text, no background scenery
```

Form reference:

| 类别 | 形态提示词 |
|------|-----------|
| 镜/盘 | circular disc, flat ritual mirror |
| 剑/刃 | elongated blade, vertical symmetry |
| 炉/鼎 | three-legged cauldron, squat vessel |
| 印/令牌 | compact square seal, hexagonal token |
| 扇 | arc-shaped folding fan, spread open |
| 壶/葫芦 | organic gourd silhouette, curved body |
| 幡/旗 | tall vertical banner, flowing ribbon |
| 珠/丹 | spherical glowing orb, luminous core |

## Result Card

```text
[user's result type] card frame for an eastern fantasy mobile game,
[panel material, default: celadon jade panel], [border, default: thin aged brass border], [surface pattern, default: subtle talisman pattern], empty title plaque,
[accent glow, default: soft teal spiritual glow], space for live text, elegant restrained ritual UI,
transparent background, no readable text, no tarot illustration, no red gold luxury
```

## Button Set

```text
set of [count, default: three] round [material, default: jade] ritual buttons, mobile game UI, idle active disabled states,
[rim material, default: aged brass rim], [icon style, default: simple talisman glyph icons], [active accent, default: teal glow] on active state,
transparent background, consistent lighting, clean atlas spacing, no text
```

## Background Plate

```text
[orientation, default: vertical] eastern fantasy background plate,
[atmosphere, default: Shanhai ink mist mountains and cloud sea],
quiet immortal mood, soft grayscale ink with celadon hints,
[composition: where to leave empty space for UI overlay, default: large empty central area, lower zone uncluttered],
no characters, no text, no strong foreground object competing with UI layer
```

Atmosphere reference:

| 氛围 | 视觉提示词 |
|------|-----------|
| 山海云雾 | Shanhai ink mist mountains, cloud sea, remote pavilions |
| 星空虚境 | deep void starfield, constellation dust, celestial dark |
| 竹林幽境 | ink bamboo grove, thin mist, stone path |
| 洞天福地 | cave interior glow, stalactites, luminous spirit spring |
| 纯色渐变 | simple gradient, no scene, clean tonal wash |

## Scan Overlay

```text
translucent [user's scan subject] for [user's reading/scan purpose],
front view, faint internal structure lines, glowing energy points,
teal-white light, ethereal glass hologram, game UI overlay asset,
transparent background, no face detail, no medical sci-fi style, no visible skeleton
```

## Energy Effect

Purpose: reusable immortal-cultivation game VFX assets for skills, combat feedback, UI activation, buffs, projectiles, trails, and area effects.

### Prompt template

```text
[element type] immortal cultivation game VFX asset,
[vfx type: cast / projectile / trail / impact / aura / buff / debuff / UI feedback / ground area],
[element-specific visual description],
refined spiritual qi, disciplined but organic flow,
jade-like glow, aged brass sparks, subtle talisman rhythm, ink-and-light texture,
[background mode, default: auto by VFX type],
VFX-only asset, no visible background pattern, no checkerboard, no preview canvas,
no character, no scenery, no UI, no text,
clean compositing edges, readable game effect shape,
avoid explosive chaos, avoid sci-fi electricity, avoid western magic circle, avoid heavy smoke, avoid red-gold webgame style
```

### VFX types

| 类型 | 用途 | 画面要求 |
|------|------|----------|
| cast | 施法起手、聚气 | 小到中型，向中心汇聚，适合放在手部/法器/脚下 |
| projectile | 飞行弹道 | 有明确方向，头部和拖尾清晰 |
| trail | 挥砍/移动轨迹 | 弧形、带速度感，边缘干净 |
| impact | 命中反馈 | 中心爆点、裂纹、涟漪或短促灵气震荡 |
| aura | 状态光环 | 不画角色，只画环绕层、轮廓光、脚底/背后气场 |
| buff | 增益/治疗/护盾 | 柔和、上升、包裹、脉冲 |
| debuff | 诅咒/禁锢/削弱 | 压制、缠绕、暗纹、符锁 |
| UI feedback | 按钮/图标/卡面反馈 | 边缘流光、小范围闪烁，不能遮挡信息 |
| ground area | 地面范围/结界 | 俯视或轻透视法阵、圈层、领域边界 |

### Background / compositing rules

The VFX body should be the only visible subject.

For hard-edge or silhouette-based effects:
use real alpha transparency if the generator/export pipeline supports it.

For glow/light-based effects:
use solid black background, additive-blend-ready or screen-blend-ready.

Never represent transparency visually.
Avoid checkerboard pattern, gray grid, alpha preview background, mockup canvas.

| VFX type | Default background | Intended blend mode |
|----------|--------------------|---------------------|
| trail | real transparent background | Alpha blend |
| projectile | real transparent background | Alpha blend |
| cast particles | real transparent background | Alpha blend |
| hard-edge buff/debuff marks | real transparent background | Alpha blend |
| ground area | solid black background | Additive / Screen |
| aura | solid black background | Additive / Screen |
| impact glow / ripple | solid black background | Additive / Screen |
| UI glow | solid black background | Additive / Screen |

User may override the background mode when a specific engine pipeline or export format is required.

### Asset purity constraints

- The image content must contain only the VFX itself.
- Do not draw transparency checkerboard patterns.
- Do not draw preview backgrounds, editor grids, mockup canvas, or alpha-mask visualization.
- Do not include character, scenery, UI panels, text labels, or placeholder shapes unless explicitly requested.
- Background handling must be either real alpha transparency or solid black for additive blending; it must not appear as a visible design element.

### Element visual guides

**thunder**:
gold-white spiritual lightning, jade fracture lines, thin branching qi cracks,
best for impact, trail, cast burst, projectile arc, UI activation sparks

**wood**:
emerald meridian qi, vine-like energy lines, soft sprouting particles,
best for healing buff, binding debuff, aura, growth pulse, UI border flow

**water**:
ink ripple qi, moonlit teal waves, liquid silk trails,
best for shield, projectile wave, ground ripple, cleansing buff, flowing trail

**fire**:
pale ritual flame, white-gold inner heat, incense-like flame tongues,
best for cast charge, aura flame, impact flare, UI ignition

**star**:
constellation dust, astral thread lines, tiny celestial glints,
best for fate mark, projectile trail, UI activation, buff orbit, summon cast

**shadow**:
ink veil, smoky brush stroke, dark teal spiritual mist,
best for debuff, concealment aura, curse impact, edge fade, ground corruption

### Avoid

```text
character illustration, full character pose, costume design, poster composition,
checkerboard transparency pattern, editor grid, mockup canvas, alpha preview visualization,
messy smoke, overfilled particles, generic magic circle, sci-fi HUD, red-gold webgame effect
```

## Example: Lingjian Game (filled templates)

Full screen:
```text
vertical 9:16 mobile game UI concept, Lingjian spirit diagnostic device reading spiritual fate,
eastern fantasy ritual style, central jade-and-brass scanning astrolabe on a pale ritual platform,
Shanhai ink mountains and cloud sea in the background, calm immortal fantasy mood,
jade and aged brass material language, fine gold talisman arcs and star chart lines,
lower third reserved for large jade interaction buttons, readable game interface composition,
no text, avoid questionnaire cards, avoid red gold webgame style, avoid generic tarot, avoid character poster
```

Ritual device:
```text
isolated front-facing Lingjian destiny-reading astrolabe, circular jade mirror and aged brass frame,
blackened metal support with scanning ring, pale teal inner glow, fine talisman glyph engraving,
symmetrical silhouette, game asset, transparent background, centered, clean edges,
no text, no background scenery
```

Scan overlay:
```text
translucent human silhouette for spiritual fate reading,
front standing pose, faint meridian lines, glowing energy points along spine and chest,
teal-white light, ethereal glass hologram, game UI overlay asset,
transparent background, no face detail, no clothing, no medical sci-fi style, no visible skeleton
```

---


---

## Character Portrait

角色立绘只约束画风、比例和边缘，角色内容由用户描述决定。

Style anchor (画风锚点，必须放 prompt 开头):
```
semi-realistic anime fantasy game character art, clean textured ink outlines, matte hand-painted style, soft painterly cel shading, watercolor-gouache texture, visible brush grain, crisp high-value contrast, medium-value muted celadon and dusty jade robes, soft gray-green main fabric, darker teal shadows only in folds and inner layers, pale mint highlights, antique warm gold trim, balanced midtone palette, not too dark, not pastel, desaturated but luminous, restrained teal glow, the robe's base color remains dark emerald green even in lit areas
```

Template structure:
```text
[style anchor], [character description + mood],
[clothing core feature], [1-2 key accessories],
[pose], [spiritual energy hint] close to body, [expression],
[gender], [age],
full body visible from head to feet, centered in frame, natural proportions,
transparent background, clean silhouette edges, no ground shadow, no floor
```

Negative (always include):
```text
bright pastel colors, glossy plastic, neon glow, 3D render, flat vector art,
background scenery, ground plane, floor reflection,
particles overlapping silhouette edge, fading edges, cropped limbs,
deformed hands, extra fingers, bad anatomy, distorted face,
chibi proportions, red gold webgame style
```

### Example: 正修 Male

```text
semi-realistic anime fantasy game character art, clean textured ink outlines, matte hand-painted style, soft painterly cel shading, watercolor-gouache texture, visible brush grain, crisp high-value contrast, medium-value muted celadon and dusty jade robes, soft gray-green main fabric, darker teal shadows only in folds and inner layers, pale mint highlights, antique warm gold trim, balanced midtone palette, not too dark, not pastel, desaturated but luminous, restrained teal glow, the robe's base color remains dark emerald green even in lit areas, righteous immortal cultivator, young adult male, serene and noble, flowing xianxia robes with thin antique gold trim, jade waist pendant, talisman glyphs on fabric, natural standing pose, calm mysterious expression, male, young adult, full body visible from head to feet, centered in frame, natural proportions, transparent background, clean silhouette edges, no ground shadow, no floor
```
