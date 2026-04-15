-- Source: https://github.com/martinpavlas/electra.lua/blob/main/pot_touch.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- Pot touch sensing demo
--
-- Electra One features touch sensing hardware pots (knobs). Callback calls
-- are triggered whenever the fingers are put down or lifted of the pots.
--
-- The pots are identified with a numeric identifier, starting with id 1
-- for the leftmost pot in the first row and going up to 12 for
-- the rightmost pot in the second row. The global variables POT_1 .. POT_12
-- are provided to identify the pots.


print ("Pot (knob) touch sensing demo loaded")


function onPotTouchDown (potId)
    print ("pot " .. potId .. " touched")

    if potId == POT_1 then
        print ("POT_1 touched")
    end
end

function onPotTouchUp (potId)
    print ("pot " .. potId .. " released")
end
