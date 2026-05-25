****** Devices Override format description ​ ******
Device Overrides are a specialized extension mechanism that allows users to
customize the assignment of MIDI ports and channels to devices defined within a
preset. While presets serve as the core structure for mapping and controlling
MIDI devices, including layout, controls, and MIDI messages. Device Overrides
provide a way to alter the default definitions of those devices without
modifying the original preset.
***** Relationship to Presets ​ *****
Each preset in Electra One can reference between one and up to 32 device
definitions. These devices represent standardized descriptions of external MIDI
gear or software. A device definition typically includes information such as
the MIDI port and channel where the device is connected, its name, and
optionally, instructions on how to request and parse data exchanged between
Electra One and the device.
Since different users may have their MIDI devices connected to different ports
or channels, they often need to edit the preset to make the necessary
adjustments. Device Overrides offer a solution by allowing users to apply these
changes without modifying the preset itself.
A Device Overrides JSON file provides an alternative version of MIDI device
definitions, specifically for MIDI port, channel, and device name. If this file
is present in the preset slot alongside the preset, Electra One will use the
device information from the Device Overrides file instead of the one embedded
in the preset.
***** Adjusting the Devices ​ *****
When a preset is loaded into a preset slot, Device Overrides can be added in
two ways:
    * via the Devices_screen in the main Menu on the Electra One device
    * by uploading a Device_Overrides_JSON_file_via_SysEx
***** Lifecycle ​ *****
Device Overrides are scoped to a specific preset slot on the Electra One. Their
lifecycle is tightly coupled with the preset currently loaded in that slot:
    * When a new preset is loaded into the slot, any existing Device Overrides
      file stored there is removed.
    * After the new preset is loaded, the device definitions from the preset
      itself are used, unless a new Device Overrides file is applied.
    * Any adjustment made via Devices screen in the main Menu on the controller
      will create or replace the Device Overrides JSON file in the current
      preset slot.
    * Uploading a Device Overrides JSON file via SysEx will also create or
      replace the file in the preset slot.
If a preset with the same projectId is uploaded to the preset slot, the
existing Device Overrides file will be retained. However, uploading a preset
with a different projectId will cause the existing Device Overrides file to be
removed.
Issuing a SysEx command to remove a preset or clear a preset slot will also
remove the Device Overrides file, along with any other associated files stored
in that slot.
***** Devices Override JSON format ​ *****
**** JSON schema ​ ****
The JSON schema of the Electra One Device Overrides file is available at
GitHub.
**** Top level objects ​ ****
The perforance has three top-level elements.
json
{
  "version": 1,
  "devices": [
  ]
}
*** version ​ ***
Provides information about the version of the device override file. Electra One
controller uses version information to distinguish between various device
overrides file formats. Note, this document describes version 1.
** example ​ **
json
"version":1
*** devices ​ ***
An array of devices. A device is a hardware MIDI device or software device
(application, VST/AU plugin) connected to the Electra One.
    * mandatory
    * array
** example: ​ **
json
"devices": [
   {
      "id": 1,
      "name": "My MKS-50",
      "port": 1,
      "channel": 1
   },
   {
      "id": 2,
      "name": "BeatFX plugin",
      "port": 2,
      "channel": 1
   }
]
**** Device ​ ****
A device refers to a MIDI hardware or software instrument connected to one of
Electra's MIDI ports. This could be a hardware synthesizer connected via a port
onMIDI IO interface, a hardware sequencer connected to Electra's USB host
interface, or a software plugin communicating through Electra's USB device
port. Electra supports up to 32 simultaneously connected devices.
When working with Electra, you must define your connected devices explicitly -
you do not send or receive MIDI messages directly to a port and channel, unless
you are using low-level Lua API calls. This abstraction ensures consistent
device handling and simplifies preset and control configuration.
** example: ​ **
json
{
   "id": 1,
   "name": "Generic MIDI",
   "port": 1,
   "channel": 1
}
*** id ​ ***
A unique identifier of the device. The identifier is used in other objects to
refer to a particular device.
    * mandatory
    * numeric
    * min = 1
    * max = 16
*** name ​ ***
A user-defined name of the device. The name makes it easier for users to
remember and identify devices.
    * mandatory
    * string
    * minLength = 0
    * maxLength = 20
*** port ​ ***
A port number represents a MIDI bus inside the Electra One. Port 1
interconnects MIDI IO Port 1, USB Host Port 1, and USB Device Port 1.
Similarly, Port 2 interconnects MIDI I/O Port 2, USB Host Port 2, and USB
Device Port 2.
    * mandatory
    * numeric
    * min = 1
    * max = 2
*** channel ​ ***
A MIDI channel where the device transmits the MIDI messages.
    * mandatory
    * numeric
    * min = 1
    * max = 16
