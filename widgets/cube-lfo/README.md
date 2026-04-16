# Cube LFO

> **Credits** · Original author: **Martin Pavlas (Electra One creator)**
> **Source**: https://app.electra.one/preset/OE5cAkqSG7tdrTa28nNs
> **Schema**: v2 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Draws a rotating 3D cube and tracks the projected (X, Y) position of one vertex, sending those coordinates as outbound CC messages every 20 ms. Two faders control the X/Y angular speed (exponential curve, max ≈0.2 rad/tick); two list pickers re-map the outbound CC numbers on the fly. A pure custom-paint demo — the cube lives entirely inside the Lua timer loop.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Custom | custom | - | - | 100 (virtual) | - | Canvas the cube is painted on; resized to 650×280 in `preset.onLoad` |
| 4 | X | fader | - | 0-100 | 11 (virtual) | - | Horizontal angular speed |
| 6 | Y | fader | - | 0-100 | 12 (virtual) | - | Vertical angular speed |
| 8 | X | list | - | - | 3 (virtual) | xCcChanged | Chooses the outbound CC# for the X axis |
| 9 | Y | list | - | - | 4 (virtual) | yCcChanged | Chooses the outbound CC# for the Y axis |
| 12 | X | fader | - | 0-127 | 5 (CC7) | - | Visualises the outbound X CC — `parameters.outX` target |
| 13 | Y | fader | - | 0-127 | 6 (CC7) | - | Visualises the outbound Y CC — `parameters.outY` target |

Labels in the source preset (refs 2, 5, 7, 10, 11) are skipped — copy them only if you want matching captions.

## Virtual parameters used

- `11` — X angular speed input (read in `parameterMap.onChange`)
- `12` — Y angular speed input (read in `parameterMap.onChange`)
- `3` — X outbound CC# selector (read through `xCcChanged`)
- `4` — Y outbound CC# selector (read through `yCcChanged`)
- `100` — custom control's own value slot (not actively used by the Lua)

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `REFRESH_RATE = 20` — timer period in ms (lower → smoother, higher CPU)
- `CUBE_WIDTH = 650`, `CUBE_HEIGHT = 280` — canvas pixel dimensions
- `COLOR_EDGE = 0xFFFF` — wireframe colour (RGB 565)
- `COLOR_CENTRE_POINT = 0xAB40` — centre-dot colour
- `COLOR_MEASURED_POINT = 0xFE47` — measured-vertex highlight colour
- `MEASSURED_EDGE_POINT = 1` — which of the 12 cube edges (and its first vertex) drives the outputs

## Notes

- Requires firmware **≥ 3.6.0** (hard-asserted at load time).
- Pure custom-paint demo — uses `setPaintCallback` and a recurring `timer.onTick`; no `setTouchCallback`.
- The inside of `sendOutboundCcMessages` has two magic numbers (`cube.centrePoint.x - 123`, `* 0.52`) that map the projected vertex pixel coordinates into a 0–127 CC value; tweak them if you change `CUBE_WIDTH`/`CUBE_HEIGHT`.
