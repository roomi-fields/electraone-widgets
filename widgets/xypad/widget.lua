-- Widget: XY Pad
-- Description: 2-axis touch pad that sends two virtual parameters (wire to any MIDI in the preset).
-- Author: electraone-widgets
-- License: MIT

-- State (normalized 0..1, origin bottom-left)
local X = 0.5
local Y = 0.5

-- Colors
local BG   = 0x000000  -- background
local GRID = 0x404040  -- crosshair lines
local DOT  = 0xFFFFFF  -- cursor

-- Virtual parameter numbers this widget writes to (wire your MIDI mapping via parameterMap)
local PARAM_X = 1
local PARAM_Y = 2
local DEVICE_ID = 1

local function emit()
  parameterMap.set(DEVICE_ID, PT_VIRTUAL, PARAM_X, math.floor(X * 127))
  parameterMap.set(DEVICE_ID, PT_VIRTUAL, PARAM_Y, math.floor(Y * 127))
end

function paintXY(control, value)
  local b = control:getBounds()
  local w = b[WIDTH]
  local h = b[HEIGHT]

  graphics.setColor(BG)
  graphics.fillRect(0, 0, w, h)

  graphics.setColor(GRID)
  local mx = math.floor(w / 2)
  local my = math.floor(h / 2)
  graphics.drawLine(mx, 0, mx, h)
  graphics.drawLine(0, my, w, my)

  graphics.setColor(DOT)
  local cx = math.floor(X * w)
  local cy = math.floor((1 - Y) * h)
  graphics.fillCircle(cx, cy, 14)
end

function touchXY(control, event)
  if event.type == MOVE or event.type == DOWN then
    local b = control:getBounds()
    X = math.max(0, math.min(1, event.x / b[WIDTH]))
    Y = math.max(0, math.min(1, 1 - event.y / b[HEIGHT]))
    emit()
    control:repaint()
  end
end

function preset.onLoad()
  local c = controls.get(1)
  c:setBounds({0, 0, 1016, 560})
  c:setPaintCallback(paintXY)
  c:setTouchCallback(touchXY)
  emit()
end
