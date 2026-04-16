# Modern ADSR

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

A flat/modern replacement for the native `dx7envelope` tile. Renders a live ADSR envelope curve with filled area, grid, and value readouts under it; the four parameters are driven by native CC7 faders so any synth patch can wire them.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Envelope | custom | — | — | — | — | Fills the whole page. Everything is drawn with Theme primitives. |

No native faders — input is handled by the custom tile's `touch` and `pot` callbacks.

## Virtual parameters used

The widget **writes** four virtuals, 0..127 each. Wire downstream synth CCs to these:

| Param | Meaning |
|---|---|
| 1 | Attack |
| 2 | Decay |
| 3 | Sustain |
| 4 | Release |

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/graph.lua`, `readout.lua`, `knob.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently.

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `PARAM_A` / `_D` / `_S` / `_R` | 1 / 2 / 3 / 4 | CC numbers to read from. Adjust if your synth uses different assignments. |
| `hold` (inside `envelopePoints()`) | 0.20 | Relative length of the sustain hold region in the drawn curve. |
| `ms()` formula | `v² × 4999 + 1` | Exponential ms mapping; tweak exponent to match your synth's time law. |

## Notes

`parameterMap.onChange` fires on every fader move and repaints the curve — no noticeable latency on MK2. The widget writes no MIDI; it's a UI block that sits next to a synth patch.
