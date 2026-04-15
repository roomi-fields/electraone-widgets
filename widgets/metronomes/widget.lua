-- Widget: metronomes
-- Metronomes — visual tempo references
-- Original author: Dave House
-- Source: https://app.electra.one/preset/CBRYC9JppeZUzOqgCvBT
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

------------------------------------------------------------------
--  Electra-One Mk-2 · SIX Bouncing Balls · v12.0
--  • master RUN  (bRun)
--  • RESET button (bReset) parks all balls at the left wall
--  • NEW: global speed-multiplier slider  (gSpeed)
--      – S-ID  gSpeed   range 1…100   default 50
--      – value 1   → ×0.1   (10× slower)
--        value 50  → ×1     (exact pot settings)
--        value 100 → ×10    (10× faster)
--  • per-ball  Chan · Note · Speed · Vel-L · Vel-R
--  • 6 lanes, canvas ID 1 (“bGfx”) 480×480
------------------------------------------------------------------

---------------- constants ---------------------------------------
local CANVAS_ID = 1
local W,H       = 640, 480
local ROWS      = 6
local TICK_MS   = 20
local MIDI_PORT = 1
------------------------------------------------------------------
-- helpers
------------------------------------------------------------------
local function clamp(v,a,b)  return (v<a) and a or (v>b) and b or v end
local function knobToMs(k)   return 50 + (k/127)*(5000-50) end
-- gSpeed 1…100  → multiplier 0.1…10   (log10 curve, symmetrical)
local function gKnobToMul(k) return 10 ^ ((k-50)/50) end

------------------------------------------------------------------
-- ball data  (rows & colours)
------------------------------------------------------------------
local balls = {
  {col=0xFFFF,row=1,pos=0,dir=1,ch=0,note=60,spdKn=64,velL=100,velR=100},
  {col=0xF81F,row=2,pos=0,dir=1,ch=0,note=67,spdKn=64,velL=100,velR=100},
  {col=0x07FF,row=3,pos=0,dir=1,ch=0,note=72,spdKn=64,velL=100,velR=100},
  {col=0xFFE0,row=4,pos=0,dir=1,ch=0,note=74,spdKn=64,velL=100,velR=100},
  {col=0x07E0,row=5,pos=0,dir=1,ch=0,note=77,spdKn=64,velL=100,velR=100},
  {col=0xFFFF,row=6,pos=0,dir=1,ch=0,note=79,spdKn=64,velL=100,velR=100},
}

-- global multiplier (GUI default 50 = ×1)
local gMulKn = 50
local gMul   = 1.0            -- effective multiplier

local function refreshStep(b)  -- use global multiplier
  local ms = knobToMs(b.spdKn) * gMul
  b.step   = 127 * TICK_MS / ms
end
for _,b in ipairs(balls) do refreshStep(b) end

------------------------------------------------------------------
-- RUN & RESET
------------------------------------------------------------------
local runMaster = 0
function bRun(_,v) runMaster=(v==1) and 1 or 0 end
function bReset(_,v)
  if v==1 then
     for _,b in ipairs(balls) do b.pos=0; b.dir=1 end
     if canvas then canvas:repaint() end
  end
end

------------------------------------------------------------------
-- GLOBAL SPEED-MULTIPLIER  (new slider callback)
------------------------------------------------------------------
function gSpeed(_,v)              -- v 1…100
  gMulKn = clamp(v,1,100)
  gMul   = gKnobToMul(gMulKn)
  for _,b in ipairs(balls) do refreshStep(b) end
end

------------------------------------------------------------------
-- per-ball GUI callbacks (auto-generated)
------------------------------------------------------------------
for i=1,6 do
  local id="b"..i; local b=balls[i]
  _G[id.."Chan"]  = function(_,v) b.ch   = clamp(v,1,16) end
  _G[id.."Note"]  = function(_,v) b.note = clamp(v,0,127)  end
  _G[id.."Speed"] = function(_,v) b.spdKn=clamp(v,0,127);  refreshStep(b) end
  _G[id.."VelL"]  = function(_,v) b.velL = clamp(v,0,127)  end
  _G[id.."VelR"]  = function(_,v) b.velR = clamp(v,0,127)  end
end

------------------------------------------------------------------
-- MIDI ping
------------------------------------------------------------------
local function bang(b,vel)
  midi.sendNoteOn (MIDI_PORT,b.ch,b.note,clamp(vel,0,127))
  midi.sendNoteOff(MIDI_PORT,b.ch,b.note,0)
end

------------------------------------------------------------------
-- TIMER
------------------------------------------------------------------
timer.enable(); timer.setPeriod(TICK_MS)
function timer.onTick()
  if runMaster~=1 then return end
  for _,b in ipairs(balls) do
    b.pos=b.pos+b.dir*b.step
    if b.dir==1 and b.pos>=127 then b.pos=127;b.dir=-1;bang(b,b.velR)
    elseif b.dir==-1 and b.pos<=0 then b.pos=0;b.dir=1;bang(b,b.velL)
    end
  end
  if canvas then canvas:repaint() end
end

------------------------------------------------------------------
-- PAINTER
------------------------------------------------------------------
local function paintCanvas(ctrl)
  local B=ctrl:getBounds(); local W,H=B[WIDTH],B[HEIGHT]
  graphics.setColor(0x0000); graphics.fillRect(0,0,W,H)
  graphics.setColor(0x4444); graphics.drawLine(2,0,2,H); graphics.drawLine(W-3,0,W-3,H)

  local laneH=H/ROWS; local r=math.max(4,laneH*0.30); local travel=W-2*r-8
  for _,b in ipairs(balls) do
    local x=2+r+travel*b.pos/127
    local y=laneH*(b.row-0.5)
    graphics.setColor(b.col)
    graphics.fillCircle(math.floor(x+0.5), math.floor(y+0.5), r)
  end
end

------------------------------------------------------------------
-- PRESET LOAD
------------------------------------------------------------------
function preset.onLoad()
  canvas=controls.get(CANVAS_ID)
  if canvas then
      local B=canvas:getBounds(); B[WIDTH],B[HEIGHT]=W,H
      canvas:setBounds(B); canvas:setPaintCallback(paintCanvas); canvas:repaint()
  end

  runMaster=controls.getValue("bRun") or 0
  gMulKn   = controls.getValue("gSpeed") or 50
  gMul     = gKnobToMul(gMulKn)

  for i=1,6 do
    local id="b"..i; local b=balls[i]
    b.ch   =(controls.getValue(id.."Chan")  or 1)
    b.note =  controls.getValue(id.."Note")  or b.note
    b.spdKn=  controls.getValue(id.."Speed") or 64
    b.velL =  controls.getValue(id.."VelL")  or 100
    b.velR =  controls.getValue(id.."VelR")  or 100
    refreshStep(b)
  end
end
