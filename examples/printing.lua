-- Source: https://github.com/martinpavlas/electra.lua/blob/main/printing.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- Printing to the console log
--
-- Electra One can send debugging log messages over a CTRL port. The log messages
-- are in fact SysEx messages carrying the timestamp and the text. For more
-- details about the log, please review Electra's SysEx Implementation doc.
--
-- The log message can be written by simple print to the standard output.
--
-- The following code will be executed immediately after it is loaded.


print ("This message will be shown in the ElectraOne console")

for i = 1, 10 do
    print ("message #" .. i)
end
