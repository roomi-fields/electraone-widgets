# Primitives Gallery

> **Role** · Dev reference (not a musical widget). Renders every `lib/primitives/*` at various sizes, colours and values so the primitive API can be QA'd visually.

## What it does

Draws all primitives currently implemented (knob, bar, led) with multiple states, plus a composition sample showing how they stack into a "filter card" and "drive card" panel.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Gallery | custom | — | — | — | — | Fills the whole page. |

## Virtual parameters used

None.

## Lua code

Paste [widget.lua](widget.lua). Relies on `Theme` + `Theme.knob` / `Theme.bar` / `Theme.led` — the emulator pre-loads `lib/theme.lua` and `lib/primitives/*`. On the device, paste those files above the widget code.

## Notes

Update this gallery each time a new primitive lands in `lib/primitives/`.
