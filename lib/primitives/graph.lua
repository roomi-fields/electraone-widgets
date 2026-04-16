-- electraone-widgets · primitive: graph
-- Polyline plot of normalised points inside a rectangle. Useful for
-- envelope shapes, EQ curves, LFO traces, waveform thumbnails.
-- Requires Theme.
--
-- Usage:
--   Theme.graph(x, y, w, h, points, {
--     color = Theme.ACCENT,   -- trace colour (default ACCENT)
--     fill  = false,          -- if true, solid-fill area under the curve
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

  -- Pre-compute screen-space points once (used by fill and trace).
  local sp = {}
  for i, p in ipairs(points) do sp[i] = { toScreen(p) } end

  -- Solid uniform fill under the curve — one fillRect per integer column.
  -- Integer coords avoid the sub-pixel "dégradé" artifact of drawLine stacking.
  if fill then
    graphics.setColor(color)
    local baseY = math.floor(y + h - baseline * h)
    local minX = math.floor(sp[1][1])
    local maxX = math.floor(sp[#sp][1])
    local seg = 1
    for px = minX, maxX do
      while seg < #sp - 1 and px > sp[seg + 1][1] do seg = seg + 1 end
      local x0, y0 = sp[seg][1], sp[seg][2]
      local x1, y1 = sp[seg + 1][1], sp[seg + 1][2]
      local dx = x1 - x0
      local t = (dx == 0) and 0 or (px - x0) / dx
      local curveY = math.floor(y0 + (y1 - y0) * t)
      local yTop = math.min(curveY, baseY)
      local yBot = math.max(curveY, baseY)
      graphics.fillRect(px, yTop, 1, yBot - yTop + 1)
    end
  end

  -- Contour trace (2px thick). When area is filled, render in TEXT for
  -- visible outline on top of the accent fill. The trace naturally traces
  -- section transitions through the curve's angle changes — no extra markers.
  local traceColor = fill and Theme.TEXT or color
  graphics.setColor(traceColor)
  for i = 1, #sp - 1 do
    local x0, y0 = sp[i][1], sp[i][2]
    local x1, y1 = sp[i + 1][1], sp[i + 1][2]
    graphics.drawLine(x0, y0,     x1, y1)
    graphics.drawLine(x0, y0 + 1, x1, y1 + 1)
  end
end

return graph
