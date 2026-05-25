****** The Concept of Control ​ ******
Before we go any further, it’s important to understand how Electra One manages
the parameters of connected MIDI devices. Grasping this concept will make it
much easier to follow along in the rest of this User Guide.
***** Overview ​ *****
Electra One can be seen as a smart MIDI device that:
   1. Generates MIDI messages based on user interaction — such as turning knobs
      or using the touchscreen.
   2. Forwards MIDI messages between its interfaces and ports (<MIDI IO>, <USB
      HOST>, and <USB DEVICE>).
   3. Merges the messages it generates (1) with the incoming and outgoing MIDI
      traffic (2).
A Control represents one or more parameters of a synthesizer. For now, we’ll
focus on Controls that manage a single parameter, such as a simple filter
cutoff. Controls that affect multiple parameters — like an ADSR envelope — will
be explained later.
A Control serves two main purposes:
    * It sends the appropriate MIDI message when the value is changed by the
      user.
    * It respond to incoming MIDI messages, updating their display
      automatically when the connected device sends back parameter changes.
The image below shows a Fader Control assigned to the filter cutoff parameter,
currently set to a value of 8:
[Fader cutoff]
Each Control has a set of attributes that define how it behaves and looks.
These include:
    * Control type (fader, list, button, etc.)
    * MIDI message type (CC, NRPN, SysEx, etc.)
    * Parameter number (e.g., MIDI CC number)
    * Minimum and maximum values
Electra One users create Presets by arranging Controls into pages and layouts
that match their workflow or synthesizer engine structure. These Presets are
created and edited using the Electra_One_App and then uploaded to the
controller via the USB.
Here’s an example showing one page from a Preset:
[Preset screen]
In this case, the Preset contains Controls for editing parameters of a specific
synthesizer. However, a single Preset can also include Controls mapped to
multiple devices, allowing Electra One to go beyond being just a synth
programmer, and instead giving you hands-on control of your entire MIDI rig.
***** Control types ​ *****
Electra One supports seven types of Controls:
    * Faders
    * Lists
    * Pads
    * Envelopes
    * Relative Controls
    * XY Pads
    * Custom Controls
The Control type determines both the visual appearance of the Control and how
it interacts with MIDI data. Some Controls are designed for continuous values
(like a fader or XY pad), while others are used for discrete values (such as a
list or pad).
Each type is suited to specific use cases, depending on how you want to
represent and control your synth parameters.
**** Fader ​ ****
Faders are ideal for controlling parameters with a continuous range of values.
Typical examples include filter cutoff, resonance, or oscillator detune, any
parameter where smooth, gradual adjustment is needed.
Turning a knob assigned to a Fader smoothly changes the value of the parameter,
and Electra One sends the appropriate MIDI messages in real time. The display
also updates to reflect the current value.
The value range is defined by a minimum and maximum value.
[Fader control]
If the minimum value is negative, the fader visually splits around zero:
Positive values extend to the right, while negative values extend to the left,
with the zero point positioned proportionally in between.
[Control positive] [Control negative]
Faders can also use an Overlay, which replaces specific numeric values with
custom text labels (for example, showing “Low,” “Mid,” or “High” instead of
numbers). You’ll learn more about overlays in a later section.
Electra One distinguishes between two types of values, the display value and
the MIDI value.
    * The display value is what you see on the screen — the number shown next
      to or inside a control.
    * The MIDI value is the raw value sent or received via MIDI messages.
Electra One automatically translates between these two values based on the
ranges you define for each. This means you can work with meaningful, human-
friendly values on the screen, while the controller handles the correct MIDI
data under the hood.
For example, you might want a Balance control to show values from -50 to 50 on
the display, but still send MIDI values between 0 and 127. Electra One takes
care of this conversion automatically.
**** Lists ​ ****
Lists are one of Electra One’s key features, especially useful when working
with discrete MIDI values that have specific meanings.
Take, for example, a synthesizer parameter like VCF Envelope Mode, which uses
the following values:
MIDI value Text label
0          Normal
16         Inverted
32         Normal with Dynamics
48         Inverted with Dynamics
Using a fader for this kind of parameter wouldn't make much sense — the values
aren’t continuous, and their meaning isn’t obvious numerically. A List Control,
however, changes the behavior of the knob to work more like an encoder: turning
the knob steps through the defined options one by one.
[List control]
Each value in the list is represented as a dot, with the currently selected
value highlighted, and its label shown next to it. Lists can contain up to 255
values.
If the list has more than 16 items, the visual layout adapts slightly —
becoming more fader-like — but still shows the appropriate text labels instead
of raw numbers.
List controls do not use minimum or maximum ranges like faders. Instead, they
work entirely from values defined in their Overlay.
If the Control receives a MIDI value that isn’t part of its defined list, the
value is ignored and no changes are made.
**** Pads ​ ****
Pads are Controls used to switch between two states (On/Off) or to trigger
specific MIDI messages.
[Pad control]
Pads send MIDI messages when their state changes. You can configure whether
messages should be sent:
    * When switching from Off to On
    * When switching from On to Off
    * Or in both directions
When changing from Off to On, the configured On Value is sent. When switching
from On to Off, the Off Value is sent.
[Program pad] [Sysex pad]
Pads can operate in two modes:
    * Toggle mode: the pad stays in its new state until changed again.
    * Momentary mode: the pad returns to the Off state automatically after
      being triggered.
Pads can be activated either by touching the display or by turning the
corresponding knob. Turning the knob clockwise switches the pad On; turning it
counter-clockwise switches it Off.
**** Envelopes ​ ****
Envelopes are multi-value Controls designed to visually and intuitively
represent envelope shapes such as ADSR, ADR, or ADDSR. They make it easier to
adjust and monitor envelope parameters like Attack, Decay, Sustain, and Release
directly on the screen.
[ADSR control]
Electra One allows you to link each segment of the envelope to individual MIDI
parameters. The controller then updates the visual shape of the envelope when:
    * You change a value using a knob
    * Incoming MIDI data updates one or more of the envelope parameters
Supported envelope types:
    * ADSR
    * AR
    * ADR
    * ADSSR
    * AHDSR
    * FOUR STAGE
You can configure which envelope parameter (e.g. Attack) is controlled by the
knob by default. However, this assignment can be changed at any time while
using the preset, meaning one knob can be used to edit any part of the envelope
as needed.
When you open the envelope’s detail window, all parameters become accessible at
once, and the knobs are temporarily remapped so you can adjust each envelope
stage directly.
[ADSR detail]
**** Relative Controls ​ ****
Relative Controls are designed specifically for sending Relative Control Change
(CC) messages. Unlike standard controls, which represent absolute values,
Relative Controls focus on value changes (deltas) — how much a parameter should
increase or decrease — rather than the current value itself.
[Relative control]
The visual appearance of a Relative Control reflects this behavior. It does not
display the actual value of the parameter. Instead, it shows a momentary
indication of how much the value changes when the knob is turned.
Relative Controls are especially useful when working with synthesizers,
software, or devices that expect relative (increment/decrement) messages rather
than full absolute values.
Since the control’s value is not stored or displayed, it cannot reflect
incoming MIDI data. Its sole purpose is to send relative messages based on user
input.
**** XY Pads ​ ****
XY Pads are multi-value Controls that combine two continuous parameters, one
for the X-axis and one for the Y-axis, into a single, touch-based control. They
are ideal for controlling two related parameters simultaneously, such as filter
cutoff and resonance, pan and level, or LFO rate and depth.
[XY Pad control]
Like Envelopes, XY Pads are multi-value controls. That means they represent
more than one MIDI parameter — in this case, two. By default, only one axis (X
or Y) is assigned to the knob at a time. You can configure which one is active
by default and switch between them as needed while using the preset. This
allows you to fine-tune each parameter individually using the knob, while still
having full dual-axis control through touch.
When you open the XY Pad's detail window, you can drag your finger across the
pad to update both values at once. This makes the XY Pad especially useful for
expressive sound shaping and real-time modulation.
**** Custom Controls ​ ****
Custom Controls are a special type of Control that give users full freedom to
define their visual appearance and behavior using the Electra One Lua Extension
scripting language.
[Custom control]
With a Custom Control, you can design entirely unique visual elements, handle
input from both touch and knobs, and define how the control reacts to changes
or incoming MIDI messages, all through Lua code.
This type of Control is ideal for advanced users who want to go beyond the
standard control types and create highly specialized interactions or displays.
Custom Controls are most often used for:
    * Creating non-standard visual layouts.
    * Handling complex or device-specific Controls.
    * Building dynamic or animated control surfaces.
***** Control Variants ​ *****
Some control types offer variants — alternative versions of a control that
retain the same basic behavior but differ in visual appearance or specific
interaction modes.
An example of two variants of the fader:
[Default variant][Default thin]
Variants are useful for tailoring how a control looks and behaves to better
suit its intended use.
    * Faders can have compact or minimal styles to emphasize the numeric value
      display.
    * Pads can operate as either toggles (stay on until switched off) or
      momentary switches (return to off automatically).
    * Envelopes offer different shapes, such as ADSR, ADR, or ADDSR, to match
      the requirements of different synthesizers.
While variants don’t change the underlying function of the control, they allow
for more flexibility in layout and interaction, helping you build presets that
are both visually intuitive and functionally precise.
Variants can be selected when adding or editing a control in the Electra One
App.
***** Values and Messages ​ *****
Each Control value, the actual data point within a control, is associated with
a Message. While many controls have only one value (like a typical fader), some
controls, such as envelopes or XY pads, contain multiple values. Each of these
values has its own individual message.
A Message defines what happens when the control value changes — typically, it
tells Electra One what kind of MIDI message to send. In most cases, that
message is a standard MIDI message. However, there are also special message
types that don’t send any MIDI data but instead set internal values (like
virtual control handling).
Electra One supports all standard MIDI message types, including:
    * Control Change (7-bit, 14-bit, relative)
    * NRPN (Non-Registered Parameter Number)
    * RPN (Registered Parameter Number)
    * Program Change
    * Pitch Bend
    * Note On / Note Off
    * Channel Pressure
    * Polyphonic Aftertouch
    * System Exclusive (SysEx)
    * System Real Time
Two non-MIDI messages are supported:
    * Virtual
    * None
Not every control type supports every message type. For example, it may not
make sense to assign a Note On message to a fader. The Electra One Editor
ensures only compatible combinations are offered when designing a preset. By
combining Control types, value definitions, and MIDI messages, Electra One
gives you flexible and powerful tools to interact with your MIDI devices.
**** Non-MIDI messages ​ ****
Message types that are directly mapped to MIDI messages are handled
automatically by the controller. When a user turns a knob, the corresponding
MIDI message is sent. Likewise, when a matching MIDI message is received, the
control’s value is automatically updated.
However, there are situations where you may want to go beyond simple MIDI
transmission — for example, sending multiple MIDI messages, executing custom
logic, or dynamically updating the layout of the preset. In such cases, you can
assign the control a message type of Virtual.
A Virtual message type does not send any MIDI data and is not updated by
incoming messages. Instead, it simply updates the control’s internal value,
which can then be processed in Lua scripts.
The None message type behaves identically to Virtual, with one key difference:
controls using None are excluded from Snapshots. This means their values are
not saved when you store a preset snapshot, while Virtual-type controls are
included.
***** Lua callbacks ​ *****
In addition to sending MIDI messages, Electra One controls can be extended with
two powerful Lua-based features, the Lua function and the Lua formatter.
    * The Lua function is a custom piece of code that is executed whenever the
      control value changes, either because the user touched the screen, turned
      a knob, or because new data came in from MIDI. This gives you full
      control to run any Lua code you like — from triggering custom logic,
      updating other controls, to sending additional MIDI messages. What the
      Lua function does is entirely up to you.
    * The Lua formatter is used to translate a numeric value into a readable
      text string that is shown on the display. Formatters are often used to
      provide clearer or more meaningful labels for the user — for example,
      showing "50%" instead of "64" or "Normal" instead of a number like "0".
These features are optional, but they open up a whole new level of flexibility
when building interactive and dynamic presets.
For more details on how to use these callbacks, see the Lua_Extension
documentation.
