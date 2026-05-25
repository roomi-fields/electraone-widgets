-- ===== note-list-16 · widget revision 137 (state of rev 127 restored) =====
WIDGET_REV = "141"

-- Widget: 16-Step Note List — Waldorf Q-style reusable step list
-- 2 tiles (NOTES top, VELOCITY bottom), each 6×1, one pot per tile.
-- Pot rotation: in "navigate" mode steps through 1..16; in "edit" mode
-- changes the selected step's value. Pot click (TOUCH→RELEASE without
-- rotation) toggles between navigate and edit modes. Double-click on the
-- pot resets the selected step's value to 0 (= step deactivated).
-- Tap a cell to select it directly. Drag vertically to edit the value.

Theme.require("0.3")

-- ===== Per-tile state (keyed by ctrl:getId() = 1 or 2) =====

lanes = {
  [1] = {
    name = "NOTES", color = Theme.ACCENT, kind = "note",
    cells = { 57, 60, 64, 67, 69, 67, 64, 60,
              57, 60, 64, 69, 72, 69, 64, 60 },
    paramBase = 0, encEdit = 6,
  },
  [2] = {
    name = "VELOCITY", color = Theme.POSITIVE, kind = "num",
    cells = { 110, 80, 95, 70, 120, 70, 90, 65,
              100, 75, 90, 80, 127, 75, 85, 60 },
    paramBase = 16, encEdit = 0,
  },
}

selectedStep = { [1] = 1, [2] = 1 }
dragging     = { [1] = nil, [2] = nil }

-- Per-step mute state. Mute preserves the underlying value; the next
-- double-click unmutes and restores. Visually, muted cells display "!"
-- in dim grey instead of the value. MIDI-wise, muted = send 0.
muted = { [1] = {}, [2] = {} }

-- Pot click state machine
laneMode  = { [1] = "navigate", [2] = "navigate" }
potState  = { [1] = {}, [2] = {} }
DOUBLE_CLICK_MS = 400

commonRange = 11
PARAM_COMMON_RANGE = 33

CELLS = 16
CELL_GAP = 2
GROUP_GAP_EXTRA = 12

-- ===== Helpers =====

NOTE_NAMES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

function noteName(n)
  if n < 0 or n > 127 then return "--" end
  local octave = math.floor(n / 12) - 1
  return NOTE_NAMES[(n % 12) + 1] .. tostring(octave)
end

-- Label lookup for a step value. If the lane defines an `overlay` table
-- ({ {value=N, label="X"}, ... }), we look up the label there (matches the
-- "all 16 parameters share the same overlay list" line of the forum spec).
-- Otherwise we fall back to the built-in formatters per lane.kind. This
-- lets a user define arbitrary step lists (scale degrees, drum kit pieces,
-- chord names, syllables…) without changing the widget logic — just
-- replace lanes[N].overlay in their preset.
function overlayLabel(overlay, v)
  for _, item in ipairs(overlay) do
    if item.value == v then return item.label end
  end
  -- Range match (item with .from and .to defines an inclusive range)
  for _, item in ipairs(overlay) do
    if item.from and item.to and v >= item.from and v <= item.to then
      return item.label
    end
  end
  return tostring(v)
end

function formatCell(lane, v)
  if lane.overlay then return overlayLabel(lane.overlay, v) end
  if lane.kind == "note" then return noteName(v) end
  if lane.kind == "pct"  then return string.format("%d%%", math.floor(v * 100 / 127 + 0.5)) end
  return tostring(v)
end

function stepGeometry(x, w)
  local extra = GROUP_GAP_EXTRA * 3
  local innerW = w - extra
  return math.floor((innerW - CELL_GAP * (CELLS - 1)) / CELLS)
end

function stepX(x, w, i)
  local cellW = stepGeometry(x, w)
  local g = math.floor((i - 1) / 4)
  return math.floor(x + (i - 1) * (cellW + CELL_GAP) + g * GROUP_GAP_EXTRA)
end

-- ===== Paint =====

function paintLane(ctrl)
  local id = ctrl:getId()
  local lane = lanes[id]
  if not lane then return end

  local b = ctrl:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  -- Card surface — matches the design-system look (no rounded corners).
  Theme.rect(0, 0, W, H, Theme.SURFACE)

  local step = selectedStep[id]
  local range = commonRange
  local isEdit = (laneMode[id] == "edit")

  -- ===== Header strip =====
  local headerH = 22
  -- Subtle accent strip on the left edge marks the lane colour.
  Theme.rect(0, 0, 4, headerH, lane.color)

  -- Lane name (uppercase, dim) — matches modern-adsr/comp-meter style
  graphics.setColor(Theme.TEXT_DIM)
  graphics.print(14, 6, lane.name, 9999, LEFT)

  -- Mode pill — small framed indicator (Theme.outline + filled bg when EDIT)
  local pillX = 14 + #lane.name * 6 + 14
  local pillY = 4
  local pillW, pillH = 38, 14
  local modeStr = isEdit and "EDIT" or "NAV"
  if isEdit then
    Theme.rect(pillX, pillY, pillW, pillH, lane.color)
    graphics.setColor(Theme.CANVAS)
  else
    Theme.outline(pillX, pillY, pillW, pillH, Theme.NEUTRAL_ACCENT)
    graphics.setColor(Theme.NEUTRAL_ACCENT)
  end
  graphics.print(pillX + math.floor((pillW - #modeStr * 6) / 2), pillY + 3, modeStr, 9999, LEFT)

  -- Right side of header: STEP nn / value
  local v = lane.cells[step] or 0
  local stepStr = string.format("STEP %02d", step)
  local isMutedSel = muted[id][step] == true
  local valueStr = isMutedSel and "MUTED" or formatCell(lane,v)
  local valueW = #valueStr * 8
  local stepW = #stepStr * 6
  graphics.setColor(Theme.TEXT_DIM)
  graphics.print(W - 14 - valueW - 12 - stepW, 6, stepStr, 9999, LEFT)
  graphics.setColor(isMutedSel and Theme.NEUTRAL_ACCENT or lane.color)
  graphics.print(W - 14 - valueW, 6, valueStr, 9999, LEFT)

  -- Hairline separator under header
  Theme.line(0, headerH, W, headerH, Theme.BORDER)

  -- Tiny revision tag, bottom-right corner of header — discreet
  graphics.setColor(Theme.NEUTRAL_ACCENT)
  graphics.print(W - 26, headerH + 2, "r" .. WIDGET_REV, 9999, LEFT)

  -- ===== Cells row =====
  local cellsY = headerH + 8
  local cellsH = math.floor(H - cellsY - 6)
  local cellsX = 10
  local cellsW = math.floor(W - 20)
  local cellW = stepGeometry(cellsX, cellsW)

  -- Group dividers — short vertical tick between every 4th cell
  for g = 1, 3 do
    local divX = math.floor(stepX(cellsX, cellsW, g * 4) + cellW + GROUP_GAP_EXTRA / 2)
    local top = math.floor(cellsY + 4)
    local bot = math.floor(cellsY + cellsH - 4)
    graphics.setColor(Theme.BORDER)
    graphics.drawLine(divX,     top, divX,     bot)
    graphics.drawLine(divX + 1, top, divX + 1, bot)
  end

  for i = 1, CELLS do
    local cx = stepX(cellsX, cellsW, i)
    local isActive = (i == step)
    local inRange = (i <= range)
    local isMuted = inRange and (muted[id][i] == true)
    local cv = lane.cells[i] or 0
    local norm = math.max(0, math.min(1, cv / 127))

    -- Background — ELEVATED on selected step, SURFACE in-range, CANVAS OOR
    local bg = Theme.SURFACE
    if not inRange then bg = Theme.CANVAS
    elseif isActive then bg = Theme.ELEVATED end
    Theme.rect(cx, cellsY, cellW, cellsH, bg)

    if inRange then
      -- Value gauge — thin bar at the bottom showing the normalised value.
      -- Lane colour when active, dim variant otherwise. Hidden if muted.
      if not isMuted and cv > 0 then
        local gaugeH = 4
        local gaugeW = math.max(2, math.floor((cellW - 8) * norm))
        local gaugeY = cellsY + cellsH - gaugeH - 4
        local gaugeColor = isActive and lane.color or Theme.ACCENT_DIM
        if lane.color == Theme.POSITIVE and not isActive then gaugeColor = 0x3F6C53 end
        Theme.rect(cx + 4, gaugeY, gaugeW, gaugeH, gaugeColor)
      end

      -- Label (value text or mute marker)
      local label, lblColor
      if isMuted then
        label = "!"
        lblColor = Theme.NEUTRAL_ACCENT
      else
        label = formatCell(lane,cv)
        lblColor = isActive and Theme.TEXT
                   or (cv == 0 and Theme.NEUTRAL_ACCENT or Theme.TEXT_DIM)
      end
      graphics.setColor(lblColor)
      local labelW = #label * 6
      graphics.print(cx + math.floor((cellW - labelW) / 2),
                        cellsY + math.floor((cellsH - 14) / 2),
                        label, 9999, LEFT)
    else
      -- Out-of-range: dim dot, very subtle
      graphics.setColor(Theme.NEUTRAL_ACCENT)
      graphics.print(math.floor(cx + cellW / 2 - 3),
                     math.floor(cellsY + cellsH / 2 - 4),
                     "·", 9999, LEFT)
    end

    -- Cell outline — bright TEXT on active, BORDER in-range, ELEVATED OOR
    local outlineCol = isActive and Theme.TEXT
                       or (inRange and Theme.BORDER or Theme.ELEVATED)
    Theme.outline(cx, cellsY, cellW, cellsH, outlineCol)

    -- Active step gets a bright top edge (signature design-system marker)
    if isActive then
      Theme.rect(cx, cellsY, cellW, 2, Theme.TEXT)
    end
  end
end

-- ===== Hit-testing =====

function hitCell(ctrl, eventX, eventY)
  local b = ctrl:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]
  local cellsY = 26
  local cellsH = math.floor(H - 32)
  if eventY < cellsY or eventY > cellsY + cellsH then return nil end
  local cellsX = 10
  local cellsW = math.floor(W - 20)
  local cellW = stepGeometry(cellsX, cellsW)
  for i = 1, CELLS do
    local cx = stepX(cellsX, cellsW, i)
    if eventX >= cx and eventX <= cx + cellW then return i end
  end
  return nil
end

-- ===== Touch =====

function touchLane(ctrl, event)
  local id = ctrl:getId()
  local lane = lanes[id]
  if not lane then return end

  if event.type == DOWN then
    local i = hitCell(ctrl, event.x, event.y)
    if i then
      selectedStep[id] = i
      dragging[id] = { idx = i, startY = event.y, startV = lane.cells[i] or 0 }
      ctrl:repaint()
    end
  elseif event.type == MOVE then
    local d = dragging[id]
    if d then
      local dy = d.startY - event.y
      local nv = math.max(0, math.min(127,
                   math.floor(d.startV + dy * 0.635 + 0.5)))
      lane.cells[d.idx] = nv
      parameterMap.set(1, PT_VIRTUAL, lane.paramBase + d.idx, nv)
      ctrl:repaint()
    end
  elseif event.type == UP then
    dragging[id] = nil
  end
end

-- ===== Pot (state machine: rotation = navigate/edit, click = toggle mode,
-- double-click = reset selected step to 0) =====

function potLane(ctrl, ev)
  local sourceId = ctrl:getId()
  local sourceLane = lanes[sourceId]
  if not sourceLane or ev.id ~= sourceLane.encEdit then return end

  -- Cross-dispatch: events arriving on tile X actually come from the pot
  -- physically adjacent to the OTHER tile. Operate on the target lane's
  -- state so "top pot controls top lane" feels right.
  local targetId = (sourceId == 1) and 2 or 1
  local lane = lanes[targetId]
  local s = potState[targetId]
  local targetCtrl = controls.get(targetId)

  if ev.type == DOWN then
    s.rotatedDuringTouch = false
  elseif ev.type == MOVE then
    s.rotatedDuringTouch = true
    s.pendingClick = nil       -- rotation invalidates a pending single
    if laneMode[targetId] == "edit" then
      local step = selectedStep[targetId]
      local cv = lane.cells[step] or 0
      cv = math.max(0, math.min(127, cv + ev.delta))
      lane.cells[step] = cv
      parameterMap.set(1, PT_VIRTUAL, lane.paramBase + step, cv)
    else
      selectedStep[targetId] = math.max(1, math.min(CELLS,
                                 selectedStep[targetId] + (ev.delta > 0 and 1 or -1)))
    end
    targetCtrl:repaint()
  elseif ev.type == UP then
    if not s.rotatedDuringTouch then
      if s.pendingClick then
        -- Double-click: undo the first click's mode toggle, then toggle
        -- the mute state of the selected step. The underlying value is
        -- preserved; muted cells display "!" and emit 0 over MIDI.
        laneMode[targetId] = (laneMode[targetId] == "navigate") and "edit" or "navigate"
        local step = selectedStep[targetId]
        local nowMuted = not (muted[targetId][step] == true)
        muted[targetId][step] = nowMuted
        local outValue = nowMuted and 0 or (lane.cells[step] or 0)
        parameterMap.set(1, PT_VIRTUAL, lane.paramBase + step, outValue)
        s.pendingClick = nil
      else
        -- Single click: toggle mode, mark pending.
        laneMode[targetId] = (laneMode[targetId] == "navigate") and "edit" or "navigate"
        s.pendingClick = true
      end
      targetCtrl:repaint()
    end
  end
end

-- ===== Boot =====

function preset.onLoad()
  print("note-list-16 rev " .. WIDGET_REV .. " loaded")
  local PAGE_W = 1016
  local LANE_H = 100

  for i = 1, 2 do
    local c = controls.get(i)
    c:setBounds({0, (i - 1) * LANE_H, PAGE_W, LANE_H})
    c:setPaintCallback(paintLane)
    c:setTouchCallback(touchLane)
    c:setPotCallback(potLane)
    c:repaint()
  end
end
