-- Widget: Lua LFO (triangle / square / ramp-up / ramp-down)
-- Description: timer-based LFO running on Electra One, modulating any CC on the
--              target device. Supports note-on phase reset.
-- Original author: NewIgnis (Ignace Vanbiervliet)
-- Source: https://forum.electra.one/t/making-additional-modulation-and-expression-with-lua/1778 (posts #12 + #15)
-- Imported: 2026-04-15 — verbatim (one "=" → "==" typo fix noted inline).
-- License at source: none specified. Removal / relicensing: see NOTICE.md at repo root.
--
-- Expected preset layout:
--   Enable pad   → function timerEnable  (PT_VIRTUAL 134 holds the destination CC)
--   Rate fader   → function lfoRate1     (0..∞ — "value" = extra steps per 20ms tick)
--   Shape list   → function lfoShape1    (0=triangle, 1=square, 2=ramp-up, 3=ramp-down)
--   Depth fader  → function lfoDpth1     (0..127)
--   Dest list    → function lfoDest1     (CC number; writes to PT_VIRTUAL 134)
--   Reset pad    → PT_VIRTUAL 181 (0=off, 1..127=start-phase seed)
--
-- Period: 20 ms / tick. Cycle length: 1270 units (default = ~25s at rate 0).
-- Multi-LFO: rename suffix _1 → _2, _3 etc. for multiple independent LFOs.

-- ===== initialization =====
deviceId = 1 -- check your preset, your deviceId might be chosen differently
device   = devices.get(deviceId)
devPort  = device:getPort()
channel  = device:getChannel()

lfoVal1        = 0   -- current LFO output (0..127)
lfoPos1        = 1   -- current position in cycle (1..1270)
lfoStep1       = 0   -- extra steps per tick (rate)
lfoType1       = 0   -- 0=tri, 1=sq, 2=ramp+, 3=ramp-
lfoPrevTarget1 = 128
lfoDepth1      = 127
lfoTarget1     = 26  -- default destination CC; override via the Dest list tile
parameterMap.set(deviceId, PT_VIRTUAL, 134, lfoTarget1)
lfoDefault1 = parameterMap.get(deviceId, PT_CC7, lfoTarget1)

timer.setPeriod(20) -- tick every 20 ms

-- ===== callbacks wired to preset controls =====

function timerEnable(valueObject, value)
  if value == 1 then
    timer.enable()
    lfoTarget1  = parameterMap.get(deviceId, PT_VIRTUAL, 134)
    lfoDefault1 = parameterMap.get(deviceId, PT_CC7, lfoTarget1)
    print(lfoTarget1 .. " def= " .. lfoDefault1)
  else
    timer.disable()
    parameterMap.set(deviceId, PT_CC7, lfoTarget1, lfoDefault1)
    parameterMap.send(deviceId, PT_CC7, lfoTarget1)
    lfoPrevTarget1 = 128 -- forget previous target
  end
end

function lfoRate1(valueObject, value)  lfoStep1  = value end
function lfoShape1(valueObject, value) lfoType1  = value end
function lfoDpth1(valueObject, value)  lfoDepth1 = value end

function lfoDest1(valueObject, value)
  if lfoPrevTarget1 ~= 128 then -- restore previous target first
    parameterMap.set(deviceId, PT_CC7, lfoTarget1, lfoDefault1)
    parameterMap.send(deviceId, PT_CC7, lfoTarget1)
  end
  lfoPrevTarget1 = lfoTarget1
  lfoTarget1  = parameterMap.get(deviceId, PT_VIRTUAL, 134)
  lfoDefault1 = parameterMap.get(deviceId, PT_CC7, lfoTarget1)
  print("value= " .. value .. " prev: " .. lfoPrevTarget1 .. " → new: " .. lfoTarget1 .. " def: " .. lfoDefault1)
end

-- ===== heartbeat =====

function timer.onTick()
  parameterMap.set(1, PT_CC7, lfoTarget1, math.min(math.max(lfoDefault1 + lfoVal1, 0), 127))
  parameterMap.send(1, PT_CC7, lfoTarget1)
  lfoPos1 = math.fmod(lfoPos1 + lfoStep1 + 1, 1270) + 1

  if lfoType1 == 0 then     -- triangle
    if lfoPos1 >= 636 then
      lfoVal1 = math.floor(lfoDepth1 * ((1270 - lfoPos1) / 635 - 1/2))
    else
      lfoVal1 = math.floor(lfoDepth1 * (lfoPos1 / 635 - 1/2))
    end
  elseif lfoType1 == 1 then -- square
    if lfoPos1 >= 635 then lfoVal1 = lfoDepth1 else lfoVal1 = 0 end
  elseif lfoType1 == 2 then -- ramp up
    lfoVal1 = math.floor(lfoDepth1 * (lfoPos1 - 1) / 1270)
  else                      -- ramp down
    lfoVal1 = math.floor(lfoDepth1 * (1270 - lfoPos1 + 1) / 1270)
  end
end

-- ===== note-on phase reset =====
-- PT_VIRTUAL 181 = reset seed (0 = disabled, 1..127 = starting phase).
-- Note: original post #15 had "= 1" typo (assignment in condition); fixed to "== 1" / "> 0".

function midi.onNoteOn(midiInput, channelIn, noteNumber, volume)
  if channelIn ~= channel then return end
  local seed = parameterMap.get(deviceId, PT_VIRTUAL, 181)
  if seed > 0 then
    lfoPos1 = seed * 10 - 9 -- variable start phase (1..1261)
  end
end
