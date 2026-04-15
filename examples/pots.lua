-- Source: https://github.com/martinpavlas/electra.lua/blob/main/pots.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- Pot reading demo
--
-- Electra One features 12 high-resolution 360-degree pots. The pot readings are
-- always relative, providing information about the rate of change. The rate
-- increases with speed of the rotation. The positive rates represent clockwise
-- rotation while negative rates are counter-clockwise.
--
-- The callback function is called whenever a change of position is detected.
--
-- The pots are identified with a numeric identifier, starting with id 1
-- for the leftmost pot in the first row and going up to 12 for
-- the rightmost pot in the second row. The global variables POT_1 .. POT_12
-- are provided to identify the pots.


print ("Pot (knob) reading demo loaded")


function onPotMove (potId, relativeChange)
    print ("pot " .. potId .. " moved by " .. relativeChange)
end
