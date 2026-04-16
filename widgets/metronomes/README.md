# Metronomes

> **Credits** · Original author: **Dave House**
> **Source**: https://app.electra.one/preset/CBRYC9JppeZUzOqgCvBT
> **Schema**: v3 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Six independent bouncing balls (one per row) act as visual metronomes. Each ball has its own channel/note/speed/left-velocity/right-velocity; when a ball hits a wall it fires a MIDI `noteOn`/`noteOff`. A master `START` pad, a `reset` pad and a logarithmic `global speed` slider (×0.1 at 1, ×1 at 50, ×10 at 100) drive the whole set. Tick rate 20 ms.

## Required tiles

All faders hit a `bN...` Lua callback that writes straight into the ball table.

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | custom | custom | - | - | 1 (CC7) | - | Canvas for the 6 lanes; 640×480 |
| 3 | START | pad | toggle | - | 6 (virtual) | bRun | Master run gate |
| 34 | reset | pad | momentary | - | 125 (CC7) | bReset | Parks all balls at left wall |
| 35 | global speed | fader | - | 0-127 | 126 (virtual) | gSpeed | Log multiplier on every ball's step |
| 33 | pattern | list | - | - | 32 (virtual) | spdPreset | Speed preset selector |
| 2 | speed | fader | - | 0-127 | 2 (virtual) | b1Speed | Ball 1 step |
| 13 | note | fader | - | 0-127 | 120 (virtual) | b1Note | Ball 1 MIDI note |
| 14 | channel | fader | - | 1-16 | 3 (virtual) | b1Chan | Ball 1 channel |
| 6 | vel1 | fader | - | 0-127 | 40 (virtual) | b1VelL | Ball 1 velocity on left wall |
| 9 | vel2 | fader | - | 0-127 | 5 (CC7) | b1VelR | Ball 1 velocity on right wall |
| 7 | speed | fader | - | 0-127 | 7 (virtual) | b2Speed | Ball 2 step |
| 15 | note | fader | - | 0-127 | 8 (virtual) | b2Note | Ball 2 MIDI note |
| 16 | channel | fader | - | 1-16 | 9 (virtual) | b2Chan | Ball 2 channel |
| 11 | vel1 | fader | - | 0-127 | 10 (virtual) | b2VelL | Ball 2 velocity L |
| 12 | vel2 | fader | - | 0-127 | 11 (CC7) | b2VelR | Ball 2 velocity R |
| 4 | speed | fader | - | 0-127 | 4 (virtual) | b3Speed | Ball 3 step |
| 10 | note | fader | - | 0-127 | 15 (virtual) | b3Note | Ball 3 MIDI note |
| 17 | channel | fader | - | 1-16 | 16 (virtual) | b3Chan | Ball 3 channel |
| 5 | vel1 | fader | - | 0-127 | 13 (virtual) | b3VelL | Ball 3 velocity L |
| 8 | vel2 | fader | - | 0-127 | 14 (CC7) | b3VelR | Ball 3 velocity R |
| 18 | speed | fader | - | 0-127 | 18 (virtual) | b4Speed | Ball 4 step |
| 27 | note | fader | - | 0-127 | 26 (virtual) | b4Note | Ball 4 MIDI note |
| 28 | channel | fader | - | 1-16 | 27 (virtual) | b4Chan | Ball 4 channel |
| 19 | vel1 | fader | - | 0-127 | 118 (virtual) | b4VelL | Ball 4 velocity L |
| 20 | vel2 | fader | - | 0-127 | 19 (CC7) | b4VelR | Ball 4 velocity R |
| 21 | speed | fader | - | 0-127 | 21 (virtual) | b5Speed | Ball 5 step |
| 29 | note | fader | - | 0-127 | 28 (virtual) | b5Note | Ball 5 MIDI note |
| 30 | channel | fader | - | 1-16 | 29 (virtual) | b5Chan | Ball 5 channel |
| 22 | vel1 | fader | - | 0-127 | 121 (virtual) | b5VelL | Ball 5 velocity L |
| 23 | vel2 | fader | - | 0-127 | 22 (CC7) | b5VelR | Ball 5 velocity R |
| 24 | speed | fader | - | 0-127 | 24 (virtual) | b6Speed | Ball 6 step |
| 31 | note | fader | - | 0-127 | 30 (virtual) | b6Note | Ball 6 MIDI note |
| 32 | channel | fader | - | 1-16 | 31 (virtual) | b6Chan | Ball 6 channel |
| 25 | vel1 | fader | - | 0-127 | 124 (virtual) | b6VelL | Ball 6 velocity L |
| 26 | vel2 | fader | - | 0-127 | 25 (CC7) | b6VelR | Ball 6 velocity R |

## Virtual parameters used

The widget reads **by control name** via `controls.getValue("bRun")`, `controls.getValue("gSpeed")` and `controls.getValue(bN..Chan|Note|Speed|VelL|VelR)` at load time. No explicit `parameterMap.get`/`set` calls — state lives entirely in the Lua `balls` table plus the per-control callbacks. If you duplicate or rename any of the faders above, keep the value IDs (`bRun`, `gSpeed`, `b1Speed`, …) aligned with the Lua or preload will skip it.

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `CANVAS_ID = 1` — control ID of the custom canvas
- `W, H = 640, 480` — canvas dimensions
- `ROWS = 6` — number of lanes / balls (to go beyond 6, also extend the `balls` table and CC map)
- `TICK_MS = 20` — timer period (ms)
- `MIDI_PORT = 1` — send port
- `balls = { ... }` — per-ball defaults (`col`, `row`, `note`, `spdKn`, `velL`, `velR`)
- `knobToMs(k)` — maps 0–127 into 50–5000 ms per full lane traversal
- `gKnobToMul(k)` — log curve, 0.1× at 1, ×1 at 50, 10× at 100

## Notes

- `bReset` only fires on value 1; momentary pads send 1 on press.
- Each wall hit immediately sends `noteOn` followed by `noteOff(…,0)` — there is no held-note behaviour.
- The display only repaints inside `timer.onTick`, so if `runMaster == 0` the balls visibly freeze.
- Canvas ID 1 is hard-coded; change `CANVAS_ID` if your preset needs a different slot.
