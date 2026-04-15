-- Widget: Ephemera Sequencer
-- Description: 1-track 16-step melodic sequencer for Electra One standalone Lua firmware.
-- Original author: shankar (forum: shankararunachalam)
-- Source: https://github.com/shankararunachalam/electra.lua/tree/main/sequencer
-- Forum thread: https://forum.electra.one/t/ephemera-sequencer-for-electra-one-standalone-lua-firmware/715
-- Imported: 2026-04-15 — verbatim, attribution preserved.
-- License at source: none specified.
-- If you are the author and want this removed or relicensed, see NOTICE.md at repo root.

print ("Ephemera Sequencer")

-- variables for sequencer logic
stepButtons = {}
steps = 16
currentStep = 0
currentStatus = 0 -- 0:stopped, 1: playing, 2: paused
topRow = true
bpm = 120
channel = 1

-- variables to calculate display positions
xpad = 207
ypad = 50
xmult = 0
bwidth = 100
bheight = 100
xgap = 70
ygap = 35
lheight = 50
stepsInRow = 4

-- Components creation. Step button ids start from 1. All non-step button components have high id numbers to differentiate from step buttons
-- titles display creation
title1Label = Component (1001, PURPLE, "Ephemera", { x = 37, y = 50, width = 120, height = lheight })
window.addAndMakeVisible (title1Label)

title2Label = Component (1002, PURPLE, "Sequencer", { x = 867, y = 50, width = 120, height = lheight })
window.addAndMakeVisible (title2Label)

-- row blocks display creation
topRows = Component (1003, BLUE, "", { x = 187, y = 30, width = 650, height = 275 })
window.addAndMakeVisible (topRows)

bottomRows = Component (1004, BLUE, "", { x = 187, y = 305, width = 650, height = 275 })
window.addAndMakeVisible (bottomRows)

-- sequencer management buttons creation
topButton = Component (101, RED, "Top", { x = 37, y = 190, width = bwidth, height = lheight })
window.addAndMakeVisible (topButton)

bottomButton = Component (102, WHITE, "Bottom", { x = 37, y = 275, width = bwidth, height = lheight })
window.addAndMakeVisible (bottomButton)

clearButton = Component (103, WHITE, "Clear", { x = 37, y = 360, width = bwidth, height = lheight })
window.addAndMakeVisible (clearButton)

-- transport buttons creation
playButton = Component (104, WHITE, "Play", { x = 887, y = 190, width = bwidth, height = lheight })
window.addAndMakeVisible (playButton)

pauseButton = Component (105, WHITE, "Pause", { x = 887, y = 275, width = bwidth, height = lheight })
window.addAndMakeVisible (pauseButton)

stopButton = Component (106, WHITE, "Stop", { x = 887, y = 360, width = bwidth, height = lheight })
window.addAndMakeVisible (stopButton)

-- channel display creation
channelLabel = Component (107, PURPLE, "Channel 1", { x = 37, y = 500, width = 120, height = lheight })
window.addAndMakeVisible (channelLabel)

-- bpm display creation
bpmLabel = Component (108, PURPLE, "BPM 120", { x = 867, y = 500, width = 120, height = lheight })
window.addAndMakeVisible (bpmLabel)

-- step buttons creation. initializing all note numbers to 60
function createSteps ()
  for i = 1, steps do
    stepButton = {}
    stepButton.control = Component (i, WHITE, "-", { x = xpad + ((bwidth + xgap) * xmult), y = ypad, width = bwidth, height = bheight })
    stepButton.isActive = false
    stepButton.isCurrentStep = false
    stepButton.note = 60

    table.insert(stepButtons, stepButton)
    window.addAndMakeVisible (stepButtons[i].control)

    xmult = xmult + 1
    if i % stepsInRow == 0 then
      ypad = ypad + bheight + ygap
      xmult = 0
      xmult = 0
    end
  end
end

function repaintSteps ()
  for i = 1, steps do
    stepButton = stepButtons[i]
    if stepButton ~= nil then
      color = WHITE
      if stepButton.isCurrentStep then
        color = ORANGE
        stepButton.isCurrentStep = false
      elseif stepButton.isActive then
        color = GREEN
      end
      stepButton.control:setColor (color)
    end
  end
  window.repaint ()
end

function repaintTransport ()
  if currentStatus == 0 then
    playButton:setColor (WHITE);
    pauseButton:setColor (WHITE);
    stopButton:setColor (RED);
  elseif currentStatus == 1 then
    playButton:setColor (RED);
    pauseButton:setColor (WHITE);
    stopButton:setColor (WHITE);
  else
    playButton:setColor (WHITE);
    pauseButton:setColor (RED);
    stopButton:setColor (WHITE);
  end
  playButton:repaint ()
  pauseButton:repaint ()
  stopButton:repaint ()
end

function setTransport (status)
  currentStatus = status
  repaintTransport ()
  if currentStatus == 2 then -- remember the current step if needed to unpause and play
    stepButtons[currentStep].isCurrentStep = true
  end
  repaintSteps ()
end

function getNoteLabel (note)
  notes = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" };
  octave = math.floor (note / 12) - 1;
  noteIndex = (note % 12) + 1;
  return notes[noteIndex] .. " " .. octave;
end

function activateStep (button, isActive, note)
  button.isActive = isActive
  button.note = note
  if isActive then
    button.control:setColor (GREEN)
    button.control:setLabel (getNoteLabel (note))
  else
    button.control:setColor (WHITE)
    button.control:setLabel ("-")
  end
  button.control:repaint ()
end

function setFocus ()
  if topRow then
    topButton:setColor (RED)
    bottomButton:setColor (WHITE)
    topRows:setVisible (1)
    bottomRows:setVisible (0)
  else
    topButton:setColor (WHITE)
    bottomButton:setColor (RED)
    topRows:setVisible (0)
    bottomRows:setVisible (1)
  end
  window.repaint ()
end

function repaintChannel ()
  channelLabel:setLabel ("Channel " .. channel)
  channelLabel:repaint ()
end

function repaintBpm ()
  bpmLabel:setLabel ("BPM " .. bpm)
  bpmLabel:repaint ()
end

function minmax (value, min, max)
  if value < min then
    value = min
  elseif value > max then
    value = max
  end
  return value
end

function clear ()
  for i = 1, steps do
    stepButton = stepButtons[i]
    if stepButton ~= nil then
      stepButton.isCurrentStep = false
      stepButton.isActive = false
      stepButton.control:setColor (WHITE)
      stepButton.note = 60
      stepButton.control:setLabel ("-")
    end
  end
  window.repaint ()
end

function play ()
  timer.enable ()
  currentStep = currentStep + 1
  setTransport (1)
end

function pause ()
  if currentStatus == 1 then -- playing. pause
    timer.disable ()
    setTransport (2)
  elseif currentStatus == 2 then -- already paused. unpause and play
    timer.enable ()
    currentStep = currentStep + 1
    setTransport (1)
  elseif currentStatus == 0 then -- already stopped, pause isn't supposed to do anything
  end
end

function stop ()
  timer.disable ()
  currentStep = 0
  setTransport (0)
end

function processAction (action, data)
  if action == 'top' then
    topRow = true
    setFocus ()
  elseif action == 'bottom' then
    topRow = false
    setFocus ()
  elseif action == 'clear' then
    clear ()
  elseif action == 'play' then
    play ()
  elseif action == 'pause' then
    pause ()
  elseif action == 'stop' then
    stop ()
  elseif action == 'channel' then
    channel = minmax (channel + data, 1, 16)
    repaintChannel ()
  elseif action == 'bpm' then
    bpm = minmax (bpm + data, 30, 200)
    timer.setBpm (bpm)
    repaintBpm ()
  elseif action == 'stepToggle' then
    stepButton = stepButtons[data]
    if stepButton ~= nil then
      if stepButton.isActive == false then
        activateStep (stepButton, true, stepButton.note)
      else
        activateStep (stepButton, false, stepButton.note)
      end
    end
  elseif action == 'stepNote' then
    step = data.pot - 1 -- using pots starting 2
    if data.pot > 7 then -- sequence row has only 4 buttons but pot row has 6
      step = step - 2
    end
    if not topRow then -- bottom rows also reuse the same 8 pots
      step = step + 8
    end
    stepButton = stepButtons[step]
    stepButton.IsActive = true
    newNote = minmax (stepButton.note + data.delta, 0, 127)
    activateStep (stepButton, true, newNote)
  end
end

function onTouchDown (touchEvent)
  if touchEvent.componentId == nil then
    do return end
  end
  if touchEvent.componentId == 101 then -- top rows focus button
    processAction ('top', nil)
  elseif touchEvent.componentId == 102 then -- bottom rows focus button
    processAction ('bottom', nil)
  elseif touchEvent.componentId == 103 then -- clear button
    processAction ('clear', nil)
  elseif touchEvent.componentId == 104 and currentStatus ~= 1 then -- play button
    processAction ('play', nil)
  elseif touchEvent.componentId == 105 then -- pause button
    processAction ('pause', nil)
  elseif touchEvent.componentId == 106 then -- stop button
    processAction ('stop', nil)
  elseif touchEvent.componentId > 0 and touchEvent.componentId < 100 then -- step buttons
    processAction ('stepToggle', touchEvent.componentId)
  end
end

-- hardware buttons for play, pause, stop and move between step rows
function onButtonDown (buttonId)
    if buttonId == BUTTON_1 then
      processAction ('top', nil)
    elseif buttonId == BUTTON_2 then
      processAction ('bottom', nil)
    elseif buttonId == BUTTON_3 then
      processAction ('clear', nil)
    elseif buttonId == BUTTON_4 then
      processAction ('play', nil)
    elseif buttonId == BUTTON_5 then
      processAction ('pause', nil)
    elseif buttonId == BUTTON_6 then
      processAction ('stop', nil)
    end
end

function onPotMove (potId, relativeChange)
    if potId == 7 or potId == 12 then -- we don't use those pots for anything as of now
      do return end
    elseif potId == 1 then
      processAction ('channel', relativeChange)
    elseif potId == 6 then
      processAction ('bpm', relativeChange)
    else
      data = {pot = potId, delta = relativeChange}
      processAction ('stepNote', data)
    end
end

function timer.onTick ()
  if currentStatus == 1 then
    stepButton = stepButtons[currentStep]
    if stepButton ~= nil then
      stepButton.isCurrentStep = true
      if stepButton.isActive then
        midi.sendNoteOn (PORT_1, channel, stepButton.note, 100)
        midi.sendNoteOff (PORT_1, channel, stepButton.note, 100)
      end
      repaintSteps ()
    end
    currentStep = currentStep + 1
    if currentStep > steps then
      currentStep = 1
    end
  end
end

-- initialize sequencer
createSteps ()
setFocus ()
repaintTransport ()
