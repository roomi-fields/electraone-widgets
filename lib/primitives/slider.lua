-- electraone-widgets · primitive: slider
-- Linear fader: thin track with a rectangular handle marking the current
-- position. Style = synth-panel linear pot (as opposed to the bar
-- primitive which fills 0 → value).
-- Requires Theme.
--
-- Usage:
--   Theme.slider(x, y, w, h, value, {
--     orientation = "h" | "v",  -- default "h"
--     color = Theme.ACCENT,     -- handle + tint colour (default ACCENT)
--     label = "ATTACK",         -- caption
--     valueText = "12 ms",      -- readout
--     bipolar = false,          -- if true, track colours from centre outward
--                               --   (useful for PAN, DETUNE, etc.)
--   })

local function slider(x, y, w, h, value, opts)
  opts = opts or {}
  local v = math.max(0, math.min(1, value or 0))
  local orient = opts.orientation or "h"
  local color = opts.color or Theme.ACCENT
  local label = opts.label
  local vtext = opts.valueText
  local bipolar = opts.bipolar

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

  if orient == "v" then
    -- Thin vertical track down the middle
    local trackX = bx + bw // 2
    graphics.setColor(Theme.ELEVATED)
    graphics.drawLine(trackX,     by, trackX,     by + bh)
    graphics.drawLine(trackX - 1, by, trackX - 1, by + bh)
    graphics.drawLine(trackX + 1, by, trackX + 1, by + bh)

    -- Colour fill from bottom to value (or bipolar from centre)
    graphics.setColor(color)
    if bipolar then
      local mid = by + bh / 2
      local posY = by + bh - bh * v
      local y0 = math.min(mid, posY)
      local y1 = math.max(mid, posY)
      graphics.drawLine(trackX,     y0, trackX,     y1)
      graphics.drawLine(trackX - 1, y0, trackX - 1, y1)
      graphics.drawLine(trackX + 1, y0, trackX + 1, y1)
      -- Centre tick
      graphics.setColor(Theme.BORDER)
      graphics.drawLine(bx, mid, bx + bw, mid)
    else
      local y0 = by + bh - bh * v
      local y1 = by + bh
      graphics.drawLine(trackX,     y0, trackX,     y1)
      graphics.drawLine(trackX - 1, y0, trackX - 1, y1)
      graphics.drawLine(trackX + 1, y0, trackX + 1, y1)
    end

    -- Handle — horizontal rectangle at the value position
    local handleY = by + bh - bh * v - 3
    local handleH = 6
    local handleW = bw - 4
    local handleX = bx + 2
    Theme.rect(handleX, handleY, handleW, handleH, Theme.TEXT)
    Theme.outline(handleX, handleY, handleW, handleH, color)
  else
    -- Horizontal
    local trackY = by + bh // 2
    graphics.setColor(Theme.ELEVATED)
    graphics.drawLine(bx, trackY,     bx + bw, trackY)
    graphics.drawLine(bx, trackY - 1, bx + bw, trackY - 1)
    graphics.drawLine(bx, trackY + 1, bx + bw, trackY + 1)

    graphics.setColor(color)
    if bipolar then
      local mid = bx + bw / 2
      local posX = bx + bw * v
      local x0 = math.min(mid, posX)
      local x1 = math.max(mid, posX)
      graphics.drawLine(x0, trackY,     x1, trackY)
      graphics.drawLine(x0, trackY - 1, x1, trackY - 1)
      graphics.drawLine(x0, trackY + 1, x1, trackY + 1)
      graphics.setColor(Theme.BORDER)
      graphics.drawLine(mid, by, mid, by + bh)
    else
      local x0 = bx
      local x1 = bx + bw * v
      graphics.drawLine(x0, trackY,     x1, trackY)
      graphics.drawLine(x0, trackY - 1, x1, trackY - 1)
      graphics.drawLine(x0, trackY + 1, x1, trackY + 1)
    end

    -- Handle — vertical rectangle at the value position
    local handleX = bx + bw * v - 3
    local handleW = 6
    local handleY = by + 2
    local handleH = bh - 4
    Theme.rect(handleX, handleY, handleW, handleH, Theme.TEXT)
    Theme.outline(handleX, handleY, handleW, handleH, color)
  end
end

return slider
