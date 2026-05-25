****** External MIDI control ​ ******
There are often situations during your gig when you need both hands to perform
and switching presets of pages could be cumbersome. The external MIDI control
provides a neat solution.
[Electra with footswitch]
The external MIDI control allows you to map a number of Electra actions to MIDI
messages sent over to Electra's <USB HOST> port. The currently supported
actions are:
    * switch to a specific page, identified by the page number
    * switch to the previous page
    * switch to the next page
    * load a specific preset, identified by the preset slot number
    * load previous preset
    * load next preset
    * recal saved snapshots
***** Configuring a USB Host device ​ *****
In order to use a MIDI Controller to send commands to Electra, it must be
connected to Electra's <USB HOST> and assigned to CTRL port. This assignment
can be done manually at the USB Host configuration on the controller. Pre-
defined mappings of USB devices to USB Host ports can be added on the
Controller configuration page of the Electra One Account application, for more
details visit Electra_One_configuration.
[USB device footswitch]
A permanent assignment can be done by uploading a custom configuration file to
your Electra One.
***** MIDI message assignments ​ *****
Electra uses default mapping of MIDI messages as shown below. The default
settings can be overridden by changing the External MIDI control configuration
in the Electra One Account application. When overriding default assignments,
the following MIDI message types can be used:
    * control change (CC)
    * note on
    * program change
**** Default setup ​ ****
*** Switching presets ​ ***
Remote switching of presets is enabled when Electra has Bank Select set to 0.
This can be done by sending Control Change #0 with value 0 to controller's <USB
DEVICE> CTRL port.
Once in the Bank select 0 mode, presets can be switched by sending Program
Change MIDI message to controller's <USB DEVICE> CTRL port. Programs 0 .. 71
are supported. This covers the 6 preset banks of 12 presets. For example,
program 13 is the second preset in Bank 2.
This can be tested in the MIDI_console by selecting the Electra One CTRL port
and entering Midi Console commands.
Switch to preset loaded in the preset Bank 1 slot 3:
cc 0 0
pc 2
Switch to preset loaded in the preset Bank 2 slot 2:
cc 0 0
pc 13
*** Re-calling snapshots ​ ***
When the controller has Bank Select set anywhere between 1 and 12, the Program
Change messages recall the saved snapshots. For each bank, up to 36 saved
snapshots can be recalled by sending a Program Change number 1 to 36.
This can be tested in the MIDI console by selecting the Electra One CTRL port
and entering Midi Console commands.
Load Snapshot 3-04, ie. bank 3 slot 4:
cc 0 3
pc 4
