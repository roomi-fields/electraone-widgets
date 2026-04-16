-- electraone-widgets · primitive: slider
-- Linear fader: thin track with a rectangular handle marking the current
-- position. Style = synth-panel linear pot, optional millimetre-ruler
-- style ticks on both sides of the track.
-- Requires Theme.
--
-- Usage:
--   Theme.slider(x, y, w, h, value, {
--     orientation = "h" | "v",   -- default "h"
--     color = Theme.ACCENT,      -- track fill colour (default ACCENT)
--     label = "ATTACK",          -- caption
--     valueText = "12 ms",       -- readout
--     bipolar = false,           -- if true, fill from centre outward
--     ticks = 20,                -- graduation count, both sides, every 5th longer
--                                 --   (omit or 0 to disable)
--   })

local function slider(x, y, w, h, value, opts)
  opts = opts or {}
  local v = math.max(0, math.min(1, value or 0))
  local orient = opts.orientation or "h"
  local color = opts.color or Theme.ACCENT
  local label = opts.label
  local vtext = opts.valueText
  local bipolar = opts.bipolar
  local ticks = opts.ticks

  local headerH = (label or vtext) and 14 or 0

  if label then
    graphics.setColor(Theme.TEXT_DIM)
    graphics.drawText(x, y, label)
  end
  if vtext then
    graphics.setColor(Theme.TEXT)
    graphics.drawText(x + w - #vtext * 6, y, vtext)
  end

  local bx, by, bw, bh = x, y + headerH, w, h - headerH

  -- Helper: draw a 2-pixel-wide line (pseudo-stroke-weight)
  local function fat(x0, y0, x1, y1, col)
    graphics.setColor(col)
    graphics.drawLine(x0, y0, x1, y1)
    if x0 == x1 then
      graphics.drawLine(x0 + 1, y0, x1 + 1, y1)
    else
      graphics.drawLine(x0, y0 + 1, x1, y1 + 1)
    end
  end

  if orient == "v" then
    local trackX = bx + bw // 2

    -- Track (3px thick)
    graphics.setColor(Theme.ELEVATED)
    for dx = -1, 1 do graphics.drawLine(trackX + dx, by, trackX + dx, by + bh) end

    -- Colour fill
    graphics.setColor(color)
    local y0, y1
    if bipolar then
      local mid = by + bh / 2
      local posY = by + bh - bh * v
      y0, y1 = math.min(mid, posY), math.max(mid, posY)
      graphics.setColor(Theme.BORDER)
      graphics.drawLine(trackX - 6, mid, trackX + 6, mid)
      graphics.setColor(color)
    else
      y0, y1 = by + bh - bh * v, by + bh
    end
    for dx = -1, 1 do graphics.drawLine(trackX + dx, y0, trackX + dx, y1) end

    -- Ruler ticks — both sides, close to track, every 5th longer + thicker
    if ticks and ticks > 0 then
      graphics.setColor(Theme.TEXT_DIM)
      for i = 0, ticks do
        local ty = by + bh - (bh * i / ticks)
        local major = (i % 5 == 0)
        local len = major and 5 or 2
        graphics.drawLine(trackX - 4 - len, ty, trackX - 4, ty)
        graphics.drawLine(trackX + 4,       ty, trackX + 4 + len, ty)
        if major then
          graphics.drawLine(trackX - 4 - len, ty + 1, trackX - 4, ty + 1)
          graphics.drawLine(trackX + 4,       ty + 1, trackX + 4 + len, ty + 1)
        end
      end
    end

    -- Handle: narrow rectangle, tall, dark body with horizontal white mark
    local hw = 18
    local hh = 12
    local hx = trackX - hw / 2
    local hy = by + bh - bh * v - hh / 2
    Theme.rect(hx, hy, hw, hh, Theme.CANVAS)
    Theme.outline(hx, hy, hw, hh, Theme.TEXT_DIM)
    -- white horizontal bar through the middle (2px)
    fat(hx + 2, hy + hh // 2, hx + hw - 2, hy + hh // 2, Theme.TEXT)
  else
    local trackY = by + bh // 2

    graphics.setColor(Theme.ELEVATED)
    for dy = -1, 1 do graphics.drawLine(bx, trackY + dy, bx + bw, trackY + dy) end

    graphics.setColor(color)
    local x0, x1
    if bipolar then
      local mid = bx + bw / 2
      local posX = bx + bw * v
      x0, x1 = math.min(mid, posX), math.max(mid, posX)
      graphics.setColor(Theme.BORDER)
      graphics.drawLine(mid, trackY - 6, mid, trackY + 6)
      graphics.setColor(color)
    else
      x0, x1 = bx, bx + bw * v
    end
    for dy = -1, 1 do graphics.drawLine(x0, trackY + dy, x1, trackY + dy) end

    -- Ruler ticks — above and below track
    if ticks and ticks > 0 then
      graphics.setColor(Theme.TEXT_DIM)
      for i = 0, ticks do
        local tx = bx + (bw * i / ticks)
        local major = (i % 5 == 0)
        local len = major and 5 or 2
        graphics.drawLine(tx, trackY - 4 - len, tx, trackY - 4)
        graphics.drawLine(tx, trackY + 4,       tx, trackY + 4 + len)
        if major then
          graphics.drawLine(tx + 1, trackY - 4 - len, tx + 1, trackY - 4)
          graphics.drawLine(tx + 1, trackY + 4,       tx + 1, trackY + 4 + len)
        end
      end
    end

    -- Handle: narrow, tall
    local hw = 12
    local hh = 18
    local hx = bx + bw * v - hw / 2
    local hy = by + bh // 2 - hh / 2
    Theme.rect(hx, hy, hw, hh, Theme.CANVAS)
    Theme.outline(hx, hy, hw, hh, Theme.TEXT_DIM)
    fat(hx + hw // 2, hy + 2, hx + hw // 2, hy + hh - 2, Theme.TEXT)
  end
end

return slider
