-- Source: https://github.com/martinpavlas/electra.lua/blob/main/midi_in.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

-- Receiving MIDI messages
--
-- The callbacks to process specific types of incoming MIDI messages.
-- Do not leave empty or unused callback functions in your Lua module -
-- it saves Electra's processing resources.
--
-- The midiInput.interface is a string currently. I would like to change
-- it to a numeric identifier.
--


function midi.onControlChange (midiInput, channel, controllerNumber, value)
    print ("controlChange received: interface=" .. midiInput.interface ..
           " channel=" .. channel ..
           " controllerNumber=" .. controllerNumber .. " value=" .. value)
end


function midi.onNoteOn (midiInput, channel, noteNumber, velocity)
    print ("noteOn received: interface=" .. midiInput.interface ..
           " channel=" .. channel ..
           " noteNumber=" .. noteNumber .. " velocity=" .. velocity)
end


function midi.onNoteOff (midiInput, channel, noteNumber, velocity)
    print ("noteOff received: interface=" .. midiInput.interface ..
           " channel=" .. channel ..
           " noteNumber=" .. noteNumber .. " velocity=" .. velocity)
end


function midi.onAfterTouchPoly (midiInput, channel, noteNumber, pressure)
    print ("afterTouchPoly received: interface=" .. midiInput.interface ..
           " channel=" .. channel ..
           " noteNumber=" .. noteNumber .. " pressure=" .. pressure)
end


function midi.onProgramChange (midiInput, channel, programNumber)
    print ("programChange received: interface=" .. midiInput.interface ..
           " channel=" .. channel ..
           " programNumber=" .. programNumber)
end


function midi.onAfterTouchChannel (midiInput, channel, pressure)
    print ("afterTouchChannel received: interface=" .. midiInput.interface ..
           " channel=" .. channel ..
           " pressure=" .. pressure)
end


function midi.onPitchBendChannel (midiInput, channel, value)
    print ("pitchBend received: interface=" .. midiInput.interface ..
           " channel=" .. channel ..
           " value=" .. value)
end


function midi.onSongSelect (midiInput, songNumber)
    print ("songSelect received: interface=" .. midiInput.interface ..
           " songNumber=" .. songNumber)
end


function midi.onSongPosition (midiInput, position)
    print ("songPosition received: interface=" .. midiInput.interface ..
           " position=" .. position)
end


function midi.onClock (midiInput)
    print ("midi clock received: interface=" .. midiInput.interface)
end


function midi.onStart (midiInput)
    print ("start received: interface=" .. midiInput.interface)
end


function midi.onStop (midiInput)
    print ("stop received: interface=" .. midiInput.interface)
end


function midi.onContinue (midiInput)
    print ("continue received: interface=" .. midiInput.interface)
end


function midi.onActiveSensing (midiInput)
    print ("active sensing received: interface=" .. midiInput.interface)
end


function midi.onSystemReset (midiInput)
    print ("system reset received: interface=" .. midiInput.interface)
end


function midi.onTuneRequest (midiInput)
    print ("tune request received: interface=" .. midiInput.interface)
end


function midi.onSysex (midiInput, data)
    print ("sysex message received: interface=" .. midiInput.interface ..
           " data=[" .. table.concat (data,", ") .. "]")
end
