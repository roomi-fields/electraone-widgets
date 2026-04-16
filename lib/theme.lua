-- electraone-widgets · Theme v0.3
-- Modern visual language for Electra One MK2 widgets.
-- Classic pro-audio combination: cool slate neutrals (echoes the MK2's
-- brushed aluminum anodised case) + warm amber-terracotta signature
-- (echoes the Electra logo). Like SSL blue on gunmetal, or Teenage
-- Engineering orange on grey.
-- Copy this module to the top of your widget.lua to reuse it; the emulator
-- pre-loads it automatically.

local Theme = {}

-- ========== Colour conversion ==========
-- Native MK2 colours are 16-bit RGB565. Convert from 8-bit components or
-- from a 0xRRGGBB integer.

function Theme.rgb(r, g, b)
  local r5 = (r >> 3) & 0x1F
  local g6 = (g >> 2) & 0x3F
  local b5 = (b >> 3) & 0x1F
  return (r5 << 11) | (g6 << 5) | b5
end

function Theme.hex(h)
  return Theme.rgb((h >> 16) & 0xFF, (h >> 8) & 0xFF, h & 0xFF)
end

-- ========== Palette — neutrals ==========
-- Cool slate hierarchy, blue-undertoned. Matches the MK2's brushed
-- aluminum anodised enclosure so the screen feels continuous with the
-- device edge.
Theme.CANVAS    = Theme.hex(0x0A0D11)  -- page base, deep slate-black
Theme.SURFACE   = Theme.hex(0x14181E)  -- card / tile, charcoal slate
Theme.ELEVATED  = Theme.hex(0x232830)  -- raised / active, brushed steel
Theme.BORDER    = Theme.hex(0x3A4048)  -- hairline, steel edge
Theme.TEXT_DIM  = Theme.hex(0x9098A3)  -- secondary text, cool silver
Theme.TEXT      = Theme.hex(0xE8EBF0)  -- primary text, cool off-white

-- ========== Palette — accents ==========
-- Signature is warm-on-cold: amber-terracotta hero accent reads like a
-- VU-meter needle or an OP-1 encoder knob against the cool slate chrome.
-- Warning keeps the warm family; Positive / Info shift cold for balance
-- and state-read clarity.
Theme.ACCENT         = Theme.hex(0xE5823E)  -- primary: active, modulation
Theme.ACCENT_DIM     = Theme.hex(0x8F5129)  -- deep copper: inactive variant
Theme.WARNING        = Theme.hex(0xF5C64A)  -- vintage VU yellow: peak-hold
Theme.ALERT          = Theme.hex(0xEB5757)  -- red: over-threshold, critical
Theme.POSITIVE       = Theme.hex(0x7EC699)  -- cool sage: in-range, confirmed
Theme.INFO           = Theme.hex(0x5B8FD4)  -- steel blue: informational
Theme.NEUTRAL_ACCENT = Theme.hex(0x6B7384)  -- cool grey-blue: disabled

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
-- Base container for most widgets: filled surface + hairline border.
function Theme.card(x, y, w, h)
  Theme.rect(x, y, w, h, Theme.SURFACE)
  Theme.outline(x, y, w, h, Theme.BORDER)
end

-- Clear the tile with canvas base — call first in paint callbacks.
function Theme.clear(w, h)
  Theme.rect(0, 0, w, h, Theme.CANVAS)
end

return Theme
