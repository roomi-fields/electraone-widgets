# MIDI multi env

> **Credits** · Original author: **Thomas Moravansky (Electra One co-founder)**
> **Source**: https://app.electra.one/preset/dcm643vSk28wT0BctHbf
> **Schema**: v2 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Multi-stage envelope editor with two modes: an 8-point **Wave** envelope (with key-on / key-off loop regions and a sustain segment) and a 4-point **Free** envelope (bipolar levels). Points are selected and dragged directly on the canvas; a stage-index fader plus Time/Level faders give pot-based editing. On edit the widget constructs a Waldorf-style SysEx packet (`{0x3E, 0x0E, devId, 0x20, bufNum, hh, pp, midiValue}`) — send is currently commented out, so wire `midi.sendSysex` back in for your own target.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 4 | Custom X | custom | - | - | 4 (virtual) | - | Envelope canvas; resized to ~850×300 at load |
| 1 | Key On Loop | pad | toggle | - | 13 (virtual) | setState | Enables Wave-mode on-loop region |
| 8 | Start | fader | unipolar | 1-8 | 15 (virtual) | setStart | On-loop start stage |
| 9 | End | fader | unipolar | 1-8 | 16 (virtual) | setEnd | On-loop end stage |
| 3 | Key Off Loop | pad | toggle | - | 14 (virtual) | setState | Enables Wave-mode off-loop region |
| 10 | Start | fader | unipolar | 1-8 | 17 (virtual) | setStart | Off-loop start stage |
| 11 | End | fader | unipolar | 1-8 | 18 (virtual) | setEnd | Off-loop end stage |
| 5 | Env Stage | fader | unipolar | 1-8 | 8 (virtual) | selectStage | Active-point selector (range re-set to 1…NUMPTS in `preset.onLoad`) |
| 6 | Time | fader | unipolar | 0-127 | 9 (virtual) | adjustTime | X (time) of the active point |
| 7 | Level | fader | unipolar | 0-127 | 10 (virtual) | adjustLevel | Y (level) of the active point |
| 12 | Env Select | pad | toggle | - | 19 (virtual) | selectEnvelope | Toggles Wave ↔ Free |

The `preset.onLoad` handler recolours the on-loop tiles (refs 1, 8, 9) blue (`ON_COLOR`) and the off-loop tiles (refs 3, 10, 11) green (`OFF_COLOR`).

## Virtual parameters used

- `8` — active-point index (written from touch / pot; read by `selectStage`)
- `9` — active-point time/X (sync'd both ways between fader and canvas)
- `10` — active-point level/Y (sync'd both ways)
- `13`, `14` — on/off loop enable flags (driven by pads 1, 3)
- `15`…`18` — loop start/end stage numbers
- `19` — Wave/Free mode flag

`parameterMap.onChange` intercepts changes with `origin == MIDI` (ignored), `origin == LUA` (only passes through for paramNums 9, 10) and others, then builds Waldorf MW2 SysEx bytes (`0x3E 0x0E …`). The actual `midi.sendSysex(portNum, paramSysex)` call is commented out at line 419 — uncomment or replace to emit.

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `WAVEPTS = 8`, `FREEPTS = 4` — point counts for Wave/Free modes
- `LOW_MIDI = 0`, `HI_MIDI = 127` — envelope value range
- `WIN_OFST = 70` — top padding of the drawable area (reserved for the per-point T/L readouts)
- `SUSTAIN = 64` — pixel width of the sustain segment
- `SCALEX = 0.90625`, `SCALEY = 2` — pixels per MIDI unit
- `STD_COLOR = 0xB0C0`, `ACT_COLOR = 0xFF0000`, `ON_COLOR = 0x0000FF`, `OFF_COLOR = 0x00FF00`
- `devId = 0`, `portNum = PORT_1`, `bufNum = 0x00` — Waldorf target (`0x00` = sound edit, `0x20` = multi, `0x24` = global)
- Wave time/level params live at 125,127,…,139 (odd = time, even = level); Free time/level at 149–156. Map them through `parameterMap` to get MIDI per stage.

## Notes

- The SysEx emit is **commented out** in the source; this widget won't send anything until you uncomment `midi.sendSysex(portNum, paramSysex)` near the end of `parameterMap.onChange`.
- Requires firmware **≥ 3.6.0** (hard-asserted at load time).
- Wave-mode loop visualisation relies on ref IDs 1,3,8,9,10,11 being intact — `loopVis(isVis)` toggles them by ID.
- The `selectStage` range is reconfigured at load (`valId:setRange(1, NUMPTS, 1, true)`) so start/end tiles end up clamped to the active mode's point count.
