-- electraone-widgets · primitive: knob
-- Rotary knob with ring gauge. 270° sweep from 7 o'clock to 5 o'clock.
-- Requires Theme (from lib/theme.lua) to be loaded first.
--
-- Usage:
--   Theme.knob(x, y, size, value, {
--     color = Theme.ACCENT,   -- value ring colour (default ACCENT)
--     label = "CUTOFF",       -- caption below (optional)
--     valueText = "72",       -- override centred readout (optional)
--   })
-- `value` is normalised 0..1. `size` is the square bounding box width/height.

local function knob(x, y, size, value, opts)
  opts = opts or {}
  local cx = x + size / 2
  local cy = y + size / 2
  local r  = size / 2 - 4                      -- ring outer radius
  local bodyR = r - 12                         -- inner disc radius
  local color = opts.color or Theme.ACCENT
  local label = opts.label
  local v = math.max(0, math.min(1, value or 0))

  local startA = math.pi * 0.75                -- 135° (7 o'clock)
  local sweep  = math.pi * 1.5                 -- 270°
  local segs   = 56

  -- Helper: draw an arc segment set at radius `rr` between two normalised t
  -- values (0..1 along the sweep). Two passes at slightly different radii
  -- thicken the line without needing a native stroke-weight.
  local function arc(rr, t0, t1, col)
    graphics.setColor(col)
    local lx, ly
    local i0 = math.floor(segs * t0)
    local i1 = math.ceil(segs * t1)
    for i = i0, i1 do
      local a = startA + sweep * (i / segs)
      local px = cx + rr * math.cos(a)
      local py = cy + rr * math.sin(a)
      if lx then graphics.drawLine(lx, ly, px, py) end
      lx, ly = px, py
    end
  end

  -- Track (dim background ring) — 3-pass for ≈3px thickness
  arc(r,     0, 1, Theme.ELEVATED)
  arc(r - 1, 0, 1, Theme.ELEVATED)
  arc(r - 2, 0, 1, Theme.ELEVATED)

  -- Value arc (coloured) — 4-pass for ≈4px thickness, more dominant
  if v > 0 then
    arc(r,     0, v, color)
    arc(r - 1, 0, v, color)
    arc(r - 2, 0, v, color)
    arc(r - 3, 0, v, color)
  end

  -- Inner body (disc)
  graphics.setColor(Theme.SURFACE)
  graphics.fillCircle(cx, cy, bodyR)
  graphics.setColor(Theme.BORDER)
  graphics.drawCircle(cx, cy, bodyR)

  -- Indicator: thick radial line from centre to the ring, in accent colour.
  -- Drawn as 3 parallel lines offset perpendicularly for pseudo-stroke-weight.
  local indA = startA + sweep * v
  local nx, ny = -math.sin(indA), math.cos(indA)    -- perpendicular unit
  local ox = cx + (bodyR - 2) * math.cos(indA)
  local oy = cy + (bodyR - 2) * math.sin(indA)
  local ix = cx + r * math.cos(indA)
  local iy = cy + r * math.sin(indA)
  graphics.setColor(color)
  graphics.drawLine(ox, oy, ix, iy)
  graphics.drawLine(ox + nx, oy + ny, ix + nx, iy + ny)
  graphics.drawLine(ox - nx, oy - ny, ix - nx, iy - ny)

  -- Centred value readout
  local text = opts.valueText or tostring(math.floor(v * 100 + 0.5))
  graphics.setColor(Theme.TEXT)
  graphics.print(cx - #text * 4, cy - 6, text, 9999, LEFT)

  -- Label below
  if label then
    graphics.setColor(Theme.TEXT_DIM)
    graphics.print(x + (size - #label * 6) / 2, y + size + 4, label, 9999, LEFT)
  end
end

return knob
