-- Widget: [Lua] XY Pad
-- [Lua] XY Pad — official demo
-- Original author: Martin Pavlas (Electra One creator)
-- Source: https://app.electra.one/preset/QIatK17htTqLzhkHRnp4
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

-- Demo of sim[ple XY Pad. Note, the preset is meant to
-- demonstrate using the paint, touch, pot action callbacks.
-- It does not handle any MIDI messaging. It is done on
-- purpose, to keep things simple.
--

-- Preset compatibility check
assert(
    controller.isRequired(MODEL_MK2, "3.6.0"),
    "Version 3.6.0 or higher is required"
)

-- Constants
--

-- Colors
local OUTLINE_COLOR = 0xB0C0
local CENTRE_CROSS_COLOR = 0x2104
local ACTIVE_CROSS_COLOR = 0xB004
local VALUE_CIRCLE_COLOR = 0xFC80


-- Animation refresh rate
local XY_PAD_WIDTH = 400
local XY_PAD_HEIGHT = 300


-- Global variables
--

-- Shortcut for graphics object
local g = graphics

-- The XY pad control
local xyPadControl = controls.get(4)
xyPadControl.x = 100
xyPadControl.y = 80

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
end

-- A callback to draw the XY pad graphics
--
function paintXyPad(control, value)
    local bounds = control:getBounds()

    -- Clear the Control's bounding box
    g.setColor(0x0000)
    g.fillRect(0, 0, bounds[WIDTH], bounds[HEIGHT])

    -- Draw the fixed graphics
    g.setColor(OUTLINE_COLOR)
    g.drawRoundRect(0, 0, bounds[WIDTH], bounds[HEIGHT], 8)
    g.setColor(CENTRE_CROSS_COLOR)
    g.drawLine(0, bounds[HEIGHT] // 2, bounds[WIDTH], bounds[HEIGHT] // 2)
    g.drawLine(bounds[WIDTH] // 2, 0, bounds[WIDTH] // 2, bounds[HEIGHT])

    -- Draw the active value indicator
    g.setColor(ACTIVE_CROSS_COLOR)
    g.drawLine(0, control.y, bounds[WIDTH], control.y)
    g.drawLine(control.x, 0, control.x, bounds[HEIGHT])
    g.setColor(VALUE_CIRCLE_COLOR)
    g.drawCircle(control.x, control.y, 20)
end

-- A callback to handle to XY pad LCD touch
--
function touchCallback(control, touchEvent)
    if touchEvent.type == MOVE then
        if control.x ~= touchEvent.x or control.y ~= touchEvent.y then
            control.x = touchEvent.x
            control.y = touchEvent.y
            control:repaint()
            print("id: " .. touchEvent.id)
            print("x: " .. touchEvent.x)
            print("y: " .. touchEvent.y)
        end
    end
end

-- A callback to handle events on assigned knob
--
function potCallback(control, potEvent)
    if potEvent.type == MOVE then
        print("delta: " .. potEvent.delta)
        control.x = control.x + potEvent.delta
        control:repaint()
    elseif potEvent.type == DOWN then
        print("down")
    elseif potEvent.type == UP then
        print("up")
    end
end

