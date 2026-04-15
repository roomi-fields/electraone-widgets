# EG Template — 7-variant Envelope Generator

> **Credits** · Original author: **NewIgnis** (Ignace Vanbiervliet) — 2026
> **Source**: https://app.electra.one/preset/HbynnPgMY6ei48yqOlrw
> **Forum context**: [Custom control for envelopes anyone?](https://forum.electra.one/t/custom-control-for-envelopes-anyone/4169)
> **Revision**: 56 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under the opt-out policy in [NOTICE.md](../../NOTICE.md).

## What it does

A versatile envelope generator preset built on the MK2's native 4-stage envelope tile (`dx7envelope`), re-rendered dynamically by Lua to present **7 different envelope types** from a single control:

1. **AD** — Attack + Decay
2. **AR** — Attack + Release
3. **ADS** — Attack + Decay + Sustain
4. **ADSR**
5. **AHDSR** — + Hold
6. **DADSR** — + Delay
7. **ADBSSR** — Breakpoint / Slope variant
8. **ALDSDSR** — Double-sustain (hidden 8th mode in the slot table)

Author's note: *"the visualisations use different parameters than the real controls."* — the display is a re-mapping layer on top of the underlying 7 faders.

## Preview

![preview](preview.svg)

## Requirements

- Electra One MK2 (`targetDevice: "mk2"`)

## Under the hood

- 7 faders on CCs 11–17 (`ctlPar = {11,12,13,14,15,16,17}`) — the real MIDI output
- A `list` tile to pick the EG type, which triggers `setEG()` to reshape labels and hidden slots
- The `slots` / `names` tables encode each variant's layout

## Integration

Load `demo.preset.json` in the Electra One editor or the [beta sandbox](https://beta.electra.one/sandbox/). Switch the **EG Type** list to see the same envelope tile re-label itself.

## Tested on

- Electra One MK2 (per preset metadata)
