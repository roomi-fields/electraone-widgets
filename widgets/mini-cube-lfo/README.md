# Mini Cube LFO

> **Credits** · Original author: **Martin Pavlas (Electra One creator)**
> **Source**: https://app.electra.one/preset/ZS5BSFRpk5L0dTXRVkvb
> **Schema**: v3 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Compact variant of the full `cube-lfo` widget — same wireframe cube and exponential-speed LFO, but sized for a single page slot (360×280). Two faders set X/Y angular speed; the tracked vertex's projected position is emitted as CC1/CC2 every 20 ms. Starts with a slow horizontal spin by default (`stepX = 0.01`).

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Custom | custom | - | - | 100 (virtual) | - | Canvas the cube is painted on; 360×280 |
| 3 | Horizontal | fader | - | 0-100 | 11 (virtual) | - | X angular-speed input |
| 14 | Vertical | fader | - | 0-100 | 12 (virtual) | - | Y angular-speed input |
| 12 | X (CC #1) | fader | - | 0-127 | 1 (CC7) | - | Visualises / receives the outbound X CC |
| 13 | Y (CC #2) | fader | - | 0-127 | 2 (CC7) | - | Visualises / receives the outbound Y CC |

## Virtual parameters used

- `11` — X angular speed (read in `parameterMap.onChange`)
- `12` — Y angular speed (read in `parameterMap.onChange`)
- `100` — custom control value slot (not actively used)

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `REFRESH_RATE = 20` — timer period in ms
- `CUBE_WIDTH = 360`, `CUBE_HEIGHT = 280` — canvas pixel dimensions
- `COLOR_EDGE = 0xFFFF` — wireframe colour (RGB 565)
- `COLOR_CENTRE_POINT = 0xAB40` — centre-dot colour
- `COLOR_MEASURED_POINT = 0xFE47` — tracked-vertex highlight
- `MEASSURED_EDGE_POINT = 1` — which of the 12 edges drives the CCs
- `uiControls.cube.stepX = 0.01` (inside `preset.onLoad`) — default idle rotation

## Notes

- Unlike the full cube-lfo, this variant does **not** expose outbound-CC pickers; the target CCs are fixed at 1 and 2.
- The outbound-value scaling (`* 0.52`, `- 123` offset) is carried over from the larger widget — if you resize the canvas, re-tune those constants in `sendOutboundCcMessages`.
- Same paint + timer architecture as `cube-lfo`; no touch callback.
