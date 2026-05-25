****** Tables as Objects ​ ******
Lua does not have built-in classes, but it supports object-oriented programming
through tables and functions. By storing data and behavior together inside a
table, we can create objects that represent entities with state and actions.
***** What Is an Object in Lua? ​ *****
An object in Lua is typically: a table that stores data (fields) functions
inside the table that operate on that data (methods)
Example:
lua
local player = {
    name = "Alex",
    score = 0
}
This table represents an object with state.
***** Adding Methods to a Table ​ *****
Methods are functions stored in a table.
lua
function player:add_score(points)
    self.score = self.score + points
end
Calling the method:
lua
player:add_score(10)
print(player.score)
The self parameter refers to the table itself.
***** The : vs . Syntax ​ *****
Using : automatically passes the table as the first argument.
lua
player:add_score(10)
Is equivalent to:
lua
player.add_score(player, 10)
Using : is recommended for methods.
***** Creating Multiple Objects ​ *****
To create multiple similar objects, a constructor function is commonly used.
lua
function new_player(name)
    return {
        name = name,
        score = 0
    }
end

local p1 = new_player("Alice")
local p2 = new_player("Bob")
***** Sharing Methods Between Objects ​ *****
Instead of duplicating methods, they can be shared using a common table.
lua
Player = {}

function Player:add_score(points)
    self.score = self.score + points
end

function new_player(name)
    return {
        name = name,
        score = 0,
        add_score = Player.add_score
    }
end
This reduces duplication, but still has limitations.
***** Introducing a Prototype Table ​ *****
A more common pattern uses a prototype table.
lua
Player = {}
Player.__index = Player

function Player:new(name)
    local obj = {
        name = name,
        score = 0
    }
    setmetatable(obj, Player)
    return obj
end

function Player:add_score(points)
    self.score = self.score + points
end
Creating objects:
lua
local p1 = Player:new("Alice")
local p2 = Player:new("Bob")

p1:add_score(10)
p2:add_score(5)
***** Encapsulation by Convention ​ *****
Lua does not enforce private fields, but conventions are used.
lua
local Player = {}

function Player:new(name)
    local obj = {
        _name = name,
        _score = 0
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end
A leading underscore indicates internal use.
***** Objects and State ​ *****
Each object has its own independent state.
lua
p1:add_score(10)
p2:add_score(5)

print(p1.score)  -- 10
print(p2.score)  -- 5
***** Common Mistakes ​ *****
Forgetting self in method definitions:
lua
function Player.add_score(points)  -- wrong
end
Calling a method with . instead of ::
lua
p1.add_score(10)  -- wrong
***** Summary ​ *****
In Lua, objects are built using tables and functions. Methods operate on object
state through the self parameter. Constructor functions and prototype tables
allow the creation of multiple objects that share behavior. This flexible
approach forms the basis of object-oriented programming in Lua.
