****** Devices ​ ******
With Electra One a MIDI message is always send to or received from some sort of
MIDI device. It can be any type of device capable of communicating using the
MIDI protocol either using <MIDI IO>, <USB HOST>, or <USB DEVICE>:
    * Hardware synthesizer
    * Sampler
    * DSP
    * DAW
    * Software plugin
A Device represents a musical instrument connected to one of Electra’s hardware
ports and listening on a particular MIDI channel. You will not be able to
communicate with your instrument unless you register it as a device. A Device
effectively tells Electra One what instrument is connected to a particular MIDI
port and channel. If you have two Waldorf Microwaves connected to your Electra
One, you will need to set up two devices and configure them accordingly.
One preset may have up to 32 devices configured. All of them can be used at the
same time.
Preset Controls do not refer to MIDI port and channel directly, instead they
are linked to devices. This makes it easy to do things such as changing a port
of a Device. No changes to Controls are needed. Once you adjust the settings of
the device, all Controls linked to this device will use the new settings.
A device may have a configuration attributes that describe the protocol of
SysEx data exchange. This is referred as to device Patch configuration. This
makes it possible for the Electra One controller to request and fetch patches
from connected devices.
