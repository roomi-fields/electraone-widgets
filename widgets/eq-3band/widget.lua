-- Widget: 3-Band EQ
-- Low-shelf + mid-peak + high-shelf with live response curve. 9 knobs
-- arranged in three "band cards" below the graph. Magnitude response is
-- approximated with Gaussian/sigmoid shapes in log-frequency space — not
-- a biquad simulation, but reads correctly as an EQ curve and stays cheap
-- enough to redraw on every parameter change.
--
-- Paste lib/theme.lua + lib/primitives/{graph,knob}.lua above this code
-- on the device. The emulator pre-loads them.

-- ===== Geometry =====
local GRAPH_X, GRAPH_Y, GRAPH_W, GRAPH_H = 20, 30, 976, 280
local CARD_Y, CARD_H = 330, 210
local CARD_XS = { 20, 352, 684 }
local CARD_W = 312
local KNOB_SIZE = 66
local KNOB_Y = CARD_Y + 50
local KNOB_OFFSETS = { 22, 122, 222 }  -- within each card: FREQ, GAIN, Q

-- ===== State =====
-- each band: { name, type, freq(0..1), gain(0..1), q(0..1) }
local bands = {
  { name = "LOW",  type = "lowshelf",  freq = 0.20, gain = 0.65, q = 0.35 },
  { name = "MID",  type = "peak",      freq = 0.55, gain = 0.70, q = 0.55 },
  { name = "HIGH", type = "highshelf", freq = 0.82, gain = 0.42, q = 0.35 },
}

local dragging = nil           -- { band = i, param = "freq"|"gain"|"q" }
local dragStartY, dragStartV = 0, 0

-- Virtual parameter layout: band_i, param_j → 1 + (i-1)*3 + (j-1)
local PARAMS = { "freq", "gain", "q" }

local eqControl = controls.get(1)

-- ===== Frequency / gain / Q mapping =====
local function hz(v)
  -- 20 Hz .. 20 kHz log
  return 20 * 10 ^ (v * 3)
end

local function gainDb(v)
  -- -18 .. +18 dB
  return (v - 0.5) * 36
end

local function qValue(v)
  -- 0.3 .. 10 exponential
  return 0.3 * (10 / 0.3) ^ v
end

-- ===== Readout formatters =====
local function fmtHz(v)
  local f = hz(v)
  if f >= 1000 then return string.format("%.1fk", f / 1000) end
  return string.format("%.0f", f)
end

local function fmtDb(v)
  local g = gainDb(v)
  return string.format("%+.1f", g)
end

local function fmtQ(v)
  return string.format("%.2f", qValue(v))
end

-- ===== Magnitude response =====
-- dB response of each band type at frequency f (Hz).
local function bandDb(b, f)
  local fc = hz(b.freq)
  local g = gainDb(b.gain)
  local oct = math.log(f / fc) / math.log(2)
  if b.type == "peak" then
    local bw = 1 / qValue(b.q)  -- bandwidth in octaves
    return g * math.exp(-0.5 * (oct / bw) ^ 2)
  elseif b.type == "lowshelf" then
    -- sigmoid: full gain below fc, flat above
    return g * (1 - 1 / (1 + math.exp(-2.2 * oct)))
  elseif b.type == "highshelf" then
    return g / (1 + math.exp(-2.2 * oct))
  end
  return 0
end

local function responseDb(f)
  return bandDb(bands[1], f) + bandDb(bands[2], f) + bandDb(bands[3], f)
end

-- Generate normalised graph points [{x, y}, ...]
local function curvePoints()
  local pts = {}
  local N = 80
  for i = 0, N do
    local t = i / N
    local f = hz(t)
    local db = responseDb(f)
    -- map -18..+18 dB to 0..1, centred at y = 0.5
    local y = 0.5 + db / 36
    y = math.max(0, math.min(1, y))
    pts[#pts + 1] = { t, y }
  end
  return pts
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

local function setParam(hit, v)
  v = math.max(0, math.min(1, v))
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

  -- Response curve — filled, baseline at 0 dB (y = 0.5)
  Theme.graph(GRAPH_X, GRAPH_Y, GRAPH_W, GRAPH_H, curvePoints(), {
    color = Theme.ACCENT,
    fill = true,
    grid = 6,             -- ±18, ±12, ±6, 0 dB lines (6 divisions)
    baseline = 0.5,       -- 0 dB sits in the middle
  })

  -- 0 dB zero line — draw in warning so it's visible across the fill
  local zeroY = GRAPH_Y + GRAPH_H - math.floor(GRAPH_H * 0.5)
  graphics.setColor(Theme.WARNING)
  graphics.drawLine(GRAPH_X + 1, zeroY, GRAPH_X + GRAPH_W - 1, zeroY)

  -- 3 band cards
  local paramLabels = { "FREQ", "GAIN", "Q" }
  for i = 1, 3 do
    local cx = CARD_XS[i]
    local bd = bands[i]

    -- Card background + band label
    Theme.rect(cx, CARD_Y + 16, CARD_W, CARD_H - 16, Theme.SURFACE)
    Theme.outline(cx, CARD_Y + 16, CARD_W, CARD_H - 16, Theme.BORDER)
    Theme.text(cx + 12, CARD_Y + 2, bd.name, Theme.ACCENT)

    -- 3 knobs per card
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
-- Pots 1-3 = LOW band (freq/gain/q), 4-6 = MID band. HIGH is touch-only on
-- MK2 (only 6 physical encoders on the top row).
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
