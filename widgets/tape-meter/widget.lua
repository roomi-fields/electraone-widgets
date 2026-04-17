-- Widget: Tape Meter
-- Mastering-style LUFS + True-Peak meter with peak-hold, target-level
-- reference lines (streaming / broadcast / live) and a stats panel
-- (integrated LUFS, short-term LUFS, LUFS Range, max True-Peak). Drives
-- both meters from a simulated audio envelope so the widget demos without
-- any external audio. On device, wire an external "level" CC into virtual
-- param 5 to replace the simulation with real loudness readings.
--
-- Paste lib/theme.lua + lib/primitives/{meter,readout,button}.lua above
-- this code on the device. The emulator pre-loads them.

Theme.require("0.3")

-- ===== Geometry =====
local METER_Y, METER_H = 60, 340
local LUFS = { x = 90,  w = 70, label = "LUFS", unit = "LUFS" }
local TP   = { x = 210, w = 70, label = "TP",   unit = "dBTP" }
local STATS_X, STATS_Y, STATS_W = 330, 60, 440
local MODES  = { "STREAMING", "BROADCAST", "LIVE" }
local TARGETS = {
  STREAMING = -14,   -- Spotify / Apple Music / YouTube
  BROADCAST = -23,   -- EBU R128 / AES
  LIVE      = -16,
}
local TP_CEILING = -1                -- dBTP ceiling (streaming standard)

local BTN_Y, BTN_H = 420, 56
local BTN_MODE  = { x = 330, y = BTN_Y, w = 170, h = BTN_H, label = "" }
local BTN_RESET = { x = 530, y = BTN_Y, w = 170, h = BTN_H, label = "RESET" }
local BTN_HOLD  = { x = 730, y = BTN_Y, w = 170, h = BTN_H, label = "HOLD" }

-- ===== State =====
local lufsShort = -60      -- short-term LUFS (3s window, smoothed)
local lufsInt   = -60      -- integrated LUFS
local lufsMax   = -60      -- max short-term since reset
local tpCur     = -60      -- current true-peak
local tpMax     = -60      -- peak-hold max
local lra       = 0        -- LUFS range (min to max)
local lufsMin   = 0        -- min short-term since reset (for LRA)

local modeIdx   = 1
local holdOn    = true     -- peak-hold enabled
local resetFlash = 0

local t = 0

local PARAM_MODE, PARAM_HOLD, PARAM_RESET, PARAM_LEVEL = 1, 2, 3, 5

local meterControl = controls.get(1)

-- ===== Simulation =====
-- Simulate a master-bus signal: slow programme envelope + occasional
-- transients that push the true-peak above the loudness level.
local function simulate()
  t = t + 0.04
  local env       = -20 + 8 * math.sin(t * 0.25)                   -- slow, -28..-12 dBFS
  local midMod    = 2 * math.sin(t * 1.7)                          -- ±2 dB gentle ripple
  local transient = (math.random() < 0.05) and (2 + math.random() * 6) or 0
  local instant   = env + midMod + transient

  -- Short-term LUFS: fast smoothing of instantaneous level
  lufsShort = lufsShort * 0.92 + instant * 0.08
  -- Integrated: much slower smoothing
  lufsInt   = lufsInt * 0.996 + instant * 0.004
  -- Range tracking
  if lufsShort > lufsMax then lufsMax = lufsShort end
  if lufsShort < lufsMin then lufsMin = lufsShort end
  lra = lufsMax - lufsMin

  -- True peak (instantaneous + small headroom, decay toward the noise floor)
  local tpInstant = instant + 1.5 + (transient > 0 and 2 or 0)
  -- Linear decay: drop 2 dB per tick (additive, not multiplicative — dB is
  -- logarithmic so multiplying a negative value doesn't mean what you'd
  -- think). Rising takes precedence over decay.
  tpCur = math.max(tpCur - 2, tpInstant)
  if tpCur > tpMax then tpMax = tpCur end
  if not holdOn then
    -- Slow additive decay of the held peak when HOLD is off
    tpMax = math.max(tpMax - 0.3, tpCur)
  end
end

-- ===== Helpers =====
-- Map a dB value in the meter range (-60..0) to 0..1 for the meter bar.
local function dbTo01(v)
  return math.max(0, math.min(1, (v + 60) / 60))
end

-- Semantic zone color for LUFS.
local function lufsColor(v)
  local target = TARGETS[MODES[modeIdx]]
  if v > target + 3     then return Theme.ALERT
  elseif v > target + 1 then return Theme.WARNING
  elseif v > target - 6 then return Theme.POSITIVE
  else return Theme.NEUTRAL_ACCENT end
end

local function tpColor(v)
  if v > TP_CEILING      then return Theme.ALERT
  elseif v > TP_CEILING - 3 then return Theme.WARNING
  else return Theme.POSITIVE end
end

-- ===== Paint =====
local function paintMeterCard(m, value, peakValue, color, yTargetDb)
  -- Card background
  Theme.rect(m.x, METER_Y, m.w, METER_H, Theme.SURFACE)
  Theme.outline(m.x, METER_Y, m.w, METER_H, Theme.BORDER)

  -- Tick marks on right edge every 10 dB, major every 20 dB
  graphics.setColor(Theme.TEXT_DIM)
  for db = -60, 0, 10 do
    local yy = METER_Y + METER_H - math.floor(METER_H * dbTo01(db))
    local major = (db % 20 == 0)
    local len = major and 10 or 6
    graphics.drawLine(m.x + m.w - len, yy, m.x + m.w, yy)
    if major then
      graphics.drawLine(m.x + m.w - len, yy + 1, m.x + m.w, yy + 1)
      graphics.drawText(m.x + m.w + 4, yy - 4, tostring(db))
    end
  end

  -- Fill bar
  local frac = dbTo01(value)
  local fillH = math.floor(METER_H * frac)
  if fillH > 0 then
    Theme.rect(m.x + 2, METER_Y + METER_H - fillH, m.w - 4, fillH, color)
  end

  -- Target reference line (horizontal dashed-ish in WARNING)
  if yTargetDb then
    local ty = METER_Y + METER_H - math.floor(METER_H * dbTo01(yTargetDb))
    graphics.setColor(Theme.WARNING)
    graphics.drawLine(m.x, ty,     m.x + m.w, ty)
    graphics.drawLine(m.x, ty + 1, m.x + m.w, ty + 1)
  end

  -- Peak-hold tick (bright TEXT line on top of the fill)
  if peakValue > -60 then
    local py = METER_Y + METER_H - math.floor(METER_H * dbTo01(peakValue))
    graphics.setColor(Theme.TEXT)
    graphics.drawLine(m.x + 2, py, m.x + m.w - 2, py)
    graphics.drawLine(m.x + 2, py + 1, m.x + m.w - 2, py + 1)
  end

  -- Label above meter
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(m.x + (m.w - #m.label * 6) / 2, METER_Y - 14, m.label)
end

function paintMeter(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 10, "TAPE METER", Theme.TEXT_DIM)
  Theme.text(W - 200, 10,
    string.format("TARGET  %d LUFS", TARGETS[MODES[modeIdx]]),
    Theme.TEXT_DIM)
  Theme.line(20, 30, W - 20, 30, Theme.BORDER)

  -- LUFS meter card
  paintMeterCard(LUFS, lufsShort, lufsMax, lufsColor(lufsShort), TARGETS[MODES[modeIdx]])

  -- True Peak meter card
  paintMeterCard(TP, tpCur, tpMax, tpColor(tpCur), TP_CEILING)

  -- Stats panel — big numbers + small sub-readouts
  Theme.rect(STATS_X, STATS_Y, STATS_W, METER_H, Theme.SURFACE)
  Theme.outline(STATS_X, STATS_Y, STATS_W, METER_H, Theme.BORDER)

  -- Big LUFS readout (short-term)
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(STATS_X + 20, STATS_Y + 16, "SHORT-TERM")
  graphics.setColor(lufsColor(lufsShort))
  local bigLufs = string.format("%.1f LUFS", lufsShort)
  graphics.drawText(STATS_X + 20,     STATS_Y + 36, bigLufs)
  graphics.drawText(STATS_X + 20 + 1, STATS_Y + 36, bigLufs)  -- double-draw for weight

  -- Big TP readout
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(STATS_X + 20, STATS_Y + 76, "TRUE PEAK")
  graphics.setColor(tpColor(tpCur))
  local bigTp = string.format("%.1f dBTP", tpCur)
  graphics.drawText(STATS_X + 20,     STATS_Y + 96, bigTp)
  graphics.drawText(STATS_X + 20 + 1, STATS_Y + 96, bigTp)

  -- Secondary stats (integrated, max, LRA) in a mini-table
  local rows = {
    { "INTEGRATED", string.format("%.1f LUFS", lufsInt) },
    { "MAX ST",     string.format("%.1f LUFS", lufsMax) },
    { "LUFS RANGE", string.format("%.1f LU",   lra) },
    { "TP MAX",     string.format("%.1f dBTP", tpMax) },
  }
  for i, row in ipairs(rows) do
    local ry = STATS_Y + 160 + (i - 1) * 32
    graphics.setColor(Theme.TEXT_DIM)
    graphics.drawText(STATS_X + 20, ry, row[1])
    graphics.setColor(Theme.TEXT)
    graphics.drawText(STATS_X + STATS_W - #row[2] * 6 - 20, ry, row[2])
  end

  -- Three transport buttons
  BTN_MODE.label = MODES[modeIdx]
  Theme.button(BTN_MODE.x, BTN_MODE.y, BTN_MODE.w, BTN_MODE.h, {
    label = BTN_MODE.label, state = true, color = Theme.ACCENT,
  })
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(BTN_MODE.x + (BTN_MODE.w - 24) / 2, BTN_MODE.y + BTN_MODE.h + 4, "MODE")

  Theme.button(BTN_RESET.x, BTN_RESET.y, BTN_RESET.w, BTN_RESET.h, {
    label = BTN_RESET.label, flashing = resetFlash > 0,
  })

  Theme.button(BTN_HOLD.x, BTN_HOLD.y, BTN_HOLD.w, BTN_HOLD.h, {
    label = BTN_HOLD.label, state = holdOn, color = Theme.POSITIVE,
  })

  -- Footer hint
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(20, 510, "MODE cycles target · RESET zeros max / integrated · HOLD freezes true-peak")
end

-- ===== Touch =====
local function inBtn(btn, x, y)
  return x >= btn.x and x <= btn.x + btn.w
     and y >= btn.y and y <= btn.y + btn.h
end

function touchMeter(control, event)
  if event.type ~= DOWN then return end
  if inBtn(BTN_MODE, event.x, event.y) then
    modeIdx = (modeIdx % #MODES) + 1
    parameterMap.set(1, PT_VIRTUAL, PARAM_MODE, math.floor((modeIdx - 1) / (#MODES - 1) * 127))
    control:repaint()
    return
  end
  if inBtn(BTN_RESET, event.x, event.y) then
    lufsInt = -60; lufsMax = -60; lufsMin = 0; lra = 0; tpMax = -60
    resetFlash = 180
    control:repaint()
    return
  end
  if inBtn(BTN_HOLD, event.x, event.y) then
    holdOn = not holdOn
    parameterMap.set(1, PT_VIRTUAL, PARAM_HOLD, holdOn and 127 or 0)
    control:repaint()
    return
  end
end

-- ===== Pot =====
-- Pot 1 cycles MODE, pot 2 toggles HOLD, pot 3 any-move triggers RESET.
function potMeter(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id
  if idx == 1 then
    if potEvent.delta > 0 then modeIdx = (modeIdx % #MODES) + 1
    else modeIdx = ((modeIdx - 2) % #MODES) + 1 end
  elseif idx == 2 then
    holdOn = (potEvent.delta > 0)
    parameterMap.set(1, PT_VIRTUAL, PARAM_HOLD, holdOn and 127 or 0)
  elseif idx == 3 then
    lufsInt = -60; lufsMax = -60; lufsMin = 0; lra = 0; tpMax = -60
    resetFlash = 180
  end
  control:repaint()
end

-- ===== Timer =====
function timer.onTick()
  local dt = 40
  if resetFlash > 0 then resetFlash = resetFlash - dt end
  simulate()
  meterControl:repaint()
end

function preset.onLoad()
  meterControl:setBounds({0, 0, 1016, 560})
  meterControl:setPaintCallback(paintMeter)
  meterControl:setTouchCallback(touchMeter)
  meterControl:setPotCallback(potMeter)
  math.randomseed(0)
  -- Warm-up: run the simulator 120 ticks silently so lufsShort / lufsInt
  -- settle at realistic values before the user sees the meter. Avoids the
  -- "LRA is 45 LU because we started at -60" artifact on first frame.
  for _ = 1, 120 do simulate() end
  lufsMin = lufsShort
  lufsMax = lufsShort
  lra = 0
  timer.setPeriod(40)
  timer.enable()
  meterControl:repaint()
end
