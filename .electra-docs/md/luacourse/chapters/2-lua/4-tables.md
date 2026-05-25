****** Tables ​ ******
Tables are the most important data structure in Lua. A table is a collection of
values grouped together under a single name. Tables can act as arrays,
dictionaries (maps), records, or even objects. Almost everything beyond basic
values in Lua is built using tables.
***** Creating Tables ​ *****
A table is created using curly braces {}.
lua
local empty = {}
Tables can store multiple values:
lua
local numbers = { 10, 20, 30 }
Tables can be assigned to variables just like any other value.
***** Tables as Arrays ​ *****
When values are stored with numeric indices starting at 1, tables behave like
arrays.
lua
local colors = { "red", "green", "blue" }

print(colors[1])  -- red
print(colors[3])  -- blue
Lua arrays are 1-based, meaning the first element is at index 1, not 0.
***** Tables as Dictionaries ​ *****
Tables can also store values under named keys.
lua
local player = {
    name = "Alex",
    score = 100,
    lives = 3
}
Values can be accessed using dot notation or bracket notation:
lua
print(player.name)
print(player["score"])
Dot notation is just a shortcut for string keys.
***** Mixed Tables ​ *****
A table can contain both numeric and named keys at the same time.
lua
local data = {
    "apple",
    "banana",
    count = 2
}
Mixed tables are common in Lua, but should be used carefully to keep code
readable.
***** Adding and Modifying Table Values ​ *****
New values can be added at any time:
lua
local items = {}

items[1] = "sword"
items[2] = "shield"
items.owner = "player"
Existing values can be changed:
lua
items[1] = "magic sword"
***** Removing Values from Tables ​ *****
Setting a key to nil removes it from the table.
lua
player.lives = nil
***** Iterating Over Tables ​ *****
Tables are commonly processed using loops. Sequential arrays use ipairs:
lua
for i, value in ipairs(colors) do
    print(i, value)
end
Key–value tables use pairs:
lua
for key, value in pairs(player) do
    print(key, value)
end
***** Table Length ​ *****
The length operator # returns the size of a sequence.
lua
print(#colors)
The result is only reliable for tables that behave as arrays without missing
indices.
***** Tables Are References ​ *****
Tables are reference values, not copies.
lua
local a = { 1, 2, 3 }
local b = a

b[1] = 99
print(a[1])  -- 99
***** Tables and Functions ​ *****
Tables can store functions as values.
lua
local calculator = {}

calculator.add = function(a, b)
    return a + b
end

print(calculator.add(2, 3))
***** Common Mistakes ​ *****
Assuming tables are copied automatically:
lua
local copy = original  -- this does not create a new table
Using index 0 in arrays:
lua
colors[0] = "black"  -- valid, but usually unintended
***** Summary ​ *****
Tables are Lua’s primary data structure. They can represent arrays,
dictionaries, or more complex structures. Tables are flexible, dynamic, and
passed by reference. Understanding how to create, modify, iterate over, and
reason about tables is essential for writing effective Lua programs.
