****** Introduction to Lua ​ ******
***** Why Lua ​ *****
Lua is a lightweight programming language designed to be embedded inside other
applications. It was created in 1993 in Brazil, and from the beginning its
purpose was clear: be small, fast, portable, and easy to integrate with
software written in C or C++.
Because of these qualities, Lua became widely used in the gaming industry,
where it allows developers to script behavior, user interfaces, and game logic
without recompiling the entire engine. It has also found a strong place in
music technology, where flexibility and real-time control are essential.
Applications and platforms such as Renoise, REAPER, Ardour, and hardware
environments like monome norns use Lua to provide users with powerful
customization options.
Electra One follows the same philosophy. Its firmware is written in C and C++,
which are compiled languages. Compiled code is translated into machine
instructions before it runs, providing maximum performance and direct hardware
control. The firmware .srec file you download when updating your Electra One is
a compiled image of that C/C++ application. If you had to write your scripts in
C++ instead of Lua, the entire process would become slow and cumbersome,
requiring recompilation and deep system knowledge.
Lua, by contrast, is an interpreted language. This means your scripts are
executed by a Lua interpreter running inside the firmware. You do not need to
compile anything. You write a script as part of your Electra One project,
upload it to the controller, and it runs immediately. This makes
experimentation fast, safe, and accessible, while the performance critical
parts remain handled by the compiled firmware underneath.
***** Electra One Lua Editor ​ *****
In principle, Lua scripts for the Electra One controller, and even the JSON
preset files, can be written in any text editor. There is nothing technically
preventing you from doing so. The more complicated part is transferring those
files to the controller.
To upload a script manually, it must be converted into SysEx messages and sent
over MIDI. While this is entirely possible, it requires additional tools and a
solid understanding of the data format. It is not the most convenient way to
work, especially during development.
For the remainder of this book, we will use the Electra One web editor. This is
the official editor maintained by Electra One, developed and maintained by
Zdenek and myself. The editor not only simplifies transferring files to the
controller, but also provides a fully integrated environment for developing
presets and Lua scripts.
