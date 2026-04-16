# XT Envelopes — Custom envelope editor

> **Credits** · Original author: **Thomas Moravansky** ([tmoravan@yahoo.com](mailto:tmoravan@yahoo.com)) — Electra One co-founder
> **Source**: https://app.electra.one/preset/GK6wmbgvwM6S3GanpoN7
> **Revision**: 2 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under the opt-out policy in [NOTICE.md](../../NOTICE.md).

## What it does

A custom control demonstrating the `paint` / `touch` / `pot` callback system on the Electra One MK2. Implements two envelope modes (`WAVE` 8-point with key-on/key-off loops, `FREE` 4-point bipolar) with active-point editing, colour-coded stages and touch dragging. The author's stated intent is **pedagogical** — showcase the Custom control type without MIDI plumbing. It's the same envelope canvas as `midi-multi-env`, without the SysEx target.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 4 | Custom X | custom | - | - | 4 (virtual) | - | Envelope canvas; resized to ~850×300 at load |
| 1 | Key On Loop | pad | toggle | - | 13 (virtual) | setState | On-loop enable (Wave mode) |
| 8 | Start | fader | unipolar | 1-8 | 15 (virtual) | setStart | On-loop start stage |
| 9 | End | fader | unipolar | 1-8 | 16 (virtual) | setEnd | On-loop end stage |
| 3 | Key Off Loop | pad | toggle | - | 14 (virtual) | setState | Off-loop enable (Wave mode) |
| 10 | Start | fader | unipolar | 1-8 | 17 (virtual) | setStart | Off-loop start stage |
| 11 | End | fader | unipolar | 1-8 | 18 (virtual) | setEnd | Off-loop end stage |
| 5 | Env Stage | fader | unipolar | 1-8 | 8 (virtual) | selectStage | Active-point selector |
| 6 | Time | fader | unipolar | 0-127 | 9 (virtual) | adjustTime | Time/X of the active point |
| 7 | Level | fader | unipolar | 0-127 | 10 (virtual) | adjustLevel | Level/Y of the active point |
| 12 | Env Select | pad | toggle | - | 19 (virtual) | selectEnvelope | Wave ↔ Free mode |

## Virtual parameters used

- `8` — active-point index (written from touch, pot, and `selectStage`)
- `9` — active-point time (X), two-way sync'd to the canvas
- `10` — active-point level (Y), two-way sync'd to the canvas
- `13`, `14` — on/off loop enable flags (from pads 1, 3)
- `15`…`18` — loop start/end stage numbers
- `19` — Wave/Free mode toggle

The widget's `parameterMap.onChange` also builds a Waldorf SysEx packet for Time/Level edits but does **not** send it (the `midi.sendSysex(portNum, paramSysex)` line is commented out).

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

| Symbol | Default | Meaning |
|---|---|---|
| `WAVEPTS` | 8 | Wave envelope point count |
| `FREEPTS` | 4 | Free envelope point count |
| `SCALEX` | 0.90625 | Horizontal scale of the canvas |
| `SCALEY` | 2 | Vertical scale |
| `WIN_OFST` | 70 | Canvas vertical offset for T/L readouts |
| `SUSTAIN` | 64 | Sustain-segment pixel width |
| `STD_COLOR` | `0xB0C0` | Inactive stage colour |
| `ACT_COLOR` | `0xFF0000` | Active stage colour |
| `ON_COLOR` | `0x0000FF` | Key-on loop markers |
| `OFF_COLOR` | `0x00FF00` | Key-off loop markers |
| `devId` | `0` | Waldorf target device ID |
| `portNum` | `PORT_1` | SysEx port (if you uncomment the send) |
| `bufNum` | `0x00` | Waldorf buffer: `0x00` sound / `0x20` multi / `0x24` global |

## Notes

- Requires firmware **≥ 3.6.0** (`controller.isRequired(MODEL_MK2, "3.6.0")` is asserted at the top of the script).
- Load `demo.preset.json` as-is in the Electra One editor / beta sandbox. The preset bundles 12 tiles (custom canvas + pads + faders) and this Lua script together.
- Almost identical in behaviour to `midi-multi-env`; the main difference is the organisation of `activeEnv` into a local reference rather than a 1/2 integer flag.
- Tested on Electra One MK2 (per author's compatibility assertion). Re-verify on current firmware.
