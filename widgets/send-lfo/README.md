# Send LFO

> **Credits** · Original author: **Martin Pavlas (Electra One creator)**
> **Source**: https://app.electra.one/preset/hXZd5qXpoMx82gIz6qWP
> **Schema**: v3 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under [NOTICE.md](../../NOTICE.md).

## What it does

Free-running LFO with a built-in oscilloscope. Generates sawtooth / square / triangle / sine simultaneously from a single phase accumulator, ships the triangle output through an inter-preset `pipe` named `"output"`, and draws the live signal on a 314×140 scope canvas. Rate is exponential (0.1 Hz at 0% → 10 Hz at 100%, cubic curve). `RUN` / `STOP` pads start and stop the timer; `Rate` / `Phase` / `Amplitude` / `Pulse Width` shape the wave.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 1 | Rate | fader | - | 0-100 | 1 (virtual) | setRate | LFO frequency (exponential 0.1–10 Hz) |
| 2 | Phase | fader | - | 0-100 | 2 (virtual) | setPhase | LFO phase offset (% of cycle) |
| 3 | Amplitude | fader | - | 0-100 | 3 (virtual) | setAmplitude | LFO amplitude 0–1.0 |
| 4 | Pulse Width | fader | - | 0-100 | 7 (virtual) | setPulseWidth | Square-wave duty 0–1.0 |
| 5 | RUN | pad | momentary | - | 5 (CC7) | run | Enables the timer and prints "Running" |
| 6 | STOP | pad | momentary | - | 6 (CC7) | stop | Disables the timer |
| 7 | Custom | custom | - | - | 8 (CC7) | - | Scope canvas; 314×140 |

## Virtual parameters used

- `4` — Pulse Width default: `parameterMap.get(1, PT_VIRTUAL, 4)` is read once at load into `defaultPulseWidth` (note: doesn't match the PW fader's paramNum `7` — the author left this as-is).
- `1`, `2`, `3`, `7` — written externally into the `lfo` state via `setRate` / `setPhase` / `setAmplitude` / `setPulseWidth` callbacks.

No other `parameterMap.set` / `.get` calls. The triangle output also flows into the pipe `pipe.acquire("output")` each tick — any other preset reading that pipe name sees it.

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `SCOPE_WIDTH = 314`, `SCOPE_HEIGHT = 140` — scope canvas size
- `timerInterval = 0.01` (seconds) — dt used by `updateLFO` (note: timer actually ticks at 10 ms, so the value matches)
- `timer.setPeriod(10)` — tick period in ms
- `percentageToRate` internals: `minOutput = 0.1`, `maxOutput = 10`, `exponent = 3` — Hz range of the Rate fader
- Draw colours are inline: outline `0xFFFF`, midline `0x7BEF`, trace `0xFFFF`, background `0x0000`

## Notes

- Only the **triangle** LFO is exported through the pipe and drawn on the scope — sawtooth/square/sine are computed but unused. Pick a different `getLFO*()` call inside `timer.onTick` to switch.
- The `pipe.acquire("output")` name is hard-coded; if you plan to run multiple instances, rename per widget or pipes will collide.
- Formatter helpers `getFrequency`, `getPulseWidth` are available for assigning to display formatters on the Rate / PW faders if you want live "x.xx Hz" readouts.
