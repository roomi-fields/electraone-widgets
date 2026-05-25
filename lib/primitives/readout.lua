-- electraone-widgets · primitive: readout
-- Typography-driven value display. Dominant value in primary text, label
-- above in dim grey, unit suffix in dim grey on the right of the value.
-- Requires Theme.
--
-- Usage:
--   Theme.readout(x, y, {
--     label = "CUTOFF",      -- tiny caption above
--     value = "5,280",       -- large primary value (any string)
--     unit  = "Hz",          -- optional dim suffix
--     color = Theme.ACCENT,  -- value colour (default TEXT)
--     align = "l" | "r",     -- text anchor at (x,y) — default "l"
--   })

local function readout(x, y, opts)
  opts = opts or {}
  local label = opts.label
  local value = tostring(opts.value or "")
  local unit = opts.unit
  local color = opts.color or Theme.TEXT
  local align = opts.align or "l"

  if label then
    graphics.setColor(Theme.TEXT_DIM)
    graphics.print(x, y, label, 9999, LEFT)
  end

  -- We don't have access to font metrics on the MK2 so character width is
  -- approximated at 8px for the big readout (assumes default system font).
  local valueW = #value * 8
  local unitW  = unit and (#unit * 6 + 4) or 0
  local totalW = valueW + unitW
  local startX = (align == "r") and (x - totalW) or x
  local valueY = label and (y + 12) or y

  graphics.setColor(color)
  graphics.print(startX, valueY, value, 9999, LEFT)

  if unit then
    graphics.setColor(Theme.TEXT_DIM)
    graphics.print(startX + valueW + 4, valueY + 4, unit, 9999, LEFT)
  end
end

return readout
