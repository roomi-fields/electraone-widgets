# Spatial Pan

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

Top-down circular pan visualisation — the kind you'd find in a VR / ambisonic / Dolby Atmos panner. The source position is a filled dot inside a circle; four cardinal labels mark FRONT / BACK / L / R; three concentric rings at 25/50/75 % give distance cues. Drag anywhere in the circle to move the source; an L/R equal-power pan law drives two level bars on the right panel so the readouts always match what a stereo fold-down would sound like.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Spatial Pan | custom | — | — | — | — | Single full-page custom tile. Everything drawn via Theme primitives. |

No native faders — input is handled by the custom tile's `touch` and `pot` callbacks.

## How the pan works

The source sits in a 2D frame where x is right and y is "forward". The widget converts that to three values:

- **Azimuth** = `atan2(x, y)`, 0° front, increasing clockwise (0..360°)
- **Distance** = `sqrt(x² + y²)` clamped to 1.0 at the rim
- **L/R gains** via equal-power pan: `pan = x/d`, then `gL = cos((pan+1)π/4)`, `gR = sin((pan+1)π/4)`, attenuated by `1/(1 + 1.2·d)` for distance roll-off

These three are written out as MIDI each time the source moves.

## Virtual parameters used

The widget **writes** two virtuals, 0..127 each:

| Param | Meaning |
|---|---|
| 1 | Azimuth (0 = 0°, 127 = 360°) |
| 2 | Distance (0 = source at centre, 127 = source at rim) |

## Interaction

- **Touch**: drag anywhere inside the circle to place the source. Release = release.
- **Pot 1**: azimuth nudge, 2° per detent
- **Pot 2**: distance nudge, 1/127 per detent

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/bar.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently.

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `CIRCLE_R` | 230 | Radius in pixels. Raise for a bigger circle (leave room for the right panel). |
| Distance attenuation | `1 / (1 + d × 1.2)` | Tighten to `1 / (1 + d × 2)` for more aggressive distance roll-off. |
| Pot step sizes | 2° azimuth, `1/127` distance | Double the azimuth step for faster rotations. |

## Notes

The pan marker is a filled accent disc with a dark "pupil" at its centre — reads cleanly against the grid and doesn't disappear near the cardinal labels. The centre-to-source trace is drawn in `ACCENT_DIM` so the marker stays the focal point even when the cord is long.
