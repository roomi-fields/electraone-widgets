-- Widget: Compressor Meter
-- Three-column VU for In / Gain Reduction / Out with a threshold line on
-- the input column and four control knobs below (threshold, ratio, attack,
-- release). GR is computed client-side from input + settings; output =
-- input - gr. A slow simulated input envelope animates the meters in the
-- emulator so the widget looks alive without a DAW. On device, either let
-- the simulation run for feedback, or replace `simulateInput()` with a
-- parameterMap.getValue(... PARAM_IN) read of a DAW-driven virtual param.
--
-- Paste lib/theme.lua + lib/primitives/{meter,knob}.lua above this code
-- on the device. The emulator pre-loads them.

Theme.require("0.3")

-- ===== Geometry =====
local METER_W      = 72
local METER_H      = 300
local METER_Y      = 50
local METER_XS     = { 230, 474, 718 }  -- IN, GR, OUT centers (left edge)
local KNOB_SIZE    = 72
local KNOB_ROW_Y   = 400
local KNOB_XS      = { 130, 340, 580, 820 }

-- ===== State =====
local thresh   = 0.70
local ratio    = 0.55  -- 0..1 mapped exponentially to 1:1 .. 20:1
local attack   = 0.25
local release  = 0.50
local input    = 0.5
local gr       = 0
local output   = 0
local peakIn   = 0
local peakOut  = 0
local dragging = nil
local dragStartY, dragStartV = 0, 0
local t = 0

local PARAM_T, PARAM_R, PARAM_A, PARAM_REL = 1, 2, 3, 4

local compControl = controls.get(1)

-- ===== Helpers =====
local function realRatio()
  return 1 + ratio * ratio * 19
end

local function dbStr(v)
  if v <= 0.001 then return "-inf" end
  return string.format("%.1f dB", 20 * math.log(v) / math.log(10))
end

local function threshDbStr()
  return string.format("%.1f dB", -36 + thresh * 36)
end

local function msStr(v, maxMs)
  local val = math.floor(1 + v * (maxMs - 1))
  if val < 1000 then return tostring(val) .. " ms" end
  return string.format("%.2fs", val / 1000)
end

-- Simulated input: slow envelope × faster modulation. Visually engaging,
-- produces natural-looking GR waveform.
local function simulateInput()
  t = t + 0.06
  local env = 0.5 + 0.35 * math.sin(t * 0.27)
  local mod = 0.45 + 0.45 * math.sin(t * 2.3)
  input = math.max(0, math.min(1, env * mod + 0.15))
end

-- Compute GR and output from input + threshold + ratio. Release is
-- applied implicitly: gr decays slowly when input falls below threshold.
local function computeGR()
  local R = realRatio()
  local decay = 1 - release * 0.4  -- higher release = slower decay
  if input > thresh then
    local over = input - thresh
    local target = over * (1 - 1 / R)
    -- Attack: how fast gr rises to the target
    local rise = 0.2 + (1 - attack) * 0.6
    gr = gr + (target - gr) * rise
  else
    gr = gr * decay
    if gr < 0.001 then gr = 0 end
  end
  output = math.max(0, input - gr)
  peakIn  = (input  > peakIn)  and input  or peakIn  * 0.995
  peakOut = (output > peakOut) and output or peakOut * 0.995
end

-- ===== Hit test =====
local function hitKnob(x, y)
  if y < KNOB_ROW_Y or y > KNOB_ROW_Y + KNOB_SIZE + 18 then return nil end
  for i = 1, 4 do
    local kx = KNOB_XS[i]
    if x >= kx and x <= kx + KNOB_SIZE then return i end
  end
  return nil
end

local function getAt(i)
  if i == 1 then return thresh
  elseif i == 2 then return ratio
  elseif i == 3 then return attack
  elseif i == 4 then return release end
end

local function setAt(i, v)
  v = math.max(0, math.min(1, v))
  local pnum
  if i == 1 then thresh = v; pnum = PARAM_T
  elseif i == 2 then ratio = v; pnum = PARAM_R
  elseif i == 3 then attack = v; pnum = PARAM_A
  elseif i == 4 then release = v; pnum = PARAM_REL end
  if pnum then parameterMap.set(1, PT_VIRTUAL, pnum, math.floor(v * 127)) end
end

-- ===== Paint =====
function paintComp(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 12, "COMPRESSOR", Theme.TEXT_DIM)
  local grDb = string.format("GR  %.1f dB", -gr * 36)
  Theme.text(W - 140, 12, grDb, Theme.ACCENT)
  Theme.line(20, 30, W - 20, 30, Theme.BORDER)

  -- IN meter
  Theme.meter(METER_XS[1], METER_Y, METER_W, METER_H, input, {
    orientation = "v",
    label = "IN",
    valueText = dbStr(input),
    peak = peakIn,
    ticks = 10,
    warn = 0.75,
    alert = 0.92,
  })

  -- Threshold line on IN meter (drawn on top of meter fill)
  local thY = METER_Y + 14 + METER_H - math.floor(METER_H * thresh)
  graphics.setColor(Theme.WARNING)
  graphics.drawLine(METER_XS[1] - 6, thY,     METER_XS[1] + METER_W + 6, thY)
  graphics.drawLine(METER_XS[1] - 6, thY + 1, METER_XS[1] + METER_W + 6, thY + 1)
  Theme.text(METER_XS[1] + METER_W + 10, thY - 6, threshDbStr(), Theme.WARNING)

  -- GR meter (inverted — fills from the top, downward, showing reduction)
  Theme.meter(METER_XS[2], METER_Y, METER_W, METER_H, gr * 2, {
    orientation = "v",
    label = "GR",
    valueText = string.format("-%.1f dB", gr * 36),
    ticks = 10,
    inverted = true,
    warn = 0.30,
    alert = 0.60,
    color = Theme.ACCENT,  -- GR is always the signature colour (reduction is the story)
  })

  -- OUT meter
  Theme.meter(METER_XS[3], METER_Y, METER_W, METER_H, output, {
    orientation = "v",
    label = "OUT",
    valueText = dbStr(output),
    peak = peakOut,
    ticks = 10,
    warn = 0.75,
    alert = 0.92,
  })

  -- 4 control knobs
  local labels = { "THRESH", "RATIO", "ATTACK", "RELEASE" }
  local values = {
    threshDbStr(),
    string.format("%.1f:1", realRatio()),
    msStr(attack, 300),
    msStr(release, 2000),
  }
  local vals = { thresh, ratio, attack, release }
  for i = 1, 4 do
    Theme.knob(KNOB_XS[i], KNOB_ROW_Y, KNOB_SIZE, vals[i], {
      label = labels[i],
      valueText = values[i],
      color = (dragging == i) and Theme.WARNING or Theme.ACCENT,
    })
  end
end

-- ===== Touch =====
function touchComp(control, event)
  if event.type == DOWN then
    local k = hitKnob(event.x, event.y)
    if k then
      dragging = k
      dragStartY = event.y
      dragStartV = getAt(k)
    end
  elseif event.type == MOVE then
    if dragging then
      local dy = dragStartY - event.y
      setAt(dragging, dragStartV + dy / 200)
      control:repaint()
    end
  elseif event.type == UP then
    dragging = nil
    control:repaint()
  end
end

-- ===== Pot =====
function potComp(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id
  if idx < 1 or idx > 4 then return end
  setAt(idx, getAt(idx) + potEvent.delta / 127)
  control:repaint()
end

-- ===== Timer (animates the simulated input + GR) =====
function timer.onTick()
  simulateInput()
  computeGR()
  compControl:repaint()
end

function preset.onLoad()
  compControl:setBounds({0, 0, 1016, 560})
  compControl:setPaintCallback(paintComp)
  compControl:setTouchCallback(touchComp)
  compControl:setPotCallback(potComp)
  timer.setPeriod(40)  -- 25 Hz — smooth without burning CPU
  timer.enable()
  compControl:repaint()
end
