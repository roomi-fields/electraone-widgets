# Tape Meter

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

A mastering-studio-style LUFS + True-Peak meter pair, with peak-hold, colour-zoned fills, and three preset targets (STREAMING −14, BROADCAST −23, LIVE −16). Two vertical bars on the left; a stats panel on the right shows the big current numbers plus Integrated LUFS, Max short-term LUFS, LUFS Range (LRA) and max True-Peak. Three SSL-tile console buttons drive transport: MODE cycles targets, RESET zeroes accumulators, HOLD freezes the peak-hold ticks.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Tape Meter | custom | — | — | — | — | Single full-page custom tile. Everything drawn via Theme primitives. |

No native faders — input is handled by the custom tile's `touch` and `pot` callbacks.

## How the readings work

The widget runs an internal audio simulator (slow programme envelope ±8 dB around −20 dBFS + occasional transient peaks) and derives four values:

- **lufsShort** — short-term LUFS, fast smoothing of the instantaneous level
- **lufsInt** — integrated LUFS, much slower smoothing (settles after several seconds)
- **lufsMax / lufsMin** — track extremes since last RESET
- **lra** = max − min (LUFS Range, dynamic range indicator)
- **tpCur / tpMax** — instantaneous and held true-peak, with a +1.5 dB headroom allowance to simulate inter-sample peaks

Colour zones are target-relative: `ALERT` when more than 3 dB above target, `WARNING` 1-3 dB above, `POSITIVE` in the −6 dB window below target, `NEUTRAL_ACCENT` below that.

**For a real mastering rig**, strip the `simulate()` call and feed `lufsShort` / `tpCur` from a DAW loudness plugin's sidechain CC routed to virtual param 5 (LEVEL).

## Virtual parameters used

The widget **writes** three virtuals, 0..127 each:

| Param | Meaning |
|---|---|
| 1 | Mode (quantised: 0 = STREAMING, 64 = BROADCAST, 127 = LIVE) |
| 2 | Hold state (0 = off, 127 = on) |
| 3 | Reset pulse (any write triggers a zero of accumulators) |

## Interaction

- **MODE button** (ACCENT terracotta LED): tap to cycle STREAMING / BROADCAST / LIVE
- **RESET button** (momentary): zeros lufsMax / lufsMin / lufsInt / tpMax, flashes WARNING amber
- **HOLD button** (POSITIVE green LED): toggles peak-hold freeze for true-peak
- **Pot 1**: MODE cycle (positive = next, negative = prev)
- **Pot 2**: HOLD (positive = on, negative = off)
- **Pot 3**: any movement triggers RESET

## Lua code

Paste `lib/theme.lua`, then `lib/primitives/button.lua` at the top of your preset's Lua tab (as globals), then [widget.lua](widget.lua). The emulator handles this transparently. (The meter primitive is not used — we draw custom fills here so the peak-hold tick can overlay on top cleanly.)

## Optional customisation

| Constant | Default | What it does |
|---|---|---|
| `TARGETS` | STREAMING −14, BROADCAST −23, LIVE −16 | Swap to add more presets (YouTube −14, AES51 −23, club-master −9, etc). |
| `TP_CEILING` | −1 dBTP | Change to −0.3 for a tighter streaming master or −3 for broadcast safety. |
| `dbTo01` range | `(v + 60) / 60` | Re-scale if you want −72..0 for extended dynamic range. |
| `simulate()` curve | slow sine + transients | Replace with `parameterMap.getValue(1, PT_VIRTUAL, 5) / 127 * 60 - 60` on device. |

## Notes

Peak-hold is implemented two ways:
- When **HOLD is on**, `tpMax` latches (decays only on RESET)
- When **HOLD is off**, `tpMax` decays slowly (moving peak-hold) so the tick still tracks recent peaks but doesn't sit forever

The horizontal target-reference line (WARNING amber) is drawn **inside** each meter at the current target level, giving an unambiguous reference — no need to squint at the dB ticks when you just want to know "is it too loud for Spotify".
