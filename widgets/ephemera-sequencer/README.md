# Ephemera Sequencer

> **Credits** · Original author: **shankar** ([GitHub](https://github.com/shankararunachalam) · [forum](https://forum.electra.one/t/ephemera-sequencer-for-electra-one-standalone-lua-firmware/715))
> **Source**: https://github.com/shankararunachalam/electra.lua/tree/main/sequencer
> **License at source**: none specified — imported with attribution under the opt-out policy in [NOTICE.md](../../NOTICE.md).
> **Walkthrough video**: [YouTube](https://www.youtube.com/watch?v=Vx5sd4NpLrM)

## What it does

A proof-of-concept **1-track, 16-step melodic sequencer** running on Electra One's standalone Lua firmware. Touch or knobs to edit notes, hardware buttons for transport.

## Features

- 1 track, 16 steps
- LCD touch screen OR knobs + buttons to interact
- 8 knobs → 8 steps (swap between top/bottom rows)
- `Top` / `Bottom` buttons to switch between step pages
- Change channel and BPM via knobs
- Transport: Play / Pause / Stop
- `Clear` to wipe the sequence
- Ephemeral: no save/load yet

## Requirements

- Electra One with [Standalone Lua firmware](https://docs.electra.one/downloads/firmware.html#lua-script-firmware)
- No preset needed — the script builds its own UI via `Component(…)` + `window.addAndMakeVisible()`

## Installation

1. Upload `widget.lua` via SysEx or the [beta sandbox](https://beta.electra.one/sandbox/)
2. Restart the device
3. Script runs on boot

## Controls

| Hardware | Action |
|---|---|
| BUTTON_1 | Focus top 8 steps |
| BUTTON_2 | Focus bottom 8 steps |
| BUTTON_3 | Clear |
| BUTTON_4 | Play |
| BUTTON_5 | Pause |
| BUTTON_6 | Stop |
| POT_1 | Channel (1..16) |
| POT_6 | BPM (30..200) |
| POT_2..5, POT_8..11 | Step note (for the focused row) |

## Tested on

- [x] Electra One (per author's demo video)
- [ ] MK2 specifically (needs re-verification)
- [ ] Mini
