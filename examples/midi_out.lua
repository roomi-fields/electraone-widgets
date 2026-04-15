-- Source: https://github.com/martinpavlas/electra.lua/blob/main/midi_out.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- Sending MIDI messages out
--
-- The MIDI functions are accessible with the midi module. The functions
-- cover current Electra One MIDI implementation. It means that not all
-- MIDI message types supported. On the other hand, some higher level messages,
-- such as NRPN are implemented.
--
-- All functions send messages to all Electra's interfaces (USB Dev, USB host,
-- MIDI IO). The idea is that this will follow the configuration of the low-level
-- Electra One system. This might change in near future.


print ("Sending MIDI out demo loaded")


-- Control change
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param parameterNumber an identifier of the CC (0 .. 127)
-- param value a value to be sent (0 .. 127)
midi.sendControlChange (PORT_1, 1, 10, 64)

-- Notes
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param noteNumber an identifier of the CC (0 .. 127)
-- param value a value to be sent (0 .. 127)
midi.sendNoteOn (PORT_1, 1, 60, 100)
midi.sendNoteOff (PORT_1, 1, 60, 100)

-- Program change
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param programNumber an identifier of the CC (0 .. 127)
midi.sendProgramChange (PORT_1, 1, 10)

-- Pitch bend
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param value an amount of the pitch bend change
midi.sendPitchBend (PORT_1, 1, 513)

-- Polyphonic aftertouch
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param noteNumber an identifier of the CC (0 .. 127)
-- param pressure a value to be sent (0 .. 127)
midi.sendAfterTouchPoly (PORT_1, 1, 60, 100)

-- Channel aftertouch
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param pressure a value to be sent (0 .. 127)
midi.sendAfterTouchChannel (PORT_1, 1, 100)

-- Send NRPN
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param parameterNumber an identifier of the NRPN parameter (0 .. 16383)
-- param value a value to be sent (0 .. 16383)
midi.sendNrpn (PORT_1, 1, 512, 8192)

-- Send RPN
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param parameterNumber an identifier of the RPN parameter (0 .. 16383)
-- param value a value to be sent (0 .. 16383)
midi.sendRpn (PORT_1, 1, 1, 4096)

-- Send Control change 14bit
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param channel a MIDI channel identifier (1 .. 16)
-- param parameterNumber an identifier of the CC (0 .. 31)
-- param value a value to be sent (0 .. 16383)
midi.sendControlChange14Bit (PORT_1, 1, 1, 2048)

-- Clock
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
midi.sendClock (PORT_1)

-- Start
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
midi.sendStart (PORT_1)

-- Stop
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
midi.sendStop (PORT_1)

-- Continue
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
midi.sendContinue (PORT_1)

-- Active sensing
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
midi.sendActiveSensing (PORT_1)

-- System reset
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
midi.sendSystemReset (PORT_1)

-- Song select
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param songNumber an identifier of the song
midi.sendSongSelect (PORT_1, 1)

-- Song position
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- param position a number of beats from start
midi.sendSongPosition (PORT_1, 200)

-- Tune request
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
midi.sendTuneRequest (PORT_1)

-- SysEx
-- param portId a port identifier (PORT_1, PORT_2, PORT_CTRL)
-- note: the sysex messages are purposely limited to 256 bytes now. This is due
-- to fact that the current Lua implementation is rather naive. Electra's
-- internal SysexBlock object will be added to support messages with virtually
-- unlimited length.
midi.sendSysex (PORT_1, { 67, 32, 0 })
