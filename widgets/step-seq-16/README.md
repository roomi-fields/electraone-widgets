# 32-Step Sequencer (2 × 16)

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

Two parallel 16-step drum-machine lanes running at the same tempo. Each cell carries an independent velocity (tap to toggle full/zero, drag vertically for fractional). A bright playhead traces the active step through every **live** row — LINE 2 can be muted via its own toggle, in which case its row greys out and the playhead skips it entirely so you see at a glance it's not being traversed.

Three SSL-console-tile buttons drive transport: **RUN** (toggle), **LINE 2** (toggle), **RESET** (momentary — flashes amber on tap).

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | 16-Step Sequencer | custom | — | — | — | — | Single full-page custom tile. Everything drawn via Theme primitives. |

No native faders — input is handled by the custom tile's `touch` and `pot` callbacks.

## How the transport works

An internal 100 Hz timer accumulates elapsed milliseconds and compares them against the current step's interval. The 16th-note interval is `60000 / BPM / 4` ms; **SWING** stretches odd 16ths and shrinks even ones (up to a 50 % skew at max). When the accumulator crosses the interval, `currentStep` advances and the grid repaints — so the playhead moves smoothly at the right tempo on whatever rows are live.

Toggling **LINE 2** off:
- Row 2 cells render in cool `NEUTRAL_ACCENT` (the pattern stays visible but clearly inactive)
- The column-active `ELEVATED` lane highlight is suppressed on row 2
- The white playhead line stops at the bottom of row 1 — row 2 is fully static

## Virtual parameters used

The widget **writes** four virtuals, 0..127 each. Wire downstream synth/drum-machine CCs to these:

| Param | Meaning |
|---|---|
| 1 | BPM (0 = 60 BPM, 127 = 200 BPM) |
| 2 | Swing amount (0..100 %) |
| 3 | Run state (0 = stopped, 127 = running) |
| 4 | Line 2 enabled (0 = muted, 127 = live) |

Per-step velocities are internal state — the widget doesn't (yet) fire MIDI notes at step transitions. To wire that up on-device, add `noteOn` calls in the timer's step-advance branch using `steps[currentStep]` for lane 1 and `steps[16 + currentStep]` for lane 2 (respecting `line2Enabled`).

## Interaction

- **Tap a step**: toggle between 0 and full velocity
- **Drag a step vertically**: set velocity 0..1
- **RUN button**: toggle transport on/off (LED window lights POSITIVE green)
- **LINE 2 button**: toggle lane 2 live/muted (LED window lights ACCENT terracotta)
- **RESET button**: tap to jump to step 1 (body flashes WARNING amber)
- **Pots 1-2 on MK2**: BPM / swing
- **Pot 3**: positive delta enables RUN, negative disables
- **Pot 4**: positive delta enables LINE 2, negative disables
- **Pot 5**: any movement triggers a RESET pulse

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/{grid,knob,led,button}.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently.

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `steps` default | 4-on-the-floor + ghost hits on both lanes | Initial pattern. Any 32-entry array of 0..1 velocities works (1..16 = row 1, 17..32 = row 2). |
| BPM range | `60..200` | Change the `60` / `140` constants in `setKnob(1, …)` to shift. |
| Swing max skew | ±50 % | Change `0.5` in `stepInterval` for a gentler or wilder swing feel. |
| Button size | 140 × 56 px | Smaller/larger values keep the SSL-tile proportions as long as `h` stays > 30 (LED window eats 10 px + frame). |
| Timer period | 10 ms (100 Hz) | Drop to 20 ms for lower CPU cost at a small timing-accuracy penalty. |

## Notes

The three transport buttons are the first production use of the new `Theme.button` primitive — an SSL-console-tile: machined-metal double-stroke frame, brushed-steel ELEVATED body, 10 px LED window across the top in the semantic color, label double-drawn for weight, momentary presses flash the whole body amber with an inverted label.
