-- Widget: <NAME>
-- Description: <one line>
-- Author: <you>
-- License: MIT

local Widget = {}

-- Called by setPaintCallback on your host control.
function Widget.paint(control, g)
  -- graphics API lives in the `g` arg (or global `graphics` in older firmware)
  -- Example:
  -- g.setColor(0xFFFFFF)
  -- g.fillRect(0, 0, control.bounds.width, control.bounds.height)
end

-- Called by setTouchCallback.
function Widget.touch(control, event)
  -- event.x, event.y, event.type ("down"|"move"|"up")
end

-- Called by setPotCallback.
function Widget.pot(control, value)
end

return Widget
