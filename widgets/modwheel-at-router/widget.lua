-- Widget: Modwheel & Aftertouch Router
-- Description: routes incoming MIDI CC1 (modwheel) and channel aftertouch
--              onto any CC destination with an adjustable depth (% multiplier).
-- Original author: NewIgnis (Ignace Vanbiervliet)
-- Source: https://forum.electra.one/t/making-additional-modulation-and-expression-with-lua/1778?page=1#post_10894
-- Imported: 2026-04-15 — verbatim. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.
--
-- Expected preset layout (reference ids in the original):
--   control 25 → modwheel depth fader (0..100), writes PT_VIRTUAL 129
--   control 26 → aftertouch depth fader (0..100), writes PT_VIRTUAL 131
--   PT_VIRTUAL 128 → modwheel destination CC (0..127)
--   PT_VIRTUAL 130 → aftertouch destination CC (0..127)

-- get the default info on the synth of the preset
deviceId = 1
device = devices.get(deviceId)
devPort = device:getPort()
channel = device:getChannel()

-- retrieving default control values and assigning them to relevant parameters at start-up of preset
setupControl = controls.get(25) -- control is on the 25th location of the preset
setupValue = setupControl:getValue("")
parameterMap.set(deviceId, PT_VIRTUAL, 129, setupValue:getDefault()) -- default mod-wheel multiplier
setupControl = controls.get(26)
setupValue = setupControl:getValue("")
parameterMap.set(deviceId, PT_VIRTUAL, 131, setupValue:getDefault()) -- default aftertouch multiplier

-- apply modwheel to destination
function midi.onControlChange(midiInput, channelIn, controllerNumber, value)
  if channelIn ~= channel then return end
  if controllerNumber ~= 1 then return end
  local modWheelMultiplier = parameterMap.get(deviceId, PT_VIRTUAL, 129)
  local destination        = parameterMap.get(deviceId, PT_VIRTUAL, 128)
  local destinationValue   = parameterMap.get(deviceId, PT_CC7, destination)
  value = math.max(0, math.min(127, destinationValue + math.floor(value * modWheelMultiplier / 100)))
  midi.sendControlChange(devPort, channel, destination, value)
end

-- apply aftertouch to destination
function midi.onAfterTouchChannel(midiInput, channelIn, value)
  if channelIn ~= channel then return end
  local atMultiplier     = parameterMap.get(deviceId, PT_VIRTUAL, 131)
  local destination      = parameterMap.get(deviceId, PT_VIRTUAL, 130)
  local destinationValue = parameterMap.get(deviceId, PT_CC7, destination)
  value = math.max(0, math.min(127, destinationValue + math.floor(value * atMultiplier / 100)))
  midi.sendControlChange(devPort, channel, destination, value)
end
