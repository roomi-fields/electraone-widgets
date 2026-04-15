-- Widget: multi env encoders
-- Multi-env encoders — multi-stage envelope
-- Original author: Thomas Moravansky (Electra One co-founder)
-- Source: https://app.electra.one/preset/ZChNPfheMT4kuBe79RXG
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

-- if loop start/end for sustain and loop start/end for release cannot overlap, then use a second custom control across the top
-- user selects which with button at the bottom then touches above the corresponding points to start/end or
-- touches and slides to include a section

-- also, possibly be able to overlap Free Env and Wave Env on same screen.  Use button to 'activate' one or the other.
-- look into displaying time/level values across the top for the stages as a summary.



-- current plan - store the raw data touch points and then scale that when updating the parameterMap and/or sending out MIDI
-- incoming data has to be arranged and scaled for the display.  So,
-- segment times of 0 to 127 get mapped to the grid points starting with x=0,y=height
-- Preset compatibility check
assert(
    controller.isRequired(MODEL_MK2, "3.6.0"),
    "Version 3.6.0 or higher is required"
)

devId = 0
portNum = PORT_1

-- Constants
--
NUMPTS   =   6
LOW_MIDI =   0
HI_MIDI  = 127

-- Index info
AX  = 1
AY  = 2
CLR = 3

-- Colors
local STD_COLOR = 0xB0C0
local ACT_COLOR = 0xFF0000


-- Active area dimensions
local XY_PAD_WIDTH = 767
local XY_PAD_HEIGHT = 255

-- Bunch of globals
--
local envPts = {}

envPts[0] = {LOW_MIDI, LOW_MIDI, STD_COLOR}
envPts[NUMPTS+1] = {HI_MIDI, HI_MIDI, STD_COLOR}
for i=1,NUMPTS do
   envPts[i] = {HI_MIDI, LOW_MIDI+20, STD_COLOR}
end
envPts[1][CLR] = ACT_COLOR

activePt = 1

-- Shortcut for graphics object
local g = graphics

-- The XY pad control
local xyPadControl = controls.get(4)
xyPadControl.x = 0
xyPadControl.y = 0

-- event handling
events.subscribe(POTS)

function events.onPotTouch(potId, controlId, touched)
   local valId = 0
   local ptVal = 0
   if (potId == 6) then
      xyPadControl:setPot(CONTROL_SET_3, POT_7)
      if (activePt ~= NUMPTS+1) then  ptVal = activePt  end
      valId = xyPadControl:getValue("value")
      valId:setRange(1,NUMPTS,math.max(ptVal,1),true)
   elseif (potId == 10) then
      xyPadControl:setPot(CONTROL_SET_3, POT_11)
      if (activePt ~= NUMPTS+1) then  ptVal = envPts[activePt][AX]  end
      valId = xyPadControl:getValue("value")
      valId:setRange(LOW_MIDI,HI_MIDI,ptVal,true)
   elseif (potId == 11) then
      xyPadControl:setPot(CONTROL_SET_3, POT_12)
      if (activePt ~= NUMPTS+1) then  ptVal = envPts[activePt][AY]  end
      valId = xyPadControl:getValue("value")
      valId:setRange(LOW_MIDI,HI_MIDI,ptVal,true)
   end
end

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
    xyPadControl:setPotCallback(potCallback)
   
   -- set the range for selecting the active point
   local valId = xyPadControl:getValue("value")
   valId:setRange(1,NUMPTS,1,true)
end
 

function printValues()
   local timeTxt = ""
   local levelTxt = ""

   for i=1,NUMPTS do
      if (i == activePt) then
         g.setColor(ACT_COLOR)
      else
         g.setColor(STD_COLOR)
      end

      g.print(10+(i*100), 5, string.format("T%d: %d ", i, envPts[i][AX]), 10, LEFT)
      g.print(10+(i*100), 20, string.format("L%d: %d ", i, envPts[i][AY]), 10, LEFT)
   end
   g.setColor(STD_COLOR)
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
   g.drawRoundRect(0, 0, bounds[WIDTH], bounds[HEIGHT], 8)
   
   -- NOTE that X increase from left to right while Y decrease going from bottom to top
   --   so, the Y value is subtracted as you increase the MIDI value from 0 to 127
   -- This is also where scaling needs to be done to fit the MIDI range into the pixel range
   --   and is dependent on the number of points and the size of the drawing area.
   local xPos = 0
   local yPos = XY_PAD_HEIGHT
   for i=1,NUMPTS do
      local xScale = envPts[i][AX]
      local ym1Scale = envPts[i-1][AY] * 2
      local yScale = envPts[i][AY] * 2
      g.setColor(envPts[i][CLR])
      g.fillCircle(xPos + xScale, yPos - yScale, 10)
      g.setColor(STD_COLOR)
      g.drawLine(xPos, yPos - ym1Scale, xPos + xScale, yPos - yScale)
      xPos = xPos + xScale
   end
   
   -- if the context needs a line going from the last point to the edge of the display, this might do it
   -- g.drawLine(xPos + envPts[NUMPTS][AX], yPos - (envPts[NUMPTS][AY] * 2), XY_PAD_WIDTH-3, XY_PAD_HEIGHT-3)

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
      
      -- VERIFY that this is OK for the last point
      for i=1,activePt-1 do  preX = preX + envPts[i][AX]  end
      postX = preX + envPts[activePt][AX]
      if (activePt ~= endPt) then
         postX = postX + envPts[activePt+1][AX]
      end

      -- CHECK - do we need to add an equal to the greater than, less than checks?
      if (activePt ~= endPt) and (touchEvent.x >= preX) and (touchEvent.x <= postX) then
         control.x = touchEvent.x
         control.y = touchEvent.y
         -- need to 'unscale' the value here
         envPts[activePt][AX] = math.min(control.x - preX, HI_MIDI)
         envPts[activePt][AY] = math.floor((XY_PAD_HEIGHT - control.y) / 2)

print("MOVE: envPts[" ..  activePt .. "][AX],[AY] = " .. envPts[activePt][AX] .. ", " .. envPts[activePt][AY])
         parameterMap.set(1,PT_VIRTUAL,9,envPts[activePt][AX])
         parameterMap.set(1,PT_VIRTUAL,10,envPts[activePt][AY])
         
--         control:repaint()
      end
   elseif touchEvent.type == DOWN then
      local i = 1
      local xPos = 0
      local yPos = XY_PAD_HEIGHT

      local minDist = math.huge
      local closestPt = endPt

      while (i < endPt) do
         local xScale = envPts[i][AX]
         local yScale = envPts[i][AY] * 2

         local dist = math.sqrt((touchEvent.x - (xPos + xScale))^2 + (touchEvent.y - (yPos - yScale))^2)
         if dist < minDist then
            minDist = dist
            closestPt = i
         end

         xPos = xPos + xScale
         i = i + 1
      end

      if minDist <= tolerance then
         i = closestPt
      else
         i = endPt
      end

      -- first if statement may result in no points selected
      -- might be ok, but impacts point select control
      -- ACTUALLY, it does not hurt to assign things to the endPt location since it a legit array position
      -- maybe better to just leave it alone until a valid (new) point is selected
      if (activePt ~= endPt) then  envPts[activePt][CLR] = STD_COLOR  end
      if (   i     ~= endPt) then  envPts[i][CLR]        = ACT_COLOR  end
      activePt = i
      parameterMap.set(1,PT_VIRTUAL,8,math.min(activePt,endPt))
   end

   control:repaint()

end

-- A callback to handle events on assigned knob
--

-- NOTE - the callback has no idea what the control range is for the assigned knob
--        as a result, it is possible to go out of bounds in the delta is not checked.
-- CURIOSITY CHECK - print out potEvent.type here to see if we always get a touch with the move
-- if so, maybe do something on the touch to make the move less of a jump sometimes?
--
function potCallback(control, potEvent)
   print("potEvent.id = " .. potEvent.id .. ", potEvent.delta = " .. potEvent.delta)
   if potEvent.type == MOVE then
      if (potEvent.id == 6) then
         local curVal = math.max(1, math.min(activePt + potEvent.delta, NUMPTS))

         envPts[activePt][CLR] = STD_COLOR
         activePt = curVal
         envPts[activePt][CLR] = ACT_COLOR

         parameterMap.set(1,PT_VIRTUAL,9,envPts[activePt][AX])
         parameterMap.set(1,PT_VIRTUAL,10,envPts[activePt][AY])
         parameterMap.set(1,PT_VIRTUAL,8,activePt)

      elseif (potEvent.id == 10) then
         envPts[activePt][AX] = math.max(LOW_MIDI, math.min(envPts[activePt][AX] + potEvent.delta, HI_MIDI))
         parameterMap.set(1,PT_VIRTUAL,9,envPts[activePt][AX])
      elseif (potEvent.id == 11) then
         envPts[activePt][AY] = math.max(LOW_MIDI, math.min(envPts[activePt][AY] + potEvent.delta, HI_MIDI))
         parameterMap.set(1,PT_VIRTUAL,10,envPts[activePt][AY])
      end
print("potCallback(): envPts[" ..  activePt .. "][AX],[AY] = " .. envPts[activePt][AX] .. ", " .. envPts[activePt][AY])
      control:repaint()
   end
end

-- Wave Env params are time then level by stage starting at 125, so
-- time  params are 125,127,129,131,133,135,137,139 and
-- level params are 126,128,130,132,134,136,138,140

-- NOTE in the sysex, 4,8,9,10 are reserved (i.e. not used) in any editor context.
-- Borrow 9 and 10 to use as the base for sending all time and level params

-- bufNum 0x00 = sound edit buffer, 0x20 = multi edit buffer, 0x24 = Global edit buffer
--        in multi mode, butNum can be 0x01 to 0x08
bufNum = 0x00

function parameterMap.onChange (valueObjects, origin, midiValue)

   -- options here are INTERNAL, MIDI, LUA
   -- only send if user changes things
   if (origin == MIDI) then return end

   local paramSysex = {}
 
   local ctlId = valueObjects[1]:getControl():getId()
   local pNum = valueObjects[1]:getMessage():getParameterNumber()
   local hh=0x00
   local pp=0x00

   if (origin == LUA) and (pNum ~= 9) and (pNum ~= 10) then return end
   
   -- create objects with control IDs very high as reserved Parameter Numbers and then
   --  do not process them.

   if (pNum < 240) then
      -- Time and Level mapped from 2 controls across 16 variables
      if (pNum == 9) or (pNum == 10) then
         pNum = 114 + pNum + (activePt * 2)
      end

      if (pNum > 127) then
         hh = 0x01
      end
      pp = pNum % 128

      print("onChange(): parameter # = " ..  pp .. ", value = " .. midiValue)

      paramSysex = {0x3E, 0x0E, devId, 0x20, bufNum, hh, pp, midiValue}
   elseif (pNum < 293) then
      pNum = pNum - 260
      paramSysex = {0x3E, 0x0E, devId, 0x24, pNum, midiValue}
   else
      print("multi param")
   end
--   midi.sendSysex(portNum, paramSysex)
end


-- formatter functions for point select, x position, and y position
-- do the display formatting to match the target device here
function dispDot(valueObject,value)
   if (activePt == NUMPTS+1) then
      return ("None")
   else
      return activePt
   end
end

function dispX(valueObject,value)
   if (activePt == NUMPTS+1) then
      return (" ? ")
   else
      return envPts[activePt][AX]
   end
end

function dispY(valueObject,value)
   if (activePt == NUMPTS+1) then
      return (" ? ")
   else
      return envPts[activePt][AY]
   end
end
