-- Widget: Theme Gallery
-- Dev reference — paints the whole Theme palette + sample typography.
-- Not intended for musical use; ship in the repo so we can visually QA
-- the design system in the emulator.

local c = controls.get(1)

-- Palette rows as (label, color) pairs
local NEUTRALS = {
  {"BG",       Theme.BG},
  {"SURFACE",  Theme.SURFACE},
  {"BORDER",   Theme.BORDER},
  {"MUTED",    Theme.MUTED},
  {"TEXT",     Theme.TEXT},
}

local ACCENTS = {
  {"TEAL",     Theme.TEAL},
  {"CORAL",    Theme.CORAL},
  {"AMBER",    Theme.AMBER},
  {"VIOLET",   Theme.VIOLET},
  {"LIME",     Theme.LIME},
  {"CYAN",     Theme.CYAN},
}

local function paintSwatchRow(x, y, items, cellW, cellH)
  for i, item in ipairs(items) do
    local name, color = item[1], item[2]
    local cx = x + (i - 1) * (cellW + 8)
    Theme.rect(cx, y, cellW, cellH, color)
    Theme.outline(cx, y, cellW, cellH, Theme.BORDER)
    Theme.text(cx + 6, y + cellH + 4, name, Theme.MUTED)
  end
end

function paintGallery(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Section title
  Theme.text(20, 12, "Theme Gallery — electraone-widgets v0.1", Theme.TEXT)
  Theme.line(20, 30, W - 20, 30, Theme.BORDER)

  -- Neutrals row
  Theme.text(20, 50, "Neutrals", Theme.MUTED)
  paintSwatchRow(20, 70, NEUTRALS, 100, 80)

  -- Accents row
  Theme.text(20, 180, "Accents", Theme.MUTED)
  paintSwatchRow(20, 200, ACCENTS, 100, 80)

  -- Card showcase
  Theme.text(20, 310, "Card primitive", Theme.MUTED)
  Theme.card(20, 330, 200, 90)
  Theme.text(32, 348, "CUTOFF", Theme.MUTED)
  Theme.text(32, 376, "72", Theme.TEAL)
  Theme.text(32, 404, "% modulation", Theme.MUTED)

  Theme.card(240, 330, 200, 90)
  Theme.text(252, 348, "RESONANCE", Theme.MUTED)
  Theme.text(252, 376, "48", Theme.CORAL)
  Theme.text(252, 404, "over-threshold", Theme.MUTED)

  Theme.card(460, 330, 200, 90)
  Theme.text(472, 348, "LFO RATE", Theme.MUTED)
  Theme.text(472, 376, "2.4 Hz", Theme.AMBER)
  Theme.text(472, 404, "sync off", Theme.MUTED)

  -- Line styles
  Theme.text(20, 440, "Line weights", Theme.MUTED)
  Theme.line(20, 468, 980, 468, Theme.BORDER)
  Theme.line(20, 482, 980, 482, Theme.MUTED)
  Theme.line(20, 496, 980, 496, Theme.TEAL)
  Theme.line(20, 510, 980, 510, Theme.TEXT)

  -- Typography sample
  Theme.text(20, 526, "TYPE — labels in MUTED, values in accent, large white for primary readouts", Theme.MUTED)
end

function preset.onLoad()
  c:setBounds({0, 0, 1016, 560})
  c:setPaintCallback(paintGallery)
end
