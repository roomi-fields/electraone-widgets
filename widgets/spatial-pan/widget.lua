-- Widget: Spatial Pan
-- Top-down ambisonic-style pan view. A circular "room" with four cardinal
-- markers (FRONT / RIGHT / BACK / LEFT); the source position is a filled
-- dot inside the circle. Drag anywhere in the circle to move the source —
-- azimuth and distance update together. Pots 1/2 control azimuth/distance
-- independently for precise tweaks.
--
-- Equal-power pan law drives the L/R gain bars on the right, so the
-- readouts match what a stereo fold-down of the pan would sound like.
--
-- Paste lib/theme.lua + lib/primitives/{bar}.lua above this code on the
-- device. The emulator pre-loads them.

Theme.require("0.3")

-- ===== Geometry =====
local CIRCLE_CX, CIRCLE_CY = 320, 280
local CIRCLE_R = 230
local RIGHT_X = 620
local RIGHT_W = 376

-- ===== State =====
-- source position in the normalised unit-circle frame. x right, y "forward"
-- so azimuth 0° = (0, 1), 90° (right) = (1, 0), 180° = (0, -1).
local srcX, srcY = 0, 0.35   -- start slightly in front, dead centre L/R
local dragging = false

local PARAM_AZ, PARAM_DIST = 1, 2

local panControl = controls.get(1)

-- ===== Derived values =====
local function azimuthDeg()
  -- atan2(x, y) with y = "forward" gives 0° at front, increasing clockwise
  local az = math.atan(srcX, srcY) * 180 / math.pi
  if az < 0 then az = az + 360 end
  return az
end

local function distance()
  return math.sqrt(srcX * srcX + srcY * srcY)
end

-- Equal-power pan: pan = x / max(0.0001, d) gives [-1, +1] across the arc.
-- gL = cos((pan+1)·π/4), gR = sin((pan+1)·π/4). Both in [0, 1].
local function panGains()
  local d = distance()
  local pan = (d < 1e-4) and 0 or math.max(-1, math.min(1, srcX / math.max(d, 0.5)))
  local phase = (pan + 1) * math.pi / 4
  local gL = math.cos(phase)
  local gR = math.sin(phase)
  -- distance attenuation: gentle inverse-proportional with a floor
  local atten = 1 / (1 + d * 1.2)
  return gL * atten, gR * atten, pan
end

local function writeParams()
  local az = azimuthDeg()
  parameterMap.set(1, PT_VIRTUAL, PARAM_AZ,   math.floor(az / 360 * 127))
  parameterMap.set(1, PT_VIRTUAL, PARAM_DIST, math.floor(math.min(1, distance()) * 127))
end

local function setSource(x, y)
  -- clamp inside unit circle
  local d = math.sqrt(x * x + y * y)
  if d > 1 then x, y = x / d, y / d end
  srcX, srcY = x, y
  writeParams()
end

-- ===== Pan circle =====
local function paintPanCircle()
  -- Circle card
  local r = CIRCLE_R
  -- outer rim in BORDER, a few concentric rings in ELEVATED for distance cues
  graphics.setColor(Theme.SURFACE)
  for dy = -r, r do
    local dx = math.floor(math.sqrt(r * r - dy * dy))
    graphics.fillRect(CIRCLE_CX - dx, CIRCLE_CY + dy, dx * 2, 1)
  end

  -- concentric rings at 25%, 50%, 75%
  graphics.setColor(Theme.ELEVATED)
  for _, frac in ipairs({ 0.25, 0.50, 0.75 }) do
    local rr = math.floor(r * frac)
    -- draw circle as polyline of 48 segments
    local N = 64
    local px, py
    for i = 0, N do
      local a = i / N * 2 * math.pi
      local x = CIRCLE_CX + math.floor(rr * math.cos(a))
      local y = CIRCLE_CY + math.floor(rr * math.sin(a))
      if i > 0 then graphics.drawLine(px, py, x, y) end
      px, py = x, y
    end
  end

  -- outer circle in BORDER
  graphics.setColor(Theme.BORDER)
  local N = 96
  local px, py
  for i = 0, N do
    local a = i / N * 2 * math.pi
    local x = CIRCLE_CX + math.floor(r * math.cos(a))
    local y = CIRCLE_CY + math.floor(r * math.sin(a))
    if i > 0 then
      graphics.drawLine(px, py, x, y)
      graphics.drawLine(px, py + 1, x, y + 1)
    end
    px, py = x, y
  end

  -- crosshairs (faint centre lines)
  graphics.setColor(Theme.ELEVATED)
  graphics.drawLine(CIRCLE_CX - r, CIRCLE_CY, CIRCLE_CX + r, CIRCLE_CY)
  graphics.drawLine(CIRCLE_CX, CIRCLE_CY - r, CIRCLE_CX, CIRCLE_CY + r)

  -- Cardinal labels (FRONT up, RIGHT, BACK down, LEFT)
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(CIRCLE_CX - 18, CIRCLE_CY - r - 16, "FRONT")
  graphics.drawText(CIRCLE_CX - 14, CIRCLE_CY + r + 6,  "BACK")
  graphics.drawText(CIRCLE_CX + r + 6,  CIRCLE_CY - 6,  "R")
  graphics.drawText(CIRCLE_CX - r - 14, CIRCLE_CY - 6,  "L")

  -- Source position: axes x right, y forward → screen x=cx+x·r, y=cy-y·r
  local sx = CIRCLE_CX + math.floor(srcX * r)
  local sy = CIRCLE_CY - math.floor(srcY * r)

  -- Line from centre to source in ACCENT_DIM
  graphics.setColor(Theme.ACCENT_DIM)
  graphics.drawLine(CIRCLE_CX, CIRCLE_CY, sx, sy)
  graphics.drawLine(CIRCLE_CX + 1, CIRCLE_CY, sx + 1, sy)

  -- Source marker: filled disc in ACCENT, black centre dot for punch
  graphics.setColor(Theme.ACCENT)
  local MR = 14
  for dy = -MR, MR do
    local dx = math.floor(math.sqrt(MR * MR - dy * dy))
    graphics.fillRect(sx - dx, sy + dy, dx * 2, 1)
  end
  -- inner "pupil"
  graphics.setColor(Theme.CANVAS)
  local IR = 5
  for dy = -IR, IR do
    local dx = math.floor(math.sqrt(IR * IR - dy * dy))
    graphics.fillRect(sx - dx, sy + dy, dx * 2, 1)
  end
end

-- ===== Right panel =====
local function paintRightPanel()
  local x = RIGHT_X
  local gL, gR, pan = panGains()

  -- Position card
  local y = 48
  Theme.rect(x, y, RIGHT_W, 120, Theme.SURFACE)
  Theme.outline(x, y, RIGHT_W, 120, Theme.BORDER)

  Theme.text(x + 16, y + 10, "POSITION", Theme.TEXT_DIM)

  -- Azimuth readout (big)
  local az = azimuthDeg()
  graphics.setColor(Theme.ACCENT)
  graphics.drawText(x + 16, y + 36, string.format("%3d°", math.floor(az + 0.5)))

  -- Distance readout
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(x + 140, y + 36, "DIST")
  graphics.setColor(Theme.ACCENT)
  graphics.drawText(x + 140, y + 56, string.format("%d%%", math.floor(distance() * 100)))

  -- Pan readout
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(x + 260, y + 36, "PAN")
  graphics.setColor(Theme.ACCENT)
  graphics.drawText(x + 260, y + 56, (pan < 0) and string.format("L%2d", math.floor(-pan*100 + 0.5))
                                  or  (pan > 0) and string.format("R%2d", math.floor( pan*100 + 0.5))
                                  or  "CTR")

  -- L / R level bars
  local barY = y + 140
  Theme.bar(x, barY,      RIGHT_W, 28, gL, {
    label = "L", valueText = string.format("%.2f", gL),
    color = Theme.ACCENT,
  })
  Theme.bar(x, barY + 54, RIGHT_W, 28, gR, {
    label = "R", valueText = string.format("%.2f", gR),
    color = Theme.ACCENT,
  })

  -- Hint
  graphics.setColor(Theme.TEXT_DIM)
  graphics.drawText(x, barY + 108, "Drag the circle to move the source.")
  graphics.drawText(x, barY + 124, "Pot 1 = azimuth, pot 2 = distance.")
end

-- ===== Paint =====
function paintPan(control)
  local b = control:getBounds()
  local W, H = b[WIDTH], b[HEIGHT]

  Theme.clear(W, H)

  -- Header
  Theme.text(20, 10, "SPATIAL PAN", Theme.TEXT_DIM)
  Theme.line(20, 28, W - 20, 28, Theme.BORDER)

  paintPanCircle()
  paintRightPanel()
end

-- ===== Touch =====
local function touchToSource(tx, ty)
  local dx = (tx - CIRCLE_CX) / CIRCLE_R
  local dy = -(ty - CIRCLE_CY) / CIRCLE_R   -- flip: screen y grows down
  setSource(dx, dy)
end

function touchPan(control, event)
  if event.type == DOWN then
    -- only start drag if touch lands inside the circle + margin
    local dx = event.x - CIRCLE_CX
    local dy = event.y - CIRCLE_CY
    if dx * dx + dy * dy <= (CIRCLE_R + 12) ^ 2 then
      dragging = true
      touchToSource(event.x, event.y)
      control:repaint()
    end
  elseif event.type == MOVE then
    if dragging then
      touchToSource(event.x, event.y)
      control:repaint()
    end
  elseif event.type == UP then
    dragging = false
  end
end

-- ===== Pot =====
-- Pot 1 = azimuth (CCW/CW nudge), pot 2 = distance. On MK2 these are the
-- first two physical encoders on the top row.
function potPan(control, potEvent)
  if potEvent.type ~= MOVE then return end
  local idx = potEvent.id
  if idx == 1 then
    local az = azimuthDeg() + potEvent.delta * 2          -- 2° per detent
    if az < 0 then az = az + 360 end
    az = az % 360
    local rad = az * math.pi / 180
    local d = distance()
    setSource(math.sin(rad) * d, math.cos(rad) * d)
    control:repaint()
  elseif idx == 2 then
    local d = math.max(0, math.min(1, distance() + potEvent.delta / 127))
    local az = azimuthDeg()
    local rad = az * math.pi / 180
    setSource(math.sin(rad) * d, math.cos(rad) * d)
    control:repaint()
  end
end

function preset.onLoad()
  panControl:setBounds({0, 0, 1016, 560})
  panControl:setPaintCallback(paintPan)
  panControl:setTouchCallback(touchPan)
  panControl:setPotCallback(potPan)
  writeParams()
  panControl:repaint()
end
