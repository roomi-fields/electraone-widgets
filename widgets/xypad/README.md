# XY Pad

> **Credits** · Authored for **electraone-widgets** (this repo)
> **License**: MIT (`-- License: MIT` in `widget.lua`)

## What it does

Minimal two-axis touch pad. Touching or dragging on the canvas updates two normalised values (0..1, origin bottom-left) and writes them as `PT_VIRTUAL` parameters 1 and 2 scaled to 0-127, so you can wire them to any MIDI message (CC, NRPN, SysEx, …) via the preset's parameter map.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | XY | custom | - | - | 1 (virtual) | - | Canvas; resized to 1016×560 at load; both paint & touch callbacks bound here |

Only one tile is needed. Attach downstream MIDI tiles by targeting virtual parameters 1 (X) and 2 (Y) on the same device ID, and set their message type/CC/channel as required.

## Virtual parameters used

- `1` — X position, 0–127 (written via `parameterMap.set(DEVICE_ID, PT_VIRTUAL, PARAM_X, …)`)
- `2` — Y position, 0–127 (written via `parameterMap.set(DEVICE_ID, PT_VIRTUAL, PARAM_Y, …)`)

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `BG = 0x000000` — background colour (24-bit RGB)
- `GRID = 0x404040` — crosshair colour
- `DOT = 0xFFFFFF` — cursor fill
- `PARAM_X = 1`, `PARAM_Y = 2` — virtual parameter numbers written on touch
- `DEVICE_ID = 1` — target device in the parameter map
- `c:setBounds({0, 0, 1016, 560})` (inside `preset.onLoad`) — canvas size (full page at 1016×560)
- Cursor circle radius `14` (inline in `paintXY`)

## Notes

- Y origin is flipped to bottom-left (`Y = 1 - event.y / h`), matching traditional XY-pad conventions.
- `emit()` is called once at the end of `preset.onLoad` so downstream parameters are initialised to (0.5, 0.5).
- To wire to real MIDI, add two fader / hidden controls in your preset that target paramNum 1 and 2 as `CC7` / `NRPN` / … on the desired device, or call `midi.send*` directly from inside `touchXY` instead of going through `parameterMap`.
