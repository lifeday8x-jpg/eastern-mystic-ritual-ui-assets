-- ============================================================================
-- 《一念测根骨》- 第三版：两层计分系统
-- 竖屏手游 | 东方玄幻 + 现代测试仪式感
-- 状态机: MainMenu → PrepareTest → LingjianAwake → QuestionFlow
--         → Calculating → SimpleResult
-- ============================================================================

local UI = require("urhox-libs/UI")

-- ============================================================================
-- 1. 数据定义
-- ============================================================================

-- 8 个修行倾向维度
local TRAIT_NAMES = {
    resolve   = "决断",
    patience  = "积累",
    insight   = "洞察",
    adapt     = "变化",
    ambition  = "进取",
    harmony   = "亲和",
    order     = "秩序",
    instinct  = "直觉",
}

-- 根骨类型定义
local BONE_TYPES = {
    thunder = {
        name = "天雷剑骨",
        color = { 160, 210, 240, 255 },
        colorDim = { 100, 150, 200, 180 },
        desc = "你心有锋芒，遇阻不绕，一念即决，似雷霆落剑。",
        fortune = "剑心通明，万法不侵",
    },
    wood = {
        name = "青木灵骨",
        color = { 100, 200, 130, 255 },
        colorDim = { 70, 160, 100, 180 },
        desc = "你根气绵长，善于积累，如古木深扎，百年方成参天。",
        fortune = "厚积薄发，润物无声",
    },
    water = {
        name = "玄水慧骨",
        color = { 80, 140, 220, 255 },
        colorDim = { 60, 110, 180, 180 },
        desc = "你心思流转，能见微知著，如水无形却入万隙。",
        fortune = "随机应变，洞若观火",
    },
    fire = {
        name = "赤炎战骨",
        color = { 230, 120, 80, 255 },
        colorDim = { 180, 90, 60, 180 },
        desc = "你气血炽盛，敢争敢战，如烈焰焚尽一切犹豫。",
        fortune = "勇猛精进，势不可挡",
    },
    star = {
        name = "星衍道骨",
        color = { 160, 130, 220, 255 },
        colorDim = { 120, 100, 180, 180 },
        desc = "你善观因果，喜布长局，如星辰运转自有定数。",
        fortune = "洞悉天机，万象归序",
    },
    none = {
        name = "无相凡骨",
        color = { 200, 200, 190, 255 },
        colorDim = { 160, 160, 150, 180 },
        desc = "你不显锋芒，却能容纳万法，无形亦无限。",
        fortune = "大道无形，万法皆通",
    },
}

-- 选择后的倾向词映射（根据本次最高 trait 显示）
local TRAIT_HINTS = {
    resolve  = { "此念有锋", "心意已决" },
    patience = { "灵息入鉴", "根气绵长" },
    insight  = { "此念藏机", "明察秋毫" },
    adapt    = { "心念流转", "随机而动" },
    ambition = { "此念灼然", "锐意难藏" },
    harmony  = { "此念归元", "温润如玉" },
    order    = { "心念已录", "条理分明" },
    instinct = { "灵觉一闪", "直觉先行" },
}

-- 7 道情境式题目（traits 计分）
local QUESTIONS = {
    {
        question = "山门试炼只允许带一样东西，你会带什么？",
        options = {
            { text = "一盏能照出岔路的旧灯", traits = { insight = 2, order = 1 } },
            { text = "一瓶缓慢回息的药露", traits = { patience = 2, harmony = 1 } },
            { text = "一枚会在危险前发烫的玉扣", traits = { instinct = 2, adapt = 1 } },
        },
    },
    {
        question = "你在闭关时听见门外有人求救，会怎么做？",
        options = {
            { text = "立刻出关，先救人再说", traits = { resolve = 1, harmony = 2, instinct = 1 } },
            { text = "判断真假与距离，再决定是否出手", traits = { insight = 2, order = 1 } },
            { text = "留下防护法诀，继续完成关键周天", traits = { patience = 2, order = 1, ambition = 1 } },
        },
    },
    {
        question = "你得到一本残缺功法，最后三页被烧毁了。",
        options = {
            { text = "先按现有内容修到极致", traits = { patience = 2, resolve = 1 } },
            { text = "对照其他功法，推演缺失部分", traits = { insight = 2, order = 2 } },
            { text = "只取其中一式，改成自己的路数", traits = { adapt = 2, ambition = 1, instinct = 1 } },
        },
    },
    {
        question = "同门约你去争一处灵泉，但消息真假难辨。",
        options = {
            { text = "先派人查证，再决定是否同行", traits = { insight = 2, order = 1 } },
            { text = "机会稍纵即逝，先到再说", traits = { ambition = 2, resolve = 1, instinct = 1 } },
            { text = "不争泉眼，去看附近是否有被忽略的小脉", traits = { adapt = 2, patience = 1, insight = 1 } },
        },
    },
    {
        question = "你的灵力第一次失控，震裂了静室。",
        options = {
            { text = "压住波动，连续七日重新打磨根基", traits = { patience = 2, order = 1 } },
            { text = "顺着失控的方向，尝试开出新术", traits = { adapt = 2, instinct = 1, ambition = 1 } },
            { text = "立刻找师长复盘原因", traits = { insight = 1, harmony = 2, order = 1 } },
        },
    },
    {
        question = "秘境中只剩最后一炷香，你看见三条路。",
        options = {
            { text = "最险的一条，有强烈灵压", traits = { ambition = 2, resolve = 1, instinct = 1 } },
            { text = "最安静的一条，灵气稳定", traits = { patience = 1, insight = 1, order = 1 } },
            { text = "最不像路的一条，有微弱风声", traits = { adapt = 2, instinct = 1, insight = 1 } },
        },
    },
    {
        question = "若有一日你必须自创一门术法，它最像什么？",
        options = {
            { text = "一道能在关键时刻改写局面的变招", traits = { adapt = 2, insight = 1, ambition = 1 } },
            { text = "一套越练越深、可传后人的根法", traits = { patience = 2, harmony = 1, order = 1 } },
            { text = "一击定胜负的破局之术", traits = { resolve = 2, ambition = 1, instinct = 1 } },
        },
    },
}

-- ============================================================================
-- 2. 全局状态
-- ============================================================================

---@type string
local gameState_ = "MainMenu"
local stateTime_ = 0
local totalTime_ = 0

-- 灵鉴动画参数
local breathScale_ = 1.0
local glowAlpha_ = 0
local ringRotation_ = 0
local awakeProgress_ = 0

-- 灵鉴颜色偏移（答题时微妙变化，不直接暴露根骨）
local lingjianColorR_ = 120
local lingjianColorG_ = 180
local lingjianColorB_ = 160
local lingjianTargetR_ = 120
local lingjianTargetG_ = 180
local lingjianTargetB_ = 160

-- 反馈动画
local feedbackTimer_ = 0
local feedbackActive_ = false
local feedbackScale_ = 0

-- 答题状态
local currentQuestion_ = 1
local questionFadeIn_ = 0
local optionLocked_ = false

-- 玩家本局累计维度分
local traits_ = {
    resolve = 0, patience = 0, insight = 0, adapt = 0,
    ambition = 0, harmony = 0, order = 0, instinct = 0,
}

-- 推演状态
local calcProgress_ = 0

-- 结果
local resultBoneKey_ = "none"
local resultRarity_ = "common"       -- common / uncommon / rare / legendary
local resultRarityScore_ = 0

-- 逐行揭示控制
local revealStep_ = 0                -- 当前揭示阶段 0~6
local revealTimer_ = 0               -- 阶段内计时
local REVEAL_DELAYS = { 0.6, 0.8, 0.5, 0.6, 0.5, 0.4, 0.5 }  -- 每步延迟

-- UI 引用
local uiRoot_ = nil
local lingjianWidget_ = nil
local menuOverlay_ = nil
local titleLabel_ = nil
local promptLabel_ = nil
local mainBtn_ = nil
local subBtn_ = nil
local questionOverlay_ = nil
local progressLabel_ = nil
local questionLabel_ = nil
local optionBtns_ = {}
local hintLabel_ = nil       -- 倾向词显示
local calcOverlay_ = nil
local calcLabel_ = nil
local resultOverlay_ = nil
local resultNameLabel_ = nil
local resultRarityLabel_ = nil
local resultFortuneLabel_ = nil
local resultTraitsLabel_ = nil
local resultDescLabel_ = nil
local resultDivider_ = nil
local resultCard_ = nil
local resultRetryBtn_ = nil
local resultGuideBtn_ = nil

-- ============================================================================
-- 3. 两层计分逻辑
-- ============================================================================

local function ResetTraits()
    for k in pairs(traits_) do
        traits_[k] = 0
    end
end

local function AddTraits(traitTable)
    for key, val in pairs(traitTable) do
        if traits_[key] ~= nil then
            traits_[key] = traits_[key] + val
        end
    end
end

--- 获取前 N 个最高维度
local function GetTopTraits(count)
    local sorted = {}
    for k, v in pairs(traits_) do
        sorted[#sorted + 1] = { key = k, val = v }
    end
    table.sort(sorted, function(a, b) return a.val > b.val end)

    local result = {}
    for i = 1, math.min(count, #sorted) do
        result[i] = sorted[i]
    end
    return result
end

--- 第二层：根据维度组合推导根骨
local function CalculateRootBone()
    local t = traits_

    -- 计算各根骨匹配分
    local boneScores = {
        thunder = t.resolve * 1.4 + t.ambition * 1.1 + t.instinct * 0.6 - t.patience * 0.3,
        wood    = t.patience * 1.4 + t.harmony * 1.2 + t.order * 0.4,
        water   = t.insight * 1.2 + t.adapt * 1.3 + t.patience * 0.3,
        fire    = t.ambition * 1.3 + t.instinct * 1.2 + t.resolve * 0.8,
        star    = t.order * 1.4 + t.insight * 1.2 + t.patience * 0.5,
    }

    -- 计算无相凡骨：维度标准差越低越高
    local sum = 0
    local vals = {}
    for _, v in pairs(traits_) do
        sum = sum + v
        vals[#vals + 1] = v
    end
    local mean = sum / #vals
    local variance = 0
    for _, v in ipairs(vals) do
        variance = variance + (v - mean) * (v - mean)
    end
    local stddev = math.sqrt(variance / #vals)
    -- 无相分 = 均衡奖励，标准差越低分越高
    local balanceScore = math.max(0, (3.0 - stddev) * 2.5 + mean * 0.5)
    boneScores.none = balanceScore

    -- 找最高分
    local maxKey = "none"
    local maxVal = -999
    local secondVal = -999
    for key, val in pairs(boneScores) do
        if val > maxVal then
            secondVal = maxVal
            maxVal = val
            maxKey = key
        elseif val > secondVal then
            secondVal = val
        end
    end

    -- 如果最高分与第二名差距极小且不是无相，也给无相机会
    if maxKey ~= "none" and (maxVal - secondVal) < 0.8 then
        -- 差距极小时，比较无相分
        if boneScores.none >= maxVal * 0.85 then
            maxKey = "none"
        end
    end

    return maxKey
end

--- 计算稀有度（根据维度分布的极端程度）
local function CalculateRarity()
    -- 方法：看最高维度与平均的偏离程度 + 根骨匹配分的集中度
    local topTraits = GetTopTraits(3)
    local sum = 0
    local count = 0
    for _, v in pairs(traits_) do
        sum = sum + v
        count = count + 1
    end
    local mean = sum / count

    -- 极化指数：前三维度占总分的比例
    local topSum = 0
    for _, item in ipairs(topTraits) do
        topSum = topSum + item.val
    end
    local polarization = (sum > 0) and (topSum / sum) or 0.5

    -- 峰值突出度：最高维度超出平均的倍数
    local peakRatio = (mean > 0) and (topTraits[1].val / mean) or 1.0

    -- 综合稀有度分
    local rarityScore = polarization * 40 + peakRatio * 30 + (sum / 28) * 30
    -- sum/28 是总投入度归一化（7题×每题最多4分=28上限）

    resultRarityScore_ = rarityScore

    if rarityScore >= 82 then
        return "legendary"
    elseif rarityScore >= 68 then
        return "rare"
    elseif rarityScore >= 52 then
        return "uncommon"
    else
        return "common"
    end
end

--- 稀有度显示信息
local RARITY_INFO = {
    common    = { label = "凡品", color = { 160, 165, 155, 200 } },
    uncommon  = { label = "良品", color = { 120, 200, 160, 220 } },
    rare      = { label = "上品", color = { 130, 160, 220, 240 } },
    legendary = { label = "极品", color = { 220, 180, 80, 255 } },
}

--- 获取选项中最高的单个 trait（用于倾向词反馈）
local function GetDominantTrait(traitTable)
    local maxKey = "resolve"
    local maxVal = 0
    for key, val in pairs(traitTable) do
        if val > maxVal then
            maxVal = val
            maxKey = key
        end
    end
    return maxKey
end

-- ============================================================================
-- 4. 灵鉴装置自定义控件
-- ============================================================================
local LingjianWidget = UI.Widget:Extend("LingjianWidget")

function LingjianWidget:Init(props)
    props = props or {}
    props.width = props.width or "100%"
    props.height = props.height or "100%"
    props.pointerEvents = "none"
    UI.Widget.Init(self, props)
end

function LingjianWidget:Update(dt)
    totalTime_ = totalTime_ + dt
    stateTime_ = stateTime_ + dt

    -- 呼吸动画
    local breathSpeed, breathAmp
    if gameState_ == "PrepareTest" then
        breathSpeed, breathAmp = 1.5, 0.03
    elseif gameState_ == "QuestionFlow" then
        breathSpeed, breathAmp = 1.0, 0.02
    elseif gameState_ == "Calculating" then
        breathSpeed, breathAmp = 2.0, 0.025
    else
        breathSpeed, breathAmp = 0.8, 0.015
    end
    breathScale_ = 1.0 + math.sin(totalTime_ * breathSpeed) * breathAmp

    -- 圆环旋转速度
    local rotSpeed = 8
    if gameState_ == "LingjianAwake" then rotSpeed = 60
    elseif gameState_ == "Calculating" then rotSpeed = 30
    elseif gameState_ == "QuestionFlow" and feedbackActive_ then rotSpeed = 40
    end
    ringRotation_ = ringRotation_ + dt * rotSpeed

    -- 醒来动画
    if gameState_ == "LingjianAwake" then
        awakeProgress_ = math.min(1.0, awakeProgress_ + dt * 1.2)
        glowAlpha_ = awakeProgress_
    elseif gameState_ == "PrepareTest" then
        glowAlpha_ = 0.2 + math.sin(totalTime_ * 2) * 0.1
    elseif gameState_ == "QuestionFlow" then
        glowAlpha_ = 0.3 + feedbackScale_ * 0.5
    elseif gameState_ == "Calculating" then
        glowAlpha_ = 0.4 + math.sin(totalTime_ * 3) * 0.2
    elseif gameState_ == "SimpleResult" then
        glowAlpha_ = 0.6 + math.sin(totalTime_ * 1.5) * 0.1
    else
        glowAlpha_ = 0.1
    end

    -- 反馈动画衰减
    if feedbackActive_ then
        feedbackTimer_ = feedbackTimer_ - dt
        feedbackScale_ = math.max(0, feedbackTimer_ / 0.4)
        if feedbackTimer_ <= 0 then
            feedbackActive_ = false
            feedbackScale_ = 0
        end
    end

    -- 灵鉴颜色平滑过渡
    local lerpSpeed = dt * 3
    lingjianColorR_ = lingjianColorR_ + (lingjianTargetR_ - lingjianColorR_) * lerpSpeed
    lingjianColorG_ = lingjianColorG_ + (lingjianTargetG_ - lingjianColorG_) * lerpSpeed
    lingjianColorB_ = lingjianColorB_ + (lingjianTargetB_ - lingjianColorB_) * lerpSpeed
end

function LingjianWidget:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local cx = l.x + l.w * 0.5

    local cyRatio = 0.42
    if gameState_ == "QuestionFlow" then cyRatio = 0.26
    elseif gameState_ == "Calculating" then cyRatio = 0.38
    elseif gameState_ == "SimpleResult" then cyRatio = 0.28
    end
    local cy = l.y + l.h * cyRatio

    self:DrawBackground(nvg, l)
    self:DrawMountains(nvg, l)
    self:DrawClouds(nvg, l)
    self:DrawLingjian(nvg, cx, cy, l)
end

function LingjianWidget:DrawBackground(nvg, l)
    nvgBeginPath(nvg)
    nvgRect(nvg, l.x, l.y, l.w, l.h)
    local bg = nvgLinearGradient(nvg, l.x, l.y, l.x, l.y + l.h,
        nvgRGBA(35, 40, 50, 255),
        nvgRGBA(15, 18, 22, 255))
    nvgFillPaint(nvg, bg)
    nvgFill(nvg)
end

function LingjianWidget:DrawMountains(nvg, l)
    local w, h = l.w, l.h
    local baseY = l.y + h * 0.65

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, l.x, baseY + 40)
    nvgBezierTo(nvg, l.x + w * 0.15, baseY - 60, l.x + w * 0.3, baseY - 80, l.x + w * 0.45, baseY - 30)
    nvgBezierTo(nvg, l.x + w * 0.6, baseY + 10, l.x + w * 0.75, baseY - 50, l.x + w, baseY + 20)
    nvgLineTo(nvg, l.x + w, l.y + h)
    nvgLineTo(nvg, l.x, l.y + h)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(22, 28, 36, 100))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, l.x, baseY + 60)
    nvgBezierTo(nvg, l.x + w * 0.2, baseY - 20, l.x + w * 0.4, baseY + 30, l.x + w * 0.55, baseY - 10)
    nvgBezierTo(nvg, l.x + w * 0.7, baseY - 40, l.x + w * 0.85, baseY + 10, l.x + w, baseY + 50)
    nvgLineTo(nvg, l.x + w, l.y + h)
    nvgLineTo(nvg, l.x, l.y + h)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(30, 38, 48, 140))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, l.x, baseY + 100)
    nvgBezierTo(nvg, l.x + w * 0.25, baseY + 40, l.x + w * 0.5, baseY + 80, l.x + w * 0.7, baseY + 50)
    nvgBezierTo(nvg, l.x + w * 0.85, baseY + 30, l.x + w * 0.95, baseY + 70, l.x + w, baseY + 90)
    nvgLineTo(nvg, l.x + w, l.y + h)
    nvgLineTo(nvg, l.x, l.y + h)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(40, 50, 60, 180))
    nvgFill(nvg)
end

function LingjianWidget:DrawClouds(nvg, l)
    local w, h = l.w, l.h
    for i = 1, 4 do
        local drift = math.sin(totalTime_ * 0.3 + i * 1.5) * w * 0.05
        local cloudY = l.y + h * (0.3 + i * 0.1)
        local cloudW = w * (0.4 + i * 0.1)
        local cloudH = 30 + i * 10
        local cloudX = l.x + w * 0.5 - cloudW * 0.5 + drift

        nvgBeginPath(nvg)
        nvgRect(nvg, cloudX, cloudY, cloudW, cloudH)
        local cg = nvgLinearGradient(nvg, cloudX, cloudY, cloudX + cloudW, cloudY,
            nvgRGBA(180, 190, 200, 0), nvgRGBA(180, 190, 200, 20 - i * 3))
        nvgFillPaint(nvg, cg)
        nvgFill(nvg)
    end
end

function LingjianWidget:DrawLingjian(nvg, cx, cy, l)
    local baseRadius = math.min(l.w, l.h) * 0.18
    if gameState_ == "QuestionFlow" then baseRadius = math.min(l.w, l.h) * 0.13 end
    if gameState_ == "SimpleResult" then baseRadius = math.min(l.w, l.h) * 0.12 end

    local radius = baseRadius * (breathScale_ + feedbackScale_ * 0.08)
    local r = math.floor(lingjianColorR_)
    local g = math.floor(lingjianColorG_)
    local b = math.floor(lingjianColorB_)

    nvgSave(nvg)
    nvgTranslate(nvg, cx, cy)

    -- 外圈光晕
    local haloAlpha = math.floor(30 + glowAlpha_ * 50)
    nvgBeginPath(nvg)
    nvgCircle(nvg, 0, 0, radius * 1.4)
    local haloGrad = nvgRadialGradient(nvg, 0, 0, radius * 0.8, radius * 1.4,
        nvgRGBA(r, g, b, haloAlpha), nvgRGBA(r, g, b, 0))
    nvgFillPaint(nvg, haloGrad)
    nvgFill(nvg)

    -- 主体玉环
    nvgBeginPath(nvg)
    nvgCircle(nvg, 0, 0, radius)
    nvgStrokeWidth(nvg, 3.5)
    nvgStrokeColor(nvg, nvgRGBA(r, g, b, 200))
    nvgStroke(nvg)

    -- 内圈
    nvgBeginPath(nvg)
    nvgCircle(nvg, 0, 0, radius * 0.75)
    nvgStrokeWidth(nvg, 1.5)
    nvgStrokeColor(nvg, nvgRGBA(r, g, b, 120))
    nvgStroke(nvg)

    -- 金色刻线
    local numLines = 12
    for i = 1, numLines do
        local angle = math.rad((i - 1) * (360 / numLines) + ringRotation_)
        local innerR = radius * 0.78
        local outerR = radius * 0.97
        local x1 = math.cos(angle) * innerR
        local y1 = math.sin(angle) * innerR
        local x2 = math.cos(angle) * outerR
        local y2 = math.sin(angle) * outerR

        nvgBeginPath(nvg)
        nvgMoveTo(nvg, x1, y1)
        nvgLineTo(nvg, x2, y2)
        nvgStrokeWidth(nvg, 1.5)
        local lineAlpha = 120 + math.floor(60 * math.sin(totalTime_ * 2 + i))
        nvgStrokeColor(nvg, nvgRGBA(200, 170, 90, lineAlpha))
        nvgStroke(nvg)
    end

    -- 四方位标记
    for i = 0, 3 do
        local angle = math.rad(i * 90 + ringRotation_ * 0.3)
        local x1 = math.cos(angle) * radius * 1.02
        local y1 = math.sin(angle) * radius * 1.02
        local x2 = math.cos(angle) * radius * 1.12
        local y2 = math.sin(angle) * radius * 1.12

        nvgBeginPath(nvg)
        nvgMoveTo(nvg, x1, y1)
        nvgLineTo(nvg, x2, y2)
        nvgStrokeWidth(nvg, 3)
        nvgStrokeColor(nvg, nvgRGBA(r, g, b, 180))
        nvgStroke(nvg)
    end

    -- 中央成像区
    local coreAlpha = math.floor(40 + glowAlpha_ * 200)
    nvgBeginPath(nvg)
    nvgCircle(nvg, 0, 0, radius * 0.55)
    local coreGrad = nvgRadialGradient(nvg, 0, 0, 0, radius * 0.55,
        nvgRGBA(r + 60, g + 40, b + 40, coreAlpha),
        nvgRGBA(r, g, b, math.floor(coreAlpha * 0.3)))
    nvgFillPaint(nvg, coreGrad)
    nvgFill(nvg)

    -- 人形轮廓（仅主菜单/准备/醒来阶段）
    if gameState_ == "MainMenu" or gameState_ == "PrepareTest"
        or (gameState_ == "LingjianAwake" and awakeProgress_ < 0.8) then
        local silAlpha = math.floor(30 + glowAlpha_ * 50)
        self:DrawHumanSilhouette(nvg, 0, 0, radius * 0.35, silAlpha)
    end

    -- 灵鉴成像：结果阶段绘制根骨专属纹样
    if gameState_ == "SimpleResult" and revealStep_ >= 1 then
        local imgAlpha = math.min(1.0, (revealStep_ - 1) * 0.4 + revealTimer_ * 0.5)
        self:DrawBoneImprint(nvg, 0, 0, radius * 0.45, resultBoneKey_, imgAlpha)
    end

    -- 醒来光芒
    if gameState_ == "LingjianAwake" and awakeProgress_ > 0.2 then
        local ba = math.floor((awakeProgress_ - 0.2) * 255 * 0.8)
        nvgBeginPath(nvg)
        nvgCircle(nvg, 0, 0, radius * 0.3 * awakeProgress_)
        local bg2 = nvgRadialGradient(nvg, 0, 0, 0, radius * 0.3 * awakeProgress_,
            nvgRGBA(220, 245, 230, ba), nvgRGBA(r, g, b, 0))
        nvgFillPaint(nvg, bg2)
        nvgFill(nvg)
    end

    -- 反馈脉冲光环
    if feedbackActive_ then
        local pulseR = radius * (1.0 + feedbackScale_ * 0.3)
        local pulseAlpha = math.floor(feedbackScale_ * 150)
        nvgBeginPath(nvg)
        nvgCircle(nvg, 0, 0, pulseR)
        nvgStrokeWidth(nvg, 2)
        nvgStrokeColor(nvg, nvgRGBA(r, g, b, pulseAlpha))
        nvgStroke(nvg)
    end

    nvgRestore(nvg)
end

--- 绘制根骨专属纹样（灵鉴成像）
function LingjianWidget:DrawBoneImprint(nvg, cx, cy, scale, boneKey, alpha)
    local a = math.floor(alpha * 200)
    if a <= 0 then return end

    local bone = BONE_TYPES[boneKey]
    local r, g, b = bone.color[1], bone.color[2], bone.color[3]

    if boneKey == "thunder" then
        -- 闪电纹：锯齿形线条
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, cx - scale * 0.15, cy - scale * 0.7)
        nvgLineTo(nvg, cx + scale * 0.05, cy - scale * 0.2)
        nvgLineTo(nvg, cx - scale * 0.05, cy - scale * 0.15)
        nvgLineTo(nvg, cx + scale * 0.2, cy + scale * 0.6)
        nvgStrokeWidth(nvg, 2.5)
        nvgStrokeColor(nvg, nvgRGBA(r, g, b, a))
        nvgStroke(nvg)
        -- 横剑
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, cx - scale * 0.5, cy)
        nvgLineTo(nvg, cx + scale * 0.5, cy)
        nvgStrokeWidth(nvg, 1.5)
        nvgStrokeColor(nvg, nvgRGBA(r, g, b, math.floor(a * 0.6)))
        nvgStroke(nvg)

    elseif boneKey == "wood" then
        -- 树纹：竖线 + 分枝
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, cx, cy + scale * 0.6)
        nvgLineTo(nvg, cx, cy - scale * 0.4)
        nvgBezierTo(nvg, cx - scale * 0.3, cy - scale * 0.6, cx - scale * 0.4, cy - scale * 0.8, cx - scale * 0.25, cy - scale * 0.9)
        nvgMoveTo(nvg, cx, cy - scale * 0.3)
        nvgBezierTo(nvg, cx + scale * 0.2, cy - scale * 0.5, cx + scale * 0.35, cy - scale * 0.65, cx + scale * 0.3, cy - scale * 0.75)
        nvgStrokeWidth(nvg, 2)
        nvgStrokeColor(nvg, nvgRGBA(r, g, b, a))
        nvgStroke(nvg)

    elseif boneKey == "water" then
        -- 水波纹：三层弧线
        for i = 1, 3 do
            local yOff = (i - 2) * scale * 0.3
            nvgBeginPath(nvg)
            nvgMoveTo(nvg, cx - scale * 0.4, cy + yOff)
            nvgBezierTo(nvg, cx - scale * 0.15, cy + yOff - scale * 0.15,
                cx + scale * 0.15, cy + yOff + scale * 0.15,
                cx + scale * 0.4, cy + yOff)
            nvgStrokeWidth(nvg, 1.8)
            nvgStrokeColor(nvg, nvgRGBA(r, g, b, math.floor(a * (1.1 - i * 0.2))))
            nvgStroke(nvg)
        end

    elseif boneKey == "fire" then
        -- 火焰纹：三角锋芒向上
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, cx, cy - scale * 0.8)
        nvgLineTo(nvg, cx - scale * 0.3, cy + scale * 0.4)
        nvgLineTo(nvg, cx + scale * 0.3, cy + scale * 0.4)
        nvgClosePath(nvg)
        nvgStrokeWidth(nvg, 2)
        nvgStrokeColor(nvg, nvgRGBA(r, g, b, a))
        nvgStroke(nvg)
        -- 内焰
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, cx, cy - scale * 0.45)
        nvgLineTo(nvg, cx - scale * 0.15, cy + scale * 0.2)
        nvgLineTo(nvg, cx + scale * 0.15, cy + scale * 0.2)
        nvgClosePath(nvg)
        nvgFillColor(nvg, nvgRGBA(r, g, b, math.floor(a * 0.3)))
        nvgFill(nvg)

    elseif boneKey == "star" then
        -- 星阵纹：六芒星
        local points = 6
        for i = 1, points do
            local angle1 = math.rad((i - 1) * 60 - 90)
            local angle2 = math.rad(i * 60 - 90)
            local outerR = scale * 0.6
            local innerR = scale * 0.3
            nvgBeginPath(nvg)
            nvgMoveTo(nvg, cx + math.cos(angle1) * outerR, cy + math.sin(angle1) * outerR)
            local midAngle = math.rad((i - 0.5) * 60 - 90)
            nvgLineTo(nvg, cx + math.cos(midAngle) * innerR, cy + math.sin(midAngle) * innerR)
            nvgLineTo(nvg, cx + math.cos(angle2) * outerR, cy + math.sin(angle2) * outerR)
            nvgStrokeWidth(nvg, 1.5)
            nvgStrokeColor(nvg, nvgRGBA(r, g, b, a))
            nvgStroke(nvg)
        end

    else -- none 无相
        -- 空心圆 + 十字虚线
        nvgBeginPath(nvg)
        nvgCircle(nvg, cx, cy, scale * 0.4)
        nvgStrokeWidth(nvg, 1.5)
        nvgStrokeColor(nvg, nvgRGBA(r, g, b, math.floor(a * 0.7)))
        nvgStroke(nvg)
        -- 四方短线
        for i = 0, 3 do
            local ang = math.rad(i * 90)
            nvgBeginPath(nvg)
            nvgMoveTo(nvg, cx + math.cos(ang) * scale * 0.2, cy + math.sin(ang) * scale * 0.2)
            nvgLineTo(nvg, cx + math.cos(ang) * scale * 0.35, cy + math.sin(ang) * scale * 0.35)
            nvgStrokeWidth(nvg, 1.5)
            nvgStrokeColor(nvg, nvgRGBA(r, g, b, math.floor(a * 0.5)))
            nvgStroke(nvg)
        end
    end
end

function LingjianWidget:DrawHumanSilhouette(nvg, cx, cy, scale, alpha)
    nvgBeginPath(nvg)
    nvgCircle(nvg, cx, cy - scale * 0.6, scale * 0.25)
    nvgFillColor(nvg, nvgRGBA(180, 210, 200, alpha))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, cx - scale * 0.2, cy - scale * 0.3)
    nvgLineTo(nvg, cx + scale * 0.2, cy - scale * 0.3)
    nvgLineTo(nvg, cx + scale * 0.35, cy + scale * 0.7)
    nvgLineTo(nvg, cx - scale * 0.35, cy + scale * 0.7)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(180, 210, 200, alpha))
    nvgFill(nvg)
end

-- ============================================================================
-- 5. 生命周期
-- ============================================================================

function Start()
    graphics.windowTitle = "一念测根骨"

    UI.Init({
        fonts = {
            { family = "sans", weights = {
                normal = "Fonts/MiSans-Regular.ttf",
            } }
        },
        scale = UI.Scale.DEFAULT,
    })

    CreateUI()
    SubscribeToEvent("Update", "HandleUpdate")
    print("=== 一念测根骨 v3 - 两层计分系统已启动 ===")
end

function Stop()
    UI.Shutdown()
end

-- ============================================================================
-- 6. UI 构建
-- ============================================================================

local function CreateOptionButton(index)
    return UI.Button {
        id = "option" .. index,
        text = "",
        width = "88%",
        maxWidth = 340,
        height = 54,
        fontSize = 14,
        backgroundColor = { 35, 50, 55, 200 },
        textColor = { 200, 215, 210, 230 },
        borderRadius = 6,
        borderWidth = 1,
        borderColor = { 100, 140, 130, 80 },
        hoverBackgroundColor = { 45, 65, 70, 220 },
        pressedBackgroundColor = { 55, 80, 85, 240 },
        transition = "backgroundColor 0.2s easeOut",
        onClick = function(self)
            SelectOption(index)
        end,
    }
end

function CreateUI()
    lingjianWidget_ = LingjianWidget {}

    -- === 菜单覆盖层 ===
    titleLabel_ = UI.Label {
        text = "一念测根骨",
        fontSize = 28,
        fontColor = { 200, 215, 210, 240 },
        textAlign = "center",
        letterSpacing = 6,
        textShadow = { offsetX = 0, offsetY = 2, blur = 4, color = { 0, 0, 0, 128 } },
    }

    promptLabel_ = UI.Label {
        text = "",
        fontSize = 14,
        fontColor = { 160, 180, 175, 200 },
        textAlign = "center",
        visible = false,
    }

    mainBtn_ = UI.Button {
        text = "开始测骨",
        width = 200, height = 48, fontSize = 16,
        backgroundColor = { 60, 100, 90, 200 },
        textColor = { 200, 230, 220, 255 },
        borderRadius = 24, borderWidth = 1,
        borderColor = { 120, 180, 160, 100 },
        hoverBackgroundColor = { 70, 120, 105, 220 },
        pressedBackgroundColor = { 50, 85, 75, 240 },
        onClick = function(self) OnMainButtonClick() end,
    }

    subBtn_ = UI.Button {
        text = "图鉴",
        width = 80, height = 32, fontSize = 12,
        backgroundColor = { 40, 50, 55, 150 },
        textColor = { 140, 160, 155, 180 },
        borderRadius = 16, borderWidth = 1,
        borderColor = { 80, 100, 95, 80 },
        hoverBackgroundColor = { 50, 65, 70, 180 },
        pressedBackgroundColor = { 35, 45, 50, 200 },
        onClick = function(self) print("图鉴功能尚未实现") end,
    }

    menuOverlay_ = UI.Panel {
        id = "menuOverlay",
        width = "100%", height = "100%",
        position = "absolute", top = 0, left = 0,
        pointerEvents = "box-none",
        children = {
            UI.Panel {
                width = "100%", paddingTop = 48,
                alignItems = "center", pointerEvents = "none",
                children = { titleLabel_, UI.Panel { height = 8 }, promptLabel_ },
            },
            UI.Panel { flexGrow = 1, pointerEvents = "none" },
            UI.Panel {
                width = "100%", paddingBottom = 60,
                alignItems = "center", gap = 16, pointerEvents = "box-none",
                children = { mainBtn_, subBtn_ },
            },
        },
    }

    -- === 答题覆盖层 ===
    progressLabel_ = UI.Label {
        text = "1 / 7",
        fontSize = 12,
        fontColor = { 140, 160, 155, 150 },
        textAlign = "center",
    }

    questionLabel_ = UI.Label {
        text = "",
        fontSize = 16,
        fontColor = { 210, 225, 220, 240 },
        textAlign = "center",
        whiteSpace = "normal",
        lineHeight = 1.6,
    }

    hintLabel_ = UI.Label {
        text = "",
        fontSize = 13,
        fontColor = { 140, 200, 180, 0 },
        textAlign = "center",
        visible = false,
    }

    optionBtns_ = {}
    for i = 1, 3 do
        optionBtns_[i] = CreateOptionButton(i)
    end

    questionOverlay_ = UI.Panel {
        id = "questionOverlay",
        width = "100%", height = "100%",
        position = "absolute", top = 0, left = 0,
        pointerEvents = "box-none",
        visible = false,
        children = {
            UI.Panel {
                width = "100%", paddingTop = 24,
                alignItems = "center", pointerEvents = "none",
                children = { progressLabel_ },
            },
            UI.Panel { flexGrow = 1, flexBasis = 0, pointerEvents = "none" },
            UI.Panel {
                width = "100%",
                paddingHorizontal = 20,
                paddingBottom = 50,
                alignItems = "center",
                gap = 12,
                pointerEvents = "box-none",
                children = {
                    questionLabel_,
                    UI.Panel { height = 4, pointerEvents = "none" },
                    hintLabel_,
                    UI.Panel { height = 6, pointerEvents = "none" },
                    optionBtns_[1],
                    optionBtns_[2],
                    optionBtns_[3],
                },
            },
        },
    }

    -- === 推演覆盖层 ===
    calcLabel_ = UI.Label {
        text = "灵鉴推演中",
        fontSize = 16,
        fontColor = { 160, 200, 180, 220 },
        textAlign = "center",
    }

    calcOverlay_ = UI.Panel {
        id = "calcOverlay",
        width = "100%", height = "100%",
        position = "absolute", top = 0, left = 0,
        pointerEvents = "none",
        visible = false,
        justifyContent = "flex-end",
        alignItems = "center",
        paddingBottom = 120,
        children = { calcLabel_ },
    }

    -- === 结果覆盖层（卡片式布局 + 逐行揭示） ===
    resultNameLabel_ = UI.Label {
        id = "resultName",
        text = "",
        fontSize = 28,
        fontColor = { 200, 230, 220, 0 },  -- 初始透明，逐行揭示
        textAlign = "center",
        letterSpacing = 6,
        textShadow = { offsetX = 0, offsetY = 2, blur = 6, color = { 0, 0, 0, 120 } },
    }

    resultRarityLabel_ = UI.Label {
        id = "resultRarity",
        text = "",
        fontSize = 11,
        fontColor = { 160, 165, 155, 0 },
        textAlign = "center",
        letterSpacing = 2,
    }

    resultFortuneLabel_ = UI.Label {
        id = "resultFortune",
        text = "",
        fontSize = 14,
        fontColor = { 200, 170, 90, 0 },
        textAlign = "center",
    }

    resultTraitsLabel_ = UI.Label {
        id = "resultTraits",
        text = "",
        fontSize = 12,
        fontColor = { 140, 170, 165, 0 },
        textAlign = "center",
    }

    resultDescLabel_ = UI.Label {
        id = "resultDesc",
        text = "",
        fontSize = 14,
        fontColor = { 160, 180, 175, 0 },
        textAlign = "center",
        whiteSpace = "normal",
        lineHeight = 1.7,
    }

    -- 分隔线
    resultDivider_ = UI.Panel {
        id = "resultDivider",
        width = 60, height = 1,
        backgroundColor = { 120, 160, 150, 0 },
    }

    local resultRetryBtn = UI.Button {
        id = "resultRetryBtn",
        text = "再测一次",
        width = 180, height = 44, fontSize = 15,
        backgroundColor = { 60, 100, 90, 0 },
        textColor = { 200, 230, 220, 0 },
        borderRadius = 22, borderWidth = 1,
        borderColor = { 120, 180, 160, 0 },
        hoverBackgroundColor = { 70, 120, 105, 220 },
        pressedBackgroundColor = { 50, 85, 75, 240 },
        visible = false,
        onClick = function(self) SetState("MainMenu") end,
    }
    resultRetryBtn_ = resultRetryBtn

    local resultGuideBtn = UI.Button {
        id = "resultGuideBtn",
        text = "查看图鉴",
        width = 100, height = 32, fontSize = 12,
        backgroundColor = { 40, 50, 55, 0 },
        textColor = { 140, 160, 155, 0 },
        borderRadius = 16, borderWidth = 1,
        borderColor = { 80, 100, 95, 0 },
        hoverBackgroundColor = { 50, 65, 70, 180 },
        pressedBackgroundColor = { 35, 45, 50, 200 },
        visible = false,
        onClick = function(self) print("图鉴功能尚未实现") end,
    }
    resultGuideBtn_ = resultGuideBtn

    -- 卡片容器
    resultCard_ = UI.Panel {
        id = "resultCard",
        width = "86%",
        maxWidth = 340,
        paddingVertical = 24,
        paddingHorizontal = 20,
        alignItems = "center",
        gap = 10,
        backgroundColor = { 25, 32, 38, 0 },  -- 初始透明
        borderRadius = 16,
        borderWidth = 1,
        borderColor = { 80, 120, 110, 0 },
        boxShadow = { offsetX = 0, offsetY = 4, blur = 20, color = { 0, 0, 0, 80 } },
        children = {
            resultNameLabel_,
            resultRarityLabel_,
            UI.Panel { height = 4, pointerEvents = "none" },
            resultFortuneLabel_,
            resultDivider_,
            resultTraitsLabel_,
            UI.Panel { height = 4, pointerEvents = "none" },
            resultDescLabel_,
        },
    }

    resultOverlay_ = UI.Panel {
        id = "resultOverlay",
        width = "100%", height = "100%",
        position = "absolute", top = 0, left = 0,
        pointerEvents = "box-none",
        visible = false,
        children = {
            UI.Panel { flexGrow = 1, flexBasis = 0, pointerEvents = "none" },
            UI.Panel {
                width = "100%",
                paddingHorizontal = 20,
                paddingBottom = 40,
                alignItems = "center",
                gap = 16,
                pointerEvents = "box-none",
                children = {
                    resultCard_,
                    resultRetryBtn,
                    resultGuideBtn,
                },
            },
        },
    }

    -- === 组合根 ===
    uiRoot_ = UI.Panel {
        id = "root",
        width = "100%", height = "100%",
        children = {
            lingjianWidget_,
            menuOverlay_,
            questionOverlay_,
            calcOverlay_,
            resultOverlay_,
        },
    }

    UI.SetRoot(uiRoot_)
end

-- ============================================================================
-- 7. 状态切换
-- ============================================================================

function SetState(newState)
    gameState_ = newState
    stateTime_ = 0

    menuOverlay_:SetVisible(false)
    questionOverlay_:SetVisible(false)
    calcOverlay_:SetVisible(false)
    resultOverlay_:SetVisible(false)

    if newState == "MainMenu" then
        menuOverlay_:SetVisible(true)
        titleLabel_:SetText("一念测根骨")
        titleLabel_:SetFontColor({ 200, 215, 210, 240 })
        promptLabel_:SetVisible(false)
        mainBtn_:SetText("开始测骨")
        mainBtn_:SetVisible(true)
        subBtn_:SetVisible(true)
        awakeProgress_ = 0
        glowAlpha_ = 0.1
        lingjianTargetR_, lingjianTargetG_, lingjianTargetB_ = 120, 180, 160
        ResetTraits()
        currentQuestion_ = 1

    elseif newState == "PrepareTest" then
        menuOverlay_:SetVisible(true)
        promptLabel_:SetText("请将一念注入灵鉴")
        promptLabel_:SetVisible(true)
        promptLabel_:SetFontColor({ 160, 180, 175, 200 })
        mainBtn_:SetText("注入灵息")
        mainBtn_:SetVisible(true)
        subBtn_:SetVisible(false)
        awakeProgress_ = 0

    elseif newState == "LingjianAwake" then
        menuOverlay_:SetVisible(true)
        promptLabel_:SetText("灵鉴感应中...")
        promptLabel_:SetVisible(true)
        promptLabel_:SetFontColor({ 140, 200, 180, 220 })
        mainBtn_:SetVisible(false)
        subBtn_:SetVisible(false)
        awakeProgress_ = 0

    elseif newState == "QuestionFlow" then
        questionOverlay_:SetVisible(true)
        optionLocked_ = false
        questionFadeIn_ = 0
        hintLabel_:SetVisible(false)
        ShowQuestion(currentQuestion_)

    elseif newState == "Calculating" then
        calcOverlay_:SetVisible(true)
        calcProgress_ = 0
        calcLabel_:SetText("灵鉴推演中")
        calcLabel_:SetFontColor({ 160, 200, 180, 220 })

    elseif newState == "SimpleResult" then
        resultOverlay_:SetVisible(true)
        resultBoneKey_ = CalculateRootBone()
        resultRarity_ = CalculateRarity()
        revealStep_ = 0
        revealTimer_ = 0
        ShowResult(resultBoneKey_)
    end

    print("[State] -> " .. newState)
end

-- ============================================================================
-- 8. 答题流程
-- ============================================================================

function ShowQuestion(index)
    local q = QUESTIONS[index]
    if not q then return end

    progressLabel_:SetText(index .. " / " .. #QUESTIONS)
    questionLabel_:SetText(q.question)

    for i = 1, 3 do
        local opt = q.options[i]
        if opt then
            optionBtns_[i]:SetText(opt.text)
            optionBtns_[i]:SetVisible(true)
            optionBtns_[i]:SetDisabled(false)
        else
            optionBtns_[i]:SetVisible(false)
        end
    end

    -- 隐藏上一轮倾向词
    hintLabel_:SetVisible(false)
    questionFadeIn_ = 0
    optionLocked_ = false
end

function SelectOption(index)
    if optionLocked_ then return end
    optionLocked_ = true

    local q = QUESTIONS[currentQuestion_]
    if not q or not q.options[index] then return end

    local option = q.options[index]

    -- 累加维度分
    AddTraits(option.traits)

    -- 获取本次选项的主要维度，显示倾向词
    local dominantTrait = GetDominantTrait(option.traits)
    local hints = TRAIT_HINTS[dominantTrait]
    if hints then
        local hintText = hints[math.random(1, #hints)]
        hintLabel_:SetText(hintText)
        hintLabel_:SetVisible(true)
        hintLabel_:SetFontColor({ 140, 200, 180, 200 })
    end

    -- 灵鉴颜色微调（不直接对应根骨，只是微妙的色调偏移）
    -- 基于维度做柔和的色彩混合
    local colorShifts = {
        resolve  = { 150, 190, 210 },
        patience = { 110, 190, 140 },
        insight  = { 100, 160, 200 },
        adapt    = { 130, 180, 180 },
        ambition = { 180, 140, 100 },
        harmony  = { 120, 200, 160 },
        order    = { 140, 140, 190 },
        instinct = { 170, 160, 130 },
    }
    local shift = colorShifts[dominantTrait] or { 120, 180, 160 }
    -- 混合当前色 + 新偏移，让变化柔和
    lingjianTargetR_ = lingjianTargetR_ * 0.6 + shift[1] * 0.4
    lingjianTargetG_ = lingjianTargetG_ * 0.6 + shift[2] * 0.4
    lingjianTargetB_ = lingjianTargetB_ * 0.6 + shift[3] * 0.4

    -- 触发反馈动画
    feedbackActive_ = true
    feedbackTimer_ = 0.4
    feedbackScale_ = 1.0

    -- 禁用按钮显示选中态
    for i = 1, 3 do
        if i == index then
            optionBtns_[i]:SetStyle({
                backgroundColor = { 55, 90, 85, 240 },
                borderColor = { 140, 200, 180, 180 },
            })
        end
        optionBtns_[i]:SetDisabled(true)
    end

    print("[答题] Q" .. currentQuestion_ .. " -> 选项" .. index .. " (主维度: " .. dominantTrait .. ")")
end

-- ============================================================================
-- 9. 结果展示
-- ============================================================================

function ShowResult(boneKey)
    local bone = BONE_TYPES[boneKey]
    if not bone then bone = BONE_TYPES.none end

    -- 准备数据（不立即显示，由 RevealStep 控制）
    resultNameLabel_:SetText(bone.name)
    resultFortuneLabel_:SetText("「" .. bone.fortune .. "」")
    resultDescLabel_:SetText(bone.desc)

    -- 稀有度标签
    local rarityInfo = RARITY_INFO[resultRarity_]
    resultRarityLabel_:SetText("· " .. rarityInfo.label .. " ·")

    -- 前三项主要倾向
    local topTraits = GetTopTraits(3)
    local traitTexts = {}
    for _, item in ipairs(topTraits) do
        local name = TRAIT_NAMES[item.key] or item.key
        traitTexts[#traitTexts + 1] = name
    end
    resultTraitsLabel_:SetText("主倾向：" .. table.concat(traitTexts, " / "))

    -- 灵鉴颜色切到结果色
    lingjianTargetR_ = bone.color[1]
    lingjianTargetG_ = bone.color[2]
    lingjianTargetB_ = bone.color[3]

    print("[结果] " .. bone.name .. " (" .. rarityInfo.label .. ") | 主倾向: " .. table.concat(traitTexts, ", "))
end

--- 逐行揭示动画：每个步骤控制一个元素淡入
local function ApplyRevealStep(step)
    if step == 1 then
        -- 卡片容器浮现
        resultCard_:SetStyle({
            backgroundColor = { 25, 32, 38, 210 },
            borderColor = { 80, 120, 110, 60 },
        })
    elseif step == 2 then
        -- 根骨名称
        local bone = BONE_TYPES[resultBoneKey_]
        resultNameLabel_:SetFontColor(bone.color)
    elseif step == 3 then
        -- 稀有度标签
        local rarityInfo = RARITY_INFO[resultRarity_]
        resultRarityLabel_:SetFontColor(rarityInfo.color)
    elseif step == 4 then
        -- 命格批语
        resultFortuneLabel_:SetFontColor({ 200, 170, 90, 220 })
        resultDivider_:SetStyle({ backgroundColor = { 120, 160, 150, 60 } })
    elseif step == 5 then
        -- 主倾向
        resultTraitsLabel_:SetFontColor({ 140, 170, 165, 200 })
    elseif step == 6 then
        -- 描述文本
        resultDescLabel_:SetFontColor({ 160, 180, 175, 210 })
    elseif step == 7 then
        -- 按钮浮现
        resultRetryBtn_:SetVisible(true)
        resultRetryBtn_:SetStyle({
            backgroundColor = { 60, 100, 90, 200 },
            textColor = { 200, 230, 220, 255 },
            borderColor = { 120, 180, 160, 100 },
        })
        resultGuideBtn_:SetVisible(true)
        resultGuideBtn_:SetStyle({
            backgroundColor = { 40, 50, 55, 150 },
            textColor = { 140, 160, 155, 180 },
            borderColor = { 80, 100, 95, 80 },
        })
    end
end

-- ============================================================================
-- 10. 按钮回调
-- ============================================================================

function OnMainButtonClick()
    if gameState_ == "MainMenu" then
        SetState("PrepareTest")
    elseif gameState_ == "PrepareTest" then
        SetState("LingjianAwake")
    end
end

-- ============================================================================
-- 11. 主更新循环
-- ============================================================================

---@param eventType string
---@param eventData UpdateEventData
function HandleUpdate(eventType, eventData)
    local dt = eventData["TimeStep"]:GetFloat()

    -- LingjianAwake → 自动进入答题
    if gameState_ == "LingjianAwake" then
        if awakeProgress_ >= 1.0 and stateTime_ > 1.2 then
            promptLabel_:SetText("灵鉴已醒")
            promptLabel_:SetFontColor({ 200, 230, 220, 255 })
        end
        if awakeProgress_ >= 1.0 and stateTime_ > 2.2 then
            SetState("QuestionFlow")
        end
    end

    -- QuestionFlow → 反馈播完后切题
    if gameState_ == "QuestionFlow" and optionLocked_ then
        if not feedbackActive_ then
            if currentQuestion_ < #QUESTIONS then
                currentQuestion_ = currentQuestion_ + 1
                ShowQuestion(currentQuestion_)
                for i = 1, 3 do
                    optionBtns_[i]:SetStyle({
                        backgroundColor = { 35, 50, 55, 200 },
                        borderColor = { 100, 140, 130, 80 },
                    })
                end
            else
                SetState("Calculating")
            end
        end
    end

    -- 题目淡入
    if gameState_ == "QuestionFlow" then
        questionFadeIn_ = math.min(1.0, questionFadeIn_ + dt * 4)
        questionOverlay_:SetStyle({ opacity = questionFadeIn_ })
    end

    -- Calculating → 推演完成
    if gameState_ == "Calculating" then
        calcProgress_ = calcProgress_ + dt
        local dots = string.rep(".", math.floor(totalTime_ * 2) % 4)
        calcLabel_:SetText("灵鉴推演中" .. dots)
        if calcProgress_ >= 1.8 then
            SetState("SimpleResult")
        end
    end

    -- SimpleResult 逐行揭示
    if gameState_ == "SimpleResult" then
        revealTimer_ = revealTimer_ + dt
        local nextStep = revealStep_ + 1
        if nextStep <= #REVEAL_DELAYS then
            if revealTimer_ >= REVEAL_DELAYS[nextStep] then
                revealStep_ = nextStep
                revealTimer_ = 0
                ApplyRevealStep(nextStep)
            end
        end
    end
end
