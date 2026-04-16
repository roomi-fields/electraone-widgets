-- electraone-widgets · primitive: grid
-- Step-sequencer / drum-matrix tile grid. Each cell shows on/off state,
-- optional velocity intensity, and the currently-playing step gets a
-- prominent highlight bar.
-- Requires Theme.
--
-- Usage:
--   Theme.grid(x, y, w, h, cols, rows, cells, {
--     color = Theme.ACCENT,   -- on-cell colour (default ACCENT)
--     active = 3,             -- 1-based index of current step (optional)
--     gap = 3,                -- pixels between cells (default 3)
--   })
-- `cells[idx]` where idx = (row-1) * cols + col:
--   nil / false         → off
--   true                → full velocity
--   number 0..1         → velocity fraction

local function grid(x, y, w, h, cols, rows, cells, opts)
  opts = opts or {}
  local color = opts.color or Theme.ACCENT
  local colorDim = opts.colorDim or Theme.ACCENT_DIM
  local active = opts.active
  local gap = opts.gap or 3

  local cellW = (w - gap * (cols - 1)) / cols
  local cellH = (h - gap * (rows - 1)) / rows

  for r = 1, rows do
    for col = 1, cols do
      local cx = x + (col - 1) * (cellW + gap)
      local cy = y + (r - 1) * (cellH + gap)
      local idx = (r - 1) * cols + col
      local state = cells and cells[idx]
      local isActive = active == idx
      local intensity = 0
      if state == true then intensity = 1
      elseif type(state) == "number" then intensity = math.max(0, math.min(1, state)) end

      -- Base cell — SURFACE for off, ELEVATED for active column (visual lane)
      local bg = isActive and Theme.ELEVATED or Theme.SURFACE
      Theme.rect(cx, cy, cellW, cellH, bg)

      -- On-cell fill: colour strength follows velocity
      if intensity > 0 then
        local fc = intensity >= 0.66 and color or colorDim
        -- Inset pad so the cell shows its lane; the velocity rectangle grows
        -- upward from the cell bottom (like a mini-bar).
        local pad = 2
        local barH = math.max(3, math.floor((cellH - pad * 2) * intensity))
        Theme.rect(cx + pad, cy + cellH - pad - barH, cellW - pad * 2, barH, fc)
      end

      -- Subtle border for every cell
      Theme.outline(cx, cy, cellW, cellH, Theme.BORDER)

      -- Active-step: bright top edge (3px tall) so the running position
      -- reads instantly without competing with the velocity fill.
      if isActive then
        Theme.rect(cx, cy, cellW, 3, Theme.TEXT)
      end
    end
  end
end

return grid
