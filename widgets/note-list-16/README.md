# 16-Step Note List (×3 lanes)

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

A reusable 16-step custom control inspired by the Waldorf Q-style arpeggiator / step-list editor. Each lane is one row of 16 cells, **grouped by 4** with thicker dividers, displaying values in-cell (note names, raw values, or `%`). A common **RANGE** parameter dims/hides the steps past the active pattern length so you can shorten without losing your edits.

The demo stacks three independent lanes — **NOTES** (MIDI note name), **VELOCITY** (0..127), **GATE %** (0..100%) — to illustrate the pattern from the forum thread that motivated this widget: *"supports up to 6 controls per screen, 96 parameters in a single screen"*. Each lane is the same primitive, sharing only the common RANGE.

Forum thread: [Looking for a 16-step custom control for arp and seq](https://forum.electra.one/t/looking-for-a-16-step-custom-control-for-arp-and-seq/4425)

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | 16-Step Note List | custom | — | — | — | — | Single full-page custom tile. All three lanes drawn inside it. |

No native faders or knobs — everything is handled by the custom tile's `touch` and `pot` callbacks.

## Interaction

- **Tap a cell**: select that lane + step (the lane's value readout switches to the right edge)
- **Drag a cell vertically**: edit the value 0..127 in place
- **Pot 1**: navigate the selected step 1..16 (1 step per detent)
- **Pot 2 / 3 / 4**: edit the current step's value on lane 1 / 2 / 3 respectively. Selecting lane via pot is automatic.
- **Pot 5**: range 1..16 — steps past the range render greyed out and stop firing
- **Pot 6**: cycle the selected lane (1..3)

## Visual conventions

- Active step (selected lane + step): `ELEVATED` background, bright top edge, full lane colour bar, primary text
- Inactive in-range step: `SURFACE` background, dim lane colour bar, dim text
- Out-of-range step (past RANGE): `CANVAS` background, dim dot only, hairline `ELEVATED` outline — clearly outside the pattern
- Group dividers: extra 6px gap after step 4 / 8 / 12, no painted divider needed
- Each lane carries its own warm/cool colour from the Theme palette (NOTES = warm `ACCENT`, VELOCITY = cool `POSITIVE`, GATE = `INFO`)

## Virtual parameters

The widget exposes **49** virtual parameters, 0..127 each:

| Range | Meaning |
|---|---|
| 1..16 | Lane 1 — note values |
| 17..32 | Lane 2 — velocity values |
| 33..48 | Lane 3 — gate length values |
| 49 | Common RANGE (0..127 maps to step 1..16) |

Wire downstream synth/sequencer CCs to any of these — the host DAW or your own playback timer reads the values and fires the notes.

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/readout.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently.

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `LANES` | `3` | Number of lanes drawn. Increase up to 6 for the full forum-described layout (you'll want to shrink `LANE_H` accordingly). |
| `LANE_H` | `110` | Lane height in px. Shrink for more lanes per screen. |
| `GROUP_GAP_EXTRA` | `6` | Extra pixels added every 4 cells to visually group steps. Set to `0` for a continuous row. |
| `lanes[i].kind` | varies | `"note"` (MIDI note name) / `"num"` (raw 0..127) / `"pct"` (0..100%) — display format. |
| `lanes[i].color` | varies | Per-lane accent colour from `Theme.*`. |
