-- Widget: Loopop's Tombola
-- Loopop's Tombola — physics ball demo
-- Original author: Ziv Eliraz (Loopop)
-- Source: https://app.electra.one/preset/eZBSxDFKpnULd4e0we97
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

-- OP-1 Tombola Style Sequencer for Electra Mini
-- Rotating polygon container with balls bouncing inside
-- Balls trigger notes when hitting walls

-- Constants
--

-- Animation refresh rate (milliseconds)
local REFRESH_RATE = 16  -- ~60 fps

-- Physics constants (will be controlled by MIDI CCs)
local GRAVITY = 0.15           -- CC11: 0-127 maps to 0-0.5
local WALL_BOUNCE = 0.85       -- CC12: 0-127 maps to 0.3-1.0 (bouncy)
local ROTATION_SPEED = 0.005   -- CC13: 0-127 maps to -0.2 to 0.2 (10x faster)
local SPAWN_RATE_MULT = 1.0    -- CC14: 0-127 maps to 0.2-5.0 (faster spawn)
local BALL_LIFETIME_BOUNCES = 10  -- CC103: uses actual CC value (1-127 bounces)

local DAMPING = 0.999
local FRICTION = 0.98

-- Container properties
local CONTAINER_SIDES = 6  -- Hexagon
local CONTAINER_BASE_RADIUS = 120

-- Control dimensions (matching original demo style)
local CONTROL_WIDTH = 360
local CONTROL_HEIGHT = 280

-- Ball constants
local MAX_BALLS = 6
local BALL_RADIUS = 10
local BASE_SPAWN_INTERVAL = 180  -- Base frames between auto-spawning

-- Colors (RGB 565) - Bright Pastel Palette
local COLOR_BG = 0x0002
local COLOR_CONTAINER = 0x07FF      -- Bright Cyan
local COLOR_WALL_HIT = 0xFFE0       -- Bright Yellow
local COLOR_BALL_1 = 0xFD5F         -- Pastel Pink
local COLOR_BALL_2 = 0x87F0         -- Pastel Green
local COLOR_BALL_3 = 0xFDAA         -- Pastel Orange
local COLOR_BALL_4 = 0x857F         -- Pastel Blue
local COLOR_BALL_5 = 0xF7FE         -- Pastel Yellow
local COLOR_BALL_6 = 0xBDFF         -- Pastel Purple

-- MIDI notes for each wall segment (supports up to 12 sides)
-- Multiple scale options - will be randomized with CC105
local SCALES = {
    {name = "C Minor Pentatonic", notes = {60, 63, 65, 67, 70, 72, 75, 77, 79, 82, 84, 86}},
    {name = "C Major Pentatonic", notes = {60, 62, 64, 67, 69, 72, 74, 76, 79, 81, 84, 86}},
    {name = "C Blues Scale", notes = {60, 63, 65, 66, 67, 70, 72, 75, 77, 78, 79, 82}},
    {name = "C Dorian", notes = {60, 62, 63, 65, 67, 69, 70, 72, 74, 75, 77, 79}},
    {name = "C Phrygian", notes = {60, 61, 63, 65, 67, 68, 70, 72, 73, 75, 77, 79}},
    {name = "C Lydian", notes = {60, 62, 64, 66, 67, 69, 71, 72, 74, 76, 78, 79}},
    {name = "C Mixolydian", notes = {60, 62, 64, 65, 67, 69, 70, 72, 74, 76, 77, 79}},
    {name = "C Harmonic Minor", notes = {60, 62, 63, 65, 67, 68, 71, 72, 74, 75, 77, 79}},
    {name = "C Hungarian Minor", notes = {60, 62, 63, 66, 67, 68, 71, 72, 74, 75, 78, 79}},
    {name = "C Whole Tone", notes = {60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82}},
    {name = "C Hirajoshi", notes = {60, 62, 63, 67, 68, 72, 74, 75, 79, 80, 84, 86}},
    {name = "C Byzantine", notes = {60, 61, 64, 65, 67, 68, 71, 72, 73, 76, 77, 79}},
    {name = "C Chromatic", notes = {60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71}}
}

local CURRENT_SCALE_INDEX = 1  -- Start with C Minor Pentatonic
local WALL_NOTES = SCALES[CURRENT_SCALE_INDEX].notes

-- Note off timing (frames)
local NOTE_OFF_DELAY = 8

-- Global variables
--

-- Shortcut for graphics object
local g = graphics

-- Main custom control
local mainControl = controls.get(1)

-- Display dimensions (fixed like original demo)
mainControl.width = CONTROL_WIDTH
mainControl.height = CONTROL_HEIGHT
mainControl.centerX = CONTROL_WIDTH / 2
mainControl.centerY = CONTROL_HEIGHT / 2

-- Container rotation angle
mainControl.rotation = 0

-- Container vertices (will be calculated)
mainControl.vertices = {}
mainControl.walls = {}  -- Each wall has two vertex indices

-- Ball objects array
mainControl.balls = {}

-- Frame counter
mainControl.frameCount = 0
mainControl.spawnTimer = 0

-- Wall hit tracking
mainControl.wallHitFrames = {}

-- Active notes tracking for note offs
mainControl.activeNotes = {}

-- CC message display (for debugging)
mainControl.recentCCs = {}  -- Store recent CC messages: {cc, value, framesLeft}

-- Scale display tracking
mainControl.scaleDisplayFrames = 180  -- Show initial scale for 3 seconds

-- Ball colors
local BALL_COLORS = {COLOR_BALL_1, COLOR_BALL_2, COLOR_BALL_3, COLOR_BALL_4, COLOR_BALL_5, COLOR_BALL_6}

-- Ball object constructor
--
function createBall(x, y, colorIndex)
    return {
        x = x,
        y = y,
        vx = (math.random() - 0.5) * 4,
        vy = (math.random() - 0.5) * 2,
        radius = BALL_RADIUS,
        active = true,
        color = BALL_COLORS[colorIndex] or COLOR_BALL_1,
        trail = {},
        bounceCount = 0,  -- Track number of bounces
        maxBounces = BALL_LIFETIME_BOUNCES  -- Max bounces before disappearing
    }
end

-- Calculate container vertices based on rotation
--
function updateContainerVertices()
    mainControl.vertices = {}
    local angle = mainControl.rotation
    local radius = CONTAINER_BASE_RADIUS
    
    for i = 0, CONTAINER_SIDES - 1 do
        local vertexAngle = angle + (i * 2 * math.pi / CONTAINER_SIDES)
        local x = mainControl.centerX + radius * math.cos(vertexAngle)
        local y = mainControl.centerY + radius * math.sin(vertexAngle)
        table.insert(mainControl.vertices, {x = x, y = y})
    end
    
    -- Define walls (pairs of vertices)
    mainControl.walls = {}
    for i = 1, CONTAINER_SIDES do
        local nextIndex = (i % CONTAINER_SIDES) + 1
        -- Wrap note index if we have more sides than notes
        local noteIndex = ((i - 1) % #WALL_NOTES) + 1
        table.insert(mainControl.walls, {v1 = i, v2 = nextIndex, note = WALL_NOTES[noteIndex]})
    end
end

-- Initialize container
--
function initializeContainer()
    -- Clear and reinitialize wall hit frames for new number of sides
    mainControl.wallHitFrames = {}
    for i = 1, CONTAINER_SIDES do
        mainControl.wallHitFrames[i] = 0
    end
    updateContainerVertices()
end

-- Spawn a new ball
--
function spawnBall()
    if #mainControl.balls < MAX_BALLS then
        local colorIndex = (#mainControl.balls % #BALL_COLORS) + 1
        local spawnX = mainControl.centerX + (math.random() - 0.5) * 60
        local spawnY = mainControl.centerY - 40
        table.insert(mainControl.balls, createBall(spawnX, spawnY, colorIndex))
    end
end

-- Check if point is inside polygon (for boundary checking)
--
function pointInPolygon(x, y)
    local vertices = mainControl.vertices
    local inside = false
    local j = #vertices
    
    for i = 1, #vertices do
        local xi, yi = vertices[i].x, vertices[i].y
        local xj, yj = vertices[j].x, vertices[j].y
        
        if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end
    
    return inside
end

-- Get distance from point to line segment
--
function pointToSegmentDistance(px, py, x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    local lengthSquared = dx * dx + dy * dy
    
    if lengthSquared == 0 then
        return math.sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1))
    end
    
    local t = math.max(0, math.min(1, ((px - x1) * dx + (py - y1) * dy) / lengthSquared))
    local projX = x1 + t * dx
    local projY = y1 + t * dy
    
    return math.sqrt((px - projX) * (px - projX) + (py - projY) * (py - projY)), projX, projY
end

-- Check and handle wall collisions
--
function checkWallCollisions(ball)
    -- Track if we've already counted a bounce this frame
    local bouncedThisFrame = false
    
    for wallIndex, wall in ipairs(mainControl.walls) do
        local v1 = mainControl.vertices[wall.v1]
        local v2 = mainControl.vertices[wall.v2]
        
        local dist, projX, projY = pointToSegmentDistance(ball.x, ball.y, v1.x, v1.y, v2.x, v2.y)
        
        if dist < ball.radius then
            -- Collision detected
            -- Calculate wall normal
            local wallDx = v2.x - v1.x
            local wallDy = v2.y - v1.y
            local wallLength = math.sqrt(wallDx * wallDx + wallDy * wallDy)
            
            -- Normal perpendicular to wall (pointing inward)
            local normalX = -wallDy / wallLength
            local normalY = wallDx / wallLength
            
            -- Check which side we're on
            local centerDx = mainControl.centerX - projX
            local centerDy = mainControl.centerY - projY
            local dotProduct = normalX * centerDx + normalY * centerDy
            
            if dotProduct < 0 then
                normalX = -normalX
                normalY = -normalY
            end
            
            -- Push ball away from wall
            local pushDistance = ball.radius - dist
            ball.x = ball.x + normalX * pushDistance
            ball.y = ball.y + normalY * pushDistance
            
            -- Reflect velocity
            local velDot = ball.vx * normalX + ball.vy * normalY
            ball.vx = (ball.vx - 2 * velDot * normalX) * WALL_BOUNCE
            ball.vy = (ball.vy - 2 * velDot * normalY) * WALL_BOUNCE
            
            -- Count bounce (only once per frame)
            if not bouncedThisFrame then
                ball.bounceCount = ball.bounceCount + 1
                bouncedThisFrame = true
                
                -- Check if ball has exceeded max bounces
                if ball.bounceCount >= ball.maxBounces then
                    ball.active = false
                    print("Ball removed after " .. ball.bounceCount .. " bounces (max: " .. ball.maxBounces .. ")")
                end
            end
            
            -- Trigger note if significant collision
            if math.abs(velDot) > 0.5 then
                sendNote(wall.note, wallIndex, math.min(127, math.floor(math.abs(velDot) * 30 + 40)))
                mainControl.wallHitFrames[wallIndex] = 12
            end
        end
    end
end

-- Update ball physics
--
function updateBall(ball)
    -- Apply gravity downward (towards bottom of screen)
    -- When GRAVITY is 0, no pull. When GRAVITY is max, strong downward pull
    ball.vy = ball.vy + GRAVITY
    
    -- Apply friction/damping
    ball.vx = ball.vx * DAMPING
    ball.vy = ball.vy * DAMPING
    
    -- Update position
    ball.x = ball.x + ball.vx
    ball.y = ball.y + ball.vy
    
    -- Store trail
    table.insert(ball.trail, {x = ball.x, y = ball.y})
    if #ball.trail > 4 then
        table.remove(ball.trail, 1)
    end
    
    -- Check wall collisions
    checkWallCollisions(ball)
end

-- Update physics
--
function updatePhysics()
    -- Rotate container
    mainControl.rotation = mainControl.rotation + ROTATION_SPEED
    updateContainerVertices()
    
    -- Update balls
    for i = #mainControl.balls, 1, -1 do
        local ball = mainControl.balls[i]
        if ball.active then
            updateBall(ball)
        else
            table.remove(mainControl.balls, i)
        end
    end
    
    -- Decay wall hit indicators
    for i = 1, CONTAINER_SIDES do
        if mainControl.wallHitFrames[i] > 0 then
            mainControl.wallHitFrames[i] = mainControl.wallHitFrames[i] - 1
        end
    end
    
    -- Decay CC message display
    for i = #mainControl.recentCCs, 1, -1 do
        mainControl.recentCCs[i].framesLeft = mainControl.recentCCs[i].framesLeft - 1
        if mainControl.recentCCs[i].framesLeft <= 0 then
            table.remove(mainControl.recentCCs, i)
        end
    end
    
    -- Decay scale name display
    if mainControl.scaleDisplayFrames > 0 then
        mainControl.scaleDisplayFrames = mainControl.scaleDisplayFrames - 1
    end
    
    -- Handle note offs
    for i = #mainControl.activeNotes, 1, -1 do
        local noteInfo = mainControl.activeNotes[i]
        noteInfo.framesRemaining = noteInfo.framesRemaining - 1
        if noteInfo.framesRemaining <= 0 then
            midi.sendNoteOff(PORT_1, 1, noteInfo.note, 0)  -- USB Device
            midi.sendNoteOff(PORT_2, 1, noteInfo.note, 0)  -- 3.5mm MIDI jack
            table.remove(mainControl.activeNotes, i)
        end
    end
    
    -- Auto-spawn balls (rate controlled by SPAWN_RATE_MULT)
    mainControl.spawnTimer = mainControl.spawnTimer + 1
    local currentSpawnInterval = BASE_SPAWN_INTERVAL / SPAWN_RATE_MULT
    if mainControl.spawnTimer >= currentSpawnInterval then
        spawnBall()
        mainControl.spawnTimer = 0
    end
end

-- Set dimensions of the control
--
function mainControl:setDimensions(width, height)
    local bounds = self:getBounds()
    bounds[WIDTH] = width
    bounds[HEIGHT] = height
    self:setBounds(bounds)
    self.width = width
    self.height = height
    self.centerX = width / 2
    self.centerY = height / 2
end

-- Send MIDI note with note off tracking
-- Omitting the port argument sends to ALL interfaces (USB + 3.5mm jack)
--
function sendNote(note, wallIndex, velocity)
    midi.sendNoteOn(PORT_1, 1, note, velocity)   -- USB Device
    midi.sendNoteOn(PORT_2, 1, note, velocity)   -- 3.5mm MIDI jack
    table.insert(mainControl.activeNotes, {
        note = note,
        framesRemaining = NOTE_OFF_DELAY
    })
end

-- Paint the main control
--
function paintMainControl(control)
    local bounds = control:getBounds()
    local width = bounds[WIDTH]
    local height = bounds[HEIGHT]
    
    -- Clear background
    g.setColor(COLOR_BG)
    g.fillRect(0, 0, width, height)
    
    -- Draw container
    drawContainer()
    
    -- Draw balls
    drawBalls()
    
    -- Draw CC messages (for debugging)
    drawCCMessages()
end

-- Draw the rotating container
--
function drawContainer()
    for wallIndex, wall in ipairs(mainControl.walls) do
        local v1 = mainControl.vertices[wall.v1]
        local v2 = mainControl.vertices[wall.v2]
        
        -- Choose color based on hit state
        if mainControl.wallHitFrames[wallIndex] > 0 then
            g.setColor(COLOR_WALL_HIT)
        else
            g.setColor(COLOR_CONTAINER)
        end
        
        -- Draw wall line (thick)
        for offset = -2, 2 do
            g.drawLine(
                math.floor(v1.x + offset),
                math.floor(v1.y),
                math.floor(v2.x + offset),
                math.floor(v2.y)
            )
        end
    end
end

-- Draw all balls
--
function drawBalls()
    for _, ball in ipairs(mainControl.balls) do
        -- Draw trail
        for trailIndex, pos in ipairs(ball.trail) do
            local alpha = trailIndex / #ball.trail
            local radius = math.floor(ball.radius * alpha * 0.5)
            if radius > 0 then
                g.setColor(ball.color)
                g.fillCircle(math.floor(pos.x), math.floor(pos.y), radius)
            end
        end
        
        -- Draw ball
        g.setColor(ball.color)
        g.fillCircle(math.floor(ball.x), math.floor(ball.y), ball.radius)
    end
end

-- Draw recent CC messages and scale name (for debugging)
--
function drawCCMessages()
    local yPos = 10
    
    -- Draw scale name if active
    if mainControl.scaleDisplayFrames > 0 then
        local scaleName = SCALES[CURRENT_SCALE_INDEX].name
        
        -- Calculate box size based on text length
        local boxWidth = #scaleName * 6 + 20
        local boxHeight = 25
        
        -- Draw background box for scale name
        g.setColor(0x0000)  -- Black background
        g.fillRect(5, 5, boxWidth, boxHeight)
        
        -- Draw border
        g.setColor(COLOR_CONTAINER)  -- Cyan border
        g.drawLine(5, 5, 5 + boxWidth, 5)
        g.drawLine(5, 5 + boxHeight, 5 + boxWidth, 5 + boxHeight)
        g.drawLine(5, 5, 5, 5 + boxHeight)
        g.drawLine(5 + boxWidth, 5, 5 + boxWidth, 5 + boxHeight)
        
        -- Draw scale name text
        drawText(10, 12, scaleName, COLOR_BALL_1)  -- Magenta/Pink text
        
        yPos = 40  -- Move CC messages down
    end
    
    -- Draw CC messages
    for i, ccMsg in ipairs(mainControl.recentCCs) do
        if ccMsg.framesLeft > 0 then
            -- Draw background box
            g.setColor(0x2104)  -- Dark gray background
            g.fillRect(10, yPos, 100, 15)
            
            -- Draw CC info
            local ccText = "CC" .. ccMsg.cc .. ":" .. ccMsg.value
            drawText(15, yPos + 4, ccText, COLOR_WALL_HIT)  -- Yellow text
            
            yPos = yPos + 20
        end
    end
end

-- Simple bitmap font for drawing text (5x7 pixels per character)
-- Each character is represented as a table of pixel rows
local FONT = {
    [" "] = {0,0,0,0,0,0,0},
    ["A"] = {0x0E,0x11,0x11,0x1F,0x11,0x11,0x11},
    ["B"] = {0x1E,0x11,0x11,0x1E,0x11,0x11,0x1E},
    ["C"] = {0x0E,0x11,0x10,0x10,0x10,0x11,0x0E},
    ["D"] = {0x1E,0x11,0x11,0x11,0x11,0x11,0x1E},
    ["E"] = {0x1F,0x10,0x10,0x1E,0x10,0x10,0x1F},
    ["F"] = {0x1F,0x10,0x10,0x1E,0x10,0x10,0x10},
    ["G"] = {0x0E,0x11,0x10,0x17,0x11,0x11,0x0F},
    ["H"] = {0x11,0x11,0x11,0x1F,0x11,0x11,0x11},
    ["I"] = {0x0E,0x04,0x04,0x04,0x04,0x04,0x0E},
    ["J"] = {0x01,0x01,0x01,0x01,0x11,0x11,0x0E},
    ["K"] = {0x11,0x12,0x14,0x18,0x14,0x12,0x11},
    ["L"] = {0x10,0x10,0x10,0x10,0x10,0x10,0x1F},
    ["M"] = {0x11,0x1B,0x15,0x15,0x11,0x11,0x11},
    ["N"] = {0x11,0x19,0x15,0x13,0x11,0x11,0x11},
    ["O"] = {0x0E,0x11,0x11,0x11,0x11,0x11,0x0E},
    ["P"] = {0x1E,0x11,0x11,0x1E,0x10,0x10,0x10},
    ["R"] = {0x1E,0x11,0x11,0x1E,0x14,0x12,0x11},
    ["S"] = {0x0E,0x11,0x10,0x0E,0x01,0x11,0x0E},
    ["T"] = {0x1F,0x04,0x04,0x04,0x04,0x04,0x04},
    ["U"] = {0x11,0x11,0x11,0x11,0x11,0x11,0x0E},
    ["W"] = {0x11,0x11,0x11,0x15,0x15,0x1B,0x11},
    ["X"] = {0x11,0x11,0x0A,0x04,0x0A,0x11,0x11},
    ["Y"] = {0x11,0x11,0x0A,0x04,0x04,0x04,0x04},
    ["Z"] = {0x1F,0x01,0x02,0x04,0x08,0x10,0x1F},
    ["a"] = {0x00,0x00,0x0E,0x01,0x0F,0x11,0x0F},
    ["b"] = {0x10,0x10,0x1E,0x11,0x11,0x11,0x1E},
    ["c"] = {0x00,0x00,0x0E,0x10,0x10,0x10,0x0E},
    ["d"] = {0x01,0x01,0x0F,0x11,0x11,0x11,0x0F},
    ["e"] = {0x00,0x00,0x0E,0x11,0x1F,0x10,0x0E},
    ["f"] = {0x06,0x09,0x08,0x1E,0x08,0x08,0x08},
    ["g"] = {0x00,0x00,0x0F,0x11,0x11,0x0F,0x01,0x0E},
    ["h"] = {0x10,0x10,0x1E,0x11,0x11,0x11,0x11},
    ["i"] = {0x04,0x00,0x0C,0x04,0x04,0x04,0x0E},
    ["j"] = {0x02,0x00,0x06,0x02,0x02,0x12,0x0C},
    ["k"] = {0x10,0x10,0x12,0x14,0x18,0x14,0x12},
    ["l"] = {0x0C,0x04,0x04,0x04,0x04,0x04,0x0E},
    ["m"] = {0x00,0x00,0x1A,0x15,0x15,0x15,0x11},
    ["n"] = {0x00,0x00,0x1E,0x11,0x11,0x11,0x11},
    ["o"] = {0x00,0x00,0x0E,0x11,0x11,0x11,0x0E},
    ["p"] = {0x00,0x00,0x1E,0x11,0x11,0x1E,0x10,0x10},
    ["q"] = {0x00,0x00,0x0F,0x11,0x11,0x0F,0x01,0x01},
    ["r"] = {0x00,0x00,0x16,0x19,0x10,0x10,0x10},
    ["s"] = {0x00,0x00,0x0F,0x10,0x0E,0x01,0x1E},
    ["t"] = {0x04,0x04,0x1F,0x04,0x04,0x04,0x03},
    ["u"] = {0x00,0x00,0x11,0x11,0x11,0x13,0x0D},
    ["v"] = {0x00,0x00,0x11,0x11,0x11,0x0A,0x04},
    ["w"] = {0x00,0x00,0x11,0x11,0x15,0x15,0x0A},
    ["x"] = {0x00,0x00,0x11,0x0A,0x04,0x0A,0x11},
    ["y"] = {0x00,0x00,0x11,0x11,0x0A,0x04,0x08},
    ["z"] = {0x00,0x00,0x1F,0x02,0x04,0x08,0x1F},
}

-- Draw a character at position (x, y) with given color
--
function drawChar(x, y, char, color)
    local glyph = FONT[char]
    if not glyph then return 6 end  -- Return width and skip unknown chars
    
    g.setColor(color)
    for row = 1, 7 do
        local rowData = glyph[row]
        for col = 0, 4 do
            if (rowData & (1 << (4 - col))) ~= 0 then
                g.fillRect(x + col, y + row - 1, 1, 1)
            end
        end
    end
    return 6  -- Return character width (5 pixels + 1 spacing)
end

-- Draw a text string at position (x, y)
--
function drawText(x, y, text, color)
    local xPos = x
    for i = 1, #text do
        local char = text:sub(i, i)
        xPos = xPos + drawChar(xPos, y, char, color)
    end
end

-- Simple text drawing using fillRect (very basic, just for numbers)
--

-- Initialize the preset
--
function preset.onLoad()
    -- Set control dimensions (like original demo)
    mainControl:setDimensions(CONTROL_WIDTH, CONTROL_HEIGHT)
    
    -- Initialize container
    initializeContainer()
    
    -- Register paint callback
    mainControl:setPaintCallback(paintMainControl)
    
    -- Spawn initial balls
    for i = 1, 3 do
        spawnBall()
    end
    
    -- Start timer
    timer.setPeriod(REFRESH_RATE)
    timer.enable()
end

-- Randomize to a new scale
--
function randomizeScale()
    local newIndex = math.random(1, #SCALES)
    CURRENT_SCALE_INDEX = newIndex
    WALL_NOTES = SCALES[CURRENT_SCALE_INDEX].notes
    
    -- Update walls with new notes
    initializeContainer()
    
    -- Show scale name for 3 seconds
    mainControl.scaleDisplayFrames = 180  -- 3 seconds at 60fps
    
    -- Log to console
    print("========================================")
    print("SCALE CHANGED: " .. SCALES[CURRENT_SCALE_INDEX].name)
    print("========================================")
end

-- Record CC message for on-screen display
--
function recordCCMessage(cc, value)
    -- Add to beginning of list
    table.insert(mainControl.recentCCs, 1, {
        cc = cc,
        value = value,
        framesLeft = 60  -- Display for 1 second (60 frames at 60fps)
    })
    
    -- Keep only last 5 messages
    while #mainControl.recentCCs > 5 do
        table.remove(mainControl.recentCCs)
    end
end

-- Helper function to get message details
--
function getTypeParameterAndValue(vo)
    return vo:getMessage():getType(),
        vo:getMessage():getParameterNumber(),
        vo:getMessage():getValue()
end

-- Handle parameter changes
--
function parameterMap.onChange(valueObjects, origin, midiValue)
    for _, valueObject in ipairs(valueObjects) do
        local type, parameterNumber, value = getTypeParameterAndValue(valueObject)
        
        -- Record CC message for on-screen display
        if type == PT_CC7 then
            recordCCMessage(parameterNumber, value)
        end
        
        -- Log received messages for debugging
        print("Received: type=" .. type .. " param=" .. parameterNumber .. " value=" .. value)
        
        -- Handle CC7 messages (MIDI CC 11, 12, 13, 14, 101)
        if type == PT_CC7 then
            if parameterNumber == 11 then
                -- CC11: Gravity (0-127 → 0 to 0.5)
                GRAVITY = (value / 127) * 0.5
                print("Set GRAVITY to " .. GRAVITY)
            elseif parameterNumber == 12 then
                -- CC12: Bounce (0-127 → 0.3 to 1.0)
                WALL_BOUNCE = 0.3 + (value / 127) * 0.7
                print("Set WALL_BOUNCE to " .. WALL_BOUNCE)
            elseif parameterNumber == 13 then
                -- CC13: Rotation Speed (0-127 → -0.2 to 0.2) - 10x faster!
                -- 0 = fast reverse, 64 = stop, 127 = fast forward
                ROTATION_SPEED = ((value / 127) - 0.5) * 0.4
                print("Set ROTATION_SPEED to " .. ROTATION_SPEED)
            elseif parameterNumber == 14 then
                -- CC14: Spawn Rate (0-127 → 0.2 to 5.0)
                SPAWN_RATE_MULT = 0.2 + (value / 127) * 4.8
                print("Set SPAWN_RATE_MULT to " .. SPAWN_RATE_MULT)
            elseif parameterNumber == 101 then
                -- CC101: Number of vertices (0-127 → 3 to 12 sides)
                -- Map: 0-12=3, 13-26=4, 27-40=5, etc.
                local newSides = 3 + math.floor((value / 127) * 10)
                newSides = math.min(12, math.max(3, newSides))  -- Clamp to 3-12
                print("CC101 received: value=" .. value .. " calculated sides=" .. newSides)
                CONTAINER_SIDES = newSides
                initializeContainer()
                print("Set CONTAINER_SIDES to " .. CONTAINER_SIDES)
            elseif parameterNumber == 103 then
                -- CC103: Ball lifetime in bounces (use actual CC value: 0-127)
                BALL_LIFETIME_BOUNCES = math.max(1, value)  -- Use CC value directly, minimum 1
                print("Set BALL_LIFETIME_BOUNCES to " .. BALL_LIFETIME_BOUNCES)
            elseif parameterNumber == 104 then
                -- CC104: Speed boost - permanently increase ball speeds
                if value > 0 then
                    -- Give all current balls a permanent speed increase
                    local boostAmount = (value / 127) * 3  -- Scale boost based on CC value
                    for _, ball in ipairs(mainControl.balls) do
                        if ball.active then
                            -- Increase speed in current direction
                            local currentSpeed = math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy)
                            if currentSpeed > 0.1 then
                                -- Boost in direction of movement
                                local dirX = ball.vx / currentSpeed
                                local dirY = ball.vy / currentSpeed
                                ball.vx = ball.vx + dirX * boostAmount
                                ball.vy = ball.vy + dirY * boostAmount
                            else
                                -- If nearly stopped, give random boost
                                ball.vx = ball.vx + (math.random() - 0.5) * boostAmount
                                ball.vy = ball.vy + (math.random() - 0.5) * boostAmount
                            end
                        end
                    end
                    print("SPEED BOOST! (" .. boostAmount .. ") Applied to " .. #mainControl.balls .. " balls")
                end
            elseif parameterNumber == 105 then
                -- CC105: Randomize scale (trigger at value 127)
                if value == 127 then
                    randomizeScale()
                end
            end
        end
        
        -- Handle Virtual parameters (also check for 11-14 and 101 in case they're virtual)
        if type == PT_VIRTUAL then
            if parameterNumber == 11 then
                -- Gravity
                GRAVITY = (value / 127) * 0.5
                print("Set GRAVITY to " .. GRAVITY)
            elseif parameterNumber == 12 then
                -- Bounce
                WALL_BOUNCE = 0.3 + (value / 127) * 0.7
                print("Set WALL_BOUNCE to " .. WALL_BOUNCE)
            elseif parameterNumber == 13 then
                -- Rotation Speed (10x faster)
                ROTATION_SPEED = ((value / 127) - 0.5) * 0.4
                print("Set ROTATION_SPEED to " .. ROTATION_SPEED)
            elseif parameterNumber == 14 then
                -- Spawn Rate
                SPAWN_RATE_MULT = 0.2 + (value / 127) * 4.8
                print("Set SPAWN_RATE_MULT to " .. SPAWN_RATE_MULT)
            elseif parameterNumber == 101 then
                -- Number of vertices
                local newSides = 3 + math.floor((value / 127) * 10)
                newSides = math.min(12, math.max(3, newSides))  -- Clamp to 3-12
                print("Virtual 101 received: value=" .. value .. " calculated sides=" .. newSides)
                CONTAINER_SIDES = newSides
                initializeContainer()
                print("Set CONTAINER_SIDES to " .. CONTAINER_SIDES)
            elseif parameterNumber == 103 then
                -- Ball lifetime in bounces (use actual value: 0-127)
                BALL_LIFETIME_BOUNCES = math.max(1, value)  -- Use value directly, minimum 1
                print("Set BALL_LIFETIME_BOUNCES to " .. BALL_LIFETIME_BOUNCES)
            elseif parameterNumber == 104 then
                -- Speed boost - permanently increase ball speeds
                if value > 0 then
                    -- Give all current balls a permanent speed increase
                    local boostAmount = (value / 127) * 3  -- Scale boost based on value
                    for _, ball in ipairs(mainControl.balls) do
                        if ball.active then
                            -- Increase speed in current direction
                            local currentSpeed = math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy)
                            if currentSpeed > 0.1 then
                                -- Boost in direction of movement
                                local dirX = ball.vx / currentSpeed
                                local dirY = ball.vy / currentSpeed
                                ball.vx = ball.vx + dirX * boostAmount
                                ball.vy = ball.vy + dirY * boostAmount
                            else
                                -- If nearly stopped, give random boost
                                ball.vx = ball.vx + (math.random() - 0.5) * boostAmount
                                ball.vy = ball.vy + (math.random() - 0.5) * boostAmount
                            end
                        end
                    end
                    print("SPEED BOOST! (" .. boostAmount .. ") Applied to " .. #mainControl.balls .. " balls")
                end
            elseif parameterNumber == 105 then
                -- Randomize scale
                if value == 127 then
                    randomizeScale()
                end
            elseif parameterNumber == 1 then
                -- Number of container sides (backup control)
                CONTAINER_SIDES = math.floor(3 + (value / 127) * 5)  -- 3-8 sides
                initializeContainer()
            elseif parameterNumber == 2 then
                -- Spawn ball
                if value > 64 then
                    spawnBall()
                end
            elseif parameterNumber == 3 then
                -- Clear balls
                if value > 64 then
                    mainControl.balls = {}
                end
            end
        end
    end
end

-- Timer callback
--
function timer.onTick()
    mainControl.frameCount = mainControl.frameCount + 1
    updatePhysics()
    mainControl:repaint()
end

