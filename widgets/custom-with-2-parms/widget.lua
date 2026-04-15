-- Widget: Custom with 2 parms
-- 3 custom tiles showing 2 parameters each
-- Original author: Ralph Mertingk
-- Source: https://app.electra.one/preset/xXHHSJir8jJHt3P1uWZ6
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

-- Some Custom Controls with two rows of parameters

-- Control Ids & Parameter Numbers
CONTROL_CUSTOM_3V = 4
CONTROL_CUSTOM_FADER = 1
CONTROL_CUSTOM_OVERLAY = 2
PMAP_CUSTOM_3V_1 = 4
PMAP_CUSTOM_3V_2 = 5
PMAP_CUSTOM_FADER_1 = 29
PMAP_CUSTOM_FADER_2 = 30
PMAP_CUSTOM_OVERLAY_1 = 1
PMAP_CUSTOM_OVERLAY_2 = 2

function initCustomControls()
    -- Custom control static definitions for graphics & pot
    CUSTOMDEF_LIST3V = {
        px=8,py=6,pw=40,ph=18,yoffset=25,
        vx=55,vy=11,vw=30,vh=18,xoffset=30,
        potTicks = 20, valueCallback = paintCustomListValues }
    CUSTOMDEF_LIST2V = {
        px=8,py=6,pw=40,ph=18,yoffset=25,
        vx=55,vy=11,vw=30,vh=18,xoffset=45,
        potTicks = 20, valueCallback = paintCustomListValues }
    CUSTOMDEF_OVLIST = {
        px=8,py=6,pw=55,ph=18,yoffset=25,
        vx=55,vy=11,vw=70,vh=18,xoffset=70,
        potTicks = 20, valueCallback = paintCustomOverlayValues }
    CUSTOMDEF_FADER = {
        px=8,py=6,pw=45,ph=18,yoffset=25,
        vx=55,vy=11,vw=58,vh=8,xoffset=25,
        potTicks = 1, valueCallback = paintCustomFaderValues }
    CUSTOMDEF_OVFADER = {
        px=8,py=6,pw=55,ph=18,yoffset=25,
        vx=70,vy=11,vw=38,vh=8,xoffset=30,
        potTicks = 1, valueCallback = paintCustomOverlayFaderValues }
    -- Custom control value definitions (overlays)
    CUSTOMOV_LFOSYNC = { {value = 0, label="Off"}, {value = 1, label="Clk"}, {value = 2, label="Tap"}}
    CUSTOMOV_LFOSYNC2 = { {value = 0, label="Off"}, {value = 1, label="Clk"}}
    CUSTOMOV_LFOWAVE = { {value = 0, label="Triangle"}, {value = 1, label="Sine"}, {value = 2, label="Saw"}, {value = 3, label="Square"}, {value = 4, label="Random"}, {value = 5, label="Chaos"}}
    CUSTOMOV_LFOWAVE2 = { {value = 0, label="Tri"}, {value = 1, label="Sin"}, {value = 2, label="Saw"}, {value = 3, label="Sqr"}, {value = 4, label="Rnd"}, {value = 5, label="Chs"}}
    -- Custom control individual definitions
    CUSTOM_CTRL = {}
    CUSTOM_CTRL[CONTROL_CUSTOM_3V] = {selected = 1, potValue = 0, valueObjects = { 
        { p = {label = "LFO1:",pmap = PMAP_CUSTOM_3V_1, gdef = CUSTOMDEF_LIST3V}, v = CUSTOMOV_LFOSYNC },
        { p = {label = "LFO2:",pmap = PMAP_CUSTOM_3V_2, gdef = CUSTOMDEF_LIST2V}, v = CUSTOMOV_LFOSYNC2 }}}
    CUSTOM_CTRL[CONTROL_CUSTOM_FADER] = {selected = 1, potValue = 0, valueObjects = {
        { p = {label = "Rate1:",pmap = PMAP_CUSTOM_FADER_1, gdef = CUSTOMDEF_FADER}, v = {} },
        { p = {label = "Rate2:",pmap = PMAP_CUSTOM_FADER_2, gdef = CUSTOMDEF_FADER}, v = {} }}}
    CUSTOM_CTRL[CONTROL_CUSTOM_OVERLAY] = {selected = 1, potValue = 0, valueObjects = {
        { p = {label = "Wave1:",pmap = PMAP_CUSTOM_OVERLAY_1, gdef = CUSTOMDEF_OVLIST}, v = CUSTOMOV_LFOWAVE },
        { p = {label = "Wave2:",pmap = PMAP_CUSTOM_OVERLAY_2, gdef = CUSTOMDEF_OVFADER}, v = CUSTOMOV_LFOWAVE2}}}
    -- initializing the custom controls 
    for c,s in pairs(CUSTOM_CTRL) do 
        local control = controls.get(c)
        -- Assign all Custom Control callbacks
        control:setPaintCallback(paintCustom)
        control:setTouchCallback(customCtrlTouchCallback)
        control:setPotCallback(customCtrlPotCallback)
        -- Assign pot to Custom Control
        local slot = getPotFromBounds(control) - 1
        control:setPot(slot//12 + 1,slot%12 + 1)

        -- Assign min/max & paramaterType from ValueObject & Message
        for i,v in pairs(control:getValues()) do
            local customValue = getCustomValue(s,v:getMessage():getParameterNumber())
            customValue.p.midiMin = v:getMessage():getMin()
            customValue.p.midiMax = v:getMessage():getMax()
            customValue.p.valMin = v:getMin()
            customValue.p.valMax = v:getMax()
            customValue.p.pType = v:getMessage():getType()
            customValue.p.quotient = (customValue.p.valMax - customValue.p.valMin) // (customValue.p.midiMax - customValue.p.midiMin)
            customValue.p.deviceId = v:getMessage():getDeviceId()
            local default = (v:getDefault() - customValue.p.valMin) / customValue.p.quotient + customValue.p.midiMin
            parameterMap.set (customValue.p.deviceId, PT_SYSEX, customValue.p.pmap, default)

        end
    end
end
function getCustomValue(custom, pmap) 
    for _,v in ipairs(custom.valueObjects) do
        if(pmap == v.p.pmap) then return v end
    end
    return nil
end
-- Paint callbacks
local g = graphics
function paintCustom(control, value)
    local bounds = control:getBounds()
    local customCtrl = CUSTOM_CTRL[control:getId()]
    -- Clear the Control's bounding box
    g.setColor(0x0000)
    g.fillRect(0, 0, bounds[WIDTH], bounds[HEIGHT])
    -- Draw the fixed graphics
    g.setColor(control:getColor())
    g.drawRoundRect(0, 0, bounds[WIDTH], bounds[HEIGHT]-3, 8)
    g.drawLine(0, bounds[HEIGHT] // 2 -1, bounds[WIDTH], bounds[HEIGHT] // 2 -1)
    -- Draw value rows
    for i,s in pairs(customCtrl.valueObjects) do
        local gdef = s.p.gdef
        if(customCtrl.selected == i) then -- value selected
            g.setColor(RED)
            g.drawRoundRect(gdef.px, gdef.py+(i-1)*gdef.yoffset, gdef.pw, gdef.ph,5)
        end
        g.setColor(WHITE)
        g.print(gdef.px+4,gdef.py+(i-1)*gdef.yoffset+5,s.p.label,gdef.ph, CENTER)
        -- Draw value items
        local midiValue = parameterMap.get(s.p.deviceId,s.p.pType,s.p.pmap)
        gdef.valueCallback(s, gdef, i, midiValue)
    end
end
function paintCustomListValues(customValue, gdef, row, midiValue)
    for j,v in ipairs(customValue.v) do
        if(midiValue == v.value) then g.setColor(RED) else g.setColor(WHITE) end
        g.print(gdef.vx+(j-1)*gdef.xoffset,gdef.vy+(row-1)*gdef.yoffset,v.label,gdef.vh, CENTER)
    end
end
function paintCustomFaderValues(customValue, gdef, row, midiValue)
    local displayValue = customValue.p.valMin + midiValue * customValue.p.quotient
    g.print(gdef.vx,gdef.vy+(row-1)*gdef.yoffset,string.format("%d",displayValue),gdef.xoffset-5, RIGHT)
    valueWidth = math.floor(gdef.vw/customValue.p.midiMax * midiValue)
    g.setColor(0x2e2e2e)
    g.fillRect(gdef.vx+gdef.xoffset, gdef.vy+(row-1)*gdef.yoffset,gdef.vw, gdef.vh)
    g.setColor(WHITE)
    g.fillRect(gdef.vx+gdef.xoffset, gdef.vy+(row-1)*gdef.yoffset,valueWidth, gdef.vh)
end
function paintCustomOverlayValues(customValue, gdef, row, midiValue)
    for j,v in ipairs(customValue.v) do
        if(midiValue == v.value) then 
            g.print(gdef.xoffset,gdef.vy+(row-1)*gdef.yoffset,v.label,gdef.vw, CENTER)
        end
    end
end 
function paintCustomOverlayFaderValues(customValue, gdef, row, midiValue)
    for j,v in ipairs(customValue.v) do
        if(midiValue == v.value) then 
            g.print(gdef.vx,gdef.vy+(row-1)*gdef.yoffset,v.label,gdef.vw, LEFT)
        end
    end
    local displayValue = customValue.p.valMin + midiValue
    valueWidth = math.floor(gdef.vw/customValue.p.midiMax * midiValue)
    g.setColor(0x2e2e2e)
    g.fillRect(gdef.vx+gdef.xoffset, gdef.vy+(row-1)*gdef.yoffset,gdef.vw, gdef.vh)
    g.setColor(WHITE)
    g.fillRect(gdef.vx+gdef.xoffset, gdef.vy+(row-1)*gdef.yoffset,valueWidth, gdef.vh)
end

-- Callback to switch selected valueObjects
function customCtrlTouchCallback(control, touchEvent)
    if touchEvent.type == DOUBLECLICK then
        local s = CUSTOM_CTRL[control:getId()]
        s.selected = 3-s.selected
        control:repaint()
    end
end
-- Callback to change midiValue by pot
function customCtrlPotCallback(control, potEvent)
    local customCtrl = CUSTOM_CTRL[control:getId()]
    local selectedValue = customCtrl.valueObjects[customCtrl.selected].p
    if((customCtrl.potValue+math.abs(potEvent.delta))%selectedValue.gdef.potTicks ~=0) then
        customCtrl.potValue = customCtrl.potValue+1
    else
        customCtrl.potValue = 0
        local pmap = selectedValue.pmap
        local pType = selectedValue.pType
        local current = parameterMap.get(selectedValue.deviceId,pType,pmap)
        if((current + potEvent.delta) <= selectedValue.midiMax and (current + potEvent.delta) >= selectedValue.midiMin) then
            parameterMap.set(selectedValue.deviceId,pType,pmap,current + potEvent.delta)
        end
    end
end
function getPotFromBounds(control)
    local bounds = control:getBounds()
    local x = math.floor(bounds[X] / 167) + 1
    local y = math.floor(bounds[Y] / 90)
    return (y*6)+x 
end
-- callback at parameter change
function customRepaint(valueObject, value)
    valueObject:getControl():repaint()
end
initCustomControls()