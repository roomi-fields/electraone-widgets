****** MIDI ​ ******
MIDI has been around for decades, and there is no shortage of articles,
tutorials, and technical references about it. Yet it is surprisingly common to
either encounter explanations that stay too superficial or documentation that
jumps straight into raw specifications without much context.
Our goal here is different. We will approach MIDI in a practical way, building
understanding bit by bit while also uncovering the principles that make it
work.
Throughout this part of the book, Electra One will serve as our working
environment. Instead of discussing MIDI only in theory, we will send messages,
receive them, observe their structure, and examine their effects. MIDI becomes
much clearer when you can see it in action.
The MIDI Console in the Electra One web editor will be our primary tool. It
allows you to send and receive MIDI messages simply by typing them in. What may
initially look like a stream of mysterious numbers quickly begins to make sense
once you can experiment with it directly.
All examples in the following chapters are designed for hands-on exploration.
You can copy them into the MIDI Console and immediately observe or hear the
result. These exercises are not meant only to explain the topic at hand. Each
one is structured to reveal a broader context as well. As we work through them,
you will not only understand MIDI more deeply, but also gain insight into how
Electra One is designed, how its features connect, and how to uncover some of
its more subtle capabilities.
Some examples do not require an Electra One controller to be connected. In
those cases, you can send messages to any MIDI port on your computer and
monitor them using an application such as MIDI Monitor on macOS or MIDI-OX on
Windows. Many examples, however, will involve interacting with the controller
directly. This makes the learning process more tangible and reinforces how MIDI
theory connects to the Electra One hardware.
We will start with the foundations: what MIDI is, where it comes from, and how
it is structured at the most basic level. From there, we will gradually move
toward more advanced topics. Some chapter titles - such as numeric systems -
may sound technical at first. In practice, they are simply tools that help us
describe and understand MIDI data more precisely.
While MIDI 2.0 has recently begun to receive broader attention, this guide
focuses on MIDI 1.0. The reason is straightforward: MIDI 2.0 builds directly on
the foundations established by MIDI 1.0. Once you understand those foundations,
the newer standard becomes far less intimidating and much easier to navigate.
Let’s take a closer look at what MIDI actually is and why it was created in the
first place.
