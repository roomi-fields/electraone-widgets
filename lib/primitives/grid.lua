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
--     disabledRows = {        -- rows to render in a muted neutral so the
--       [2] = true,           -- pattern stays visible but clearly inactive
--     },
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
  local disabledRows = opts.disabledRows or {}

  local cellW = (w - gap * (cols - 1)) / cols
  local cellH = (h - gap * (rows - 1)) / rows

  for r = 1, rows do
    local rowDisabled = disabledRows[r]
    -- Muted palette for disabled rows — keeps the pattern visible but reads
    -- as "not playing". Cool neutral contrasts the warm accent of live rows.
    local rowColor    = rowDisabled and Theme.NEUTRAL_ACCENT or color
    local rowColorDim = rowDisabled and Theme.BORDER         or colorDim

    for col = 1, cols do
      local cx = x + (col - 1) * (cellW + gap)
      local cy = y + (r - 1) * (cellH + gap)
      local idx = (r - 1) * cols + col
      local state = cells and cells[idx]
      -- Active-step highlight should only "light up" cells of live rows.
      local isActiveCell = (active and (active % cols == 0 and cols or active % cols) == col)
      local isActive = active == idx
      local intensity = 0
      if state == true then intensity = 1
      elseif type(state) == "number" then intensity = math.max(0, math.min(1, state)) end

      -- Base cell — SURFACE by default; ELEVATED on the active-column lane,
      -- but only if the row is live. Disabled rows stay fully static so no
      -- "traveling" highlight leaks through.
      local bg = (isActiveCell and not rowDisabled) and Theme.ELEVATED or Theme.SURFACE
      Theme.rect(cx, cy, cellW, cellH, bg)

      -- On-cell fill: colour strength follows velocity
      if intensity > 0 then
        local fc = intensity >= 0.66 and rowColor or rowColorDim
        local pad = 2
        local barH = math.max(3, math.floor((cellH - pad * 2) * intensity))
        Theme.rect(cx + pad, cy + cellH - pad - barH, cellW - pad * 2, barH, fc)
      end

      Theme.outline(cx, cy, cellW, cellH, Theme.BORDER)

      -- Active-step marker: bright top edge on every cell in the active
      -- column, but only if the row is live (else the highlight would
      -- suggest the row still plays).
      if isActiveCell and not rowDisabled then
        Theme.rect(cx, cy, cellW, 3, Theme.TEXT)
      end
    end
  end
end

return grid
