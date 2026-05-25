****** Modules and Namespaced Functions ​ ******
As Lua programs grow, simply placing all functions in the global space becomes
confusing and unsafe. Modules solve this problem by grouping related functions
together under a single table. This is exactly how the Electra One Lua
Extension API is structured.
***** What Is a Module in Lua? ​ *****
In Lua, a module is usually just a table that contains functions.
lua
local math_utils = {}
Functions related to the same task are stored inside this table.
lua
function math_utils.add(a, b)
    return a + b
end

function math_utils.sub(a, b)
    return a - b
end
This table now represents a module.
***** Calling Functions from a Module ​ *****
Functions inside a module are accessed using the dot (.) operator.
lua
local result = math_utils.add(3, 5)
The dot means:
“Access the value named add inside the table math_utils.”
This is not special syntax — it is simply table access.
lua
math_utils.add
-- is the same as
math_utils["add"]
***** Why the Dot (.) Is Important ​ *****
The dot operator makes it clear:
    * where a function comes from
    * what it belongs to
    * what area of functionality it represents
Compare these two styles:
lua
sendMidiNote(60, 127)
vs
lua
electra.sendMidiNote(60, 127)
The second version is self-documenting. You immediately know:
    * this function belongs to electra
    * it is part of an API, not user code
    * it is related to Electra One functionality
***** Avoiding Global Namespace Pollution ​ *****
Without modules, functions are global by default.
lua
function draw()
end

function send()
end
This easily leads to name collisions. Modules avoid this:
lua
ui.draw()
midi.send()
Each function lives in a clearly defined namespace.
***** Modules Group Related Behavior ​ *****
A module is not just a container — it represents a concept. Example:
lua
midi.sendNote(note, velocity)
midi.sendCC(cc, value)
midi.sendProgramChange(program)
All MIDI-related behavior lives under midi. Users do not need to remember
dozens of unrelated function names — they explore the module instead.
***** Modules vs Objects ​ *****
Modules look similar to objects, but they serve a different purpose. Modules
organize functionality Objects represent individual entities with state Example
module:
lua
midi.sendNote(60, 127)
Example object:
lua
local button = Button:new()
button:setLabel("Play")
***** Summary ​ *****
In Lua, modules are tables that group related functions. The dot (.) operator
is used to access functions stored inside these tables. This pattern avoids
global name conflicts, improves readability, and makes APIs easier to
understand and maintain. The Electra One Lua Extension API uses modules
extensively to clearly separate areas of functionality and provide a clean,
scalable interface for users.
