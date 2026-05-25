****** What Is a Value? ​ ******
A value is a piece of data that a program works with. In Lua, everything you
store or manipulate is a value.
Examples of values:
    * 10
    * "hello"
    * true
    * nil
Values have a type, which tells Lua how to treat them.
****** Basic Value Types in Lua ​ ******
Lua has a small number of core types:
    * Number – numeric values (integers and decimals)
    * String – text enclosed in quotes
    * Boolean – logical values: true or false
    * Nil – represents “no value”
    * Table – collections of values (covered in detail later)
    * Function – executable values (covered later)
For now, we focus on the first four.
****** Numbers ​ ******
Numbers represent quantities and can be used in calculations.
Examples:
    * 5
    * 3.1
    * -20
Common arithmetic operators:
    *     o addition
    *     o subtraction
    *     o multiplication
    * / division
    * % remainder
Lua treats all numbers as the same numeric type.
****** Strings ​ ******
Strings represent text. They are written using:
    * Double quotes: "Hello"
    * Single quotes: 'Hello'
Strings can contain letters, numbers, and symbols.
Common string operations:
    * Concatenation using ..
    * Length using #
Strings are immutable, meaning they cannot be changed in place.
****** Booleans ​ ******
Booleans represent truth values:
    * true
    * false
They are mainly used in conditions and logic.
Important rule: Only false and nil are considered false. Everything else is
considered true.
****** Nil ​ ******
nil represents the absence of a value. Uses of nil:
    * Indicating that something does not exist
    * Removing values from tables
    * Representing “unknown” or “not set”
Accessing an undefined variable results in nil.
****** What Is a Variable? ​ ******
A variable is a name that refers to a value. In Lua, variables are created by
assignment.
Example:
lua
x = 10
name = "Lua"
****** Assigning and Reassigning Variables ​ ******
Variables can be reassigned to new values at any time. Example:
lua
score = 100
score = 150
****** Local and Global Variables ​ ******
Variables are either global or local. Global variables are accessible
everywhere Local variables exist only within a limited scope
Example:
lua
local count = 5
Using local is recommended to avoid unintended side effects.
****** Naming Rules and Conventions ​ ******
Variable names:
    * Can contain letters, numbers, and underscores
    * Must not start with a number
    * Are case-sensitive
Common conventions:
    * snake_case for variables
    * Descriptive names over short ones
