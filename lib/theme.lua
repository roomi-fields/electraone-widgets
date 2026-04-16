-- electraone-widgets · Theme v0.1
-- Modern visual language for Electra One MK2 widgets.
-- Copy this module to the top of your widget.lua to reuse the palette and
-- drawing helpers; the emulator pre-loads it automatically.

local Theme = {}

-- ========== Colour conversion ==========
-- Native MK2 colours are 16-bit RGB565. Convert from 8-bit components or from
-- a 0xRRGGBB integer you pasted from a web designer tool.

function Theme.rgb(r, g, b)
  local r5 = (r >> 3) & 0x1F
  local g6 = (g >> 2) & 0x3F
  local b5 = (b >> 3) & 0x1F
  return (r5 << 11) | (g6 << 5) | b5
end

function Theme.hex(h)
  return Theme.rgb((h >> 16) & 0xFF, (h >> 8) & 0xFF, h & 0xFF)
end

-- ========== Palette ==========
-- Neutrals
Theme.BG        = Theme.hex(0x0E0E11)  -- near-black, canvas base
Theme.SURFACE   = Theme.hex(0x1A1A22)  -- card / tile surface
Theme.BORDER    = Theme.hex(0x3A3A44)  -- hairline divider
Theme.MUTED     = Theme.hex(0x7A7A88)  -- secondary text / disabled
Theme.TEXT      = Theme.hex(0xE6E6E6)  -- primary text

-- Accents — use semantically, not decoratively
Theme.TEAL      = Theme.hex(0x00C7B7)  -- primary, modulation, safe
Theme.CORAL     = Theme.hex(0xFF5E5B)  -- alert, over-threshold
Theme.AMBER     = Theme.hex(0xFFB400)  -- warning, warm value
Theme.VIOLET    = Theme.hex(0x8B5CF6)  -- secondary accent
Theme.LIME      = Theme.hex(0xA3E635)  -- positive, in-range
Theme.CYAN      = Theme.hex(0x22D3EE)  -- info, informational

-- ========== Drawing helpers ==========
-- Thin wrappers around graphics.* so widget code stays declarative.

local g = graphics

function Theme.rect(x, y, w, h, color)
  g.setColor(color)
  g.fillRect(x, y, w, h)
end

function Theme.outline(x, y, w, h, color)
  g.setColor(color)
  g.drawRect(x, y, w, h)
end

function Theme.roundRect(x, y, w, h, r, color)
  g.setColor(color)
  g.fillRoundRect(x, y, w, h, r)
end

function Theme.line(x1, y1, x2, y2, color)
  g.setColor(color)
  g.drawLine(x1, y1, x2, y2)
end

function Theme.text(x, y, str, color)
  g.setColor(color)
  g.drawText(x, y, tostring(str))
end

-- ========== Composite ==========
-- A "card" is the base container for most widgets: filled surface + hairline
-- border. Use before drawing instrumentation on top.
function Theme.card(x, y, w, h)
  Theme.rect(x, y, w, h, Theme.SURFACE)
  Theme.outline(x, y, w, h, Theme.BORDER)
end

-- Clear the whole tile with the canvas base colour — call first in paint
-- callbacks to reset state.
function Theme.clear(w, h)
  Theme.rect(0, 0, w, h, Theme.BG)
end

return Theme
