-- Widget: [Lua] Graphics
-- [Lua] Graphics — graphics API demo
-- Original author: Martin Pavlas (Electra One creator)
-- Source: https://app.electra.one/preset/4H2c4AvYhDGJ2tiZFYwY
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

-- A simple demo of using graphics library
--

-- Preset compatibility check
assert(
    controller.isRequired(MODEL_MK2, "3.6.0"),
    "Version 3.6.0 or higher is required"
)

-- Shortcut for graphics object
local g = graphics

-- The XY pad control
local customControl = controls.get(1)


-- Initialize the preset
--
function preset.onLoad()
    resizeControl(customControl, 400, 300)
    customControl:setPaintCallback(myPaintCallback)
end

-- Resize the control
--
function resizeControl(control, width, height)
    local bounds = control:getBounds()
    bounds[WIDTH] = width
    bounds[HEIGHT] = height
    control:setBounds(bounds)
end

-- Paint callback function
--
function myPaintCallback(control)    
    local bounds = control:getBounds()

    -- Clear the Control's bounding box
    g.setColor(0x0000)
    g.fillRect(0, 0, bounds[WIDTH], bounds[HEIGHT])

    -- Use a function from the graphics library

    -- Set color
    g.setColor(0xFFFFFF)

    -- Draw pixel
    g.drawPixel(bounds[WIDTH] - 5, 5)
    g.drawPixel(bounds[WIDTH] - 5, bounds[HEIGHT] - 5)

    -- Draw line
    g.drawLine(
        bounds[WIDTH] - 5,
        10,
        bounds[WIDTH] - 5,
        bounds[HEIGHT] - 10
    )

    -- Draw rectangle
    g.drawRect(0, 0, bounds[WIDTH], bounds[HEIGHT])

    -- Draw filled rectangle
    g.setColor(0xFF0000)
    g.fillRect(5, 5, (bounds[WIDTH] // 4) - 5, bounds[HEIGHT] - 10)

    -- Draw rounded rectangle
    g.setColor(0x0000FF)
    g.drawRoundRect(
        (bounds[WIDTH] // 4) + 10,
        5,
        (bounds[WIDTH] // 4),
        bounds[HEIGHT] - 10,
        30
    )

    -- Draw filled rounded rectangle
    g.fillRoundRect(
        (bounds[WIDTH] // 4) + 20,
        15,
        (bounds[WIDTH] // 4 - 20),
        bounds[HEIGHT] // 4,
        20
    )

    g.print(
        bounds[WIDTH] // 2 + 20,
        bounds[HEIGHT] // 2,
        "Hello world!",
        85,
        CENTER)
end