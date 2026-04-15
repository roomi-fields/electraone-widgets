# Modwheel & Aftertouch Router

> **Credits** · Original author: **NewIgnis** (Ignace Vanbiervliet)
> **Source**: [forum #1778, post #3](https://forum.electra.one/t/making-additional-modulation-and-expression-with-lua/1778?page=1#post_10894)
> **Imported**: 2026-04-15 · **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Takes two incoming MIDI performance signals — the **mod wheel** (CC 1) and **channel aftertouch** — and routes each onto any CC destination on the synth, with a **percentage-depth multiplier** controllable from the preset UI.

Use case: synths that lack internal modwheel-to-any-destination or aftertouch matrices — you add the matrix in Lua on the Electra side.

## Expected preset layout

| Role | Control ref / Virtual param | Range |
|---|---|---|
| Modwheel depth fader | control 25 → `PT_VIRTUAL 129` | 0..100 (percent) |
| Aftertouch depth fader | control 26 → `PT_VIRTUAL 131` | 0..100 (percent) |
| Modwheel destination (CC#) | `PT_VIRTUAL 128` | 0..127 |
| Aftertouch destination (CC#) | `PT_VIRTUAL 130` | 0..127 |

Wire a list tile (or pair of faders) onto the virtual parameters 128 / 130 to let the user pick the destination CC live.

## Integration

Paste `widget.lua` into your preset's Lua script. Adjust `deviceId`, `PT_VIRTUAL` numbers, and `controls.get(...)` refs to match your preset.

## Category

**Behavioral** — no custom paint. Runs entirely as MIDI event handlers. No widget-specific preview.
