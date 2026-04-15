-- Source: https://github.com/martinpavlas/electra.lua/blob/main/component.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- The component demo
--
-- Electra base firmware is rather component and event oriented. Even though
-- it is possible to paint graphics directly, it is preferred to wrap it
-- to components. Components provide all the functionality related to the touch,
-- visibility, repainting.
--
-- The current Lua implementation is purposely limited to a plain component
-- that is represented as a square with a label. I would like to extend this
-- after some general agreement on the interface is reached.
--
-- Components are implemented as user data meta tables pointing to the low-level
-- C++ objects.


print ("UI Component demo loaded")

-- Create and display the component
button = Component (1, ORANGE, "Button 1", { x = 462, y = 250, width = 100, height = 100 })
window.addAndMakeVisible (button)


-- Call a few getter methods
print ("component id=" .. button:getId ())
print ("component name=" .. button:getName ())
print ("component label=" .. button:getLabel ())

-- Change the component a bit
button:setBounds (412, 200, 200, 200)
button:setColor (BLUE)
button:setLabel ("Button 2")
