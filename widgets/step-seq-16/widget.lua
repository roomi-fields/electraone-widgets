-- Widget: 32-Step Sequencer (2 × 16)
-- Two parallel 16-step lanes at the same tempo. Line 1 is always live;
-- line 2 can be enabled/disabled via its own button (muted cells still
-- show the pattern so you don't lose your work). Transport controls are
-- real on-screen buttons, not knobs — RUN toggles, RESET is momentary.
--
-- Paste lib/theme.lua + lib/primitives/{grid,knob,led}.lua above this
-- code on the device. The emulator pre-loads them.

Theme.require("0.3")

-- ===== Geometry =====
local GRID_X, GRID_Y, GRID_W, GRID_H = 20, 60, 976, 280
local CELL_GAP = 4
local COLS, ROWS = 16, 2

local KNOB_SIZE = 76
local KNOB_Y = 390
local KNOB_XS = { 30, 200 }

-- Buttons start after the two knobs — compact SSL console-tile size
local BTN_Y, BTN_H, BTN_W = 410, 56, 140
local BTN_RUN    = { x = 440, y = BTN_Y, w = BTN_W, h = BTN_H, label = "RUN" }
local BTN_LINE2  = { x = 610, y = BTN_Y, w = BTN_W, h = BTN_H, label = "LINE 2" }
local BTN_RESET  = { x = 780, y = BTN_Y, w = BTN_W, h = BTN_H, label = "RESET" }

-- ===== State =====
-- 32 velocities: indices 1..16 = row 1, 17..32 = row 2.
local steps = {
  -- Row 1 — kick pattern
  1.00, 0.00, 0.35, 0.00,   1.00, 0.00, 0.00, 0.45,
  1.00, 0.00, 0.35, 0.00,   1.00, 0.25, 0.50, 0.00,
  -- Row 2 — snare / offbeats
  0.00, 0.00, 0.00, 0.00,   1.00, 0.00, 0.30, 0.00,
  0.00, 0.00, 0.00, 0.45,   1.00, 0.00, 0.00, 0.60,
}

local bpm          = 120
local swing        = 0
local running      = true
local line2Enabled = true
local currentStep  = 1
local tickMs       = 0
local resetFlash   = 0    -- ms counter for RESET button flash feedback

local dragging = nil      -- { kind = "knob"|"cell", ... }
local DRAG_THRESHOLD = 4

local PARAM_BPM, PARAM_SWING, PARAM_RUN, PARAM_LINE2 = 1, 2, 3, 4

local seqControl = controls.get(1)

-- ===== Helpers =====
local function bpmToMs()
  return 60000 / bpm / 4
end

local function stepInterval(i)
  local base = bpmToMs()
  if swing <= 0 then return base end
  local factor = 1 + swing * 0.5
  return (i % 2 == 1) and (base * factor) or (base * (2 - factor))
end

local function knobValue(i)
  if i == 1 then return (bpm - 60) / 140
  elseif i == 2 then return swing end
  return 0
end

local function setKnob(i, v)
  v = math.max(0, math.min(1, v))
  if i == 1 then
    bpm = 60 + math.floor(v * 140 + 0.5)
    parameterMap.set(1, PT_VIRTUAL, PARAM_BPM, math.floor(v * 127))
  elseif i == 2 then
    swing = v
    parameterMap.set(1, PT_VIRTUAL, PARAM_SWING, math.floor(v * 127))
  end
end

-- ===== Buttons =====
local function inBtn(btn, x, y)
  return x >= btn.x and x <= btn.x + btn.w
     and y >= btn.y and y <= btn.y + btn.h
end

-- ===== Hit-testing =====
local function hitKnob(x, y)
  if y < KNOB_Y or y > KNOB_Y + KNOB_SIZE + 18 then return nil end
  for i = 1, #KNOB_XS do
    local kx = KNOB_XS[i]
    if x >= kx and x <= kx + KNOB_SIZE then return i end
  end
  return nil
end

local function hitCell(x, y)
  if y < GRID_Y or y > GRID_Y + GRID_H then return nil end
  if x < GRID_X or x > GRID_X + GRID_W then return nil end
  local cellW = (GRID_W - CELL_GAP * (COLS - 1)) / COLS
  local cellH = (GRID_H - CELL_GAP * (ROWS - 1)) / ROWS
  local col = math.floor((x - GRID_X) / (cellW + CELL_GAP)) + 1
  local row = math.floor((y - GRID_Y) / (cellH + CELL_GAP)) + 1
  if col < 1 or col > COLS or row < 1 or row > ROWS then return nil end
  return (row - 1) * COLS + col
end

-- ===== Paint =====
function paintSeq(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 10, "STEP SEQ", Theme.TEXT_DIM)
  Theme.line(20, 30, W - 20, 30, Theme.BORDER)

  Theme.text(W - 260, 10, string.format("STEP %02d / 16", currentStep), Theme.TEXT_DIM)
  graphics.setColor(Theme.ACCENT)
  graphics.print(W - 130, 10, string.format("%d BPM", bpm), 9999, LEFT)
  Theme.led(W - 30, 18, running, { color = Theme.POSITIVE, size = 6 })

  -- 2-row grid, 32 cells. Active column highlights both rows — but on
  -- disabled rows the top-edge strip is suppressed so the "playing" signal
  -- only applies to live lanes.
  Theme.grid(GRID_X, GRID_Y, GRID_W, GRID_H, COLS, ROWS, steps, {
    color = Theme.ACCENT,
    colorDim = Theme.ACCENT_DIM,
    active = running and currentStep or nil,
    gap = CELL_GAP,
    disabledRows = line2Enabled and {} or { [2] = true },
  })

  -- Playhead — bright 2px vertical segments at the active column, one per
  -- live row. Disabled rows don't get a playhead so the user sees at a
  -- glance that they're not being traversed.
  if running then
    local cellW = (GRID_W - CELL_GAP * (COLS - 1)) / COLS
    local cellH = (GRID_H - CELL_GAP * (ROWS - 1)) / ROWS
    local px = GRID_X + math.floor((currentStep - 1) * (cellW + CELL_GAP) + cellW / 2)
    graphics.setColor(Theme.TEXT)
    for r = 1, ROWS do
      local rowLive = (r == 1) or line2Enabled
      if rowLive then
        local ry = GRID_Y + (r - 1) * (cellH + CELL_GAP)
        graphics.drawLine(px,     ry, px,     ry + cellH)
        graphics.drawLine(px + 1, ry, px + 1, ry + cellH)
      end
    end
  end

  -- 2 control knobs (BPM + SWING)
  local isDragBpm   = dragging and dragging.kind == "knob" and dragging.idx == 1
  local isDragSwing = dragging and dragging.kind == "knob" and dragging.idx == 2
  Theme.knob(KNOB_XS[1], KNOB_Y, KNOB_SIZE, knobValue(1), {
    label = "BPM", valueText = tostring(bpm),
    color = isDragBpm and Theme.WARNING or Theme.ACCENT,
  })
  Theme.knob(KNOB_XS[2], KNOB_Y, KNOB_SIZE, knobValue(2), {
    label = "SWING", valueText = string.format("%d%%", math.floor(swing * 100)),
    color = isDragSwing and Theme.WARNING or Theme.ACCENT,
  })

  -- 3 transport buttons — SSL console-tile style, LED window across the top
  Theme.button(BTN_RUN.x, BTN_RUN.y, BTN_RUN.w, BTN_RUN.h, {
    label = BTN_RUN.label, state = running, color = Theme.POSITIVE,
  })
  Theme.button(BTN_LINE2.x, BTN_LINE2.y, BTN_LINE2.w, BTN_LINE2.h, {
    label = BTN_LINE2.label, state = line2Enabled, color = Theme.ACCENT,
  })
  Theme.button(BTN_RESET.x, BTN_RESET.y, BTN_RESET.w, BTN_RESET.h, {
    label = BTN_RESET.label, flashing = resetFlash > 0,
  })

  -- Footer hint
  graphics.setColor(Theme.TEXT_DIM)
  graphics.print(20, 510, "Tap a cell to toggle · drag vertically to set velocity", 9999, LEFT)
end

-- ===== Touch =====
function touchSeq(control, event)
  if event.type == DOWN then
    -- Buttons first (fully-momentary RESET, toggles for RUN / LINE 2)
    if inBtn(BTN_RUN, event.x, event.y) then
      running = not running
      parameterMap.set(1, PT_VIRTUAL, PARAM_RUN, running and 127 or 0)
      control:repaint()
      return
    end
    if inBtn(BTN_LINE2, event.x, event.y) then
      line2Enabled = not line2Enabled
      parameterMap.set(1, PT_VIRTUAL, PARAM_LINE2, line2Enabled and 127 or 0)
      control:repaint()
      return
    end
    if inBtn(BTN_RESET, event.x, event.y) then
      currentStep = 1
      tickMs = 0
      resetFlash = 180              -- ms of visual feedback
      control:repaint()
      return
    end
    -- Knobs
    local k = hitKnob(event.x, event.y)
    if k then
      dragging = { kind = "knob", idx = k, startY = event.y, startV = knobValue(k) }
      return
    end
    -- Cells
    local c = hitCell(event.x, event.y)
    if c then
      dragging = { kind = "cell", idx = c, startY = event.y, startV = steps[c], tapped = true }
    end
  elseif event.type == MOVE then
    if not dragging then return end
    local dy = dragging.startY - event.y
    if math.abs(dy) > DRAG_THRESHOLD then dragging.tapped = false end
    if dragging.kind == "knob" then
      setKnob(dragging.idx, dragging.startV + dy / 200)
    elseif dragging.kind == "cell" then
      steps[dragging.idx] = math.max(0, math.min(1, dragging.startV + dy / 200))
    end
    control:repaint()
  elseif event.type == UP then
    if dragging and dragging.kind == "cell" and dragging.tapped then
      steps[dragging.idx] = (dragging.startV > 0.05) and 0 or 1
    end
    dragging = nil
    control:repaint()
  end
end

-- ===== Pot =====
-- Pot 1 = BPM, 2 = swing, 3 = RUN toggle, 4 = LINE 2 toggle, 5 = RESET pulse.
function potSeq(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id
  if idx == 1 or idx == 2 then
    setKnob(idx, knobValue(idx) + potEvent.delta / 127)
  elseif idx == 3 then
    running = (potEvent.delta > 0)
    parameterMap.set(1, PT_VIRTUAL, PARAM_RUN, running and 127 or 0)
  elseif idx == 4 then
    line2Enabled = (potEvent.delta > 0)
    parameterMap.set(1, PT_VIRTUAL, PARAM_LINE2, line2Enabled and 127 or 0)
  elseif idx == 5 then
    currentStep = 1
    tickMs = 0
    resetFlash = 180
  end
  control:repaint()
end

-- ===== Timer / transport =====
function timer.onTick()
  local dt = 10
  if resetFlash > 0 then
    resetFlash = resetFlash - dt
    seqControl:repaint()
  end
  if running then
    tickMs = tickMs + dt
    local interval = stepInterval(currentStep)
    if tickMs >= interval then
      tickMs = tickMs - interval
      currentStep = currentStep + 1
      if currentStep > 16 then currentStep = 1 end
    end
    seqControl:repaint()
  end
end

function preset.onLoad()
  seqControl:setBounds({0, 0, 1016, 560})
  seqControl:setPaintCallback(paintSeq)
  seqControl:setTouchCallback(touchSeq)
  seqControl:setPotCallback(potSeq)
  timer.setPeriod(10)
  timer.enable()
  seqControl:repaint()
end
