# Theme Gallery

> **Role** · Dev reference (not a musical widget). Paints the whole [`lib/theme.lua`](../../lib/theme.lua) palette + sample typography so design-system changes can be reviewed visually in the emulator.

## What it does

Draws all Theme palette entries (neutrals + accents), the `Theme.card(…)` primitive, line weights, and typography samples in a single custom tile.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Gallery | custom | — | — | — | — | Fills the whole page (1016×560). |

## Virtual parameters used

None.

## Lua code

Paste [widget.lua](widget.lua) into a preset's Lua tab. It relies on the global `Theme` — the emulator pre-loads [`lib/theme.lua`](../../lib/theme.lua); on the device, paste `lib/theme.lua` above this code.

## Optional customisation

None — this is a QA tool, not a user-facing widget.

## Notes

Keep this widget updated whenever `lib/theme.lua` changes so the visual contract stays verifiable at a glance.
