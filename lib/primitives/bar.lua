-- electraone-widgets · primitive: bar
-- Horizontal value bar with optional label. Minimal — for linear values
-- where a rotary knob would be too heavy.
--
-- Usage:
--   Theme.bar(x, y, w, h, value, {
--     color = Theme.ACCENT,   -- fill colour (default ACCENT)
--     label = "LEVEL",        -- caption above (optional)
--     valueText = "-6 dB",    -- right-aligned readout (optional)
--   })
-- `value` is 0..1.

local function bar(x, y, w, h, value, opts)
  opts = opts or {}
  local color = opts.color or Theme.ACCENT
  local v = math.max(0, math.min(1, value or 0))
  local label = opts.label
  local vtext = opts.valueText

  local barY = label and (y + 14) or y
  local barH = label and (h - 14) or h

  -- Track
  Theme.rect(x, barY, w, barH, Theme.ELEVATED)
  Theme.outline(x, barY, w, barH, Theme.BORDER)

  -- Fill
  local fillW = math.floor(w * v)
  if fillW > 0 then
    Theme.rect(x, barY, fillW, barH, color)
  end

  -- Label on top-left
  if label then
    graphics.setColor(Theme.TEXT_DIM)
    graphics.print(x, y, label, 9999, LEFT)
  end

  -- Value on top-right
  if vtext then
    graphics.setColor(Theme.TEXT)
    graphics.print(x + w - #vtext * 6, y, vtext, 9999, LEFT)
  end
end

return bar
