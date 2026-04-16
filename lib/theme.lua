-- electraone-widgets · Theme v0.2
-- Modern visual language for Electra One MK2 widgets.
-- Palette aligned with Electra One's own brand (their signature #D66448
-- terracotta) and 2026 design trends (warm neutrals, jewel-inspired
-- secondary accents, no neon).
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
-- Warm-tilted dark hierarchy, not pure greys. Aligns with Electra's own
-- charcoals and the 2026 "elevated neutrals" trend (warm sand / taupe).
Theme.CANVAS    = Theme.hex(0x0F0D0C)  -- page base, canvas outer
Theme.SURFACE   = Theme.hex(0x1C1917)  -- card / tile surface
Theme.ELEVATED  = Theme.hex(0x2B2622)  -- raised element / active card
Theme.BORDER    = Theme.hex(0x3F3A35)  -- hairline divider, subtle outline
Theme.TEXT_DIM  = Theme.hex(0xA39A90)  -- secondary text, labels, units
Theme.TEXT      = Theme.hex(0xF0E9DF)  -- primary text (warm off-white)

-- ========== Palette — accents ==========
-- Signature hero colour = Electra's own #D66448 terracotta.
-- Secondary accents pulled from their own UI bundle for continuity.
Theme.ACCENT         = Theme.hex(0xD66448)  -- primary: active controls, modulation
Theme.ACCENT_DIM     = Theme.hex(0xA64D36)  -- inactive / low-intensity variant
Theme.WARNING        = Theme.hex(0xE8B04C)  -- warm gold: warn-zone, peak-hold
Theme.ALERT          = Theme.hex(0xE54D42)  -- deep coral: over-threshold, critical
Theme.POSITIVE       = Theme.hex(0x6A8E5C)  -- sage désaturé: in-range, confirmed
Theme.INFO           = Theme.hex(0x4A7EA8)  -- muted sapphire (jewel): informational
Theme.NEUTRAL_ACCENT = Theme.hex(0x8C7D6B)  -- warm taupe: disabled, sparkline

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
