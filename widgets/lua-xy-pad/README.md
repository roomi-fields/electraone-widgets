# [Lua] XY Pad

> **Credits** · Original author: **Martin Pavlas (Electra One creator)**
> **Source**: https://app.electra.one/preset/QIatK17htTqLzhkHRnp4
> **Schema**: v2 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Reference XY-pad demo showing how to wire `paint`, `touch` and `pot` callbacks on a single Custom control. Touch the pad to drag a crosshair + circle marker; an assigned pot nudges X by its delta. Deliberately MIDI-free — the point is to demonstrate the callback surface, not send data.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 4 | Custom X | custom | - | - | 4 (CC7) | - | The XY pad canvas — resized to 400×300 in `preset.onLoad`; touch & pot callbacks both bound here |

The preset itself only holds this one tile; the CC7 parameterNumber is present for infrastructure but the widget sends nothing over MIDI.

## Virtual parameters used

None. The widget keeps its state in two locals (`xyPadControl.x`, `xyPadControl.y`) and never calls `parameterMap.set` / `parameterMap.get`.

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `XY_PAD_WIDTH = 400`, `XY_PAD_HEIGHT = 300` — canvas pixel dimensions
- `OUTLINE_COLOR = 0xB0C0` — pad border (RGB 565)
- `CENTRE_CROSS_COLOR = 0x2104` — crosshair at centre
- `ACTIVE_CROSS_COLOR = 0xB004` — moving crosshair at touch point
- `VALUE_CIRCLE_COLOR = 0xFC80` — cursor ring

## Notes

- Requires firmware **≥ 3.6.0** (hard-asserted at load time).
- To get actual MIDI output, hook `parameterMap.set(deviceId, PT_VIRTUAL, N, value)` inside `touchCallback` — see `xypad/widget.lua` in this repo for a minimal emitting variant.
- `potCallback` prints delta events and only edits X; you can extend it to use `potEvent.id` and nudge Y too.
