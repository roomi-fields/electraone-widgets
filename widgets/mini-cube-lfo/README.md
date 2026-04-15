# Mini Cube LFO

> **Credits** · Original author: **Martin Pavlas (Electra One creator)**
> **Source**: https://app.electra.one/preset/ZS5BSFRpk5L0dTXRVkvb
> **Schema**: v3 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## Description

Demo of graphics handled in the timer interrupt handler

The Cube LFO generates a pseudo random series of CC messages according to reading of a projection of X, Y coordinates of one of the cube vertices.

**Note**, it is really meant just to demonstrate handling graphics for Custom Control.

## Integration

Load `demo.preset.json` in the Electra One editor (`app.electra.one`) — the Lua is embedded in the `lua` field.
For manual reuse, copy `widget.lua` into your own preset's Lua script.

## Category

Custom-paint widget — uses `setPaintCallback` / `setTouchCallback`.
