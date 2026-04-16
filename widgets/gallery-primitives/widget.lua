-- Widget: Primitives Gallery
-- Dev reference — renders every primitive at various sizes, colours and
-- values so we can QA the primitive API visually.

local c = controls.get(1)

function paintGallery(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  Theme.text(20, 14, "PRIMITIVES v0.1 — knob · bar · led", Theme.TEXT)
  Theme.text(20, 30, "3 primitives in this pass. meter / arc / readout / graph / grid to follow.", Theme.TEXT_DIM)
  Theme.line(20, 48, W - 20, 48, Theme.BORDER)

  ------------------------------------------------------------------
  -- Knob row
  ------------------------------------------------------------------
  Theme.text(20, 64, "KNOB — rotary, 270° sweep", Theme.TEXT_DIM)

  Theme.knob( 20,  84, 80, 0.00, { label = "OFF"                                 })
  Theme.knob(120,  84, 80, 0.25, { label = "CUTOFF"                              })
  Theme.knob(220,  84, 80, 0.50, { label = "RESONANCE", color = Theme.ALERT      })
  Theme.knob(320,  84, 80, 0.75, { label = "LFO RATE",  color = Theme.WARNING    })
  Theme.knob(420,  84, 80, 1.00, { label = "DRIVE"                               })
  Theme.knob(520,  84, 80, 0.60, { label = "FEEDBACK",  color = Theme.POSITIVE   })
  Theme.knob(620,  84, 80, 0.40, { label = "SPREAD",    color = Theme.INFO       })

  -- Size variants
  Theme.text(740, 64, "SIZES", Theme.TEXT_DIM)
  Theme.knob(740,  84, 50, 0.65, { label = "50" })
  Theme.knob(800,  84, 80, 0.65, { label = "80" })
  Theme.knob(900, 84, 100, 0.65, { label = "100" })

  ------------------------------------------------------------------
  -- Bar row
  ------------------------------------------------------------------
  Theme.text(20, 230, "BAR — horizontal value fill", Theme.TEXT_DIM)

  Theme.bar(20, 250, 200, 34, 0.30, { label = "INPUT",      valueText = "-12 dB"                          })
  Theme.bar(240, 250, 200, 34, 0.80, { label = "OUTPUT",    valueText = "-3 dB",   color = Theme.WARNING  })
  Theme.bar(460, 250, 200, 34, 0.95, { label = "PEAK",      valueText = "+2 dB",   color = Theme.ALERT    })
  Theme.bar(680, 250, 200, 34, 0.55, { label = "HEADROOM",  valueText = "OK",      color = Theme.POSITIVE })

  ------------------------------------------------------------------
  -- LED row
  ------------------------------------------------------------------
  Theme.text(20, 310, "LED — status indicator", Theme.TEXT_DIM)

  Theme.led( 40, 340, true,  { label = "SYNC"                                })
  Theme.led(130, 340, false, { label = "MUTED"                               })
  Theme.led(220, 340, true,  { label = "REC",     color = Theme.ALERT        })
  Theme.led(310, 340, true,  { label = "CLIP",    color = Theme.WARNING      })
  Theme.led(400, 340, true,  { label = "PLAYING", color = Theme.POSITIVE     })
  Theme.led(530, 340, true,  { label = "MIDI IN", color = Theme.INFO         })

  -- Size variants
  Theme.text(640, 310, "SIZES", Theme.TEXT_DIM)
  Theme.led(660, 340, true, { size = 4 })
  Theme.led(690, 340, true, { size = 8 })
  Theme.led(730, 340, true, { size = 14 })
  Theme.led(780, 340, true, { size = 22 })

  ------------------------------------------------------------------
  -- Composition sample — what a real widget panel might look like
  ------------------------------------------------------------------
  Theme.text(20, 400, "COMPOSITION — sample filter section", Theme.TEXT_DIM)

  -- A "filter card" that composes knob + led + bar
  Theme.card(20, 420, 500, 130)
  Theme.text(32, 432, "FILTER", Theme.TEXT)

  Theme.knob( 40, 454, 70, 0.68, { label = "FREQ" })
  Theme.knob(130, 454, 70, 0.42, { label = "Q" })
  Theme.knob(220, 454, 70, 0.15, { label = "DRIVE" })

  Theme.bar(320, 460, 180, 14, 0.75, { label = "MOD DEPTH", valueText = "75%" })
  Theme.bar(320, 500, 180, 14, 0.30, { label = "KEY TRACK", valueText = "30%", color = Theme.INFO })

  Theme.led(460, 540, true, { size = 4, label = "LP24" })

  -- Second card — drive section
  Theme.card(540, 420, 460, 130)
  Theme.text(552, 432, "DRIVE", Theme.TEXT)

  Theme.knob(560, 454, 70, 0.85, { label = "AMT", color = Theme.WARNING })
  Theme.knob(650, 454, 70, 0.55, { label = "TONE" })

  Theme.bar(750, 460, 230, 14, 0.92, { label = "GAIN", valueText = "+8.4 dB", color = Theme.ALERT })
  Theme.bar(750, 500, 230, 14, 0.60, { label = "MIX",  valueText = "60%" })

  Theme.led(970, 540, true, { size = 4, color = Theme.ALERT, label = "CLIP" })
end

function preset.onLoad()
  c:setBounds({0, 0, 1016, 560})
  c:setPaintCallback(paintGallery)
end
