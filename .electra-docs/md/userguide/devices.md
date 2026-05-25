****** Devices ​ ******
With Electra One, every MIDI message is sent to or received from a MIDI device,
whether it is:
    * Hardware synth
    * Sampler
    * DSP
    * DAW
    * Software plugin
These devices can be connected via any of Electra’s MIDI interfaces:
    * <MIDI IO> ports
    * <USB HOST> ports
    * <USB DEVICE> ports on the host computer
To make this process efficient and flexible, Electra One uses a concept called
a Device.
A Device is a named configuration that represents an actual instrument or MIDI-
capable component connected to Electra One. Each Device defines:
    * The MIDI port the instrument is connected to.
    * The MIDI channel it listens on.
    * Optionally, additional settings for SysEx communication (used to fetch or
      send patches).
Instead of having every control store its own port and channel settings, all
Controls refer to a Device. That Device handles where (and how) MIDI messages
are sent. This approach offers several benefits:
    * You can change the port or channel in one place — the Device — and all
      linked Controls update automatically.
    * Electra One always knows what instrument it’s talking to, not just an
      arbitrary port and channel.
    * You can manage and swap gear setups much more easily.
    * Advanced features like patch requesting and SysEx communication become
      possible through Device configuration.
For example, if you have two Waldorf Microwaves, you’d create two separate
Devices, each with its own port and channel settings. Then assign the
appropriate Controls in your preset to the correct Device.
A single preset can define up to 32 Devices, and all of them can be used
simultaneously. That is sufficient even for very large MIDI setups.
A Device can also include a Patch configuration, which defines how SysEx patch
data is requested and received. This enables Electra One to fetch and manage
patches directly from your hardware instruments.
