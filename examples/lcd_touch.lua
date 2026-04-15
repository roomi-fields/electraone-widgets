-- Source: https://github.com/martinpavlas/electra.lua/blob/main/lcd_touch.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- LCD touch sensing demo
--
-- Electra One LCD has a capacitive touch panel attached. Callback calls
-- are triggered whenever the fingers interact with the touch panel.
-- The hardware supports detection of up to five touch points, the API is,
-- however, currently limited to one touch point only.
--
-- The callbacks receive a touchEvent data table as their parameter.
-- The touchEvent provides complete information about the touch status
--
-- touchEvent =
-- {
--     id: integer,          -- id of the touch point
--     x:  integer,          -- X position
--     y:  integer,          -- Y position
--     componentId: integer, -- id of a component that received the touch
-- }
--
-- The touch points are identified with a numeric identifier, starting with
-- id 1 going up to 5. The global variables TOUCH_POINT_1 .. TOUCH_POINT_6
-- are provided to identify the touch points. Currently only TOUCH_POINT_1
-- is available.


print ("LCD touch reading demo loaded")


function onTouchDown (touchEvent)
    print ("id=" .. touchEvent.id ..
           " touchDown x=" .. touchEvent.x ..
           " y=" .. touchEvent.y)
end

function onTouchHold (touchEvent)
    print ("id=" .. touchEvent.id ..
           " onTouchHold x=" .. touchEvent.x ..
           " y=" .. touchEvent.y)
end

function onTouchUp (touchEvent)
    print ("id=" .. touchEvent.id ..
           " onTouchUp x=" .. touchEvent.x ..
           " y=" .. touchEvent.y)
end

function onTouchLongHold (touchEvent)
    print ("id=" .. touchEvent.id ..
           " onTouchLongHold x=" .. touchEvent.x ..
           " y=" .. touchEvent.y)
end

function onTouchClick (touchEvent)
    print ("id=" .. touchEvent.id ..
           " onTouchClick x=" .. touchEvent.x ..
           " y=" .. touchEvent.y)
end

function onTouchDoubleClick (touchEvent)
    print ("id=" .. touchEvent.id ..
           " onTouchDoubleClick x=" .. touchEvent.x ..
           " y=" .. touchEvent.y)
end
