-- Widget: Modern ADSR
-- Flat/modern replacement for the native dx7envelope tile. Single custom
-- tile covers the whole page — everything is drawn with Theme primitives.
-- Touch drag on a knob region changes its value; each knob writes to its
-- own virtual parameter via parameterMap.set so downstream synths can
-- wire CC mapping to it.
--
-- On-device: physical pots 1..4 map to the 4 knobs via potCallback.
-- Paste lib/theme.lua + lib/primitives/{knob,graph,readout}.lua above
-- this code on the device. The emulator pre-loads them.

-- ===== Geometry =====
local KNOB_SIZE = 80
local KNOB_ROW_Y = 380
local KNOB_XS = { 100, 340, 580, 820 }   -- left edge of each knob

-- ===== State =====
local adsr = { a = 0.15, d = 0.30, s = 0.65, r = 0.40 }
local dragging = nil       -- index of knob being dragged, 1..4 or nil
local dragStartY = 0
local dragStartV = 0

-- Virtual parameters this widget writes (downstream synths read these)
local PARAM_A, PARAM_D, PARAM_S, PARAM_R = 1, 2, 3, 4

local envControl = controls.get(1)

-- ===== Curve =====
local function envelopePoints()
  local a, d, s, r = adsr.a, adsr.d, adsr.s, adsr.r
  local hold = 0.20
  local total = a + d + hold + r
  if total <= 0 then return { {0, 0}, {1, 0} } end
  local tA = a / total
  local tD = (a + d) / total
  local tS = (a + d + hold) / total
  return {
    {0.00, 0.00},
    {tA,   1.00},
    {tD,   s},
    {tS,   s},
    {1.00, 0.00},
  }
end

local function ms(v)
  local val = math.floor(1 + v ^ 2 * 4999)
  if val < 1000 then return tostring(val) .. " ms" end
  return string.format("%.2fs", val / 1000)
end

-- ===== Hit test =====
-- Return index 1..4 of the knob whose square region contains (x, y), or nil.
local function hitKnob(x, y)
  if y < KNOB_ROW_Y or y > KNOB_ROW_Y + KNOB_SIZE + 18 then return nil end
  for i = 1, 4 do
    local kx = KNOB_XS[i]
    if x >= kx and x <= kx + KNOB_SIZE then return i end
  end
  return nil
end

local function getAt(i)
  if i == 1 then return adsr.a
  elseif i == 2 then return adsr.d
  elseif i == 3 then return adsr.s
  elseif i == 4 then return adsr.r end
end

local function setAt(i, v)
  v = math.max(0, math.min(1, v))
  local pnum
  if i == 1 then adsr.a = v; pnum = PARAM_A
  elseif i == 2 then adsr.d = v; pnum = PARAM_D
  elseif i == 3 then adsr.s = v; pnum = PARAM_S
  elseif i == 4 then adsr.r = v; pnum = PARAM_R end
  if pnum then parameterMap.set(1, PT_VIRTUAL, pnum, math.floor(v * 127)) end
end

-- ===== Paint =====
function paintEnvelope(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 12, "ENVELOPE", Theme.TEXT_DIM)
  Theme.line(20, 30, W - 20, 30, Theme.BORDER)

  -- Curve (top half)
  Theme.graph(20, 42, W - 40, 320, envelopePoints(), {
    color = Theme.ACCENT,
    fill = true,
    grid = 4,
  })

  -- 4 knobs with their readouts inline
  local labels = { "ATTACK", "DECAY", "SUSTAIN", "RELEASE" }
  local values = { ms(adsr.a), ms(adsr.d), tostring(math.floor(adsr.s * 100)) .. "%", ms(adsr.r) }
  for i = 1, 4 do
    Theme.knob(KNOB_XS[i], KNOB_ROW_Y, KNOB_SIZE, getAt(i), {
      label = labels[i],
      valueText = values[i],
      color = (dragging == i) and Theme.WARNING or Theme.ACCENT,
    })
  end

  -- Mode metadata top-right
  Theme.readout(W - 220, 12, { label = "CURVE",  value = "EXP",    color = Theme.TEXT_DIM })
  Theme.readout(W - 120, 12, { label = "RETRIG", value = "LEGATO", color = Theme.TEXT_DIM })
end

-- ===== Touch =====
-- Drag vertically on a knob to change its value. Up = increase.
function touchEnvelope(control, event)
  if event.type == DOWN then
    local k = hitKnob(event.x, event.y)
    if k then
      dragging = k
      dragStartY = event.y
      dragStartV = getAt(k)
    end
  elseif event.type == MOVE then
    if dragging then
      local dy = dragStartY - event.y          -- up = positive
      local sensitivity = 200                   -- pixels for full 0..1 sweep
      setAt(dragging, dragStartV + dy / sensitivity)
      control:repaint()
    end
  elseif event.type == UP then
    dragging = nil
    control:repaint()
  end
end

-- ===== Pot (physical encoder on MK2) =====
function potEnvelope(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id            -- pot IDs on MK2 top row = 1..6
  if idx < 1 or idx > 4 then return end
  local delta = potEvent.delta / 127
  setAt(idx, getAt(idx) + delta)
  control:repaint()
end

function preset.onLoad()
  envControl:setBounds({0, 0, 1016, 560})
  envControl:setPaintCallback(paintEnvelope)
  envControl:setTouchCallback(touchEnvelope)
  envControl:setPotCallback(potEnvelope)
  envControl:repaint()
end
