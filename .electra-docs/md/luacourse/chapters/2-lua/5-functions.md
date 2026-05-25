****** Functions ​ ******
Functions allow you to group code into reusable units. Instead of repeating the
same logic in multiple places, a function lets you write it once and call it
whenever needed. In Lua, functions are values, which means they can be stored
in variables, passed to other functions, and placed inside tables.
***** Defining a Function ​ *****
A function is defined using the function keyword.
lua
function greet()
    print("Hello!")
end
The function does nothing until it is called.
lua
greet()
***** Function Parameters ​ *****
Functions can accept input values called parameters.
lua
function greet(name)
    print("Hello, " .. name)
end

greet("Lua")
Parameters are local to the function.
***** Returning Values ​ *****
Functions can return values using the return statement.
lua
function add(a, b)
    return a + b
end

local result = add(3, 5)
print(result)
When return is executed, the function stops immediately.
***** Multiple Return Values ​ *****
Lua functions can return more than one value.
lua
function divide(a, b)
    return a / b, a % b
end

local quotient, remainder = divide(10, 3)
If fewer variables are used, extra return values are discarded.
***** Functions as Values ​ *****
Functions can be assigned to variables.
lua
local say_hello = function()
    print("Hello!")
end

say_hello()
This allows functions to be passed around like any other value.
***** Local and Global Functions ​ *****
Functions can be global or local.
lua
function global_func()
    print("I am global")
end

local function local_func()
    print("I am local")
end
Using local functions is recommended to avoid polluting the global namespace.
***** Functions in Tables ​ *****
Functions are often stored in tables.
lua
local math_utils = {}

function math_utils.square(x)
    return x * x
end

print(math_utils.square(4))
This pattern is commonly used for modules and objects.
***** The : Syntax and self ​ *****
Lua provides a special syntax for functions that operate on tables.
lua
local player = {
    name = "Alex"
}

function player:print_name()
    print(self.name)
end

player:print_name()
The : syntax automatically passes the table as the first argument, called self.
This is equivalent to:
lua
function player.print_name(self)
    print(self.name)
end
***** Scope and Lifetime ​ *****
Variables defined inside a function exist only while the function runs.
lua
function test()
    local x = 10
end

-- x is not accessible here
This helps prevent unintended interactions between parts of the program.
***** Common Mistakes ​ *****
Forgetting to return a value:
lua
function sum(a, b)
    a + b  -- no return
end
Mixing . and : incorrectly:
lua
player.print_name()   -- wrong
player:print_name()  -- correct
***** Summary ​ *****
Functions are reusable blocks of code. They can accept parameters, return
values, and be treated like any other value. Functions stored in tables form
the basis for modules and objects. Understanding how functions and tables work
together is essential for writing structured Lua programs.
