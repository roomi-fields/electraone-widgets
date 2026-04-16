-- electraone-widgets · primitive: knob
-- Rotary knob with ring gauge. 270° sweep from 7 o'clock to 5 o'clock.
-- Requires Theme (from lib/theme.lua) to be loaded first.
--
-- Usage:
--   Theme.knob(x, y, size, value, {
--     color = Theme.ACCENT,   -- value ring colour (default ACCENT)
--     label = "CUTOFF",       -- caption below (optional)
--     valueText = "72",       -- override centered readout (optional; default is value × 100 rounded)
--   })
-- `value` is normalised 0..1. `size` is the square bounding box width/height.

local function knob(x, y, size, value, opts)
  opts = opts or {}
  local cx = x + size / 2
  local cy = y + size / 2
  local r  = size / 2 - 4                      -- ring outer radius
  local bodyR = r - 10                         -- inner body radius
  local color = opts.color or Theme.ACCENT
  local dim   = Theme.ELEVATED
  local label = opts.label
  local v = math.max(0, math.min(1, value or 0))

  -- Angular sweep: 7 o'clock → 5 o'clock going clockwise = 270°.
  -- In screen coords (y down), angle 0 = right, pi/2 = down.
  -- 7 o'clock ≈ 135° = 3π/4, 5 o'clock ≈ 45° = π/4 (but past the bottom).
  local startA = math.pi * 0.75                -- 135° (lower-left)
  local sweep  = math.pi * 1.5                 -- 270°
  local segs   = 48                            -- circle approximation density

  local lastX, lastY
  -- Track (background ring)
  graphics.setColor(dim)
  for i = 0, segs do
    local a = startA + sweep * (i / segs)
    local px = cx + r * math.cos(a)
    local py = cy + r * math.sin(a)
    if lastX then graphics.drawLine(lastX, lastY, px, py) end
    lastX, lastY = px, py
  end

  -- Value arc (coloured portion)
  if v > 0 then
    graphics.setColor(color)
    lastX, lastY = nil, nil
    local valSegs = math.max(1, math.floor(segs * v))
    for i = 0, valSegs do
      local a = startA + sweep * (i / segs)
      local px = cx + r * math.cos(a)
      local py = cy + r * math.sin(a)
      if lastX then graphics.drawLine(lastX, lastY, px, py) end
      lastX, lastY = px, py
    end
  end

  -- Inner body (disc)
  graphics.setColor(Theme.SURFACE)
  graphics.fillCircle(cx, cy, bodyR)
  graphics.setColor(Theme.BORDER)
  graphics.drawCircle(cx, cy, bodyR)

  -- Indicator line from centre to current position on the ring
  local indA = startA + sweep * v
  local ix = cx + bodyR * math.cos(indA)
  local iy = cy + bodyR * math.sin(indA)
  graphics.setColor(color)
  graphics.drawLine(cx, cy, ix, iy)

  -- Centred value readout
  local text = opts.valueText or tostring(math.floor(v * 100 + 0.5))
  graphics.setColor(Theme.TEXT)
  graphics.drawText(cx - #text * 4, cy - 6, text)

  -- Label below the knob
  if label then
    graphics.setColor(Theme.TEXT_DIM)
    graphics.drawText(x + (size - #label * 6) / 2, y + size + 4, label)
  end
end

return knob
