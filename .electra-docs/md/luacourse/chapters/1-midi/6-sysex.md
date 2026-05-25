****** System Exclusive (SysEx) Messages ​ ******
System Exclusive (SysEx) messages are a special type of MIDI message that allow
manufacturer-specific communication. Unlike standard MIDI messages, SysEx can
carry arbitrary data, making it possible to configure devices, exchange presets
and access features that standard MIDI cannot represent.
***** Why SysEx Exists ​ *****
Standard MIDI messages are limited:
    * fixed message types
    * small number of parameters
    * predefined meanings
Manufacturers needed a way to:
    * expose advanced features
    * transfer large data blocks
    * support device-specific protocols
SysEx provides this flexibility.
***** Basic Structure of a SysEx Message ​ *****
Every SysEx message has the same outer structure:
F0 <manufacturer ID> <data bytes...> F7
Where:
    * F0 — SysEx start
    * F7 — SysEx end
    * everything in between is manufacturer-defined
***** Manufacturer ID ​ *****
The Manufacturer ID identifies which company the message is intended for.
Examples:
    * 41 — Roland
    * 43 — Yamaha
    * 7D — Educational / non-commercial
    * 3-byte IDs for newer manufacturers
This ensures that devices ignore SysEx messages not meant for them.
***** Why SysEx Uses Only 7-bit Data Bytes ​ *****
SysEx data bytes must be in the range:
0x00 – 0x7F
This avoids:
    * accidental interpretation as status bytes
    * interference with running status
    * parsing ambiguity
Larger values are split across multiple bytes using bit masking and shifting.
***** SysEx and MIDI Channels ​ *****
SysEx messages are not tied to MIDI channels.
Instead:
    * they target devices, not parts
    * all devices receive them
    * devices decide whether to respond
Because of this, SysEx protocols include their own addressing.
***** Device IDs ​ *****
Since SysEx is channel-independent, many protocols include a Device ID inside
the message. Example:
F0 <manufacturer> <device ID> <command> <data> F7
Purpose of Device IDs
    * distinguish multiple devices of the same type
    * replace MIDI channel addressing
    * allow broadcast or targeted messages
Common conventions:
    * 0x7F = all devices
    * 0x00–0x0F = individual device numbers
***** Common SysEx Message Patterns ​ *****
Although SysEx content is manufacturer-defined, most protocols follow common
patterns.
**** Command-Based SysEx ​ ****
Many SysEx messages include a command byte.
Example:
F0 <mfg> <device> <command> <data> F7
Typical commands:
    * set parameter
    * request data
    * write memory
    * read memory
**** Request–Response Pattern ​ ****
One of the most common SysEx use cases is requesting data from a device.
*** Step 1: Send a Request ​ ***
F0 <mfg> <device> <request command> <address> F7
This tells the device: “Please send me this data.”
*** Step 2: Device Sends a Response ​ ***
F0 <mfg> <device> <response command> <data> F7
The response may:
    * contain parameter values
    * include checksums
    * be split into multiple messages
***** Why Data Is Often Requested Instead of Pushed ​ *****
SysEx is often pull-based:
    * controllers ask for data
    * devices respond when ready
This avoids:
    * flooding the MIDI bus
    * sending unnecessary data
    * synchronization issues
***** Checksums ​ *****
Many SysEx protocols include a checksum. Purpose:
    * detect transmission errors
    * validate data integrity
Checksums are usually:
    * simple sums
    * masked to 7 bits
***** Common SysEx Use Cases ​ *****
**** Parameter Editing ​ ****
Change a specific parameter:
F0 <mfg> <device> <set param> <param ID> <value> F7
**** Patch and Preset Dumps ​ ****
Transfer large blocks of data:
    * single patch
    * entire bank
    * global settings
These messages may contain hundreds of bytes.
**** Device Configuration ​ ****
    * MIDI routing
    * mode selection
    * calibration
    * system settings
****** Device Identification ​ ******
Some devices respond to an identity request.
F0 7E <device> 06 01 F7
Response identifies:
    * manufacturer
    * model
    * version
***** Why SysEx Protocols Are Custom ​ *****
SysEx is not standardized beyond its framing. This allows:
    * innovation
    * proprietary features
    * device-specific workflows
The downside:
    * documentation is essential
    * each device must be handled individually
***** System Real-Time Messages Inside SysEx ​ *****
Critical Rule System Real-Time messages are allowed to appear inside SysEx
messages. Example stream:
F0 43 10 4C
F8
00 01 02
F8
03 04 F7
The real-time messages: interrupt the SysEx stream must be processed
immediately do not break or terminate the SysEx message After processing the
real-time message, SysEx parsing resumes.
***** Summary ​ *****
SysEx messages provide a flexible, manufacturer-specific extension to MIDI.
They are framed by standard start and end bytes but contain custom data defined
by each device. SysEx is channel-independent and often uses device IDs for
addressing. Common patterns include command-based messages and request–response
exchanges for reading and writing data. SysEx enables advanced control,
configuration, and data transfer that is not possible with standard MIDI
messages.
