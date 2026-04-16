-- Widget: Theme Gallery
-- Dev reference — visualises the whole Theme palette + sample typography.
-- Paste lib/theme.lua at top for device deployment; the emulator pre-loads it.

local c = controls.get(1)

-- Palette rows
local NEUTRALS = {
  {"CANVAS",     Theme.CANVAS,     "0F0D0C", "page base"},
  {"SURFACE",    Theme.SURFACE,    "1C1917", "card/tile"},
  {"ELEVATED",   Theme.ELEVATED,   "2B2622", "raised"},
  {"BORDER",     Theme.BORDER,     "3F3A35", "divider"},
  {"TEXT_DIM",   Theme.TEXT_DIM,   "A39A90", "2nd text"},
  {"TEXT",       Theme.TEXT,       "F0E9DF", "primary"},
}

local ACCENTS = {
  {"ACCENT",         Theme.ACCENT,         "D66448", "modulation"},
  {"ACCENT_DIM",     Theme.ACCENT_DIM,     "A64D36", "inactive"},
  {"WARNING",        Theme.WARNING,        "E8B04C", "peak-hold"},
  {"ALERT",          Theme.ALERT,          "E54D42", "over-thresh"},
  {"POSITIVE",       Theme.POSITIVE,       "6A8E5C", "in-range"},
  {"INFO",           Theme.INFO,           "4A7EA8", "info"},
  {"NEUTRAL_ACCENT", Theme.NEUTRAL_ACCENT, "8C7D6B", "sparkline"},
}

local function paintSwatchRow(startX, startY, items, cellW, cellH, gap)
  for i, item in ipairs(items) do
    local name, color, hex, use = item[1], item[2], item[3], item[4]
    local x = startX + (i - 1) * (cellW + gap)
    -- swatch
    Theme.rect(x, startY, cellW, cellH, color)
    Theme.outline(x, startY, cellW, cellH, Theme.BORDER)
    -- name + hex underneath
    Theme.text(x, startY + cellH + 4, name, Theme.TEXT)
    Theme.text(x, startY + cellH + 18, "#" .. hex, Theme.TEXT_DIM)
    Theme.text(x, startY + cellH + 32, use, Theme.TEXT_DIM)
  end
end

function paintGallery(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 14, "THEME v0.2 — electraone-widgets", Theme.TEXT)
  Theme.text(20, 30, "Aligned with Electra One brand (signature #D66448) + 2026 trends", Theme.TEXT_DIM)
  Theme.line(20, 48, W - 20, 48, Theme.BORDER)

  -- Neutrals
  Theme.text(20, 64, "NEUTRALS", Theme.TEXT_DIM)
  paintSwatchRow(20, 80, NEUTRALS, 120, 60, 12)

  -- Accents
  Theme.text(20, 200, "ACCENTS", Theme.TEXT_DIM)
  paintSwatchRow(20, 216, ACCENTS, 120, 60, 12)

  -- Card showcase — 3 sample tiles
  Theme.text(20, 340, "CARD PRIMITIVE — sample widget compositions", Theme.TEXT_DIM)

  -- card 1: value in ACCENT (normal)
  Theme.card(20, 360, 200, 100)
  Theme.text(32, 378, "CUTOFF", Theme.TEXT_DIM)
  Theme.text(32, 402, "72", Theme.ACCENT)
  Theme.text(32, 436, "% modulation", Theme.TEXT_DIM)
  Theme.rect(32, 446, 120, 4, Theme.ELEVATED)
  Theme.rect(32, 446, 87, 4, Theme.ACCENT)

  -- card 2: value in ALERT (over-threshold)
  Theme.card(240, 360, 200, 100)
  Theme.text(252, 378, "RESONANCE", Theme.TEXT_DIM)
  Theme.text(252, 402, "+4.2", Theme.ALERT)
  Theme.text(252, 436, "dB — limiting", Theme.TEXT_DIM)
  Theme.rect(252, 446, 120, 4, Theme.ELEVATED)
  Theme.rect(252, 446, 118, 4, Theme.ALERT)

  -- card 3: value in WARNING (warm zone)
  Theme.card(460, 360, 200, 100)
  Theme.text(472, 378, "LFO RATE", Theme.TEXT_DIM)
  Theme.text(472, 402, "2.4 Hz", Theme.WARNING)
  Theme.text(472, 436, "sync off", Theme.TEXT_DIM)
  Theme.rect(472, 446, 120, 4, Theme.ELEVATED)
  Theme.rect(472, 446, 60, 4, Theme.WARNING)

  -- card 4: value in POSITIVE (in-range)
  Theme.card(680, 360, 200, 100)
  Theme.text(692, 378, "THRESHOLD", Theme.TEXT_DIM)
  Theme.text(692, 402, "-18", Theme.POSITIVE)
  Theme.text(692, 436, "dB — clean", Theme.TEXT_DIM)
  Theme.rect(692, 446, 120, 4, Theme.ELEVATED)
  Theme.rect(692, 446, 45, 4, Theme.POSITIVE)

  -- Footer typography sample
  Theme.line(20, 480, W - 20, 480, Theme.BORDER)
  Theme.text(20, 492, "Typography — labels TEXT_DIM, values in semantic accent, chrome TEXT.", Theme.TEXT_DIM)
  Theme.text(20, 508, "No gradients (LCD flattens them), 2px strokes, warm-tilted greys.", Theme.TEXT_DIM)
  Theme.text(20, 524, "Primary reads in warm off-white #F0E9DF — never harsh pure white.", Theme.TEXT_DIM)
end

function preset.onLoad()
  c:setBounds({0, 0, 1016, 560})
  c:setPaintCallback(paintGallery)
end
