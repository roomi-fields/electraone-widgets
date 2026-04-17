-- electraone-widgets · primitive: button
-- Console-tile style toggle / momentary button — SSL-inspired. The body
-- is a fixed dark slab (ELEVATED) wrapped in a machined-metal double-
-- stroke frame, carrying an LED window across the top that lights up in
-- a semantic colour when state is true. For momentary presses, pass
-- `flashing = true` and the whole body flips to WARNING amber with the
-- label inverted to CANVAS black — a hardware "pressed hard" feel.
-- Requires Theme.
--
-- Usage:
--   Theme.button(x, y, w, h, {
--     label = "RUN",
--     state = true,           -- toggle state (ignored for momentary)
--     color = Theme.POSITIVE, -- LED window colour when state=true
--     flashing = false,       -- momentary: force pressed look
--   })

local function button(x, y, w, h, opts)
  opts = opts or {}
  local label = opts.label or ""
  local state = opts.state
  local color = opts.color or Theme.ACCENT
  local flashing = opts.flashing

  -- Momentary pressed look: full WARNING body + inverted label
  if flashing then
    Theme.outline(x,     y,     w,     h,     Theme.BORDER)
    Theme.outline(x + 2, y + 2, w - 4, h - 4, Theme.BORDER)
    Theme.rect   (x + 3, y + 3, w - 6, h - 6, Theme.WARNING)
    local tw = #label * 6
    local lx = x + (w - tw) / 2
    local ly = y + h / 2 - 5
    graphics.setColor(Theme.CANVAS)
    graphics.drawText(lx,     ly, label)
    graphics.drawText(lx + 1, ly, label)
    return
  end

  -- Machined-metal double-stroke frame (outer + inner, 1px gap between)
  Theme.outline(x,     y,     w,     h,     Theme.BORDER)
  Theme.outline(x + 2, y + 2, w - 4, h - 4, Theme.BORDER)

  -- Inner body — brushed-steel ELEVATED fill
  local bx, by, bw, bh = x + 3, y + 3, w - 6, h - 6
  Theme.rect(bx, by, bw, bh, Theme.ELEVATED)

  -- Top LED window — 10px tall strip (scaled for compact button sizes)
  local winH = 10
  local winColor = state and color or Theme.CANVAS
  Theme.rect(bx, by, bw, winH, winColor)
  -- 1px BORDER separator between window and label area
  graphics.setColor(Theme.BORDER)
  graphics.drawLine(bx, by + winH, bx + bw - 1, by + winH)

  -- Label — centred in the area below the window, double-drawn for weight
  local labelAreaY = by + winH + 1
  local labelAreaH = bh - winH - 1
  local tw = #label * 6
  local lx = x + (w - tw) / 2
  local ly = labelAreaY + (labelAreaH - 10) / 2
  graphics.setColor(state and Theme.TEXT or Theme.TEXT_DIM)
  graphics.drawText(lx,     ly, label)
  graphics.drawText(lx + 1, ly, label)
end

return button
