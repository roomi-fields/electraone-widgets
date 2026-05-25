****** Loops ​ ******
Loops allow a program to repeat actions. Instead of writing the same code
multiple times, a loop executes a block of code repeatedly while a condition
holds or for a fixed number of iterations. Lua provides several loop
constructs, each suited to different situations.
***** The while Loop ​ *****
A while loop repeats as long as a condition evaluates to true.
lua
while condition do
    -- repeated code
end
Example:
lua
local count = 1

while count <= 5 do
    print(count)
    count = count + 1
end
The condition is checked before each iteration. If it is false initially, the
loop body is never executed.
***** Avoiding Infinite Loops ​ *****
If the condition never becomes false, the loop will run forever. This is called
an infinite loop.
lua
-- infinite loop
while true do
    print("Running...")
end
To avoid infinite loops, ensure that something inside the loop changes the
condition.
***** The repeat ... until Loop ​ *****
The repeat ... until loop executes the block at least once, because the
condition is checked at the end.
lua
repeat
    -- repeated code
until condition
Example:
lua
local count = 1

repeat
    print(count)
    count = count + 1
until count > 5
***** The Numeric for Loop ​ *****
The numeric for loop is used when the number of iterations is known in advance.
lua
for variable = start, finish, step do
    -- repeated code
end
Example:
lua
for i = 1, 5 do
    print(i)
end
The optional step value controls how much the variable changes each iteration:
lua
for i = 10, 1, -1 do
    print(i)
end
The loop variable is local to the loop.
***** Looping Over Tables ​ *****
Tables are commonly iterated using pairs or ipairs. ipairs is used for
sequential numeric indices starting at 1:
lua
local fruits = { "apple", "banana", "cherry" }

for i, value in ipairs(fruits) do
    print(i, value)
end
pairs iterates over all key–value pairs:
lua
local scores = { alice = 10, bob = 15 }

for name, score in pairs(scores) do
    print(name, score)
end
The order of iteration with pairs is not guaranteed.
***** Breaking Out of Loops ​ *****
The break statement stops a loop immediately.
lua
for i = 1, 10 do
    if i == 5 then
        break
    end
    print(i)
end
After break, execution continues after the loop.
***** Skipping an Iteration ​ *****
Lua does not have a built-in continue statement. Instead, conditional logic is
used.
Example:
lua
for i = 1, 5 do
    if i ~= 3 then
        print(i)
    end
end
another option, which I personally do not like, is to use goto command to jump
to a label.
lua
for i = 1, 10 do
  if i == 5 then
    goto continue
  end

  print(i)

  ::continue::
end
***** Nested Loops ​ *****
Loops can be placed inside other loops.
lua
for x = 1, 3 do
    for y = 1, 2 do
        print(x, y)
    end
end
Nested loops increase complexity and should be used carefully.
***** Common Loop Mistakes ​ *****
Forgetting to update the loop variable:
lua
-- infinite loop
while x < 10 do
    print(x)
end
***** Summary ​ *****
Loops allow code to run repeatedly. Lua provides while, repeat ... until, and
for loops for different situations. Numeric for loops are ideal when the
iteration count is known, while while and repeat loops are better for
condition-based repetition. Understanding how to safely exit loops and iterate
over tables is essential for writing efficient programs.
