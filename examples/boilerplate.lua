-- Source: https://github.com/martinpavlas/electra.lua/blob/main/boilerplate.lua
-- Original author: Martin Pavlas (Electra One creator)
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / modification: see NOTICE.md at repo root.

--! an example Electra Lua application

print ("Demo Lua app started")

button = Component (1, BLUE, "TEST", { x = 462, y = 250, width = 100, height = 100 })
window.addAndMakeVisible (button)
window.repaint ()


function onButtonDown (buttonId)
    print ("button " .. buttonId .. " pressed")
end


function onButtonUp (buttonId)
    print ("button " .. buttonId .. " released")
end


function onButtonLongPress (buttonId)
    print ("button " .. buttonId .. " pressed for longer time")
end


function onPotMove (potId, relativeChange)
    print ("pot " .. potId .. " moved by " .. relativeChange)
end


function onPotTouchDown (potId)
    print ("pot " .. potId .. " touched")
end


function onPotTouchUp (potId)
    print ("pot " .. potId .. " released")
end


function onTouchDown (touchEvent)
    print ("touchDown x=" .. touchEvent.x .. " y=" .. touchEvent.y)

    if touchEvent.componentId then
      print ("ComponentId=" .. touchEvent.componentId)
    end
end


function onTouchHold (touchEvent)
  print ("touchHold x=" .. touchEvent.x .. " y=" .. touchEvent.y)

  if touchEvent.componentId then
    print ("ComponentId=" .. touchEvent.componentId)
    end
end


function onTouchUp (touchEvent)
  print ("touchUp x=" .. touchEvent.x .. " y=" .. touchEvent.y)

  if touchEvent.componentId then
    print ("ComponentId=" .. touchEvent.componentId)
    end
end


function onTouchLongHold (touchEvent)
  print ("touchLongHold x=" .. touchEvent.x .. " y=" .. touchEvent.y)

  if touchEvent.componentId then
    print ("ComponentId=" .. touchEvent.componentId)
    end
end


function onTouchClick (touchEvent)
  print ("touchClick x=" .. touchEvent.x .. " y=" .. touchEvent.y)

  if touchEvent.componentId then
    print ("ComponentId=" .. touchEvent.componentId)
  end
end


function onTouchDoubleClick (touchEvent)
  print ("touchDoubleClick x=" .. touchEvent.x .. " y=" .. touchEvent.y)

  if touchEvent.componentId then
    print ("ComponentId=" .. touchEvent.componentId)
  end
end


function midi.onMessage (midiInput, midiMessage)
    if midiMessage.type == SYSEX then
        print ("sysex message received: interface=" .. midiInput.interface ..
               " data=[" .. table.concat (midiMessage.data,", ") .. "]")
    else
        print ("midi message received: interface=" .. midiInput.interface ..
               " channel=" .. midiMessage.channel ..
               " type=" .. midiMessage.type ..
               " data1=" .. midiMessage.data1 ..
               " data2=" .. midiMessage.data2)
    end
end
