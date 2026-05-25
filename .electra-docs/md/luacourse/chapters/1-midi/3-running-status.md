#Running Status
***** What Is Running Status? ​ *****
Running Status is a feature of MIDI that allows repeated messages of the same
type and channel to be sent without repeating the status byte every time.
In short:
If multiple MIDI messages in a row have the same status byte, the status byte
can be sent once and then omitted until it changes.
This reduces the amount of data that needs to be transmitted.
***** Why Running Status Exists ​ *****
MIDI was designed in the early 1980s, when:
    * bandwidth was very limited
    * messages had to be sent in real time
    * efficiency mattered
By removing repeated status bytes, MIDI can:
    * send data faster
    * reduce congestion
    * improve timing accuracy
This is especially important for streams of notes or controller movements.
***** Normal MIDI Message Transmission ​ *****
Without running status, each Note On message looks like this:
Status   Data   Data
0x90     60     100
0x90     62     100
0x90     64     100
Each note repeats the same status byte (0x90).
***** MIDI with Running Status ​ *****
With running status, the status byte is sent once, then omitted:
0x90 60 100
    62 100
    64 100
The receiver remembers the last status byte and applies it to subsequent data
bytes.
***** What “Status” Means Here ​ *****
The “status” includes:
    * message type (e.g. Note On)
    * channel number
Example:
    * 0x90 = Note On, Channel 1
    * 0x91 = Note On, Channel 2
Running status only works as long as both stay the same.
***** When Running Status Ends ​ *****
Running status is cancelled immediately when:
    * a new status byte is received
    * a System Common or System Real-Time message appears
    * a SysEx message starts (0xF0)
After that, the next message must send a new status byte.
***** Running Status with Different Message Types ​ *****
Running status works with channel voice messages, such as:
    * Note On
    * Note Off
    * Control Change
    * Program Change
    * Aftertouch
    * Pitch Bend
It does not apply to:
    * System Exclusive
    * System Common messages
***** Example with Control Change ​ *****
Without running status:
0xB0 7 100
0xB0 7 90
0xB0 7 80
With running status:
0xB0 7 100
    7 90
    7 80
This is common when moving a knob or slider.
****** System Real-Time Messages and Running Status ​ ******
System Real-Time messages (like MIDI Clock 0xF8) are special. They:
    * can appear between data bytes
    * do not cancel running status
Example:
0x90 60 100
0xF8
    62 100
***** Summary ​ *****
Running status is a MIDI optimization that allows repeated messages of the same
type and channel to omit the status byte. The receiver remembers the last
status and applies it to subsequent data bytes. This reduces bandwidth usage
and improves timing. While most APIs hide this detail, understanding running
status is essential for working with raw MIDI data and interpreting MIDI
streams correctly.
