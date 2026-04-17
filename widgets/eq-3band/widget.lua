-- Widget: 3-Band EQ
-- Low-shelf + mid-peak + high-shelf with a live magnitude response curve.
-- Uses the Audio EQ Cookbook (RBJ) biquad formulas to compute real filter
-- coefficients, then evaluates the transfer function at 80 log-spaced
-- points between 20 Hz and 20 kHz. No audio processing — just the
-- analytical |H(e^jω)| — so redraw stays cheap on MK2 hardware.
--
-- Band centre frequencies are constrained to keep LOW < MID < HIGH at all
-- times (half-octave minimum separation) so you can't accidentally fold
-- bands on top of each other.
--
-- Paste lib/theme.lua + lib/primitives/{graph,knob}.lua above this code
-- on the device. The emulator pre-loads them.

Theme.require("0.3")

-- ===== Geometry =====
local GRAPH_X, GRAPH_Y, GRAPH_W, GRAPH_H = 20, 30, 976, 280
local CARD_Y, CARD_H = 330, 210
local CARD_XS = { 20, 352, 684 }
local CARD_W = 312
local KNOB_SIZE = 66
local KNOB_Y = CARD_Y + 50
local KNOB_OFFSETS = { 22, 122, 222 }

-- ===== DSP constants =====
local FS = 48000                -- Sample rate assumed for the curve shape
local GAIN_DB_RANGE = 18         -- ±18 dB at knob extremes
local GRAPH_DB_RANGE = 24        -- graph shows ±24 dB so peak bumps fit

-- ===== State =====
-- Each band: { name, type, freq(0..1), gain(0..1), q(0..1) }
local bands = {
  { name = "LOW",  type = "lowshelf",  freq = 0.18, gain = 0.65, q = 0.40 },
  { name = "MID",  type = "peak",      freq = 0.55, gain = 0.70, q = 0.55 },
  { name = "HIGH", type = "highshelf", freq = 0.82, gain = 0.42, q = 0.40 },
}

local dragging = nil
local dragStartY, dragStartV = 0, 0
local PARAMS = { "freq", "gain", "q" }
local FREQ_MARGIN = 0.08         -- min half-octave gap between adjacent bands

local eqControl = controls.get(1)

-- ===== Knob → physical value mapping =====
local function hz(v)
  -- 20 Hz .. 20 kHz log-frequency
  return 20 * 10 ^ (v * 3)
end

local function gainDb(v)
  -- symmetric ±GAIN_DB_RANGE around 0 dB at v=0.5
  return (v - 0.5) * 2 * GAIN_DB_RANGE
end

local function qValue(v)
  -- 0.3 .. 10 exponential (covers everything from wide shelf to surgical bell)
  return 0.3 * (10 / 0.3) ^ v
end

-- ===== Biquad coefficients (RBJ Audio EQ Cookbook) =====
-- Returns b0, b1, b2, a0, a1, a2 for the requested filter type.

local function peakCoeffs(fc, Q, dbG)
  local w0 = 2 * math.pi * fc / FS
  local cw, sw = math.cos(w0), math.sin(w0)
  local A = 10 ^ (dbG / 40)
  local alpha = sw / (2 * Q)
  local aA = alpha * A
  local a_A = alpha / A
  return 1 + aA, -2 * cw, 1 - aA,
         1 + a_A, -2 * cw, 1 - a_A
end

-- alpha for shelves uses the "S" slope parameter; we treat Q as S so that
-- turning the Q knob tightens or loosens the shelf transition. Clamp S so
-- the sqrt argument stays non-negative (A+1/A)(1/S-1)+2 >= 0  =>  S bounded.
local function shelfAlpha(sw, A, Q)
  local S = math.max(0.3, math.min(10, Q))
  local inside = (A + 1 / A) * (1 / S - 1) + 2
  if inside < 0 then inside = 0 end
  return (sw / 2) * math.sqrt(inside)
end

local function lowShelfCoeffs(fc, Q, dbG)
  local w0 = 2 * math.pi * fc / FS
  local cw, sw = math.cos(w0), math.sin(w0)
  local A = 10 ^ (dbG / 40)
  local alpha = shelfAlpha(sw, A, Q)
  local sqrtA2alpha = 2 * math.sqrt(A) * alpha
  local b0 =    A * ((A + 1) - (A - 1) * cw + sqrtA2alpha)
  local b1 =  2 * A * ((A - 1) - (A + 1) * cw)
  local b2 =    A * ((A + 1) - (A - 1) * cw - sqrtA2alpha)
  local a0 =         (A + 1) + (A - 1) * cw + sqrtA2alpha
  local a1 =    -2 * ((A - 1) + (A + 1) * cw)
  local a2 =         (A + 1) + (A - 1) * cw - sqrtA2alpha
  return b0, b1, b2, a0, a1, a2
end

local function highShelfCoeffs(fc, Q, dbG)
  local w0 = 2 * math.pi * fc / FS
  local cw, sw = math.cos(w0), math.sin(w0)
  local A = 10 ^ (dbG / 40)
  local alpha = shelfAlpha(sw, A, Q)
  local sqrtA2alpha = 2 * math.sqrt(A) * alpha
  local b0 =    A * ((A + 1) + (A - 1) * cw + sqrtA2alpha)
  local b1 = -2 * A * ((A - 1) + (A + 1) * cw)
  local b2 =    A * ((A + 1) + (A - 1) * cw - sqrtA2alpha)
  local a0 =         (A + 1) - (A - 1) * cw + sqrtA2alpha
  local a1 =     2 * ((A - 1) - (A + 1) * cw)
  local a2 =         (A + 1) - (A - 1) * cw - sqrtA2alpha
  return b0, b1, b2, a0, a1, a2
end

-- ===== Analytical magnitude response =====
-- |H(e^jω)|² = |b0 + b1·e^-jω + b2·e^-2jω|² / |a0 + a1·e^-jω + a2·e^-2jω|²
-- then convert to dB. No sample processing — reads true biquad magnitude.
local function biquadDb(b0, b1, b2, a0, a1, a2, omega)
  local c1, s1 =  math.cos(omega),     -math.sin(omega)
  local c2, s2 =  math.cos(2 * omega), -math.sin(2 * omega)
  local nR = b0 + b1 * c1 + b2 * c2
  local nI =      b1 * s1 + b2 * s2
  local dR = a0 + a1 * c1 + a2 * c2
  local dI =      a1 * s1 + a2 * s2
  local num2 = nR * nR + nI * nI
  local den2 = dR * dR + dI * dI
  if den2 <= 1e-30 then return 0 end
  if num2 <= 1e-30 then return -300 end
  return 10 * math.log(num2 / den2) / math.log(10)
end

local function bandDb(b, f)
  local fc = hz(b.freq)
  local g = gainDb(b.gain)
  local q = qValue(b.q)
  -- Guard: if f is above Nyquist, response is the DC/Nyquist limit. Clamp.
  local omega = math.min(2 * math.pi * f / FS, math.pi * 0.99)
  local b0, b1, b2, a0, a1, a2
  if b.type == "peak" then
    b0, b1, b2, a0, a1, a2 = peakCoeffs(fc, q, g)
  elseif b.type == "lowshelf" then
    b0, b1, b2, a0, a1, a2 = lowShelfCoeffs(fc, q, g)
  elseif b.type == "highshelf" then
    b0, b1, b2, a0, a1, a2 = highShelfCoeffs(fc, q, g)
  else
    return 0
  end
  return biquadDb(b0, b1, b2, a0, a1, a2, omega)
end

local function responseDb(f)
  return bandDb(bands[1], f) + bandDb(bands[2], f) + bandDb(bands[3], f)
end

local function curvePoints()
  local pts = {}
  local N = 100
  for i = 0, N do
    local t = i / N
    local f = hz(t)
    local db = responseDb(f)
    local y = 0.5 + db / (2 * GRAPH_DB_RANGE)
    y = math.max(0, math.min(1, y))
    pts[#pts + 1] = { t, y }
  end
  return pts
end

-- ===== Readout formatters =====
local function fmtHz(v)
  local f = hz(v)
  if f >= 10000 then return string.format("%.1fk", f / 1000) end
  if f >= 1000  then return string.format("%.2fk", f / 1000) end
  return string.format("%.0f", f)
end

local function fmtDb(v)
  return string.format("%+.1f", gainDb(v))
end

local function fmtQ(v)
  return string.format("%.2f", qValue(v))
end

-- ===== Hit-testing =====
local function hitKnob(x, y)
  if y < KNOB_Y or y > KNOB_Y + KNOB_SIZE + 18 then return nil end
  for i = 1, 3 do
    local cx = CARD_XS[i]
    for j = 1, 3 do
      local kx = cx + KNOB_OFFSETS[j]
      if x >= kx and x <= kx + KNOB_SIZE then
        return { band = i, param = PARAMS[j] }
      end
    end
  end
  return nil
end

local function getParam(hit)
  return bands[hit.band][hit.param]
end

-- Apply band-order protection: LOW.freq < MID.freq < HIGH.freq with
-- FREQ_MARGIN minimum spacing. Only clamps the `freq` param; gain and Q
-- are independent.
local function clampFreq(bandIdx, v)
  if bandIdx == 1 then
    v = math.min(v, bands[2].freq - FREQ_MARGIN)
  elseif bandIdx == 2 then
    v = math.max(bands[1].freq + FREQ_MARGIN, math.min(v, bands[3].freq - FREQ_MARGIN))
  elseif bandIdx == 3 then
    v = math.max(v, bands[2].freq + FREQ_MARGIN)
  end
  return math.max(0, math.min(1, v))
end

local function setParam(hit, v)
  v = math.max(0, math.min(1, v))
  if hit.param == "freq" then v = clampFreq(hit.band, v) end
  bands[hit.band][hit.param] = v
  local paramIdx
  for j = 1, 3 do if PARAMS[j] == hit.param then paramIdx = j end end
  local pnum = (hit.band - 1) * 3 + paramIdx
  parameterMap.set(1, PT_VIRTUAL, pnum, math.floor(v * 127))
end

-- ===== Paint =====
function paintEQ(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 10, "3-BAND EQ", Theme.TEXT_DIM)

  -- Response curve
  Theme.graph(GRAPH_X, GRAPH_Y, GRAPH_W, GRAPH_H, curvePoints(), {
    color = Theme.ACCENT,
    fill = true,
    grid = 8,              -- 0, ±6, ±12, ±18 dB rows (±24 range)
    baseline = 0.5,
  })

  -- 0 dB reference line across the graph, in WARNING amber
  local zeroY = GRAPH_Y + GRAPH_H - math.floor(GRAPH_H * 0.5)
  graphics.setColor(Theme.WARNING)
  graphics.drawLine(GRAPH_X + 1, zeroY,     GRAPH_X + GRAPH_W - 1, zeroY)
  graphics.drawLine(GRAPH_X + 1, zeroY + 1, GRAPH_X + GRAPH_W - 1, zeroY + 1)

  -- Vertical tick at each band's centre frequency (so you see where each band sits)
  graphics.setColor(Theme.TEXT_DIM)
  for i = 1, 3 do
    local fx = GRAPH_X + math.floor(GRAPH_W * bands[i].freq)
    graphics.drawLine(fx, GRAPH_Y + GRAPH_H - 6, fx, GRAPH_Y + GRAPH_H - 1)
  end

  -- 3 band cards
  local paramLabels = { "FREQ", "GAIN", "Q" }
  for i = 1, 3 do
    local cx = CARD_XS[i]
    local bd = bands[i]
    Theme.rect(cx, CARD_Y + 16, CARD_W, CARD_H - 16, Theme.SURFACE)
    Theme.outline(cx, CARD_Y + 16, CARD_W, CARD_H - 16, Theme.BORDER)
    Theme.text(cx + 12, CARD_Y + 2, bd.name, Theme.ACCENT)
    local values = { bd.freq, bd.gain, bd.q }
    local fmts = {
      fmtHz(bd.freq) .. " Hz",
      fmtDb(bd.gain) .. " dB",
      fmtQ(bd.q),
    }
    for j = 1, 3 do
      local kx = cx + KNOB_OFFSETS[j]
      local isDrag = dragging and dragging.band == i and dragging.param == PARAMS[j]
      Theme.knob(kx, KNOB_Y, KNOB_SIZE, values[j], {
        label = paramLabels[j],
        valueText = fmts[j],
        color = isDrag and Theme.WARNING or Theme.ACCENT,
      })
    end
  end
end

-- ===== Touch =====
function touchEQ(control, event)
  if event.type == DOWN then
    local h = hitKnob(event.x, event.y)
    if h then
      dragging = h
      dragStartY = event.y
      dragStartV = getParam(h)
    end
  elseif event.type == MOVE then
    if dragging then
      local dy = dragStartY - event.y
      setParam(dragging, dragStartV + dy / 200)
      control:repaint()
    end
  elseif event.type == UP then
    dragging = nil
    control:repaint()
  end
end

-- ===== Pot =====
function potEQ(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id
  if idx < 1 or idx > 6 then return end
  local bandIdx = (idx <= 3) and 1 or 2
  local paramIdx = ((idx - 1) % 3) + 1
  local h = { band = bandIdx, param = PARAMS[paramIdx] }
  setParam(h, getParam(h) + potEvent.delta / 127)
  control:repaint()
end

function preset.onLoad()
  eqControl:setBounds({0, 0, 1016, 560})
  eqControl:setPaintCallback(paintEQ)
  eqControl:setTouchCallback(touchEQ)
  eqControl:setPotCallback(potEQ)
  eqControl:repaint()
end
