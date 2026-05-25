-- electraone-widgets · Theme v0.3
-- Modern visual language for Electra One MK2 widgets.
-- Classic pro-audio combination: cool slate neutrals (echoes the MK2's
-- brushed aluminum anodised case) + warm amber-terracotta signature
-- (echoes the Electra logo). Like SSL blue on gunmetal, or Teenage
-- Engineering orange on grey.
-- Copy this module to the top of your widget.lua to reuse it; the emulator
-- pre-loads it automatically.

Theme = Theme or {}

-- ========== Version ==========
-- Widgets declare which Theme version they were written against via
--   Theme.require("0.3")
-- at the top of their widget.lua. Bumps to this number signal a breaking
-- change in the palette, primitive APIs, or both — widgets pinned to an
-- older version should be audited before they render on the new Theme.
Theme.VERSION = "0.3"

function Theme.require(expected)
  if Theme.VERSION ~= expected then
    error(string.format(
      "This widget was written for Theme v%s but the loaded Theme is v%s — review widget.lua for API changes.",
      tostring(expected), tostring(Theme.VERSION)))
  end
end

-- ========== Palette — RGB888 (24-bit) ==========
-- The firmware (4.1.4+) accepts 0xRRGGBB values directly and converts to
-- the panel's native RGB565 internally. The release notes for v4.1.4
-- specifically fixed the RGB888→RGB565 translation for preset bank
-- colours, confirming RGB888 is the expected input format.
--
-- Neutrals: cool slate hierarchy, blue-undertoned. Matches the MK2's
-- brushed aluminum anodised enclosure so the screen feels continuous
-- with the device edge.
Theme.CANVAS    = 0x0A0D11   -- page base, deep slate-black
Theme.SURFACE   = 0x14181E   -- card / tile, charcoal slate
Theme.ELEVATED  = 0x232830   -- raised / active, brushed steel
Theme.BORDER    = 0x3A4048   -- hairline, steel edge
Theme.TEXT_DIM  = 0x9098A3   -- secondary text, cool silver
Theme.TEXT      = 0xE8EBF0   -- primary text, cool off-white

-- Accents: warm-on-cold signature. Amber-terracotta hero accent reads
-- like a VU-meter needle or an OP-1 encoder knob against cool slate.
Theme.ACCENT         = 0xE5823E   -- primary: active, modulation
Theme.ACCENT_DIM     = 0x8F5129   -- deep copper: inactive variant
Theme.WARNING        = 0xF5C64A   -- vintage VU yellow: peak-hold
Theme.ALERT          = 0xEB5757   -- red: over-threshold, critical
Theme.POSITIVE       = 0x7EC699   -- cool sage: in-range, confirmed
Theme.INFO           = 0x5B8FD4   -- steel blue: informational
Theme.NEUTRAL_ACCENT = 0x6B7384   -- cool grey-blue: disabled

-- ========== Drawing helpers ==========
-- Thin wrappers around graphics.* so widget code stays declarative.
-- IMPORTANT: do NOT cache `graphics` to a local upvalue — the firmware
-- (and our IIFE-free bundle layout) doesn't reliably keep upvalues alive
-- across paint dispatch. Reference `graphics` directly inside each helper.

-- The firmware's graphics primitives require integer coordinates; passing
-- a float (e.g. from a division) raises "number has no integer
-- representation". math.floor on every coord keeps things safe.

function Theme.rect(x, y, w, h, color)
  graphics.setColor(color)
  graphics.fillRect(math.floor(x), math.floor(y), math.floor(w), math.floor(h))
end

function Theme.outline(x, y, w, h, color)
  graphics.setColor(color)
  graphics.drawRect(math.floor(x), math.floor(y), math.floor(w), math.floor(h))
end

function Theme.roundRect(x, y, w, h, r, color)
  graphics.setColor(color)
  graphics.fillRoundRect(math.floor(x), math.floor(y), math.floor(w), math.floor(h), math.floor(r))
end

function Theme.line(x1, y1, x2, y2, color)
  graphics.setColor(color)
  graphics.drawLine(math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2))
end

function Theme.text(x, y, str, color)
  graphics.setColor(color)
  graphics.print(math.floor(x), math.floor(y), tostring(str), 9999, LEFT)
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
