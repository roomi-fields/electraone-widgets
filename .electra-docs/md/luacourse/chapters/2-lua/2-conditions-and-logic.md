****** Conditions and Logic ​ ******
Programs become useful when they can make decisions. In Lua, this is done using
conditions and logical expressions. A condition is an expression that evaluates
to either true or false, and the program can choose what to do based on that
result.
***** The if Statement ​ *****
The most basic decision structure in Lua is the if statement.
lua
if condition then
    -- code runs if condition is true
end
If the condition evaluates to true, the code inside the block is executed. If
it evaluates to false, the block is skipped.
Example:
lua
local score = 80

if score > 50 then
    print("You passed!")
end
***** Comparison Operators ​ *****
Lua provides comparison operators for building conditions:
    * == equal to
    * ~= not equal to
    * < less than
    * <= less than or equal
    *      greater than
    *      = greater than or equal
Example:
lua
local age = 18

if age >= 18 then
    print("Access granted")
end
Strings can also be compared:
lua
if name == "Lua" then
    print("Hello, Lua!")
end
***** elseif and else ​ *****
To handle multiple possible cases, Lua uses elseif and else.
lua
local score = 72

if score >= 90 then
    print("Grade A")
elseif score >= 75 then
    print("Grade B")
elseif score >= 60 then
    print("Grade C")
else
    print("Failed")
end
Lua checks conditions from top to bottom and executes the first block that
evaluates to true.
***** Boolean Values ​ *****
Booleans represent logical truth values:
lua
true
false
They are often stored in variables:
lua
local is_admin = true

if is_admin then
    print("Admin access")
end
***** Logical Operators ​ *****
Lua supports logical operators to combine or modify conditions:
    * and — true if both sides are true
    * or — true if at least one side is true
    * not — inverts a boolean value
Example using and:
lua
if age >= 18 and has_id then
    print("Entry allowed")
end
Example using or:
lua
if is_admin or is_moderator then
    print("Permission granted")
end
Example using not:
lua
if not game_over then
    print("Game is running")
end
***** Truthiness in Lua ​ *****
Lua has a simple rule for truth values:
    * false and nil are false
    * everything else is true
This includes:
    * 0
    * "" (empty string)
    * {} (empty table)
Example:
lua
if 0 then
    print("This will run")
end
Understanding this rule is critical to avoiding logic errors.
***** Operator Precedence ​ *****
Logical operators follow this order:
   1. not
   2. and
   3. or
Example:
lua
if not a and b then
    -- same as: (not a) and b
end
Parentheses should be used when in doubt:
lua
if not (a and b) then
    print("Condition met")
end
***** Common Mistakes ​ *****
Using = instead of ==:
lua
-- wrong
if x = 5 then
end

-- correct
if x == 5 then
end
Forgetting that 0 is true:
lua
if lives then
    -- runs even when lives == 0
end
***** Summary ​ *****
Conditions allow Lua programs to make decisions. The if, elseif, and else
statements control program flow based on boolean expressions. Comparison and
logical operators are used to build conditions, and understanding Lua’s
truthiness rules is essential for writing correct and readable logic.
