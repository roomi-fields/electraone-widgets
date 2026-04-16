# Compressor Meter

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

Three-column vertical VU (In / Gain Reduction / Out) with a horizontal threshold line on the input column. Four knobs below control the compressor: threshold, ratio (exp-mapped to 1:1..20:1), attack and release. GR is computed client-side from the input level + settings — no external sidechain plugin needed. A simulated input envelope animates the meters at 25 Hz, so the widget demos cleanly without a DAW.

## How the movement works

By default the widget **simulates its input level** — there's no external audio feeding it. On each 40 ms tick (25 Hz), `simulateInput()` multiplies two sine waves:

- a **slow envelope** (≈ 23 s period) — shapes the overall loudness contour
- a **faster modulator** (≈ 2.7 s period) — ripples on top

The product looks like real programme material: crests that repeatedly cross the threshold. Whenever that happens:

1. **GR meter** falls from the top → reduction = `(input - threshold) × (1 − 1/ratio)`
2. **OUT meter** follows `input − GR`
3. **Attack** sets how quickly GR rises to the target; **Release** sets how slowly it decays when input drops below threshold again

Drag any knob vertically (or use physical pots 1–4 on MK2) to change the compression in real time and watch the GR curve react.

**For live DAW monitoring** of an actual compressor plugin, replace `simulateInput()` inside `timer.onTick` with `input = parameterMap.getValue(1, PT_VIRTUAL, 5) / 127` and route your DAW's output-level CC to virtual param 5.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Compressor | custom | — | — | — | — | Single full-page custom tile. Everything drawn via Theme primitives. |

No native faders — input is handled by the custom tile's `touch` and `pot` callbacks.

## Virtual parameters used

The widget **writes** four virtuals, 0..127 each. Wire downstream synth/effect CCs to these:

| Param | Meaning |
|---|---|
| 1 | Threshold (0 = -36 dB, 127 = 0 dB) |
| 2 | Ratio (exp-mapped 1:1 → 20:1) |
| 3 | Attack (0..300 ms) |
| 4 | Release (0..2000 ms) |

For **live DAW monitoring** of a real compressor, replace `simulateInput()` in `timer.onTick` with `input = parameterMap.getValue(1, PT_VIRTUAL, 5) / 127` and wire your DAW's output level to virtual param 5.

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/{meter,knob}.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently.

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `PARAM_T` / `_R` / `_A` / `_REL` | 1 / 2 / 3 / 4 | Virtual CC numbers for the four knobs. |
| `realRatio()` mapping | `1 + r² × 19` | Ratio curve. Swap to linear if you want 1:1..20:1 as a straight slider. |
| `simulateInput()` frequencies | `0.27` / `2.3` | Slow envelope × fast modulator. Tweak for a livelier or calmer signal. |
| Timer period | 40 ms (25 Hz) | Reduce to 20 ms for 50 Hz smoothness if your CPU budget allows. |

## Notes

The GR meter uses `Theme.meter` with `inverted = true` — fills from the top downward, matching the SSL/1176 convention where "0 dB reduction" sits at the ceiling and compression pulls it down. Colour is `Theme.ACCENT` (terracotta) always, not zone-shifted: reduction is the story, not a threshold state.
