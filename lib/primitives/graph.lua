-- electraone-widgets · primitive: graph
-- Polyline plot of normalised points inside a rectangle. Useful for
-- envelope shapes, EQ curves, LFO traces, waveform thumbnails.
-- Requires Theme.
--
-- Usage:
--   Theme.graph(x, y, w, h, points, {
--     color = Theme.ACCENT,   -- trace colour (default ACCENT)
--     fill  = false,          -- if true, fill area under the curve
--     grid  = 0,              -- N horizontal divisions (default 0 = none)
--     baseline = 0,           -- y-value of the baseline for fill (0..1)
--   })
-- `points` is an array of {x, y} pairs with each coord normalised 0..1.
-- y=0 is the bottom of the rect, y=1 the top.

local function graph(x, y, w, h, points, opts)
  opts = opts or {}
  local color = opts.color or Theme.ACCENT
  local fill = opts.fill
  local grid = opts.grid or 0
  local baseline = opts.baseline or 0

  -- Plot area card
  Theme.rect(x, y, w, h, Theme.SURFACE)
  Theme.outline(x, y, w, h, Theme.BORDER)

  -- Grid divisions
  if grid > 0 then
    graphics.setColor(Theme.ELEVATED)
    for i = 1, grid - 1 do
      local gy = y + (h * i) // grid
      graphics.drawLine(x + 1, gy, x + w - 1, gy)
    end
  end

  if not points or #points < 2 then return end

  -- Map normalised point → screen pixel (flip y: 0=bottom, 1=top)
  local function toScreen(p)
    return x + p[1] * w, y + h - p[2] * h
  end

  -- Optional fill under the curve: iterate pairs and draw vertical lines
  -- from baseline to curve. Cheap approximation, no polygon primitive.
  if fill then
    graphics.setColor(color)
    local baseY = y + h - baseline * h
    for i = 1, #points - 1 do
      local x0, y0 = toScreen(points[i])
      local x1, y1 = toScreen(points[i + 1])
      local steps = math.max(1, math.floor(math.abs(x1 - x0)))
      for s = 0, steps do
        local t = (steps == 0) and 0 or (s / steps)
        local sx = x0 + (x1 - x0) * t
        local sy = y0 + (y1 - y0) * t
        graphics.drawLine(sx, math.min(sy, baseY), sx, math.max(sy, baseY))
      end
    end
  end

  -- Trace (2px thick)
  graphics.setColor(color)
  for i = 1, #points - 1 do
    local x0, y0 = toScreen(points[i])
    local x1, y1 = toScreen(points[i + 1])
    graphics.drawLine(x0,     y0,     x1,     y1)
    graphics.drawLine(x0,     y0 + 1, x1,     y1 + 1)
  end
end

return graph
