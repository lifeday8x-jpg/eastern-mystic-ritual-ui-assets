---
name: eastern-mystic-ritual-style
description: 东方玄幻仪式风格美术系统，含可选的批量生产流水线模式。定义配色（青玉、墨灰、古铜）、材质语言、构图规则与负面约束。两种模式——单资产（默认）或全流水线（用户请求时）用于批量一致性交付。
---

# 东方玄幻仪式风格 — 美术系统

## 定位

本 Skill 是一个**视觉风格系统**，附带可选的**批量生产流水线模式**。

- **默认模式**：用户每次请求一个素材，Skill 应用风格约束后生成。
- **流水线模式**（用户请求"全套"/"批量"/"完整资产包"时）：Skill 充当美术总监——建立风格圣经、规划素材清单、分批生成、校验一致性、按命名和图层规范交付。

---

## 模式判断

| 用户说 | 模式 |
|--------|------|
| "帮我生成一张结算卡" | 单资产（默认） |
| "生成一个按钮" | 单资产 |
| "我要全套 UI 素材" / "batch generate" / "给我完整资产包" | 流水线 |
| "先确认风格方向，再出图" | 流水线 |
| "帮我做一套风格统一的素材" | 流水线 |

---

## 单资产模式（默认）

1. 从用户请求中识别素材类型。
2. 阅读 `references/01-style-bible.md` —— 作为共享风格锚点。
3. 阅读 `references/04-asset-types.md` —— 找到匹配模块，区分用户定义 vs Skill 提供。
4. 阅读 `references/02-asset-prompt-templates.md` —— 选择并填充 prompt 模板。
5. 阅读 `references/03-layer-specs.md` —— 确定该素材类型的默认图层分离方式。
6. 生成图片。
7. 简要自检：是否符合风格圣经？有无烧入文字？边缘是否干净？

---

## 流水线模式（用户请求时）

完整美术总监工作流，严格按顺序执行：

### 第 1 步：确定范围

询问用户（或从上下文推断）：
- 产品类型、目标受众、平台
- 屏幕方向和宽高比
- 需要哪些素材类型（参见下方"素材族"）
- 是否有风格覆盖（在东方玄幻范围内调整材质、配色、氛围）

### 第 2 步：锁定风格圣经

阅读 `references/01-style-bible.md`，向用户确认或输出摘要以获得批准。
此后它成为每条 prompt 前置的**共享锚点**。未完成此步骤前不生成任何图片。

### 第 3 步：规划素材清单

阅读 `references/04-asset-types.md` 和 `references/06-delivery-naming.md`。
输出完整素材列表及计划文件名，用户批准或调整。

### 第 4 步：分批生成

阅读 `references/02-asset-prompt-templates.md`。
按类别逐批生成素材，每条 prompt 前置风格锚点。
每个素材生成前阅读 `references/03-layer-specs.md` 确定需要分层生成的内容。

### 第 5 步：一致性检查

阅读 `references/05-consistency-checklist.md`。
对所有生成素材进行自检，标记不达标的素材。

### 第 6 步：交付

输出：
- 文件列表（含文件名和用途说明）
- 需要重新生成的素材（附修订后的 prompt）
- 每个素材的图层分离状态

---

## 素材族

| ID | 用途 | 备注 |
|----|------|------|
| `main-screen` | 完整交互概念图 | 用户定义核心装置 |
| `ritual-device` | 核心交互仪器 | 用户定义是什么 |
| `result-card` | 交互后结果展示卡 | 用户定义槽位 + 风格画框 |
| `button-set` | 可点击 UI 控件 | 用户定义类型 + 必须覆盖所有状态 |
| `decorative-overlay` | 装饰环、刻度盘、叠加层 | 风格装饰图层 |
| `energy-effect` | 元素特效素材 | 雷/木/水/火/星/暗 |
| `background-plate` | 水墨山海背景板 | 有纵深 + 预留 UI 区域 |
| `scan-overlay` | 半透明扫描/感应覆盖层 | 扫描任意对象时使用 |
| `character-portrait` | 角色立绘 | 风格约束下，用户定义角色 |

---

## 风格锚点（始终前置到 prompt，保持英文）

```
eastern fantasy ritual style, jade and aged brass material language,
luminous talisman glyphs, Shanhai ink atmosphere, calm mysterious immortal mood,
celadon jade and muted teal glow palette, fine gold ornamental lines,
avoid red gold webgame style, avoid generic tarot, avoid questionnaire card,
avoid character-poster composition, avoid sci-fi medical, no baked text
```

用户的概念描述和素材专属构图指令插入到锚点之前。

---

## 参考文档阅读顺序

| 参考文档 | 何时阅读 |
|----------|----------|
| `01-style-bible.md` | 始终（风格锚点来源） |
| `02-asset-prompt-templates.md` | 构建 prompt 时 |
| `03-layer-specs.md` | 生成任何素材时（决定分层方式） |
| `04-asset-types.md` | 区分用户定义 vs Skill 提供时 |
| `05-consistency-checklist.md` | 生成后自检（流水线）或抽检（单资产） |
| `06-delivery-naming.md` | 流水线模式，或用户要求整理输出时 |
| `07-character-portrait.md` | 生成角色时 |
| `08-mobile-adaptation.md` | 适配手机屏幕时 |
