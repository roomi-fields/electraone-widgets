-- electraone-widgets · primitive: led
-- Status indicator dot with optional glow halo when on.
--
-- Usage:
--   Theme.led(cx, cy, on, {
--     color = Theme.POSITIVE,   -- on-state colour (default POSITIVE)
--     size = 6,                 -- radius (default 6)
--     label = "SYNC",           -- caption to the right (optional)
--   })
-- (cx, cy) is the LED centre.

local function led(cx, cy, on, opts)
  opts = opts or {}
  local color = opts.color or Theme.POSITIVE
  local r = opts.size or 6
  local label = opts.label

  if on then
    -- Glow halo — slightly larger, same colour but we rely on the MK2's
    -- lack of anti-aliasing to give it that blown-pixel feel.
    graphics.setColor(color)
    graphics.fillCircle(cx, cy, r + 2)
    graphics.setColor(Theme.TEXT)
    graphics.fillCircle(cx, cy, r - 2)
  else
    graphics.setColor(Theme.ELEVATED)
    graphics.fillCircle(cx, cy, r)
    graphics.setColor(Theme.BORDER)
    graphics.drawCircle(cx, cy, r)
  end

  if label then
    graphics.setColor(on and Theme.TEXT or Theme.TEXT_DIM)
    graphics.print(cx + r + 6, cy - 5, label, 9999, LEFT)
  end
end

return led
