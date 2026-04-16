-- Widget: Modern ADSR
-- Flat/modern replacement for the native dx7envelope tile. A live ADSR
-- curve with four faders driving A / D / S / R. Built on lib/theme.lua
-- and the lib/primitives/* library (Theme.knob, Theme.graph, Theme.card).
-- Paste those above this code for device deployment.

-- ===== State =====
-- Each value is normalised 0..1. The widget itself doesn't emit notes —
-- it's a UI block that any synth patch can read parameters 1..4 from.
local adsr = { a = 0.15, d = 0.30, s = 0.65, r = 0.40 }

-- Virtual parameter numbers this widget reads
local PARAM_A = 1
local PARAM_D = 2
local PARAM_S = 3
local PARAM_R = 4

local envControl = controls.get(1)

-- ===== Curve generation =====
-- ADSR shape over a normalised time axis. Sustain has a fixed visual hold
-- so the segment stays visible when A/D/R are small.
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

-- Format seconds from a 0..1 value (min 1 ms, max 5000 ms, exponential)
local function ms(v)
  local val = math.floor(1 + v ^ 2 * 4999)
  if val < 1000 then return tostring(val) .. " ms" end
  return string.format("%.2fs", val / 1000)
end

-- ===== Paint callback =====
function paintEnvelope(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 12, "ENVELOPE", Theme.TEXT_DIM)
  Theme.line(20, 30, W - 20, 30, Theme.BORDER)

  -- Graph: top 60 % of the tile
  local gx, gy, gw, gh = 20, 42, W - 40, math.floor(H * 0.55)
  Theme.graph(gx, gy, gw, gh, envelopePoints(), {
    color = Theme.ACCENT,
    fill = true,
    grid = 4,
  })

  -- Value readouts in a row under the graph
  local ry = gy + gh + 12
  Theme.readout( 40, ry, { label = "ATTACK",  value = ms(adsr.a),           color = Theme.ACCENT })
  Theme.readout(180, ry, { label = "DECAY",   value = ms(adsr.d),           color = Theme.ACCENT })
  Theme.readout(320, ry, { label = "SUSTAIN", value = tostring(math.floor(adsr.s * 100)), unit = "%", color = Theme.ACCENT })
  Theme.readout(460, ry, { label = "RELEASE", value = ms(adsr.r),           color = Theme.ACCENT })

  -- BPM / voice / mode metadata on the right — editorial balance
  Theme.readout(W - 220, ry, { label = "CURVE",    value = "EXP",      color = Theme.TEXT_DIM })
  Theme.readout(W - 120, ry, { label = "RETRIG",   value = "LEGATO",   color = Theme.TEXT_DIM })
end

-- ===== Input routing =====
-- Drag one of the 4 native faders → onChange fires → update state → repaint
function parameterMap.onChange(valueObjects, origin, midiValue)
  local p = valueObjects[1]:getMessage():getParameterNumber()
  local v = midiValue / 127
  if p == PARAM_A then adsr.a = v
  elseif p == PARAM_D then adsr.d = v
  elseif p == PARAM_S then adsr.s = v
  elseif p == PARAM_R then adsr.r = v
  else return end
  envControl:repaint()
end

function preset.onLoad()
  envControl:setBounds({0, 0, 1016, 400})
  envControl:setPaintCallback(paintEnvelope)
  envControl:repaint()
end
