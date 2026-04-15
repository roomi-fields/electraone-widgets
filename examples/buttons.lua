-- Source: https://github.com/martinpavlas/electra.lua/blob/main/buttons.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- Hardware buttons handling demo
--
-- A simple example application that demonstrates handling of callbacks
-- triggered by the hardware buttons.
--
-- The buttons are identified with a numeric identifier, starting with id 1
-- for the top-left button and going up to 6 for the right-bottom button.
-- The global variables BUTTON_1 .. BUTTON_6 are provided to identify
-- the buttons.


print ("Hardware buttons demo loaded")


function onButtonDown (buttonId)
    print ("button " .. buttonId .. " pressed")

    if buttonId == BUTTON_6 then
        print ("[MENU] button pressed")
    end
end

function onButtonUp (buttonId)
    print ("button " .. buttonId .. " released")
end

function onButtonLongHold (buttonId)
    print ("button " .. buttonId .. " held long")
end
