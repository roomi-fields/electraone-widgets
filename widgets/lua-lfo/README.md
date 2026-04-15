# Lua LFO

> **Credits** · Original author: **NewIgnis** (Ignace Vanbiervliet)
> **Source**: [forum #1778, posts #12 and #15](https://forum.electra.one/t/making-additional-modulation-and-expression-with-lua/1778?page=2#post_11012)
> **Imported**: 2026-04-15 · **License at source**: none specified.

## What it does

A free-running LFO implemented entirely in Lua on the Electra One, driven by the built-in 20 ms `timer.onTick()`. Modulates any CC on the target device with a selectable shape and depth, and supports **note-on phase reset** with a variable seed.

Shapes:
- **0** — triangle
- **1** — square
- **2** — ramp up
- **3** — ramp down

Multi-LFO: copy this file, rename all `*_1` suffixes to `*_2`, `*_3` etc., and wire separate preset controls. Each LFO keeps its own state.

## Expected preset layout

| Control | Binding | Function |
|---|---|---|
| Enable pad (toggle) | — | `timerEnable(valueObject, value)` |
| Rate fader | — | `lfoRate1(valueObject, value)` — value = extra ticks per 20 ms |
| Shape list (0..3) | — | `lfoShape1(valueObject, value)` |
| Depth fader (0..127) | — | `lfoDpth1(valueObject, value)` |
| Destination list (CC#) | writes `PT_VIRTUAL 134` | `lfoDest1(valueObject, value)` |
| Reset seed fader (0..127) | `PT_VIRTUAL 181` | 0 disables; 1..127 seeds start phase |

## Integration

Paste `widget.lua` into the preset's Lua script, adjust `deviceId` / default `lfoTarget1` / CC numbers, wire the `*_1` callbacks to your preset controls.

## Category

**Behavioral + light UI binding** — no custom paint. The UI is native faders/pads/lists.

## Notes / gotchas

- Cycle length is fixed at 1270 units. At rate 0 and 20 ms period, one full cycle is ~25 s.
- Post #15 had a typo: `if ... = 1` in a conditional. Corrected here to `> 0` / `== 1` depending on context. Behavior preserved.
- `parameterMap.send` is called every tick — on slow MIDI busses this can saturate the output; consider rate-limiting if you add many LFOs.
