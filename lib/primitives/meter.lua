-- electraone-widgets · primitive: meter
-- VU-style meter with graduated tick marks. Horizontal or vertical.
-- Requires Theme.
--
-- Usage:
--   Theme.meter(x, y, w, h, value, {
--     orientation = "h" | "v",  -- default "h"
--     color = Theme.POSITIVE,   -- fill colour in safe zone (default POSITIVE)
--     warn = 0.70,              -- value threshold where color becomes WARNING
--     alert = 0.90,             -- value threshold where color becomes ALERT
--     peak = 0.82,              -- optional peak-hold marker (0..1)
--     label = "IN",             -- caption
--     valueText = "-6 dB",      -- right / top readout
--     ticks = 6,                -- number of graduations (default 6, 0 to disable)
--   })

local function meter(x, y, w, h, value, opts)
  opts = opts or {}
  local v = math.max(0, math.min(1, value or 0))
  local orient = opts.orientation or "h"
  local warn = opts.warn or 0.70
  local alert = opts.alert or 0.90
  local peak = opts.peak
  local ticks = opts.ticks or 6

  -- Colour selection by zone
  local color = opts.color or Theme.POSITIVE
  if v >= alert then color = Theme.ALERT
  elseif v >= warn then color = Theme.WARNING end

  -- Header row: label + value (reserve 14px top)
  local headerH = (opts.label or opts.valueText) and 14 or 0
  local bx, by, bw, bh = x, y + headerH, w, h - headerH

  if opts.label then
    graphics.setColor(Theme.TEXT_DIM)
    graphics.drawText(x, y, opts.label)
  end
  if opts.valueText then
    graphics.setColor(Theme.TEXT)
    graphics.drawText(x + w - #opts.valueText * 6, y, opts.valueText)
  end

  -- Track
  Theme.rect(bx, by, bw, bh, Theme.ELEVATED)
  Theme.outline(bx, by, bw, bh, Theme.BORDER)

  -- Fill + ticks depending on orientation
  if orient == "v" then
    local fillH = math.floor(bh * v)
    if fillH > 0 then
      Theme.rect(bx, by + bh - fillH, bw, fillH, color)
    end
    -- Ticks on the right edge
    if ticks > 0 then
      graphics.setColor(Theme.TEXT_DIM)
      for i = 1, ticks - 1 do
        local ty = by + (bh * i) // ticks
        local major = (i % 5 == 0)
        local len = major and 10 or 7
        graphics.drawLine(bx + bw - len, ty, bx + bw, ty)
        if major then graphics.drawLine(bx + bw - len, ty + 1, bx + bw, ty + 1) end
      end
    end
    -- Peak marker
    if peak and peak > 0 then
      local py = by + bh - math.floor(bh * peak)
      graphics.setColor(Theme.TEXT)
      graphics.drawLine(bx, py, bx + bw, py)
    end
  else
    local fillW = math.floor(bw * v)
    if fillW > 0 then
      Theme.rect(bx, by, fillW, bh, color)
    end
    -- Ticks on the bottom edge
    if ticks > 0 then
      graphics.setColor(Theme.TEXT_DIM)
      for i = 1, ticks - 1 do
        local tx = bx + (bw * i) // ticks
        local major = (i % 5 == 0)
        local len = major and 10 or 7
        graphics.drawLine(tx, by + bh - len, tx, by + bh)
        if major then graphics.drawLine(tx + 1, by + bh - len, tx + 1, by + bh) end
      end
    end
    -- Peak marker
    if peak and peak > 0 then
      local px = bx + math.floor(bw * peak)
      graphics.setColor(Theme.TEXT)
      graphics.drawLine(px, by, px, by + bh)
    end
  end
end

return meter
