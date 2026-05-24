-- Widget: 16-Step Note List — Waldorf Q-style reusable step list
-- One row of 16 cells, grouped every 4 with a thin BORDER tick. Values
-- are drawn directly inside each cell (no fader bars). Each instance is
-- a single custom tile, driven by two dedicated encoders: one for step
-- selection, one for value editing. A common RANGE virtual parameter is
-- shared between instances — out-of-range steps darken without losing
-- their stored value.
--
-- This widget.lua is a *factory*. The demo instantiates it twice
-- (NOTES on ENC 1+2, VELOCITY on ENC 3+4) sharing the same RANGE.
-- Up to 6 instances fit on a single MK2 screen, using all 12 encoders.
--
-- Paste lib/theme.lua (no primitives required) above this code on the
-- device. The emulator pre-loads it.

Theme.require("0.3")

-- ===== Shared state (commonRange) =====
-- The common RANGE parameter is exposed as a virtual param (33). Multiple
-- instances of the widget read it from this module-level table at paint
-- time; on the device, a native knob / list bound to virtual param 33
-- updates it via parameterMap.onChange (wired in preset.onLoad when
-- the API is available — guarded so the emulator stub doesn't crash).
local commonRange = { value = 11 }                  -- default trims to 11/16
local PARAM_COMMON_RANGE = 33
local instances = {}

local function setCommonRange(newValue)
  commonRange.value = math.max(1, math.min(16, newValue))
  for _, inst in ipairs(instances) do inst.repaint() end
end

-- ===== Helpers =====
local NOTE_NAMES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

local function noteName(n)
  if n < 0 or n > 127 then return "--" end
  local octave = math.floor(n / 12) - 1
  return NOTE_NAMES[(n % 12) + 1] .. tostring(octave)
end

local function formatCell(kind, v)
  if kind == "note" then return noteName(v)
  elseif kind == "pct"  then return string.format("%d%%", math.floor(v * 100 / 127 + 0.5))
  else                       return tostring(v) end
end

-- ===== Factory =====

local function makeNoteList(control, opts)
  opts = opts or {}
  local name      = opts.name or "STEPS"
  local color     = opts.color or Theme.ACCENT
  local kind      = opts.kind or "note"
  local cells     = opts.cells or { 60, 62, 64, 65, 67, 69, 71, 72,
                                    60, 62, 64, 65, 67, 69, 71, 72 }
  local paramBase = opts.paramBase or 0
  local encSelect = opts.encSelect or 1
  local encEdit   = opts.encEdit or 2

  local selectedStep = 1
  local dragging = nil

  local CELLS = 16
  local CELL_GAP = 2
  local GROUP_GAP_EXTRA = 12

  local function stepGeometry(x, w)
    local extra = GROUP_GAP_EXTRA * 3                       -- 3 dividers
    local innerW = w - extra
    local cellW = (innerW - CELL_GAP * (CELLS - 1)) / CELLS
    local function xOf(i)
      local g = math.floor((i - 1) / 4)
      return x + (i - 1) * (cellW + CELL_GAP) + g * GROUP_GAP_EXTRA
    end
    return cellW, xOf
  end

  local function paint(ctrl)
    local b = ctrl:getBounds()
    local W, H = b[WIDTH], b[HEIGHT]
    Theme.card(0, 0, W, H)

    -- Header — name + encoder assignment on the left
    graphics.setColor(Theme.TEXT)
    graphics.drawText(10, 6, name)
    local encStr = string.format("ENC %d+%d", encSelect, encEdit)
    graphics.setColor(Theme.NEUTRAL_ACCENT)
    graphics.drawText(10 + #name * 6 + 14, 6, encStr)

    -- Header — selected step + value on the right (live readout)
    local v = cells[selectedStep] or 0
    local valueStr = formatCell(kind, v)
    local stepStr = string.format("STEP %02d", selectedStep)
    local valueW = #valueStr * 8
    local stepW = #stepStr * 6
    graphics.setColor(Theme.TEXT_DIM)
    graphics.drawText(W - 10 - valueW - 10 - stepW, 8, stepStr)
    graphics.setColor(color)
    graphics.drawText(W - 10 - valueW, 6, valueStr)

    -- Cells row
    local cellsY = 26
    local cellsH = H - 32
    local cellW, xOf = stepGeometry(10, W - 20)
    local range = commonRange.value

    -- Group dividers — 2px tick centred in the 12px gap between groups
    for g = 1, 3 do
      local divX = xOf(g * 4) + cellW + GROUP_GAP_EXTRA / 2
      graphics.setColor(Theme.BORDER)
      graphics.drawLine(divX,     cellsY + 4, divX,     cellsY + cellsH - 4)
      graphics.drawLine(divX + 1, cellsY + 4, divX + 1, cellsY + cellsH - 4)
    end

    for i = 1, CELLS do
      local cx = xOf(i)
      local isActive = (i == selectedStep)
      local inRange = (i <= range)
      local cv = cells[i] or 0

      -- Background: ELEVATED active, SURFACE in-range, CANVAS out-of-range
      local bg = Theme.SURFACE
      if not inRange then bg = Theme.CANVAS
      elseif isActive then bg = Theme.ELEVATED end
      Theme.rect(cx, cellsY, cellW, cellsH, bg)

      if inRange then
        local label = formatCell(kind, cv)
        local lblColor = isActive and color or Theme.TEXT
        if not isActive then lblColor = Theme.TEXT_DIM end
        if isActive then lblColor = color end
        graphics.setColor(lblColor)
        local labelW = #label * 6
        local lx = cx + math.floor((cellW - labelW) / 2)
        local ly = cellsY + math.floor((cellsH - 10) / 2)
        graphics.drawText(lx, ly, label)
      else
        graphics.setColor(Theme.NEUTRAL_ACCENT)
        graphics.drawText(cx + cellW / 2 - 3, cellsY + cellsH / 2 - 4, "·")
      end

      -- Outline: TEXT on active, BORDER on in-range, ELEVATED on OOR
      local outlineCol = isActive and Theme.TEXT
                         or (inRange and Theme.BORDER or Theme.ELEVATED)
      Theme.outline(cx, cellsY, cellW, cellsH, outlineCol)

      -- Top edge highlight on the active cell
      if isActive then
        Theme.rect(cx, cellsY, cellW, 2, Theme.TEXT)
      end
    end
  end

  local function hitCell(eventX, eventY)
    -- event.x / event.y arrive in tile-local coordinates from the runtime.
    local b = control:getBounds()
    local cellsY = 26
    local cellsH = b[HEIGHT] - 32
    if eventY < cellsY or eventY > cellsY + cellsH then return nil end
    local cellW, xOf = stepGeometry(10, b[WIDTH] - 20)
    for i = 1, CELLS do
      local cx = xOf(i)
      if eventX >= cx and eventX <= cx + cellW then return i end
    end
    return nil
  end

  local function touch(ctrl, event)
    if event.type == DOWN then
      local i = hitCell(event.x, event.y)
      if i then
        selectedStep = i
        dragging = { idx = i, startY = event.y, startV = cells[i] or 0 }
        ctrl:repaint()
      end
    elseif event.type == MOVE then
      if dragging then
        local dy = dragging.startY - event.y
        local nv = math.max(0, math.min(127,
                     math.floor(dragging.startV + dy * 0.635 + 0.5)))
        cells[dragging.idx] = nv
        parameterMap.set(1, PT_VIRTUAL, paramBase + dragging.idx, nv)
        ctrl:repaint()
      end
    elseif event.type == UP then
      dragging = nil
    end
  end

  local function pot(ctrl, ev)
    if ev.type ~= MOVE then return end
    if ev.id == encSelect then
      selectedStep = math.max(1, math.min(CELLS,
                       selectedStep + (ev.delta > 0 and 1 or -1)))
      ctrl:repaint()
    elseif ev.id == encEdit then
      local cv = cells[selectedStep] or 0
      cv = math.max(0, math.min(127, cv + ev.delta))
      cells[selectedStep] = cv
      parameterMap.set(1, PT_VIRTUAL, paramBase + selectedStep, cv)
      ctrl:repaint()
    end
  end

  control:setPaintCallback(paint)
  control:setTouchCallback(touch)
  control:setPotCallback(pot)

  local instance = { repaint = function() control:repaint() end }
  table.insert(instances, instance)
  return instance
end

-- ===== Boot — demo instantiates two lanes =====

function preset.onLoad()
  -- Wire external param-33 changes → commonRange (guarded for emulator).
  if parameterMap.onChange and parameterMap.get then
    local ok, vo = pcall(parameterMap.get, 1, PT_VIRTUAL, PARAM_COMMON_RANGE)
    if ok and type(vo) == "userdata" then
      parameterMap.onChange(vo, function(valueObject, origin)
        if origin == ORIGIN_LUA then return end
        local v = valueObject:getValue()
        setCommonRange(math.floor(v * 16 / 127 + 0.5))
      end)
    end
  end

  local ctrl1 = controls.get(1)
  local ctrl2 = controls.get(2)

  -- Tile 1 — NOTES lane, top of the page, ENC 1+2
  ctrl1:setBounds({ 4, 30, 1008, 110 })
  makeNoteList(ctrl1, {
    name = "NOTES", color = Theme.ACCENT, kind = "note",
    cells = { 57, 60, 64, 67, 69, 67, 64, 60,
              57, 60, 64, 69, 72, 69, 64, 60 },
    paramBase = 0, encSelect = 1, encEdit = 2,
  })

  -- Tile 2 — VELOCITY lane, middle of the page, ENC 3+4
  ctrl2:setBounds({ 4, 160, 1008, 110 })
  makeNoteList(ctrl2, {
    name = "VELOCITY", color = Theme.POSITIVE, kind = "num",
    cells = { 110, 80, 95, 70, 120, 70, 90, 65,
              100, 75, 90, 80, 127, 75, 85, 60 },
    paramBase = 16, encSelect = 3, encEdit = 4,
  })

  ctrl1:repaint()
  ctrl2:repaint()
end
