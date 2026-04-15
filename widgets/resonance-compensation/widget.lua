-- Widget: Resonance Compensation (Moog-ladder style)
-- Description: auto-boosts volume as filter resonance rises, compensating the
--              bass loss typical of ladder filters (Minitaur/Sub37-style).
-- Original author: NewIgnis (Ignace Vanbiervliet)
-- Source: https://forum.electra.one/t/making-additional-modulation-and-expression-with-lua/1778?page=1#post_10944
-- Imported: 2026-04-15 — verbatim (one comment-syntax fix). License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.
--
-- Expected preset layout:
--   A toggle pad bound to PT_VIRTUAL 140 — enables/disables compensation
--   A "feedback" fader bound to PT_VIRTUAL 141 — visual feedback of how much volume is added
--   CC 7 on the device is volume; CC 21 is resonance (Minitaur default — adjust if needed)

-- catch the main device parameters for use in MIDI instructions
deviceId = 1
device   = devices.get(deviceId)
devPort  = device:getPort()
channel  = device:getChannel()

prevValueVol = 0

function showNothing() -- a simple way of not showing any values on a fader
  return ("")
end

function compensationOn(valueObject, value) -- only called when (des)activating
  if value == 1 then return end
  local CC7Value = parameterMap.get(deviceId, PT_CC7, 7) -- get the preset volume stored in Electra
  midi.sendControlChange(devPort, channel, 7, CC7Value)  -- ensure the synth is in sync
  prevValueVol = CC7Value
end

function resoCompensation(valueObject, value)
  if parameterMap.get(deviceId, PT_VIRTUAL, 140) == 0 then return end -- disabled
  local CC7Value = parameterMap.get(deviceId, PT_CC7, 7)
  value = math.min(127, CC7Value + math.floor(value * 70 / 100)) -- add 70% of resonance to volume
  if value ~= prevValueVol then
    midi.sendControlChange(devPort, channel, 7, value)
    if CC7Value <= 127 then
      parameterMap.set(deviceId, PT_VIRTUAL, 141,
        math.floor(127 * (value - CC7Value) / (127 - CC7Value)))
    end
    prevValueVol = value
  end
end

function midi.onControlChange(midiInput, channelIn, controllerNumber, value)
  if channelIn ~= channel then return end
  if controllerNumber == 21 then -- CC 21 = resonance on Minitaur; adjust for other synths
    resoCompensation(valueObject, value)
    return
  end
end
