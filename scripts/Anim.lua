-- ============================================================================
-- Anim.lua — 统一动画管理系统
-- 《一念测根骨》专用 Tween / Delay / Sequence Manager
-- ============================================================================
-- 核心职责:
--   1. 数值缓动 TweenValue (灵鉴参数、NanoVG 渲染值)
--   2. 延迟执行 Delay
--   3. 序列/并行编排 Sequence / Parallel
--   4. Tag 系统避免同属性多 tween 抖动
--
-- UI 动画(淡入/位移/颜色)推荐直接使用引擎内置 transition + Animate API,
-- 本模块主要服务于 NanoVG 渲染层和需要精确数值控制的场景。
--
-- 用法:
--   local Anim = require("Anim")
--   Anim.Update(dt)  -- 每帧调用一次
--   Anim.TweenValue(0, 1, 0.5, "easeOutCubic", function(v) ... end)
--   Anim.TaggedTween("glow", 0.3, 0.8, 0.4, "easeOutSine", function(v) glowAlpha = v end)
-- ============================================================================

local Anim = {}

-- ============================================================================
-- 1. AnimationConfig — 统一时间与幅度参数
-- ============================================================================

Anim.Config = {
    -- 通用淡入淡出
    fadeFast       = 0.18,
    fadeNormal     = 0.35,
    fadeSlow       = 0.6,

    -- 答题
    questionIn     = 0.35,
    questionOut    = 0.18,
    optionStagger  = 0.06,

    -- 按钮交互
    buttonPressScale = 0.96,
    buttonPressTime  = 0.12,

    -- 灵鉴脉冲
    lingjianPulseScale = 1.035,
    lingjianPulseTime  = 0.45,

    -- 灵鉴常驻旋转 (度/秒)
    ambientOuterRotateSpeed = 360 / 22,   -- ~16.4 度/秒, 22秒一圈
    ambientInnerRotateSpeed = -360 / 32,  -- 反向, 32秒一圈

    -- 灵鉴呼吸
    breathePeriod   = 3.2,
    breatheAlphaMin = 0.45,
    breatheAlphaMax = 0.65,
    breatheScaleMin = 0.98,
    breatheScaleMax = 1.02,

    -- 反馈
    feedbackHold    = 0.45,
    feedbackFadeIn  = 0.12,
    feedbackFadeOut = 0.2,

    -- 推演
    calculatingDuration = 1.8,
    calculatingRotateMultiplier = 2.5,

    -- 状态切换
    transitionOut   = 0.18,
    transitionIn    = 0.35,
    transitionGap   = 0.08,

    -- 灵鉴醒来
    awakeDuration   = 0.45,
    awakeHold       = 0.8,

    -- 结果页逐行揭示
    revealNameDelay    = 0.45,
    revealRarityDelay  = 0.60,
    revealFortuneDelay = 0.75,
    revealTraitsDelay  = 1.0,
    revealDescDelay    = 1.2,
    revealBtnDelay     = 1.5,

    -- 灵鉴位置
    lingjianCyMenu       = 0.42,
    lingjianCyQuestion   = 0.26,
    lingjianCyCalculate  = 0.38,
    lingjianCyResult     = 0.28,
}

-- ============================================================================
-- 2. Easing 函数
-- ============================================================================

local Easing = {}

function Easing.linear(t) return t end

function Easing.easeOutCubic(t) return 1 - (1 - t) ^ 3 end

function Easing.easeInCubic(t) return t * t * t end

function Easing.easeInOutSine(t) return -(math.cos(math.pi * t) - 1) * 0.5 end

function Easing.easeOutSine(t) return math.sin(t * math.pi * 0.5) end

function Easing.easeInSine(t) return 1 - math.cos(t * math.pi * 0.5) end

function Easing.easeOutQuad(t) return 1 - (1 - t) * (1 - t) end

function Easing.easeInQuad(t) return t * t end

function Easing.easeOutBack(t)
    -- 克制版 overshoot = 1.0
    local c1 = 1.0
    local c3 = c1 + 1
    return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

function Easing.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return 1 - (-2 * t + 2) ^ 3 / 2
    end
end

Anim.Easing = Easing

-- ============================================================================
-- 3. Tween 存储
-- ============================================================================

local tweens_ = {}
local nextId_ = 1

-- ============================================================================
-- 4. 核心 API
-- ============================================================================

local function ResolveEasing(easing)
    if type(easing) == "function" then return easing end
    if type(easing) == "string" and Easing[easing] then return Easing[easing] end
    return Easing.easeOutCubic
end

--- 创建一个数值缓动
---@param from number
---@param to number
---@param duration number
---@param easing? string|function
---@param onUpdate fun(value: number, t: number)
---@param onComplete? fun()
---@return number tweenId
function Anim.TweenValue(from, to, duration, easing, onUpdate, onComplete)
    local id = nextId_
    nextId_ = nextId_ + 1
    tweens_[id] = {
        id = id,
        elapsed = 0,
        duration = math.max(0.001, duration),
        easingFn = ResolveEasing(easing),
        onUpdate = function(easedT)
            local v = from + (to - from) * easedT
            onUpdate(v, easedT)
        end,
        onComplete = onComplete,
        cancelled = false,
    }
    return id
end

--- 延迟执行
---@param duration number
---@param callback fun()
---@return number tweenId
function Anim.Delay(duration, callback)
    local id = nextId_
    nextId_ = nextId_ + 1
    tweens_[id] = {
        id = id,
        elapsed = 0,
        duration = math.max(0.001, duration),
        easingFn = Easing.linear,
        onUpdate = function() end,
        onComplete = callback,
        cancelled = false,
    }
    return id
end

--- 取消一个 tween
---@param id number|nil
function Anim.Cancel(id)
    if id and tweens_[id] then
        tweens_[id].cancelled = true
    end
end

--- 按 tag 取消所有 tween
---@param tag string
function Anim.CancelByTag(tag)
    for _, tw in pairs(tweens_) do
        if tw.tag == tag then
            tw.cancelled = true
        end
    end
end

--- 取消所有 tween
function Anim.CancelAll()
    for _, tw in pairs(tweens_) do
        tw.cancelled = true
    end
end

--- 取消以指定前缀开头的 tag
---@param prefix string
function Anim.CancelByPrefix(prefix)
    local pLen = #prefix
    for _, tw in pairs(tweens_) do
        if tw.tag and tw.tag:sub(1, pLen) == prefix then
            tw.cancelled = true
        end
    end
end

--- 带 tag 的 TweenValue（自动取消同 tag 旧 tween）
---@param tag string
---@param from number
---@param to number
---@param duration number
---@param easing? string|function
---@param onUpdate fun(value: number, t: number)
---@param onComplete? fun()
---@return number tweenId
function Anim.TaggedTween(tag, from, to, duration, easing, onUpdate, onComplete)
    Anim.CancelByTag(tag)
    local id = Anim.TweenValue(from, to, duration, easing, onUpdate, onComplete)
    tweens_[id].tag = tag
    return id
end

--- 带 tag 的 Delay
---@param tag string
---@param duration number
---@param callback fun()
---@return number tweenId
function Anim.TaggedDelay(tag, duration, callback)
    Anim.CancelByTag(tag)
    local id = Anim.Delay(duration, callback)
    tweens_[id].tag = tag
    return id
end

-- ============================================================================
-- 5. 序列与并行编排
-- ============================================================================

--- 简单序列：依次执行多个 {delay, callback} 步骤
---@param steps table[] { {delay, callback}, ... }
---@param tag? string 可选 tag，取消时清理整组
function Anim.Sequence(steps, tag)
    if #steps == 0 then return end
    local idx = 1
    local function RunNext()
        if idx > #steps then return end
        local step = steps[idx]
        idx = idx + 1
        local id = Anim.Delay(step[1] or 0, function()
            if step[2] then step[2]() end
            RunNext()
        end)
        if tag then tweens_[id].tag = tag end
    end
    RunNext()
end

--- 并行执行多个带延迟的回调
---@param items table[] { {delay, callback}, ... }
---@param tag? string
function Anim.Parallel(items, tag)
    for _, item in ipairs(items) do
        if item[1] and item[1] > 0 then
            local id = Anim.Delay(item[1], item[2])
            if tag then tweens_[id].tag = tag end
        else
            if item[2] then item[2]() end
        end
    end
end

-- ============================================================================
-- 6. 每帧更新
-- ============================================================================

---@param dt number deltaTime
function Anim.Update(dt)
    local toRemove = {}
    for id, tw in pairs(tweens_) do
        if tw.cancelled then
            toRemove[#toRemove + 1] = id
        else
            tw.elapsed = tw.elapsed + dt
            local progress = math.min(1.0, tw.elapsed / tw.duration)
            local easedT = tw.easingFn(progress)
            tw.onUpdate(easedT)
            if progress >= 1.0 then
                if tw.onComplete then tw.onComplete() end
                toRemove[#toRemove + 1] = id
            end
        end
    end
    for _, id in ipairs(toRemove) do
        tweens_[id] = nil
    end
end

--- 获取当前活跃 tween 数量（调试用）
function Anim.ActiveCount()
    local c = 0
    for _ in pairs(tweens_) do c = c + 1 end
    return c
end

return Anim
