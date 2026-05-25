****** Preset Menu ​ ******
The Preset Menu provides access to a set of actions related to the currently
loaded preset. These actions help you manage control values, reset them, and
trigger custom behavior.
[Preset Menu]
Available Actions:
    * Set Defaults – Reset only the controls with a defined default value.
    * Set All Defaults – Reset all controls to their default or to zero if no
      default is defined.
    * Randomize Values – Apply randomized values to all preset controls based
      on their type.
    * Reset Preset - Restart the preset.
    * Send All Control Values – Resend the current value of every control in
      the preset.
    * Assign Buttons - Assign preset's user functions to hardware buttons.
    * Pin Preset – Keep preset running on background.
    * Edit Mode - Toggle the edit mode.
    * Preset User Functions – Access up to twelve user-defined Lua functions
      mapped to buttons.
***** Setting Defaults ​ *****
Each control in a preset may optionally have a default value defined by the
preset author. This value is used when resetting or initializing the control,
and can be tailored to the musical or functional purpose of the preset.
If a control does not have a defined default, the controller will apply a
fallback rule:
    * If the control allows 0, that becomes its default
    * If 0 is not within the control’s valid range, the minimum allowed value
      is used instead
This behavior also determines how the preset behaves when it is first loaded,
or when a user resets an individual control to its default, for example, by
double-tapping the control, if that action is enabled in the configuration.
By thoughtfully assigning default values, preset authors can define which
controls are resettable and what their ideal starting state should be. This
gives users precise control over what the defaulting actions will affect.
**** Set Defaults ​ ****
The [SET DEFAULTS] button resets the values of only those controls that have a
default value explicitly defined in the preset. Controls without a defined
default will be left unchanged.
This is useful when you want to restore just the intended default state,
without affecting experimental values or undefined parameters.
**** Set All Defaults ​ ****
The [SET ALL DEFAULTS] button resets the value of every control in the preset.
For controls with a defined default, that value is used. For controls without a
default, the controller uses 0 or the control’s minimum value, depending on
what is allowed as described above.
***** Randomize ​ *****
The [RANDOMIZE] performs a full randomization of all preset controls:
    * Faders and numeric inputs: random value within defined range
    * Lists: random list item
    * Pads: randomly set to on or off
If you need a more refined control over the randomization or if you need to
morph sound parameters between two existing sounds refer to the Snapshots
section of the User Guide.
***** Restart Preset ​ *****
Pressing [RESTART PRESET] fully restarts the current preset. All preset values
are reset to their default settings, and the Lua script is reloaded. Restarting
the preset is equivalent to re-uploading the preset to the same preset slot.
***** Send All Control Values ​ *****
Tapping the [SEND CONTROLS] button forces the controller to retransmit the
current value of every control in the preset. This is useful for
resynchronizing connected MIDI devices or reinitializing external gear.
***** Assign Buttons ​ *****
The Assign Buttons feature is used to assign custom Lua user functions to the
controller’s hardware buttons. These assignments allow users to further
customize the Electra One controller to fit their workflow.
**** Assigning a button ​ ****
To assign a user function to a hardware button, arm the learning mode by
tapping the [ASSIGN BUTTONS]. The learning mode is indicated by the flashing
frame around the button.
[Assign buttons armed]
Touch and hold the knob that represents the user function you want to assign.
The on-screen button will be highlighted while you hold the knob. While
continuing to hold the knob, press the hardware button you want to assign the
user function to. Once the hardware button is pressed, the assignment will be
shown on the on-screen button representing the user function.
[Assign buttons assigned]
The picture above shows the Clear function being assigned to the Left Middle
hardware button, while Start and Stop user functions stay unassigned.
**** Button mode ​ ****
You can assign buttons in Normal and Alternate modes.
[Assign buttons mode]
Buttons assigned in Normal Mode will trigger their user functions when you
simply press the hardware button while working with a preset.
Alternate assignments are available only when the controller is in Alt Mode,
meaning that the Alt button is pressed or the Alt Mode has been activated via
MIDI_control.
**** Clearing the assignments ​ ****
If there is at least one assignment, you can clear all assignments by pressing
the [CLEAR ALL] button.
To clear an individual assignment, touch the corresponding knob and then press
the [CLEAR] button.
***** Pin Preset ​ *****
By default, when you switch from one preset to another, the previous preset is
suspended. This means it temporarily stops all activity:
    * It no longer listens to incoming MIDI messages
    * Any running Lua timers, callbacks, or Data pipe logic are paused
    * The preset will remain suspended until you switch back to it, either
      manually via the Preset Selection screen or programmatically (e.g. using
      a MIDI Control command)
**** Keeping a Preset Active ​ ****
When you pin a preset by tapping the [PIN PRESET] button, you instruct Electra
One to keep that preset active in the background, even after switching to a
different one. A pinned preset continues to:
    * Respond to incoming MIDI messages
    * Execute Lua functions, including timers and callbacks
    * Generate Data pipe output, such as MIDI LFOs, step sequencers, or
      automation sources
The preset stays pinned until you either unpin it by tapping the [PIN PRESET]
button again, or you replace it by uploading a new preset to the same preset
slot. In both cases, the pinned status is cleared and the preset will no longer
remain active in the background.
**** Indicating pinned presets ​ ****
When a preset is pinned:
    * The [PIN PRESET] button appears in blue and is highlighted with a light
      gray outline. [Pinned preset button]
    * In the Preset Selection window, pinned presets are marked with a small
      visual indicator, so you can quickly see which presets are currently
      running in the background [Pinned preset]
***** Parallel Operation ​ *****
Pinning allows Electra One to become a multi-layered control environment, where
one preset may drive background behavior while another handles foreground
interaction, or several presets operate in parallel.
This is especially useful when:
    * You want multiple presets to stay in sync with connected MIDI devices
    * A preset is acting as a sequencer, clock source, or MIDI generator
    * You rely on background activity, like modulation, even while focusing on
      a different preset
***** Edit Mode ​ *****
Tapping the [EDIT MODE] toggles the control between Standard Mode and Edit
Mode. Edit Mode is used to create and modify a preset’s Performance page. A
detailed description of how to edit the Performance page can be found in the
[Performance] section of this user guide.
When edit mode is enabled, the [EDIT MODE] button is highlighted: [Edit mode
enabled]
***** User Functions ​ *****
User Functions are custom Lua functions defined by the preset developer to
provide additional actions or behaviors tailored to the preset. These functions
are registered in the preset’s Lua script using the preset.userFunctions table.
[Pinned preset button]
Up to twelve functions can be registered per preset, each represented as a
button in the Preset Menu.
    * Buttons with an assigned user function are shown in blue
    * Tapping a button on the touchscreen triggers the corresponding function
    * If enabled in the preset’s configuration (see Pot Touch Selections under
      Settings → Interface), touching the corresponding knob can also trigger
      the function.
User functions can perform virtually any task supported by the Lua environment,
such as sending MIDI messages, triggering patch requests, adjusting control
states, or interacting with external gear. This makes them a powerful tool for
extending the preset's capabilities.
For more information on how to register and implement user functions, see the
Lua Extension preset section of the Developer Documentation.
***** Toggling Preset Menu ​ *****
The Preset Menu window is designed for quick access and smooth transitions
during live use or studio work. You can easily switch between the Preset Menu
and your regular preset pages using touch gestures or hardware buttons.
**** Accessing Preset Menu ​ ****
There are two ways to open the Preset Menu window on the Electra One
controller:
    * Swipe Gesture - swipe downward from the left of the screen. This gesture
      provides quick access without requiring any special configuration.
    * Hardware Button Assignment - assign the Open Preset Menu command to any
      of the controller’s hardware buttons via the button settings. Pressing
      the assigned button will switch between the current preset page and the
      Preset Menu window.
**** Leaving Preset Menu ​ ****
To return to the regular preset page:
    * Swipe down again
    * Or press any of the hardware buttons
Either method will close the Preset Menu window and bring you back to your last
viewed preset page.
