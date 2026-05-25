****** Lua ​ ******
When I was developing the very first version of the Electra One firmware, I
strongly believed that users should be able to build everything simply by
clicking things together - MIDI messages, routing, and basic logic. And for a
while, that idea worked surprisingly well. Early Electra One presets allowed
users to send and receive MIDI data, including complex voice and patch dumps,
without writing a single line of code.
As time went on, however, users began asking for more. They wanted greater
control over what was shown on the screen, more flexible behavior, and smarter
ways to process MIDI data. At that point it became clear that Electra One
needed some form of procedural logic. Not because the original system was
incapable, but because pushing it further would have made everything
increasingly complex, cumbersome, and difficult to maintain. Allowing users to
add small pieces of programmatic logic felt like a much more elegant solution.
For this purpose, I chose Lua. It is fast, lightweight, and remarkably
efficient, especially when you realize that the original Electra One mk1 had
only 256 kB of RAM. Lua was also a natural fit for another reason: it is widely
used in music and creative tools.
Over the years, the Lua implementation in Electra One grew from a small
collection of helper functions for formatting and processing MIDI data into a
full-blown API (Application Programming Interface), complete with a capable
development environment. At the time of writing, Lua allows you to build highly
customized presets with dynamically changing layouts, create sequencers, and
develop your own MIDI processors. In practice, your imagination is the only
real limit.
That said, this work is far from finished. New ideas emerge with nearly every
preset I build, not to mention the steady stream of inspiration coming from the
Electra One community itself.
The chapters in this section will introduce you to the Lua programming language
in general. All examples can be run directly on your Electra One controller,
but their primary goal is to help you understand Lua itself. The knowledge you
gain here can be reused elsewhere, whether in other products that use Lua or
simply when experimenting with Lua on your computer.
The third part of this book builds on what you learn in both the MIDI section
and this Lua section. There, we will dive deep into the Electra One Lua
Extensions and explore how to use their full potential in real-world projects.
While learning MIDI, the MIDI Console served as your main tool. Now, we will
expand that setup with the Lua Editor and the Debugger. Together, these three
tools form a powerful and approachable environment - one that helps you connect
the pieces, experiment freely, and get the very most out of your controller.
