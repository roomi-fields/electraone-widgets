# Resonance Compensation

> **Credits** · Original author: **NewIgnis** (Ignace Vanbiervliet)
> **Source**: [forum #1778, post #6](https://forum.electra.one/t/making-additional-modulation-and-expression-with-lua/1778?page=1#post_10944)
> **Imported**: 2026-04-15 · **License at source**: none specified.

## What it does

On ladder-filter synths (Moog Minitaur, Sub 37, Voyager, and clones), pushing resonance up drains bass and perceived volume. This widget **auto-boosts volume (CC 7) by 70% of the current resonance value**, restoring perceived loudness.

## Expected preset layout

| Role | Binding | Default |
|---|---|---|
| Enable toggle | `PT_VIRTUAL 140` (pad, on/off) | off |
| Visual feedback fader | `PT_VIRTUAL 141` (0..127, informational) | — |
| Resonance CC | incoming CC 21 on device channel | Minitaur default — adjust constant if different synth |
| Volume CC | outgoing CC 7 | standard |

## Integration

1. Paste `widget.lua` into your preset's Lua script.
2. Bind `compensationOn` to the on/off pad (it re-syncs volume on deactivation).
3. Bind `showNothing` as the display formatter on the feedback fader (keeps its screen clean).
4. Adjust the CC 21 comparison in `midi.onControlChange` to match your synth's resonance CC.

## Category

**Behavioral** — no custom paint.
