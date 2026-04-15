-- Widget: Mini Cube LFO
-- Mini Cube LFO — compact variant of Cube LFO
-- Original author: Martin Pavlas (Electra One creator)
-- Source: https://app.electra.one/preset/ZS5BSFRpk5L0dTXRVkvb
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

-- Demo of graphics handled in the timer interrupt handler
-- The Cube LFO generates a pseudo random series of CC messages
-- according to reading of a projection of X, Y coordinates
-- of one of the cube vertices.

-- Constants
--

-- Animation refresh rate
local REFRESH_RATE = 20

-- Cube Control dimmensions
local CUBE_WIDTH = 360
local CUBE_HEIGHT = 280

-- Colors (RGB 565 for now)
local COLOR_EDGE = 0xFFFF
local COLOR_CENTRE_POINT = 0xAB40
local COLOR_MEASURED_POINT = 0xFE47

-- Edge Point to meassure
local MEASSURED_EDGE_POINT = 1

-- Global variables
--

-- Shortcut for graphics object
local g = graphics

-- Cube custom control
local cubeControl = controls.get(1)

-- Cube's projected drawing points
cubeControl.projection = {}

-- Cube vertices
cubeControl.vertices = {
    {-50, -50, -50}, {50, -50, -50}, {50, 50, -50}, {-50, 50, -50},
    {-50, -50, 50}, {50, -50, 50}, {50, 50, 50}, {-50, 50, 50}
}

-- Cube edges
cubeControl.edges = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8}
}

-- Cube rotation angles
cubeControl.angleX = 0
cubeControl.angleY = 0

-- Angular speed steps
cubeControl.stepX = 0
cubeControl.stepY = 0

-- Center of the Cube
cubeControl.centrePoint = { x = 0, y = 0 }

-- Apply rotation change
--
function cubeControl:update()
    self.angleX = self.angleX + self.stepX
    self.angleY = self.angleY + self.stepY

    local projected = {}
    for i, v in ipairs(self.vertices) do
        local rotatedY = rotateY(v, self.angleX)
        local rotatedX = rotateX(rotatedY, self.angleY)
        projected[i] = project(rotatedX)
    end

    self.projection =  projected
end

-- Set dimensions of the cube
--
function cubeControl:setDimensions(width, height)
    local bounds = self:getBounds()
    bounds[WIDTH] = width
    bounds[HEIGHT] = height
    self:setBounds(bounds)
    self.centrePoint.x = width // 2
    self.centrePoint.y = height // 2
end


-- Map of UI controls with dynamic changes
--
local uiControls = {
    cube = cubeControl,
    outX = controls.get(12),
    outY = controls.get(13),
}

-- Map of parameters used in the preset
--
local parameters = {
    outX = { PT_CC7, 1 },
    outY = { PT_CC7, 2 },
}


-- Initialize the preset
--
function preset.onLoad()
    -- Resize the custom Cube Control
    cubeControl:setDimensions(CUBE_WIDTH, CUBE_HEIGHT)

    -- Register the paint callback
    cubeControl:setPaintCallback(paintCubeControl)

    -- Configure and enable the timer
    timer.setPeriod(REFRESH_RATE)
    timer.enable()

    uiControls.cube.stepX = 0.01
end

-- Handle Grid changes
--
function parameterMap.onChange(valueObjects, origin, midiValue)
    -- Process user input
    for _, valueObject in ipairs(valueObjects) do
        local type, parameterNumber, midiValue = getTypeParameterAndValue(valueObject)

        if type == PT_VIRTUAL then
            if parameterNumber == 11 then 
                uiControls.cube.stepX = convertValue(midiValue)
            elseif parameterNumber == 12 then 
                uiControls.cube.stepY = convertValue(midiValue)
            end
        end
    end
end

-- Handle the timer callback
--
function timer.onTick()
    cubeControl:update()
    sendOutboundCcMessages(uiControls.cube)
    cubeControl:repaint()
end

-- Paint Cube Control callback
--
function paintCubeControl(control)
    -- Get the bounding box
    local bounds = control:getBounds()

    -- Clear the bounding box
    g.setColor(0x0002)
    g.fillRect(0, 0, bounds[WIDTH], bounds[HEIGHT])

    -- Paint the Cube
    paintCube(control)
end

-- Rotate a point around the Y axis
--
function rotateY(point, angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    return {
        point[1] * cos - point[3] * sin,
        point[2],
        point[1] * sin + point[3] * cos
    }
end

-- Rotate a point around the X axis
--
function rotateX(point, angle)
    local cos = math.cos(angle)
    local sin = math.sin(angle)
    return {
        point[1],
        point[2] * cos - point[3] * sin,
        point[2] * sin + point[3] * cos
    }
end

-- Project 3D points to 2D
--
function project(point)
    local fov = 256
    local viewer_distance = 200
    return {
        CUBE_WIDTH / 2 + (fov * point[1]) / (viewer_distance + point[3]),
        CUBE_HEIGHT / 2 - (fov * point[2]) / (viewer_distance + point[3])
    }
end

-- Paint the Cube 2D projection
--
function paintCube(cube)
    -- Set color of Cube edges
    g.setColor(COLOR_EDGE)

    -- Draw all edges
    for i, edge in ipairs(cube.edges) do
        -- Calculate projected coordinates of given
        -- edge endpoints
        local p1X = math.floor(cube.projection[edge[1]][1])
        local p1Y = math.floor(cube.projection[edge[1]][2])
        local p2X = math.floor(cube.projection[edge[2]][1])
        local p2Y = math.floor(cube.projection[edge[2]][2])

        -- Connect he first edge point with the reference point
        if i == MEASSURED_EDGE_POINT then
            -- Draw the centre pojnt the the arm to
            -- the meassured point
            g.setColor(COLOR_CENTRE_POINT)
            g.fillCircle(
                cube.centrePoint.x,
                cube.centrePoint.y, 5
            )
            g.drawLine(
                cube.centrePoint.x,
                cube.centrePoint.y,
                p1X,
                p1Y
            )

            -- Draw the meassured point
            g.setColor(COLOR_MEASURED_POINT)
            g.fillCircle(p1X, p1Y, 5)

            -- Switch back to the edge color
            g.setColor(COLOR_EDGE)
        end

        -- Draw the edge
        g.drawLine(p1X, p1Y, p2X, p2Y)
    end
end

-- Paint the Cube 2D projection
--
function sendOutboundCcMessages(cube)
    local edge = cube.edges[MEASSURED_EDGE_POINT]
    local p1 = cube.projection[edge[1]]
    local p2 = cube.projection[edge[2]]

    -- TODO: Get rid of the magic numbers
    setParameter(
        parameters.outX,
        math.floor((p1[1] - (cube.centrePoint.x - 123)) * 0.52)
    )
    setParameter(
        parameters.outY,
        math.floor((p1[2] - (cube.centrePoint.y - 123)) * 0.52)
    )
end

-- Convert a liner fader value to altered exponential
-- value that suits angular speed adjustment
--
function convertValue(input)
    -- Steepness of the slope
    local k = 1

    --  Maximum angular speed
    local T = 0.2
    
    return T * (math.exp((input / 100) * k) - 1) / (math.exp(k) - 1)
end

-- Set a parameter value
--
function setParameter(parameter, value)
    local type, parameterNumber = table.unpack(parameter)
    parameterMap.set(1, type, parameterNumber, value)
end

-- Get a MIDI type, parameter, and value from the value object
--
function getTypeParameterAndValue(vo)
    return vo:getMessage():getType(),
        vo:getMessage():getParameterNumber(),
        vo:getMessage():getValue()
end

-- Get MIDI value from the value object
--
function getMidiValue(vo)
    return vo:getMessage():getValue()
end

-- Changes CC parameterNumber associated with given Control
--
function setControlCc(control, cc)
    local message = control:getValue():getMessage()
    message:setParameterNumber(cc)
end


-- Handle change of Outbound X CC
--
function xCcChanged(valueObject, value)
    local newCc = getMidiValue(valueObject)
    parameters.outX[2] = newCc
    setControlCc(uiControls.outX, newCc)
end

-- Handle change of Outbound Y CC
--
function yCcChanged(valueObject, value)
    local newCc = getMidiValue(valueObject)
    parameters.outY[2] = newCc
    setControlCc(uiControls.outY, newCc)
end