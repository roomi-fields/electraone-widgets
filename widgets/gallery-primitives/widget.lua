-- Widget: Primitives Gallery
-- Dev reference — renders every primitive so the API can be QA'd visually.

local c = controls.get(1)

-- Sample envelope points for the graph showcase (AD → S → R curve)
local ENV_POINTS = {
  {0.00, 0.00}, {0.12, 1.00}, {0.30, 0.70}, {0.70, 0.70}, {1.00, 0.00}
}

-- Sample LFO shape (sine)
local LFO_POINTS = {}
for i = 0, 40 do
  LFO_POINTS[#LFO_POINTS + 1] = { i / 40, 0.5 + 0.4 * math.sin(i / 40 * math.pi * 4) }
end

-- Sample step-sequencer cells (8 steps × 2 rows, velocity 0..1)
local STEP_CELLS = {
  -- row 1 (kick)
  1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0,
  -- row 2 (hat)
  0.3, 0.9, 0.3, 0.9, 0.3, 0.9, 0.3, 0.6,
}

function paintGallery(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  Theme.text(20, 10, "PRIMITIVES v0.3 — knob · bar · led · meter · slider · readout · graph · grid", Theme.TEXT)
  Theme.line(20, 28, W - 20, 28, Theme.BORDER)

  ------------------------------------------------------------------
  -- Row 1: knobs + sliders
  ------------------------------------------------------------------
  Theme.text(20, 40, "KNOB + SLIDER", Theme.TEXT_DIM)
  Theme.knob( 20, 58, 70, 0.68, { label = "CUTOFF" })
  Theme.knob(110, 58, 70, 0.42, { label = "RES",   color = Theme.ALERT })
  Theme.knob(200, 58, 70, 0.30, { label = "DRIVE", color = Theme.WARNING })

  Theme.slider(300, 58, 140, 28, 0.35, { label = "ATTACK", valueText = "12 ms", ticks = 20 })
  Theme.slider(450, 58, 140, 28, 0.30, { label = "PAN",    valueText = "-20",   ticks = 10, bipolar = true, color = Theme.INFO })

  Theme.slider(600,  58, 30, 110, 0.62, { orientation = "v", ticks = 20, color = Theme.ACCENT })
  Theme.slider(640,  58, 30, 110, 0.45, { orientation = "v", ticks = 20, color = Theme.POSITIVE })

  ------------------------------------------------------------------
  -- Row 2: bars + meters + leds + readout
  ------------------------------------------------------------------
  Theme.text(20, 190, "BAR + METER + LED + READOUT", Theme.TEXT_DIM)
  Theme.bar( 20, 208, 150, 26, 0.30, { label = "INPUT",  valueText = "-12" })
  Theme.bar(180, 208, 150, 26, 0.80, { label = "OUTPUT", valueText = "-3",  color = Theme.WARNING })

  Theme.meter(340, 208, 180, 26, 0.95, { ticks = 20, label = "L", valueText = "+2 dB", peak = 0.97 })
  Theme.meter(530, 208, 180, 26, 0.60, { ticks = 20, label = "R", valueText = "-6 dB" })

  Theme.led(740, 220, true,  { label = "SYNC" })
  Theme.led(820, 220, true,  { label = "REC",  color = Theme.ALERT })
  Theme.led(910, 220, true,  { label = "CLIP", color = Theme.WARNING })

  -- Readouts cluster
  Theme.readout(720, 60, { label = "BPM",    value = "128",    unit = "",    color = Theme.ACCENT })
  Theme.readout(820, 60, { label = "KEY",    value = "A♭ min", color = Theme.TEXT })
  Theme.readout(720, 110, { label = "TIME",   value = "4/4",   color = Theme.TEXT_DIM })
  Theme.readout(820, 110, { label = "OUTPUT", value = "-6.0",  unit = "dB", color = Theme.POSITIVE })

  ------------------------------------------------------------------
  -- Row 3: graph showcase
  ------------------------------------------------------------------
  Theme.text(20, 248, "GRAPH — envelope + LFO traces", Theme.TEXT_DIM)
  Theme.graph( 20, 266, 240, 88, ENV_POINTS, { color = Theme.ACCENT, fill = true, grid = 4 })
  Theme.text(260, 356, "ADSR", Theme.TEXT_DIM)

  Theme.graph(320, 266, 340, 88, LFO_POINTS, { color = Theme.INFO, grid = 4 })
  Theme.text(660, 356, "LFO sine × 4 cycles", Theme.TEXT_DIM)

  ------------------------------------------------------------------
  -- Row 4: grid showcase (step seq)
  ------------------------------------------------------------------
  Theme.text(20, 380, "GRID — step sequencer (8 steps × 2 rows, active step 5)", Theme.TEXT_DIM)
  Theme.grid(20, 398, 640, 60, 8, 2, STEP_CELLS, { active = 5 })

  -- Right side: composition card using everything at once
  Theme.text(690, 380, "COMPOSITION", Theme.TEXT_DIM)
  Theme.card(690, 398, 310, 150)
  Theme.text(702, 412, "TRACK 01", Theme.TEXT)

  Theme.knob(700, 432, 60, 0.62, { label = "VOL" })
  Theme.knob(770, 432, 60, 0.50, { label = "PAN", color = Theme.INFO })
  Theme.meter(840, 430, 20, 94, 0.80, { orientation = "v", ticks = 20, peak = 0.86 })
  Theme.meter(870, 430, 20, 94, 0.76, { orientation = "v", ticks = 20, peak = 0.82 })

  Theme.slider(910, 430, 28, 94, 0.62, { orientation = "v", ticks = 20, color = Theme.ACCENT })
  Theme.led(960, 450, true, { size = 4, color = Theme.POSITIVE })
  Theme.led(960, 470, true, { size = 4, color = Theme.ALERT })
  Theme.led(960, 490, false, { size = 4 })
  Theme.readout(955, 510, { label = "", value = "01", color = Theme.ACCENT })
end

function preset.onLoad()
  c:setBounds({0, 0, 1016, 560})
  c:setPaintCallback(paintGallery)
end
