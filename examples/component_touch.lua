-- Source: https://github.com/martinpavlas/electra.lua/blob/main/component_touch.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- The component touch demo
--
-- The touchEvent data table provided in LCD touch callbacks does not provide
-- only the screen coordinates. if the active touch point is within the
-- boundaries of a component, a component identifier is provided.
-- This simplifies handling of the touch events.
--
-- The current Lua implementation is purposely limited to having the component
-- identifier in the touchEvent data table. This means that if actions are to
-- be taken with the component it needs to be looked up by the Id. I want to
-- change this so that the reference to the component is provided directly in
-- the touchEvent as a Lua user data object / meta table. I still need to find
-- out how to do that.


print ("UI Component touch demo loaded")

-- Create and display the component
button = Component (1, ORANGE, "Button 1", { x = 462, y = 250, width = 100, height = 100 })
window.addAndMakeVisible (button)


function onTouchHold (touchEvent)
    print ("x=" .. touchEvent.x .. " y=" .. touchEvent.y)

    if touchEvent.componentId then
        print ("Component with id=" .. touchEvent.componentId ..
        " received the touch")
    end
end
