-- Widget: Arpeggiator Visualiser
-- Scrolling piano-roll view of a running arpeggiator — notes slide from
-- the right edge (freshly fired) to the left (falling off history). The
-- arp generates notes internally from a fixed demo chord + rate + pattern
-- so the widget demos cleanly without any MIDI input; on device you can
-- replace the internal clock with your DAW's tempo + an external chord.
--
-- Paste lib/theme.lua + lib/primitives/{knob,led,readout,button}.lua above
-- this code on the device. The emulator pre-loads them.

Theme.require("0.3")

-- ===== Geometry =====
local VIZ_X, VIZ_Y, VIZ_W, VIZ_H = 20, 44, 976, 320
local FOOTER_Y = 390
local KNOB_SIZE = 72
local KNOB_XS = { 40, 220, 400 }       -- RATE / GATE / OCTAVES
local PATTERN_BTN = { x = 600, y = FOOTER_Y, w = 170, h = 56, label = "" }
local LED_XY = { x = 820, y = FOOTER_Y + 8 }

-- ===== Arp config =====
-- Chord stays fixed for the demo: C minor 7 (C Eb G Bb) — looks lively
-- under all four patterns without needing user input.
local CHORD = { 60, 63, 67, 70 }   -- MIDI note numbers
local PATTERNS = { "UP", "DOWN", "UP-DN", "RAND" }

-- ===== State =====
local rate      = 0.45            -- 0..1 → rate knob
local gate      = 0.6             -- 0..1 → note length as fraction of step
local octaves   = 0.33            -- 0..1 → 1..4 octaves (actually snap to 1/2/3/4)
local patternIdx = 1              -- 1..4

local notes = {}                  -- { startMs, endMs, pitch, vel }
local currentMs = 0
local nextFireMs = 0
local seqIdx = 1                  -- position inside the pattern
local seqDir = 1                  -- for UP-DN
local ledFlash = 0                -- ms remaining while the LED glows

local dragging = nil
local DRAG_THRESHOLD = 4

local PARAM_RATE, PARAM_GATE, PARAM_OCT, PARAM_PAT = 1, 2, 3, 4

-- Visible pitch range — 3 octaves, C3..C6 (48..84)
local PITCH_MIN, PITCH_MAX = 48, 84
local TIME_WINDOW_MS = 3500       -- scroll window (~3.5s)

local arpControl = controls.get(1)

-- ===== Helpers =====
local function rateMs()
  -- 1000 ms (slow, ~60 BPM 16ths) down to 60 ms (fast, ~250 BPM 16ths)
  return 60 + (1 - rate) * 940
end

local function gateMs(stepMs)
  return math.max(20, stepMs * (0.15 + gate * 0.85))
end

local function octaveCount()
  -- map 0..1 → 1/2/3/4 octaves
  if octaves < 0.25 then return 1
  elseif octaves < 0.50 then return 2
  elseif octaves < 0.75 then return 3
  else return 4 end
end

-- Advance the pattern and return the next MIDI pitch, wrapping across the
-- configured octave count.
local function nextPitch()
  local oct = octaveCount()
  local L = #CHORD * oct
  local p
  if PATTERNS[patternIdx] == "UP" then
    p = seqIdx
    seqIdx = seqIdx + 1
    if seqIdx > L then seqIdx = 1 end
  elseif PATTERNS[patternIdx] == "DOWN" then
    p = L - seqIdx + 1
    seqIdx = seqIdx + 1
    if seqIdx > L then seqIdx = 1 end
  elseif PATTERNS[patternIdx] == "UP-DN" then
    p = seqIdx
    seqIdx = seqIdx + seqDir
    if seqIdx > L then seqIdx = L - 1; seqDir = -1
    elseif seqIdx < 1 then seqIdx = 2; seqDir = 1 end
  else  -- RAND
    p = math.random(1, L)
  end
  local noteIdx = ((p - 1) % #CHORD) + 1
  local octStep = math.floor((p - 1) / #CHORD)
  return CHORD[noteIdx] + octStep * 12
end

-- ===== Knobs =====
local function knobValue(i)
  if i == 1 then return rate
  elseif i == 2 then return gate
  elseif i == 3 then return octaves end
  return 0
end

local function setKnob(i, v)
  v = math.max(0, math.min(1, v))
  local pnum
  if     i == 1 then rate    = v; pnum = PARAM_RATE
  elseif i == 2 then gate    = v; pnum = PARAM_GATE
  elseif i == 3 then octaves = v; pnum = PARAM_OCT end
  if pnum then parameterMap.set(1, PT_VIRTUAL, pnum, math.floor(v * 127)) end
end

-- ===== Hit-testing =====
local function hitKnob(x, y)
  if y < FOOTER_Y or y > FOOTER_Y + KNOB_SIZE + 18 then return nil end
  for i = 1, 3 do
    local kx = KNOB_XS[i]
    if x >= kx and x <= kx + KNOB_SIZE then return i end
  end
  return nil
end

local function inBtn(btn, x, y)
  return x >= btn.x and x <= btn.x + btn.w
     and y >= btn.y and y <= btn.y + btn.h
end

-- ===== Paint =====
function paintArp(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 10, "ARP VIZ", Theme.TEXT_DIM)
  Theme.text(W - 240, 10, string.format("RATE %d ms", math.floor(rateMs())), Theme.TEXT_DIM)
  Theme.text(W - 110, 10, string.format("%d OCT", octaveCount()), Theme.ACCENT)
  Theme.line(20, 30, W - 20, 30, Theme.BORDER)

  -- Viz card
  Theme.rect(VIZ_X, VIZ_Y, VIZ_W, VIZ_H, Theme.SURFACE)
  Theme.outline(VIZ_X, VIZ_Y, VIZ_W, VIZ_H, Theme.BORDER)

  -- Horizontal guide lines — every octave. 3 octaves → 2 interior lines.
  graphics.setColor(Theme.ELEVATED)
  local pitchRange = PITCH_MAX - PITCH_MIN
  for octLine = PITCH_MIN + 12, PITCH_MAX - 1, 12 do
    local gy = VIZ_Y + VIZ_H - math.floor(VIZ_H * (octLine - PITCH_MIN) / pitchRange)
    graphics.drawLine(VIZ_X + 1, gy, VIZ_X + VIZ_W - 1, gy)
  end

  -- Vertical playhead at the right edge (where new notes appear)
  local phX = VIZ_X + VIZ_W - 2
  graphics.setColor(Theme.ACCENT)
  graphics.drawLine(phX,     VIZ_Y + 1, phX,     VIZ_Y + VIZ_H - 1)
  graphics.drawLine(phX + 1, VIZ_Y + 1, phX + 1, VIZ_Y + VIZ_H - 1)

  -- Notes — piano-roll rectangles. x = right edge minus age-proportional
  -- offset; width = duration on screen; y = pitch position; fill colour
  -- varies with age so older notes fade to ACCENT_DIM.
  for _, n in ipairs(notes) do
    local ageMs = currentMs - n.startMs
    local offPx  = math.floor(ageMs * VIZ_W / TIME_WINDOW_MS)
    local durPx  = math.max(2, math.floor((n.endMs - n.startMs) * VIZ_W / TIME_WINDOW_MS))
    local x1     = VIZ_X + VIZ_W - offPx - durPx
    if x1 + durPx > VIZ_X then
      local pitchRel = (n.pitch - PITCH_MIN) / pitchRange
      pitchRel = math.max(0, math.min(1, pitchRel))
      local noteH = 8
      local ny = VIZ_Y + VIZ_H - math.floor(VIZ_H * pitchRel) - noteH / 2
      -- Color: fresh → ACCENT, aging → ACCENT_DIM
      local freshness = 1 - ageMs / TIME_WINDOW_MS
      local fc = (freshness > 0.5) and Theme.ACCENT or Theme.ACCENT_DIM
      -- Clip left edge if note extends off-canvas
      local drawX = math.max(x1, VIZ_X + 1)
      local drawW = math.min(x1 + durPx, VIZ_X + VIZ_W - 1) - drawX
      if drawW > 0 then
        Theme.rect(drawX, ny, drawW, noteH, fc)
      end
    end
  end

  -- Pitch labels on the right edge of the viz
  graphics.setColor(Theme.TEXT_DIM)
  for _, midi in ipairs({ 48, 60, 72, 84 }) do
    local yy = VIZ_Y + VIZ_H - math.floor(VIZ_H * (midi - PITCH_MIN) / pitchRange) - 5
    local octLabel = "C" .. tostring(math.floor(midi / 12) - 1)
    graphics.drawText(VIZ_X + VIZ_W + 6, yy, octLabel)
  end

  -- Footer: 3 knobs + PATTERN button + activity LED
  local labels = { "RATE", "GATE", "OCTAVES" }
  local vals   = { rate, gate, octaves }
  local texts  = {
    string.format("%d ms", math.floor(rateMs())),
    string.format("%d%%", math.floor(gate * 100)),
    tostring(octaveCount()),
  }
  for i = 1, 3 do
    local isDrag = dragging and dragging.kind == "knob" and dragging.idx == i
    Theme.knob(KNOB_XS[i], FOOTER_Y, KNOB_SIZE, vals[i], {
      label = labels[i],
      valueText = texts[i],
      color = isDrag and Theme.WARNING or Theme.ACCENT,
    })
  end

  -- Pattern-cycle button (tap to cycle UP/DOWN/UP-DN/RAND)
  PATTERN_BTN.label = PATTERNS[patternIdx]
  Theme.button(PATTERN_BTN.x, PATTERN_BTN.y, PATTERN_BTN.w, PATTERN_BTN.h, {
    label = PATTERN_BTN.label, state = true, color = Theme.ACCENT,
  })
  -- Sub-label under the button
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(PATTERN_BTN.x + (PATTERN_BTN.w - 42) / 2, PATTERN_BTN.y + PATTERN_BTN.h + 4, "PATTERN")

  -- Activity LED
  Theme.led(LED_XY.x, LED_XY.y + KNOB_SIZE / 2, ledFlash > 0, {
    color = Theme.POSITIVE, size = 10,
  })
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(LED_XY.x - 18, LED_XY.y + KNOB_SIZE / 2 + 18, "FIRING")
end

-- ===== Touch =====
function touchArp(control, event)
  if event.type == DOWN then
    if inBtn(PATTERN_BTN, event.x, event.y) then
      patternIdx = (patternIdx % #PATTERNS) + 1
      seqIdx = 1
      seqDir = 1
      parameterMap.set(1, PT_VIRTUAL, PARAM_PAT, math.floor((patternIdx - 1) / (#PATTERNS - 1) * 127))
      control:repaint()
      return
    end
    local k = hitKnob(event.x, event.y)
    if k then
      dragging = { kind = "knob", idx = k, startY = event.y, startV = knobValue(k) }
    end
  elseif event.type == MOVE then
    if dragging and dragging.kind == "knob" then
      local dy = dragging.startY - event.y
      setKnob(dragging.idx, dragging.startV + dy / 200)
      control:repaint()
    end
  elseif event.type == UP then
    dragging = nil
    control:repaint()
  end
end

-- ===== Pot =====
function potArp(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id
  if idx >= 1 and idx <= 3 then
    setKnob(idx, knobValue(idx) + potEvent.delta / 127)
  elseif idx == 4 then
    -- Any movement cycles through patterns
    if potEvent.delta > 0 then
      patternIdx = (patternIdx % #PATTERNS) + 1
    else
      patternIdx = ((patternIdx - 2) % #PATTERNS) + 1
    end
    seqIdx = 1
    seqDir = 1
    parameterMap.set(1, PT_VIRTUAL, PARAM_PAT, math.floor((patternIdx - 1) / (#PATTERNS - 1) * 127))
  end
  control:repaint()
end

-- ===== Timer =====
function timer.onTick()
  local dt = 20
  currentMs = currentMs + dt
  if ledFlash > 0 then ledFlash = ledFlash - dt end

  if currentMs >= nextFireMs then
    local stepMs = rateMs()
    local pitch = nextPitch()
    local noteLen = gateMs(stepMs)
    notes[#notes + 1] = {
      startMs = currentMs,
      endMs   = currentMs + noteLen,
      pitch   = pitch,
      vel     = 0.7 + math.random() * 0.3,
    }
    -- Garbage-collect notes that are fully off-screen
    local cutoff = currentMs - TIME_WINDOW_MS - 100
    local j = 1
    for _, n in ipairs(notes) do
      if n.endMs >= cutoff then notes[j] = n; j = j + 1 end
    end
    for k = j, #notes do notes[k] = nil end
    nextFireMs = currentMs + stepMs
    ledFlash = 90
  end

  arpControl:repaint()
end

function preset.onLoad()
  arpControl:setBounds({0, 0, 1016, 560})
  arpControl:setPaintCallback(paintArp)
  arpControl:setTouchCallback(touchArp)
  arpControl:setPotCallback(potArp)
  math.randomseed(0)   -- stable RAND pattern for reproducible screenshots
  timer.setPeriod(20)
  timer.enable()
  arpControl:repaint()
end
