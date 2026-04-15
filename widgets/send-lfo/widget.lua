-- Widget: Send LFO
-- Send LFO — LFO with CC send visualization
-- Original author: Martin Pavlas (Electra One creator)
-- Source: https://app.electra.one/preset/hXZd5qXpoMx82gIz6qWP
-- Imported: 2026-04-15 from Firestore. License at source: none specified.
-- Removal / relicensing: see NOTICE.md at repo root.

-- Global variables
--
local SCOPE_WIDTH = 314
local SCOPE_HEIGHT = 140

-- Shortcut for graphics object
local g = graphics

-- The Scope control
local scopeControl = controls.get(7)

-- Scope buffer (one sample per pixel column)
local scope = {
    y = {},
}

-- Initialize the preset
--
function preset.onLoad()
    local bounds = scopeControl:getBounds()
    bounds[WIDTH] = SCOPE_WIDTH
    bounds[HEIGHT] = SCOPE_HEIGHT
    scopeControl:setBounds(bounds)

    -- Initialize and assign Custom Control callbacks
    initializeScopeData();
    scopeControl:setPaintCallback(paintScope)
    scopeControl:repaint()
end

-- Sample usage (assuming timer updates every 1 ms)
local timerInterval = 0.01  -- 1 ms in seconds

-- Enable timer
timer.setPeriod (10)

-- Acquire a Data pipe
local pipeOutput = pipe.acquire("output");

-- Read default values
local defaultPulseWidth = parameterMap.get(1, PT_VIRTUAL, 4) / 100

-- Initialize LFO parameters
local lfo = {
    frequency = 0.1,               -- Initial frequency in Hz
    phase = 0.0,                  -- Phase of the waveform
    amplitude = 1.0,               -- Amplitude of the waveform (-0.5 to 0.5)
    pulseWidth = defaultPulseWidth,  -- Pulse width for square waveform (0.0 to 1.0)
    dcOffset = 0.0,                -- DC offset for all waveforms (-0.5 to 0.5)
}

-- Update LFO state based on time interval
function updateLFO(dt)
    lfo.phase = lfo.phase + lfo.frequency * dt
    if lfo.phase >= 1.0 then
        lfo.phase = lfo.phase - 1.0
    end
end

-- Calculate and get the current LFO value
function getLFOSawtooth()
    local value = (lfo.phase * 2 - 1) * lfo.amplitude + lfo.dcOffset
    return value
end

function getLFOSquare()
    local value = (lfo.phase < lfo.pulseWidth and lfo.amplitude or -lfo.amplitude) + lfo.dcOffset
    return value
end

function getLFOTriangle()
    local value = (lfo.phase < 0.5 and (lfo.phase * 4 - 1) * lfo.amplitude
                  or ((1.0 - lfo.phase) * 4 - 1) * lfo.amplitude) + lfo.dcOffset
    return value
end

function getLFOSine()
    local value = math.sin(lfo.phase * 2 * math.pi) * lfo.amplitude + lfo.dcOffset
    return value
end

-- timer callback
function timer.onTick ()
    updateLFO(timerInterval)
    local lfoSawtooth = getLFOSawtooth()
    local lfoSquare   = getLFOSquare()
    local lfoTriangle = getLFOTriangle()
    local lfoSine     = getLFOSine()

    -- Currently, only the triangle waveform is sent to Data pipe channel #1
    pipe.send(pipeOutput, lfoTriangle)

    -- Scroll left and append newest sample
    for i = 1, SCOPE_WIDTH - 1 do
        scope.y[i] = scope.y[i + 1]
    end
    scope.y[SCOPE_WIDTH] = lfoTriangle  -- draw what we actually output
    scopeControl:repaint()
end

-- Setters
function setRate(valueObject, value)
    lfo.frequency = percentageToRate(value)
end

function setPulseWidth(valueObject, value)
    lfo.pulseWidth = value / 100
end

-- LFO state control
function run(valueObject, value)
    timer.enable()
    info.setText("Running")
end

function stop(valueObject, value)
    timer.disable()
    info.setText("")
end


-- helpers
function percentageToRate(number)
    if number < 0 or number > 100 then
        return nil  -- Number is out of range
    end
    
    local minInput = 0
    local maxInput = 100
    local minOutput = 0.1
    local maxOutput = 10
    
    local normalizedInput = (number - minInput) / (maxInput - minInput)
    local exponent = 3  -- You can adjust this to control the rate of exponential growth
    
    local normalizedOutput = normalizedInput ^ exponent
    local output = minOutput + (maxOutput - minOutput) * normalizedOutput
    
    return output
end

-- formatters
function getFrequency(valueObject, value)
    return string.format("%.2fHz", lfo.frequency)
end

function getPulseWidth(valueObject, value)
    return string.format("%.0f%%", lfo.pulseWidth * 100)
end

-- A callback to draw the XY pad graphics
--
function paintScope(control, value)
    local bounds = control:getBounds()
    local left   = 0
    local right  = bounds[WIDTH] - 1
    local top    = 0
    local bottom = bounds[HEIGHT] - 1

    -- Clear the Control's bounding box
    g.setColor(0x0000)
    g.fillRect(0, 0, bounds[WIDTH], bounds[HEIGHT])
    g.setColor(0xffff)
    g.drawRoundRect(0, 0, bounds[WIDTH], bounds[HEIGHT], 5)

    -- midline
    g.setColor(0x7bef) -- light gray
    local mid = normToPixel(0, top + 4, bottom - 4)
    g.drawLine(left + 4, mid, right - 4, mid)

    -- signal trace
    g.setColor(0xffff)
    local lastx = left + 4
    local lasty = normToPixel(scope.y[1], top + 4, bottom - 4)
    for x = 2, math.min(SCOPE_WIDTH - 4, right - 4) do
        local y = normToPixel(scope.y[x], top + 4, bottom - 4)
        g.drawLine(lastx, lasty, x, y)
        lastx, lasty = x, y
    end
end

-- Map normalized [-1,1] to pixel Y inside the scope rect
function normToPixel(n, top, bottom)
    local center = (top + bottom) * 0.5
    local amp    = (bottom - top) * 0.5
    return math.floor(center - n * amp + 0.5)
end

-- Zero the scope data
function initializeScopeData()
    for i = 1, SCOPE_WIDTH do scope.y[i] = 0 end
end

function setAmplitude(valueObject, value)   -- value is 0..100
    lfo.amplitude = (value or 100) / 100
end

function setPhase(valueObject, value)       -- value is 0..100 (% of a cycle)
    lfo.phase = ((value or 0) / 100) % 1.0
end
