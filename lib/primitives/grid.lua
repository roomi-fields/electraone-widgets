-- electraone-widgets · primitive: grid
-- N×M cells with per-cell state (on/off + intensity). Primary use-case is
-- step sequencers and drum matrices.
-- Requires Theme.
--
-- Usage:
--   Theme.grid(x, y, w, h, cols, rows, cells, {
--     color = Theme.ACCENT,   -- on-cell colour (default ACCENT)
--     active = 3,             -- 1-based index of the current step (optional
--                              --   highlight box around it)
--     gap = 2,                -- pixels between cells (default 2)
--   })
-- `cells` is an array indexed by (row - 1) * cols + col, each entry either:
--   - nil or false        → off
--   - true                → fully on
--   - number 0..1         → intensity (velocity)

local function grid(x, y, w, h, cols, rows, cells, opts)
  opts = opts or {}
  local color = opts.color or Theme.ACCENT
  local active = opts.active
  local gap = opts.gap or 2

  local cellW = (w - gap * (cols - 1)) / cols
  local cellH = (h - gap * (rows - 1)) / rows

  for r = 1, rows do
    for col = 1, cols do
      local cx = x + (col - 1) * (cellW + gap)
      local cy = y + (r - 1) * (cellH + gap)
      local idx = (r - 1) * cols + col
      local state = cells and cells[idx]

      -- Off-state background
      Theme.rect(cx, cy, cellW, cellH, Theme.ELEVATED)

      -- On-state or intensity fill
      if state then
        local intensity = (state == true) and 1 or math.max(0, math.min(1, state))
        if intensity > 0 then
          -- Fill full rect with colour — LCD flattens alpha, so we blend
          -- manually by choosing between ACCENT_DIM and color based on
          -- intensity.
          if intensity >= 0.8 then
            Theme.rect(cx, cy, cellW, cellH, color)
          elseif intensity >= 0.4 then
            Theme.rect(cx, cy, cellW, cellH, Theme.ACCENT_DIM)
            Theme.outline(cx, cy, cellW, cellH, color)
          else
            Theme.outline(cx, cy, cellW, cellH, color)
          end
        end
      end

      -- Active-step highlight
      if active and idx == active then
        graphics.setColor(Theme.TEXT)
        graphics.drawRect(cx - 1, cy - 1, cellW + 2, cellH + 2)
      end
    end
  end
end

return grid
