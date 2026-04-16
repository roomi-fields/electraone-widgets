# Loopop's Tombola

> **Credits** · Original author: **Ziv Eliraz (Loopop)**
> **Source**: https://app.electra.one/preset/eZBSxDFKpnULd4e0we97
> **Schema**: v3 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

OP-1-style physics sequencer: up to 6 coloured balls bounce inside a rotating hexagonal (or 3–12 sided) container, triggering MIDI notes when they hit a wall. Each wall plays a note from one of 13 built-in scales; CCs control gravity, wall bounciness, rotation, spawn rate and ball lifespan. Note-on/note-off messages are sent on MIDI port 1 + port 2 (USB + 3.5 mm jack), channel 1.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Custom | custom | - | - | 100 (virtual) | - | Canvas the simulation is painted on (360×280) |
| 3 | Gravity | fader | unipolar | 0-127 | 11 (virtual) | - | Mapped to GRAVITY 0–0.5 |
| 14 | Bounce | fader | unipolar | 0-127 | 12 (virtual) | - | Mapped to WALL_BOUNCE 0.3–1.0 |
| 4 | Speed | fader | - | 0-127 | 13 (virtual) | - | Rotation speed (-0.2 to +0.2, 64=stopped) |
| 5 | Spawn rate | fader | unipolar | 0-127 | 14 (virtual) | - | Spawn interval multiplier 0.2–5.0 |
| 6 | # of notes | list | - | - | 101 (virtual) | - | 3–12 walls/notes |
| 8 | Life Span | list | - | - | 103 (virtual) | - | Max bounces before a ball disappears (1–127) |
| 7 | Boost | pad | momentary | - | 104 (virtual) | - | Permanent velocity boost applied to every active ball |
| 9 | Scale dice | pad | momentary | - | 105 (virtual) | - | Randomises which of the 13 scales is used (trigger on value 127) |

## Virtual parameters used

The Lua's `parameterMap.onChange` reacts to both `PT_CC7` and `PT_VIRTUAL` variants of the same numbers (11–14, 101, 103, 104, 105) so either wiring works:

- `11` — Gravity
- `12` — Wall bounciness
- `13` — Rotation speed
- `14` — Spawn rate
- `101` — Number of container sides
- `103` — Ball lifetime (bounces)
- `104` — Speed boost trigger
- `105` — Scale randomiser (fires when value == 127)
- `1`, `2`, `3` — virtual-only backup controls (alt sides / spawn-one / clear-all)

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `REFRESH_RATE = 16` — timer period in ms (16 ≈ 60 fps)
- `MAX_BALLS = 6` — hard cap on concurrent balls
- `BALL_RADIUS = 10` — ball size
- `BASE_SPAWN_INTERVAL = 180` — frames between auto-spawns at spawn-rate 1×
- `CONTAINER_SIDES = 6` — default polygon shape (CC101 overrides at runtime)
- `CONTAINER_BASE_RADIUS = 120` — container size
- `CONTROL_WIDTH = 360`, `CONTROL_HEIGHT = 280` — canvas dimensions
- `DAMPING = 0.999`, `FRICTION = 0.98` — physics feel
- `NOTE_OFF_DELAY = 8` — frames before matching note-off is sent
- `BALL_LIFETIME_BOUNCES = 10` — default max bounces (overridden by CC103)
- `SCALES` table — add/replace any of the 13 12-note scales; `CURRENT_SCALE_INDEX` picks the startup one
- `BALL_COLORS` / `COLOR_*` — RGB 565 palette

## Notes

- Notes are sent on both USB (`PORT_1`) and the 3.5 mm MIDI jack (`PORT_2`), always channel 1 — edit `sendNote` if you need different routing.
- Collision counting is clamped to one-bounce-per-frame, so very high bounce values still decay linearly.
- The widget ships its own bitmap font (`FONT` table) to print the current scale name inside the canvas — MK2 `graphics.print` isn't used here.
- Intended as a graphics-in-timer demo; MIDI side is deliberately simple.
