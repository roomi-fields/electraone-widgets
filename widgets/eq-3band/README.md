# 3-Band EQ

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

Three-band parametric EQ — low shelf + mid peak + high shelf — with a live response curve above nine control knobs (FREQ / GAIN / Q per band). Drag any knob or turn pots 1-6 on the MK2 to reshape the curve; the graph redraws instantly because the magnitude response is computed in Lua (no biquad processing, just Gaussian / sigmoid approximations in log-frequency space that read as a convincing EQ curve).

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | 3-Band EQ | custom | — | — | — | — | Single full-page custom tile. Everything drawn via Theme primitives. |

No native faders — input is handled by the custom tile's `touch` and `pot` callbacks.

## How the curve works

For each of 80 points across 20 Hz → 20 kHz (log axis), the widget sums three dB contributions:

- **Low shelf**: sigmoid transition, full gain below `fc`, flat above
- **Mid peak**: Gaussian bell in log-frequency, width ≈ `1 / Q` octaves
- **High shelf**: mirror of low shelf

The total is mapped to the graph's ±18 dB range and drawn as a filled trace with the 0 dB zero-line in yellow. No biquad coefficients are computed — the shapes are chosen to *look* right, not to be DSP-accurate.

## Virtual parameters used

The widget **writes** nine virtuals, 0..127 each. Wire downstream synth/effect CCs to these:

| Param | Meaning |
|---|---|
| 1 / 2 / 3 | LOW: freq / gain / Q |
| 4 / 5 / 6 | MID: freq / gain / Q |
| 7 / 8 / 9 | HIGH: freq / gain / Q |

Ranges: freq is mapped 20 Hz..20 kHz log; gain is -18..+18 dB; Q is 0.3..10 exponential.

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/{graph,knob}.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently.

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `gainDb` formula | `(v - 0.5) × 36` | ±18 dB range. Tighten to `± × 24` for ±12 dB per band. |
| `qValue` formula | `0.3 × (10/0.3)^v` | Exponential Q 0.3..10. Drop the max to 5 for softer peaks. |
| `bandDb` sigmoid slope | `2.2` | Higher = sharper shelf transition. |
| Pot layout | pots 1-3 → LOW, 4-6 → MID | MK2 has 6 top-row encoders; HIGH band is touch-only. |

## Notes

The 0 dB zero-line is drawn in `Theme.WARNING` (amber) so it stays readable through the terracotta fill. The graph's `baseline = 0.5` parameter means the fill is two-sided: it grows upward for boost, downward for cut — which matches how every DAW EQ shows response.
