-- Widget: EG Template (7-variant Envelope Generator)
-- Original author: NewIgnis (Ignace Vanbiervliet) — 2026
-- Source: https://app.electra.one/preset/HbynnPgMY6ei48yqOlrw
-- Forum: https://forum.electra.one/t/custom-control-for-envelopes-anyone/4169
-- Imported: 2026-04-15 via Firestore `projects` collection.
-- License at source: none specified.
-- Author's note: "A versatile Envelope Generator, as seen often on digital
-- synths. Uses the 4 stage envelope of the Mk2 and can display 7 EG variants."
-- Removal / relicensing: see NOTICE.md at repo root.

deviceId = 1
device = devices.get(deviceId)
devPort = device:getPort()
devChannel = device:getChannel()
local authorDate ="New Ignis 2026"
info.setText(authorDate)


ctls = {1,2,12,13,8,4,6} -- ctl numbers R1,L1,R2..L4
stages = {"r1","l1","r2","l2","r3","l3","r4"}
stagePar = {1001,1002,1003,1004,1005,1006,1007} -- virtual par of each stage in the EG graph
ctlPar = {11,12,13,14,15,16,17} -- CC par of each stage

slots = {{2,0,0,0,3},{2,0,0,0,0,0,5},{2,0,0,0,3,4},{2,0,0,0,3,4,5},{2,0,8,0,3,4,5},{1,0,2,0,3,4,5},{2,0,3,4,8,9,10},{1,2,3,4,8,9,10}} -- slot position or hide
names = {{"Attack",127,127,127,"Decay",0,0}, -- AD ctl names or fixed values
        {"Attack",127,127,127,127,127,"Release"}, -- AR
        {"Attack",127,127,127,"Decay","Sustain","#R3"}, -- ADS
        {"Attack",127,127,127,"Decay","Sustain","Release"}, -- ADSR
        {"Attack",127,"Hold",127,"Decay","Sustain","Release"}, -- AHDSR
        {"Delay",0,"Attack",127,"Decay","Sustain","Release"}, -- DADSR
        {"Attack",127,"Decay","Breakpoint","Slope","Sustain","Release"}, -- ADBSSR
        {"Attack","Attack Level","Decay","Sustain","Decay2","Sustain2","Release"} -- ALDSDSR
        }

function setEG(valueObject, value)
  value = value + 1
  local position = 0
  local control = controls.get(ctls[1])
  for i = 1,7 do
    control = controls.get(ctls[i])
    if slots[value][i] then position = slots[value][i] else position = 0 end 
    if position == 0 then 
      control:setVisible (false)
      if type(names[value][i]) == "number" then -- set a fixed value
        parameterMap.set(deviceId, PT_VIRTUAL,stagePar[i],names[value][i])
      end
    else -- visible control
      control:setSlot(slots[value][i], 1)
      control:setName (names[value][i])
      control:setVisible (true)
      parameterMap.set(deviceId, PT_VIRTUAL,stagePar[i],parameterMap.get(deviceId, PT_CC7,ctlPar[i]))
    end
  end 
end

function convRate(valueObject, value)
  local message = valueObject:getMessage ()
  local paramNum = message:getParameterNumber()
  parameterMap.set (deviceId, PT_VIRTUAL, paramNum+990, 127-value)
  if paramNum == 15 and parameterMap.get (deviceId, PT_CC7, 9) == 2 then -- ADS EG
    parameterMap.set (deviceId, PT_VIRTUAL, 1007, 127-value)  -- set release equal to sustain
  end
end

function convLevel(valueObject, value)
  local message = valueObject:getMessage ()
  local paramNum = message:getParameterNumber()
  parameterMap.set (deviceId, PT_VIRTUAL, paramNum+990, value)
end