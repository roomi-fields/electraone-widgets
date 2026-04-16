# multi env encoders

> **Credits** · Original author: **Thomas Moravansky (Electra One co-founder)**
> **Source**: https://app.electra.one/preset/ZChNPfheMT4kuBe79RXG
> **Schema**: v2 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Six-point envelope editor driven entirely through encoders (pot 6 = active point, pot 10 = X/time, pot 11 = Y/level) plus touch drag on the canvas. On every edit the widget fills a Waldorf-style SysEx packet `{0x3E, 0x0E, devId, 0x20, bufNum, hh, pp, midiValue}` — send is commented out by default. Intended as a stripped-down, touch + encoder-only sibling of `midi-multi-env`.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 4 | Custom X | custom | - | - | 4 (virtual) | - | Envelope canvas; resized to 767×255 at load |
| 5 | Env Stage | fader | unipolar | 1-8 | 8 (virtual) | - | Active-point selector; range re-set to 1…NUMPTS (6) in `preset.onLoad` |
| 6 | X Pos | fader | unipolar | 10-758 | 6 (virtual) | - | Shows the active point's time (pixel X within canvas) |
| 7 | Y Pos | fader | unipolar | 10-256 | 7 (virtual) | - | Shows the active point's level (pixel Y within canvas) |

## Virtual parameters used

- `8` — active-point index (written from touch / pot 6)
- `9` — active-point time (X), written from touch and pot 10
- `10` — active-point level (Y), written from touch and pot 11
- `6`, `7` — X Pos / Y Pos display faders (set via the canvas-value range)

Pot routing: `events.onPotTouch` rebinds the custom canvas's internal pot slot to `POT_7/11/12` when you touch encoder 6/10/11 — the canvas hijacks those knobs while the finger is on the encoder cap.

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `NUMPTS = 6` — envelope point count
- `LOW_MIDI = 0`, `HI_MIDI = 127` — value range
- `XY_PAD_WIDTH = 767`, `XY_PAD_HEIGHT = 255` — canvas size
- `STD_COLOR = 0xB0C0`, `ACT_COLOR = 0xFF0000`
- `devId = 0`, `portNum = PORT_1`, `bufNum = 0x00` — Waldorf target (`0x00` = sound, `0x20` = multi, `0x24` = global)
- Touch tolerance `tolerance = 25` inside `touchCallback`

## Notes

- The SysEx emit is **commented out** — uncomment `midi.sendSysex(portNum, paramSysex)` in `parameterMap.onChange` to actually ship bytes.
- Requires firmware **≥ 3.6.0** (hard-asserted at load time).
- `events.subscribe(POTS)` + `events.onPotTouch` wiring is needed for the encoder-to-canvas hijack; don't drop those lines when slicing the Lua down.
- Time/level params in the target device are assumed to live at 125,127,…,139 (odd = time, even = level); `parameterMap.onChange` rewrites paramNum 9/10 with `114 + pNum + activePt*2` to hit the right stage.
