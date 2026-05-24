-- Widget: 16-Step Note List (×3 lanes)
-- A reusable 16-step custom control inspired by the Waldorf Q-style arp /
-- step list. Each lane is the same primitive — one row of 16 cells, grouped
-- every 4 by a vertical divider, with a common RANGE that dims/hides the
-- steps past the active length. The demo stacks 3 lanes (NOTES / VELOCITY /
-- GATE %) to show the same widget being instantiated multiple times on a
-- single screen, sharing the RANGE control.
--
-- Layout target: one lane occupies the equivalent of a 6×1 tile slot
-- (~1012 × 90px). Three lanes + a common header + a footer hint = full page.
--
-- Paste lib/theme.lua + lib/primitives/{readout}.lua above this code on the
-- device. The emulator pre-loads them.

Theme.require("0.3")

-- ===== Geometry =====
local W_PAGE, H_PAGE = 1016, 560

local LANES = 3
local LANE_X, LANE_W = 16, 984
local LANE_H = 110
local LANE_GAP = 16
local LANE_Y0 = 80                              -- below the global header

local CELLS = 16
local CELL_GAP = 2
local GROUP_GAP_EXTRA = 12                      -- thicker space every 4 steps,
                                                -- with a 2px BORDER tick inside

-- ===== State =====
-- Pre-fill with a musically suggestive default per lane so the demo reads
-- as a real arp pattern, not a flat row. Lane 1 = MIDI notes around A
-- minor, lane 2 = velocities, lane 3 = gate lengths 0..127.
local lanes = {
  { -- NOTES  (MIDI note number)
    name  = "NOTES",
    color = Theme.ACCENT,
    kind  = "note",                              -- display = note name
    cells = { 57, 60, 64, 67,  69, 67, 64, 60,
              57, 60, 64, 69,  72, 69, 64, 60 },
  },
  { -- VELOCITY (0..127)
    name  = "VELOCITY",
    color = Theme.POSITIVE,
    kind  = "num",
    cells = { 110, 80, 95, 70,  120, 70, 90, 65,
              100, 75, 90, 80,  127, 75, 85, 60 },
  },
  { -- GATE % (0..127 → 0..100%)
    name  = "GATE %",
    color = Theme.INFO,
    kind  = "pct",
    cells = { 80, 80, 80, 80,  100, 60, 80, 60,
              90, 60, 80, 70,  120, 60, 80, 60 },
  },
}

local range        = 16     -- common to all lanes — 1..16
local selectedLane = 1      -- which lane the value pot edits
local selectedStep = 1      -- which step is highlighted

-- Virtual parameters: 1..16 = lane1, 17..32 = lane2, 33..48 = lane3, 49 = range
local PARAM_RANGE = 49

local function paramFor(laneIdx, stepIdx)
  return (laneIdx - 1) * 16 + stepIdx
end

local mainControl = controls.get(1)

-- ===== Helpers =====

local NOTE_NAMES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

local function noteName(n)
  if n < 0 or n > 127 then return "--" end
  local octave = math.floor(n / 12) - 1
  return NOTE_NAMES[(n % 12) + 1] .. tostring(octave)
end

local function formatCell(kind, v)
  if kind == "note" then return noteName(v)
  elseif kind == "pct" then return string.format("%d%%", math.floor(v * 100 / 127 + 0.5))
  else return tostring(v) end
end

-- Map a step index 1..16 to the on-screen x of its left edge inside the
-- lane, accounting for the extra spacing every 4 steps.
local function stepGeometry(laneX, laneW)
  local groups = 4                                          -- 4 groups of 4
  local extra = GROUP_GAP_EXTRA * (groups - 1)              -- 3 dividers
  local innerW = laneW - extra
  local cellW = (innerW - CELL_GAP * (CELLS - 1)) / CELLS

  local function xOf(stepIdx)
    local groupIdx = math.floor((stepIdx - 1) / 4)
    local intra = (stepIdx - 1) * (cellW + CELL_GAP)
    return laneX + intra + groupIdx * GROUP_GAP_EXTRA
  end
  return cellW, xOf
end

local function laneRectY(laneIdx)
  return LANE_Y0 + (laneIdx - 1) * (LANE_H + LANE_GAP)
end

-- ===== Paint a single lane =====

local function paintLane(laneIdx)
  local lane = lanes[laneIdx]
  local ly = laneRectY(laneIdx)
  local lx = LANE_X
  local lw = LANE_W
  local lh = LANE_H

  -- Lane card
  Theme.card(lx, ly, lw, lh)

  -- Lane header strip — name on the left, current value readout on the right
  -- when this lane is the one being edited.
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(lx + 10, ly + 6, lane.name)

  if laneIdx == selectedLane then
    local v = lane.cells[selectedStep]
    local label = string.format("STEP %02d", selectedStep)
    local valueStr = formatCell(lane.kind, v)
    local labelW = #label * 6
    local valueW = #valueStr * 8
    local right = lx + lw - 12
    graphics.setColor(Theme.TEXT_DIM)
    graphics.drawText(right - valueW - 8 - labelW, ly + 8, label)
    graphics.setColor(lane.color)
    graphics.drawText(right - valueW, ly + 6, valueStr)
  else
    graphics.setColor(Theme.TEXT_DIM)
    local hint = "edit: pot " .. tostring(laneIdx + 1)
    graphics.drawText(lx + lw - 10 - #hint * 6, ly + 8, hint)
  end

  -- Cells row
  local cellsY = ly + 32
  local cellsH = lh - 38
  local cellW, xOf = stepGeometry(lx + 10, lw - 20)

  -- Group dividers — short vertical ticks centred in the gap between every
  -- 4th cell. Drawn before the cells so the active-step bright outline
  -- always wins on top.
  for groupIdx = 1, 3 do
    local lastCellRight = xOf(groupIdx * 4) + cellW
    local divX = lastCellRight + GROUP_GAP_EXTRA / 2
    graphics.setColor(Theme.BORDER)
    graphics.drawLine(divX, cellsY + 6, divX, cellsY + cellsH - 6)
    graphics.drawLine(divX + 1, cellsY + 6, divX + 1, cellsY + cellsH - 6)
  end

  for i = 1, CELLS do
    local cx = xOf(i)
    local active = (i == selectedStep) and (laneIdx == selectedLane)
    local inRange = (i <= range)
    local v = lane.cells[i] or 0
    local norm = math.max(0, math.min(1, v / 127))

    -- Background — ELEVATED on the active step (only on the selected lane),
    -- SURFACE otherwise. Cells past the range are CANVAS so they read
    -- "outside the pattern".
    local bg = Theme.SURFACE
    if not inRange then bg = Theme.CANVAS
    elseif active then bg = Theme.ELEVATED end
    Theme.rect(cx, cellsY, cellW, cellsH, bg)

    if inRange then
      -- Value indicator — a vertical bar from the bottom representing the
      -- normalised value. Warm colour family for the lane; on the active
      -- step the bar uses the full lane colour, otherwise dim.
      local pad = 3
      local barH = math.max(2, math.floor((cellsH - pad * 2 - 14) * norm))
      local barY = cellsY + cellsH - pad - barH
      local barColor = active and lane.color or Theme.ACCENT_DIM
      if lane.color == Theme.POSITIVE then
        barColor = active and Theme.POSITIVE or Theme.hex(0x3F6C53)
      elseif lane.color == Theme.INFO then
        barColor = active and Theme.INFO or Theme.hex(0x35567E)
      end
      Theme.rect(cx + pad, barY, cellW - pad * 2, barH, barColor)

      -- Value label inside the cell (top-aligned, small)
      local label = formatCell(lane.kind, v)
      local lblColor = active and Theme.TEXT or Theme.TEXT_DIM
      graphics.setColor(lblColor)
      graphics.drawText(cx + (cellW - #label * 6) / 2, cellsY + 3, label)
    else
      -- Out-of-range cell — empty body, dimmed dash
      graphics.setColor(Theme.NEUTRAL_ACCENT)
      graphics.drawText(cx + cellW / 2 - 3, cellsY + cellsH / 2 - 4, "·")
    end

    -- Outline — bright for the active step, dim for live, hairline for OOR
    local outlineCol = active and Theme.TEXT
                       or (inRange and Theme.BORDER or Theme.ELEVATED)
    Theme.outline(cx, cellsY, cellW, cellsH, outlineCol)

    -- Top edge highlight on the active step
    if active then
      Theme.rect(cx, cellsY, cellW, 2, Theme.TEXT)
    end
  end
end

-- ===== Paint =====

function paintMain(control)
  Theme.clear(W_PAGE, H_PAGE)

  -- Global header
  Theme.text(LANE_X, 16, "NOTE LIST 16  ·  3 lanes share RANGE", Theme.TEXT_DIM)
  Theme.line(LANE_X, 38, W_PAGE - LANE_X, 38, Theme.BORDER)

  -- Right side: RANGE common readout (drawn direct so label aligns right too)
  local rangeLabel = "RANGE"
  local rangeValue = string.format("%d / 16", range)
  local rangeLabelW = #rangeLabel * 6
  local rangeValueW = #rangeValue * 8
  local rangeRight = W_PAGE - 16
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(rangeRight - rangeLabelW, 8, rangeLabel)
  graphics.setColor(Theme.WARNING)
  graphics.drawText(rangeRight - rangeValueW, 20, rangeValue)

  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(W_PAGE / 2 - 80, 16,
    string.format("LANE %d  ·  STEP %02d", selectedLane, selectedStep))

  -- 3 lanes
  for i = 1, LANES do paintLane(i) end

  -- Footer hint
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(LANE_X, H_PAGE - 18,
    "pot 1 = step  ·  pot 2/3/4 = value (notes / vel / gate)  ·  pot 5 = range  ·  pot 6 = lane select")
end

-- ===== Hit-testing =====

local function hitCell(x, y)
  for laneIdx = 1, LANES do
    local ly = laneRectY(laneIdx)
    local cellsY = ly + 32
    local cellsH = LANE_H - 38
    if y >= cellsY and y <= cellsY + cellsH then
      local cellW, xOf = stepGeometry(LANE_X + 10, LANE_W - 20)
      for i = 1, CELLS do
        local cx = xOf(i)
        if x >= cx and x <= cx + cellW then
          return laneIdx, i
        end
      end
    end
  end
  return nil
end

-- ===== Touch =====

local dragging = nil

function touchMain(control, event)
  if event.type == DOWN then
    local laneIdx, stepIdx = hitCell(event.x, event.y)
    if laneIdx then
      selectedLane = laneIdx
      selectedStep = stepIdx
      dragging = {
        lane = laneIdx, step = stepIdx,
        startY = event.y,
        startV = lanes[laneIdx].cells[stepIdx] or 0,
      }
      control:repaint()
    end
  elseif event.type == MOVE then
    if not dragging then return end
    -- Vertical drag edits the value 0..127 (one pixel = ~0.6 value units;
    -- 200px swing covers full range, matches the rest of the design system).
    local dy = dragging.startY - event.y
    local v = math.max(0, math.min(127, math.floor(dragging.startV + dy * 0.635 + 0.5)))
    lanes[dragging.lane].cells[dragging.step] = v
    parameterMap.set(1, PT_VIRTUAL, paramFor(dragging.lane, dragging.step), v)
    control:repaint()
  elseif event.type == UP then
    dragging = nil
  end
end

-- ===== Pot =====
-- Pot 1 = selected step (1..16)
-- Pot 2 = value lane 1   (notes)
-- Pot 3 = value lane 2   (velocity)
-- Pot 4 = value lane 3   (gate)
-- Pot 5 = range          (1..16, common)
-- Pot 6 = lane selector  (1..3) — useful when editing via Pot 2 isn't enough

function potMain(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id
  local d = potEvent.delta

  if idx == 1 then
    selectedStep = math.max(1, math.min(CELLS, selectedStep + (d > 0 and 1 or -1)))
  elseif idx == 2 or idx == 3 or idx == 4 then
    local laneIdx = idx - 1
    selectedLane = laneIdx
    local v = lanes[laneIdx].cells[selectedStep] or 0
    v = math.max(0, math.min(127, v + d))
    lanes[laneIdx].cells[selectedStep] = v
    parameterMap.set(1, PT_VIRTUAL, paramFor(laneIdx, selectedStep), v)
  elseif idx == 5 then
    range = math.max(1, math.min(CELLS, range + (d > 0 and 1 or -1)))
    parameterMap.set(1, PT_VIRTUAL, PARAM_RANGE, math.floor((range - 1) * 127 / 15))
  elseif idx == 6 then
    selectedLane = math.max(1, math.min(LANES, selectedLane + (d > 0 and 1 or -1)))
  end
  control:repaint()
end

function preset.onLoad()
  mainControl:setBounds({0, 0, W_PAGE, H_PAGE})
  mainControl:setPaintCallback(paintMain)
  mainControl:setTouchCallback(touchMain)
  mainControl:setPotCallback(potMain)
  mainControl:repaint()
end
