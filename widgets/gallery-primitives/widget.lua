-- Widget: Primitives Gallery
-- Dev reference — renders every primitive at various sizes, colours and
-- values so the primitive API can be QA'd visually.

local c = controls.get(1)

function paintGallery(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  Theme.text(20, 10, "PRIMITIVES v0.2 — knob · bar · led · meter · slider", Theme.TEXT)
  Theme.line(20, 28, W - 20, 28, Theme.BORDER)

  ------------------------------------------------------------------
  -- Knob row — thicker rings + indicator (v0.2)
  ------------------------------------------------------------------
  Theme.text(20, 40, "KNOB — rotary, 270° sweep", Theme.TEXT_DIM)
  Theme.knob( 20, 58, 70, 0.00, { label = "OFF" })
  Theme.knob(110, 58, 70, 0.25, { label = "CUTOFF" })
  Theme.knob(200, 58, 70, 0.50, { label = "RES", color = Theme.ALERT })
  Theme.knob(290, 58, 70, 0.75, { label = "LFO", color = Theme.WARNING })
  Theme.knob(380, 58, 70, 1.00, { label = "DRIVE" })
  Theme.knob(470, 58, 70, 0.60, { label = "FBACK", color = Theme.POSITIVE })
  Theme.knob(560, 58, 70, 0.40, { label = "SPREAD", color = Theme.INFO })

  ------------------------------------------------------------------
  -- Slider row (h + bipolar + v)
  ------------------------------------------------------------------
  Theme.text(660, 40, "SLIDER — linear pot with handle", Theme.TEXT_DIM)
  Theme.slider(660, 58, 160, 28, 0.30, { label = "ATTACK", valueText = "12 ms",  ticks = 20 })
  Theme.slider(830, 58, 160, 28, 0.72, { label = "DECAY",  valueText = "180 ms", ticks = 20, color = Theme.WARNING })
  Theme.slider(660, 94, 160, 28, 0.30, { label = "PAN L→R", valueText = "-20%", ticks = 10, bipolar = true, color = Theme.INFO })
  Theme.slider(830, 94, 160, 28, 0.80, { label = "DETUNE",  valueText = "+12c", ticks = 10, bipolar = true, color = Theme.POSITIVE })

  ------------------------------------------------------------------
  -- Bar row
  ------------------------------------------------------------------
  Theme.text(20, 170, "BAR — horizontal fill (0 → value)", Theme.TEXT_DIM)
  Theme.bar( 20, 188, 180, 28, 0.30, { label = "INPUT",   valueText = "-12 dB" })
  Theme.bar(220, 188, 180, 28, 0.80, { label = "OUTPUT",  valueText = "-3 dB",  color = Theme.WARNING })
  Theme.bar(420, 188, 180, 28, 0.95, { label = "PEAK",    valueText = "+2 dB",  color = Theme.ALERT })
  Theme.bar(620, 188, 180, 28, 0.55, { label = "HEADRM",  valueText = "OK",     color = Theme.POSITIVE })

  ------------------------------------------------------------------
  -- Meter row (h + v)
  ------------------------------------------------------------------
  Theme.text(20, 240, "METER — VU with graduation + zones", Theme.TEXT_DIM)
  Theme.meter( 20, 258, 220, 32, 0.35, { label = "L",  valueText = "-14",           ticks = 8 })
  Theme.meter(260, 258, 220, 32, 0.82, { label = "R",  valueText = "-1",  peak = 0.88, ticks = 8 })
  Theme.meter(500, 258, 220, 32, 0.95, { label = "SUM",valueText = "+2",  peak = 0.97, ticks = 10 })

  -- Vertical meters cluster
  Theme.meter(760,  42, 40, 248, 0.65, { orientation = "v", ticks = 10, valueText = "L" })
  Theme.meter(810,  42, 40, 248, 0.88, { orientation = "v", ticks = 10, valueText = "R", peak = 0.92 })
  Theme.meter(860,  42, 40, 248, 0.30, { orientation = "v", ticks = 10, valueText = "C" })
  Theme.meter(910,  42, 40, 248, 0.97, { orientation = "v", ticks = 10, valueText = "S", peak = 0.99 })

  ------------------------------------------------------------------
  -- LED row
  ------------------------------------------------------------------
  Theme.text(20, 310, "LED — status indicator", Theme.TEXT_DIM)
  Theme.led( 40, 332, true,  { label = "SYNC" })
  Theme.led(130, 332, false, { label = "MUTED" })
  Theme.led(220, 332, true,  { label = "REC",     color = Theme.ALERT })
  Theme.led(310, 332, true,  { label = "CLIP",    color = Theme.WARNING })
  Theme.led(400, 332, true,  { label = "PLAYING", color = Theme.POSITIVE })
  Theme.led(530, 332, true,  { label = "MIDI IN", color = Theme.INFO })
  -- Size variants
  Theme.led(660, 332, true, { size = 4 })
  Theme.led(690, 332, true, { size = 8 })
  Theme.led(730, 332, true, { size = 14 })

  ------------------------------------------------------------------
  -- Composition sample
  ------------------------------------------------------------------
  Theme.text(20, 378, "COMPOSITION — sample filter + compressor section", Theme.TEXT_DIM)

  -- Filter card
  Theme.card(20, 398, 380, 150)
  Theme.text(32, 412, "FILTER", Theme.TEXT)
  Theme.knob( 40, 432, 70, 0.68, { label = "FREQ" })
  Theme.knob(130, 432, 70, 0.42, { label = "Q" })
  Theme.knob(220, 432, 70, 0.15, { label = "DRIVE" })
  Theme.slider(310, 440, 70, 20, 0.75, { label = "MOD", ticks = 10 })
  Theme.slider(310, 476, 70, 20, 0.30, { label = "KEY", ticks = 10, color = Theme.INFO })
  Theme.led(35, 538, true, { size = 4, label = "LP24" })

  -- Compressor card
  Theme.card(420, 398, 380, 150)
  Theme.text(432, 412, "COMP", Theme.TEXT)
  Theme.knob(430, 432, 70, 0.55, { label = "THRESH" })
  Theme.knob(520, 432, 70, 0.30, { label = "RATIO" })
  Theme.knob(610, 432, 70, 0.72, { label = "ATK", color = Theme.WARNING })
  Theme.meter(700, 420, 92, 48, 0.85, { orientation = "h", ticks = 6, label = "GR",    valueText = "-6", peak = 0.90, color = Theme.POSITIVE })
  Theme.meter(700, 480, 92, 48, 0.75, { orientation = "h", ticks = 6, label = "OUT",   valueText = "-3", peak = 0.82 })

  -- Meters-only card (stereo master)
  Theme.card(820, 398, 180, 150)
  Theme.text(832, 412, "MASTER", Theme.TEXT)
  Theme.meter(840, 430, 28, 110, 0.68, { orientation = "v", ticks = 10, valueText = "L" })
  Theme.meter(878, 430, 28, 110, 0.72, { orientation = "v", ticks = 10, valueText = "R", peak = 0.80 })
  Theme.slider(920, 430, 32, 110, 0.55, { orientation = "v", ticks = 20, color = Theme.ACCENT })
end

function preset.onLoad()
  c:setBounds({0, 0, 1016, 560})
  c:setPaintCallback(paintGallery)
end
