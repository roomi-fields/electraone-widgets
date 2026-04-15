-- Widget: XT Envelopes (custom XY-pad-style envelope editor)
-- Original author: Thomas Moravansky (Electra One co-founder)
-- Source: https://app.electra.one/preset/GK6wmbgvwM6S3GanpoN7
-- Imported: 2026-04-15 via Firestore `projects` collection.
-- License at source: none specified.
-- Author's note: "Demo of simple XY Pad. Note, the preset is meant to demonstrate
-- using the paint, touch, pot action callbacks. It does not handle any MIDI
-- messaging. It is done on purpose, to keep things simple."
-- Removal / relicensing: see NOTICE.md at repo root.


-- Preset compatibility check
assert(
    controller.isRequired(MODEL_MK2, "3.6.0"),
    "Version 3.6.0 or higher is required"
)

devId = 0
portNum = PORT_1

-- Constants
--

WAVEPTS = 8
FREEPTS = 4
NUMPTS  = WAVEPTS

LOW_MIDI =   0
HI_MIDI  = 127

WIN_OFST = 70
SUSTAIN  = 64
SCALEX   = 0.90625
SCALEY   = 2

-- envelope stage index constants
AX  = 1
AY  = 2
CLR = 3

-- Colors
local STD_COLOR = 0xB0C0
local ACT_COLOR = 0xFF0000
local OFF_COLOR = 0x00FF00
local ON_COLOR  = 0x0000FF


-- Active area dimensions
local XY_PAD_WIDTH  = (128 * SCALEX * WAVEPTS) + SUSTAIN
local XY_PAD_HEIGHT = (128 * SCALEY) + WIN_OFST

-- Bunch of globals
--
-- Wave, Free envelope point info
-- activeEnv is assigned to either waveEnv or freeEnv
-- curEnv is flag for special cases between the envelopes
--  1 is wave, 2 is free
--
local activePt  = 1
local curEnv    = 1
local activeEnv = {}
local waveEnv   = {}
local freeEnv   = {}

freeEnv[0] = {LOW_MIDI, LOW_MIDI+64, STD_COLOR}
freeEnv[FREEPTS+1] = {HI_MIDI, HI_MIDI, STD_COLOR}
for i=1,FREEPTS do
   freeEnv[i] = {HI_MIDI, LOW_MIDI+84, STD_COLOR}
end
freeEnv[activePt][CLR] = ACT_COLOR

waveEnv[0] = {LOW_MIDI, LOW_MIDI, STD_COLOR}
waveEnv[WAVEPTS+1] = {HI_MIDI, HI_MIDI, STD_COLOR}
for i=1,WAVEPTS do
   waveEnv[i] = {HI_MIDI, LOW_MIDI+20, STD_COLOR}
end
waveEnv[activePt][CLR] = ACT_COLOR

activeEnv = waveEnv

-- Wave envelope key loop stuff
-- [1] is on loop, [2] is off loop
-- inside each, [1] is start segment, [2] is end segment, [3] is on/off, [4] is the color
envLoop = {}
envLoop[1] = {1,4,false,ON_COLOR}
envLoop[2] = {4,8,false,OFF_COLOR}


-- Shortcut for graphics object
local g = graphics

-- The XY pad control
local xyPadControl = controls.get(4)
xyPadControl.x = 0
xyPadControl.y = 0


-- Initialize the preset
--
function preset.onLoad()
    -- Resize the XY Pad (Custom) Control
    local bounds = xyPadControl:getBounds()
    bounds[WIDTH] = XY_PAD_WIDTH
    bounds[HEIGHT] = XY_PAD_HEIGHT
    xyPadControl:setBounds(bounds)

    -- Assign all Custom Control callbacks
    xyPadControl:setPaintCallback(paintXyPad)
    xyPadControl:setTouchCallback(touchCallback)
   
   -- set the range for selecting the active point
   local ctlId = controls.get(5)
   local valId = ctlId:getValue("value")
   valId:setRange(1,NUMPTS,1,true)

   -- ctl 1,8,9   for key on loop
   -- ctl 3,10,11 for key off loop
   ctlId = controls.get(1)
   ctlId:setColor(ON_COLOR)
   ctlId = controls.get(8)
   ctlId:setColor(ON_COLOR)
   ctlId = controls.get(9)
   ctlId:setColor(ON_COLOR)

   ctlId = controls.get(3)
   ctlId:setColor(OFF_COLOR)
   ctlId = controls.get(10)
   ctlId:setColor(OFF_COLOR)
   ctlId = controls.get(11)
   ctlId:setColor(OFF_COLOR)
end
 

function printValues()
   local ts = "T%d: %d "
   local ls = "L%d: %d "
   local tf = "T8: %d "
   local lf = "L8: %d "
   local ofst = 0

   if (curEnv == 2) then
      ls = "L%d: %+d "
      tf = "Rel T:  %d "
      lf = "Rel L: %+d "
      ofst = SUSTAIN
   end

   for i=1,NUMPTS do
         g.setColor(activeEnv[i][CLR])
         if (i < NUMPTS) then
            g.print(i*110,  0, string.format(ts, i, activeEnv[i][AX]), 10, LEFT)
            g.print(i*110, 15, string.format(ls, i, activeEnv[i][AY]-ofst), 10, LEFT)
         else
            g.print(i*110,  0, string.format(tf, activeEnv[NUMPTS][AX]), 10, LEFT)
            g.print(i*110, 15, string.format(lf, activeEnv[NUMPTS][AY]-ofst), 10, LEFT)
         end
   end
   g.setColor(STD_COLOR)
end

function loopVis(isVis)
   local ctl = controls.get(1)
   ctl:setVisible(isVis)
   ctl = controls.get(3)
   ctl:setVisible(isVis)
   for i=8,11 do
      ctl = controls.get(i)
      ctl:setVisible(isVis)
   end
end

function loopCalc(loop)
      local st = 0
      for i=1,envLoop[loop][1] do st = st + waveEnv[i][AX] end
      st = math.floor(st * SCALEX)

      local sz = 0
      for i=envLoop[loop][1]+1,envLoop[loop][2] do  sz = sz + waveEnv[i][AX]  end
      sz = math.floor(sz * SCALEX)
      return st,sz
end

-- A callback to draw the XY pad graphics
--
function paintXyPad(control, value)
   local bounds = control:getBounds()

   -- Clear the Control's bounding box
   g.setColor(0x0000)
   g.fillRect(0, 0, bounds[WIDTH], bounds[HEIGHT])

   -- Draw the fixed graphics
   g.setColor(STD_COLOR)
   g.drawRect(0, WIN_OFST, bounds[WIDTH], bounds[HEIGHT]-WIN_OFST)
   
   if (curEnv == 1) then
      -- Draw the key on and key off loop indicators
      local strt, lnth
      for i=1,2 do
         strt,lnth = loopCalc(i)
         g.setColor(envLoop[i][4])

         if (envLoop[i][3] == true) then
            if (i == 2) and (envLoop[1][3] == false) then strt = strt + SUSTAIN end
            g.fillRect(strt, (i*15)+20, lnth, 10)
         else
            local keyRel = 0
            local ofst = 0
            for j=1,envLoop[i][2] do keyRel = keyRel + waveEnv[j][AX] end
            if (envLoop[1][3] == false) then ofst = SUSTAIN end
            
            keyRel = math.floor(keyRel * SCALEX) + ofst
            g.fillRect(keyRel-5, (i*15)+20, 10, 10)
         end
      end
   else
      local zeroLine = math.floor((XY_PAD_HEIGHT + WIN_OFST) / 2)
      g.setColor(STD_COLOR)
      g.drawLine(0, zeroLine, XY_PAD_WIDTH, zeroLine)
   end

   local xPos = 0
   local yPos = XY_PAD_HEIGHT
   for i=1,NUMPTS do
      local xScale = math.floor(activeEnv[i][AX] * SCALEX)
      local ym1Scale = activeEnv[i-1][AY] * SCALEY
      local yScale   = activeEnv[i][AY] * SCALEY

      g.setColor(activeEnv[i][CLR])
      g.fillCircle(xPos + xScale, yPos - yScale, 10)
      g.setColor(STD_COLOR)
      g.drawLine(xPos, yPos - ym1Scale, xPos + xScale, yPos - yScale)
      xPos = xPos + xScale

      if (curEnv == 1) and (i == envLoop[1][2]) and (envLoop[1][3] == false) then
         g.drawLine(xPos, yPos - yScale, xPos + SUSTAIN, yPos - yScale)
         xPos = xPos + SUSTAIN
      end
   end     
   
   -- show the time and level values for each point
   printValues()
end

-- A callback to handle an LCD touch
--
function touchCallback(control, touchEvent)
   local endPt = NUMPTS+1
   local tolerance = 25  -- Increased tolerance for touch detection
 
   if touchEvent.type == MOVE then
      local preX = 0
      local postX = 0
      
      -- if we go 'out of bounds', just stop      
      if (touchEvent.y < WIN_OFST) then return end
      
      -- preX and postX are for boundary checking.  For most applications
      -- we do not want envelope points crossing each other
      for i=1,activePt-1 do  preX = preX + activeEnv[i][AX]  end
      postX = preX + activeEnv[activePt][AX]
      if (activePt ~= endPt) then
         postX = postX + activeEnv[activePt+1][AX]
      end

      if (activePt ~= endPt) and (touchEvent.x >= preX) and (touchEvent.x <= postX) then
         control.x = touchEvent.x
         control.y = touchEvent.y
         -- need to 'unscale' the value here
         activeEnv[activePt][AX] = math.min(math.floor((control.x - preX) / SCALEX), HI_MIDI)
         activeEnv[activePt][AY] = math.floor((XY_PAD_HEIGHT - control.y) / SCALEY)

         -- this updates the control in real time.  Not sure we need this since the other graphics are doing it
         -- could move this to the UP event unless we need to be sending MIDI while moving.
         -- maybe either/or depending on whether the receiving device can handle the stream
         parameterMap.set(1,PT_VIRTUAL, 9,activeEnv[activePt][AX])
         parameterMap.set(1,PT_VIRTUAL,10,activeEnv[activePt][AY])
      end
   elseif touchEvent.type == DOWN then
      local i = 1
      local xPos = 0
      local yPos = XY_PAD_HEIGHT

      -- if we are in bounds, check which point, else nothing selected      
      if (touchEvent.y >= WIN_OFST) then
         while (i < endPt) do
            local xScale = math.floor(activeEnv[i][AX] * SCALEX)
            -- for wave envelope, check if sustain is active (looping off) and look for the sustain segment
            if (curEnv == 1) and (envLoop[1][3] == false) and (i == envLoop[1][2]+1) then
               xScale = xScale + SUSTAIN
            end
            local yScale = activeEnv[i][AY] * SCALEY

            if (touchEvent.x >= (xPos + xScale - 15) and touchEvent.x <= (xPos + xScale + 15) and
                touchEvent.y >= (yPos - yScale - 15) and touchEvent.y <= (yPos - yScale + 15)) then
               break
            else
               xPos = xPos + xScale
               i = i + 1
            end
         end
      else
         i = endPt
      end

      if (activePt ~= endPt) then  activeEnv[activePt][CLR] = STD_COLOR  end
      if (   i     ~= endPt) then  activeEnv[i][CLR]        = ACT_COLOR  end
      activePt = i
      parameterMap.set(1,PT_VIRTUAL,8,math.min(activePt,endPt))
   end

   control:repaint()

end

-- Wave Env params are time then level by stage starting at 125, so
-- time  params are 125,127,129,131,133,135,137,139 and
-- level params are 126,128,130,132,134,136,138,140

-- Free Env params are time then level by stage starting at 149, so
-- time params  are 149,151,153,155 and
-- level params are 150, 152, 154, 156

-- NOTE in the sysex, 4,8,9,10 are reserved (i.e. not used) in any editor context.
-- Borrow 9 and 10 to use as the base for sending all time and level params
--
-- I could just use param numbers above and beyond the parameterMap values 
--  like always in the final iteration, but for now this works and the idea is the same.
-- easier to handle excepetions in code here versus changing values in the control objects all the time

-- bufNum 0x00 = sound edit buffer, 0x20 = multi edit buffer, 0x24 = Global edit buffer
--        in multi mode, bufNum can be 0x01 to 0x08
bufNum = 0x00

function parameterMap.onChange (valueObjects, origin, midiValue)

   if (origin == MIDI) then return end

   local paramSysex = {}
 
   local ctlId = valueObjects[1]:getControl():getId()
   local pNum = valueObjects[1]:getMessage():getParameterNumber()
   local hh=0x00
   local pp=0x00

   -- multi stage envelope handling is done by multiplexing the original parameter numbers
   if (origin == LUA) and (pNum ~= 9) and (pNum ~= 10) then return end
   
   -- create objects with control IDs very high as reserved Parameter Numbers and then
   --  do not process them.

   if (pNum < 240) then
      -- Time and Level mapped from 2 controls across 16 variables
      if (pNum == 9) or (pNum == 10) then
         if (curEnv == 1) then
            pNum = 114 + pNum + (activePt * 2)
         else
            pNum = 138 + pNum + (activePt * 2)
         end
      end

      if (pNum > 127) then
         hh = 0x01
      end
      pp = pNum % 128
      
      paramSysex = {0x3E, 0x0E, devId, 0x20, bufNum, hh, pp, midiValue}
   elseif (pNum < 293) then
      pNum = pNum - 260
      paramSysex = {0x3E, 0x0E, devId, 0x24, pNum, midiValue}
   else
      print("multi param")
   end
   midi.sendSysex(portNum, paramSysex)
end


-- formatter functions for point select, x position, and y position
-- do the display formatting to match the target device here
function dispDot(valueObject,value)
   if (activePt == NUMPTS+1) then
      return ("None")
   else
      return math.floor(activePt)
   end
end

function dispX(valueObject,value)
   if (activePt == NUMPTS+1) then
      return (" ? ")
   else
      return math.floor(activeEnv[activePt][AX])
   end
end

function dispY(valueObject,value)
   if (activePt == NUMPTS+1) then
      return (" ? ")
   else
      local ofst = 0
      if (curEnv == 2) then ofst = SUSTAIN  end
      return math.floor(activeEnv[activePt][AY] - ofst)
   end
end


function adjustTime(valueObject,value)
   if (activePt ~= NUMPTS+1) then
      activeEnv[activePt][AX] = value
      xyPadControl:repaint()
   end
end


function adjustLevel(valueObject,value)
   if (activePt ~= NUMPTS+1) then
      activeEnv[activePt][AY] = value
      xyPadControl:repaint()
   end
end


function selectStage(valueObject,value)
   activeEnv[activePt][CLR] = STD_COLOR
   activePt = value
   activeEnv[activePt][CLR] = ACT_COLOR

   parameterMap.set(1,PT_VIRTUAL,9,activeEnv[activePt][AX])
   parameterMap.set(1,PT_VIRTUAL,10,activeEnv[activePt][AY])
   xyPadControl:repaint()
end


function selectEnvelope(valueObject,value)
   local ctl = valueObject:getControl()
   if (value == 1) then
      freeEnv[activePt][CLR] = STD_COLOR
      loopVis(true)
      activeEnv = waveEnv
      curEnv = 1
      NUMPTS = WAVEPTS
      ctl:setName("Wave Env")
   else
      waveEnv[activePt][CLR] = STD_COLOR
      loopVis(false)
      activeEnv = freeEnv
      curEnv = 2
      NUMPTS = FREEPTS
      ctl:setName("Free Env")
   end
   activePt = 1
   local ctlId = controls.get(5)
   local valId = ctlId:getValue("value")
   valId:setRange(1,NUMPTS,activePt,true)
   xyPadControl:repaint()
end
  

-- Wave envelope key on/off looping
-- ctl 1,8,9   for key on loop
-- ctl 3,10,11 for key off loop

function setState(valueObject,value)
   local ctlId = valueObject:getControl():getId()
   local onOff = 1
   if (ctlId == 3) then  onOff=2  end
   
   if (value == 1) then
      envLoop[onOff][3] = true
   else
      envLoop[onOff][3] = false
   end
   xyPadControl:repaint()
end

function setStart(valueObject,value)
   local ctlId = valueObject:getControl():getId()
   local onOff = 1
   if (ctlId == 10) then  onOff=2  end

   envLoop[onOff][1] = value
   xyPadControl:repaint()
end


function setEnd(valueObject,value)
   local ctlId = valueObject:getControl():getId()
   local onOff = 1
   if (ctlId == 11) then  onOff=2  end

   envLoop[onOff][2] = value
   xyPadControl:repaint()
end

