# Arp Viz

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

A scrolling piano-roll view of a running arpeggiator. Notes slide left across a 3-octave pitch window (C3..C6) as time advances — the right edge is the playhead (where new notes appear) and the left edge is the oldest visible note (~3.5 s back). The widget generates its own notes internally from a fixed demo chord + rate + pattern, so it looks alive without any MIDI input.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Arp Viz | custom | — | — | — | — | Single full-page custom tile. Everything drawn via Theme primitives. |

No native faders — input is handled by the custom tile's `touch` and `pot` callbacks.

## How the arpeggiator works

The demo chord is **C minor 7** (C / Eb / G / Bb) — chosen because it reads well under all four patterns. On each rate tick, the widget picks the next note:

- **UP**: ascends through `chord × octaves`, wraps to bottom
- **DOWN**: descends, wraps to top
- **UP-DN**: bounces endpoint-to-endpoint
- **RAND**: uniform random pick from the whole range

Notes are pushed into a rolling buffer tagged with `startMs` / `endMs`. Every timer tick advances `currentMs`; each note is drawn at `VIZ.x + VIZ.w − age·VIZ.w/windowMs`. The fill colour fades from `ACCENT` (fresh, last ~50 %) to `ACCENT_DIM` (older) so recent activity naturally pops.

## Controls

| Control | Range | What it does |
|---|---|---|
| **RATE knob** | 1000 ms (slow) → 60 ms (fast) | Interval between notes. |
| **GATE knob** | 15 % → 100 % of step interval | Visual note length on the roll. |
| **OCTAVES knob** | 1, 2, 3, 4 | How many octaves the pattern spans. Snaps at thresholds. |
| **PATTERN button** | Cycles UP / DOWN / UP-DN / RAND | Tap to cycle. `seqIdx` resets on cycle so you always start at the root. |
| **FIRING LED** | — | Flashes POSITIVE green for 90 ms each time a note fires. |

## Virtual parameters used

The widget **writes** four virtuals, 0..127 each. Wire downstream synth CCs if you want a host DAW to follow the arp settings:

| Param | Meaning |
|---|---|
| 1 | Rate (0 = 1000 ms, 127 = 60 ms) |
| 2 | Gate length (0..100 %) |
| 3 | Octaves (thresholded to 1/2/3/4) |
| 4 | Pattern (quantised: 0 = UP, 42 = DOWN, 85 = UP-DN, 127 = RAND) |

## Pot layout (MK2)

- **Pot 1**: RATE
- **Pot 2**: GATE
- **Pot 3**: OCTAVES
- **Pot 4**: cycles PATTERN (positive delta = next, negative = prev)

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/{knob,led,button}.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently.

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `CHORD` | `{60, 63, 67, 70}` (Cm7) | Replace with any MIDI-pitch array. |
| `PITCH_MIN` / `PITCH_MAX` | `48` / `84` | Visible pitch window (3 octaves). |
| `TIME_WINDOW_MS` | 3500 | How much history fits on the roll. Stretch for slower rates. |
| `noteH` (inside paintArp) | 8 px | Note-segment thickness. |

## Notes

The activity LED is wired to a one-shot `ledFlash` counter that decrements in the timer — so it pulses for 90 ms on each note-fire, enough to read as a rhythm at high rates but not bleed into a solid glow. Replace the timer-driven `nextPitch()` call with a `parameterMap.onChange` hook on your chord-source CC to build a live arpeggiator that follows a real sustained chord.
