-- Widget: XYPad
-- Description: 2-axis touch pad sending two CCs (or any MIDI parameters).
-- Author: electraone-widgets
-- License: MIT

local XYPad = {
  x = 0.5,
  y = 0.5,
  cursorColor = 0xFFFFFF,
  bgColor     = 0x202020,
  gridColor   = 0x404040,
  onChange    = function(x, y) end,
}

function XYPad.paint(control, g)
  local w, h = control.bounds.width, control.bounds.height
  g.setColor(XYPad.bgColor);   g.fillRect(0, 0, w, h)
  g.setColor(XYPad.gridColor)
  g.drawLine(w/2, 0, w/2, h)
  g.drawLine(0, h/2, w, h/2)
  local cx, cy = XYPad.x * w, (1 - XYPad.y) * h
  g.setColor(XYPad.cursorColor)
  g.fillCircle(cx, cy, 14)
end

function XYPad.touch(control, event)
  if event.type == "down" or event.type == "move" then
    local w, h = control.bounds.width, control.bounds.height
    XYPad.x = math.max(0, math.min(1, event.x / w))
    XYPad.y = math.max(0, math.min(1, 1 - event.y / h))
    XYPad.onChange(XYPad.x, XYPad.y)
    control:repaint()
  end
end

return XYPad
