# EG Template — 7-variant Envelope Generator

> **Credits** · Original author: **NewIgnis** (Ignace Vanbiervliet) — 2026
> **Source**: https://app.electra.one/preset/HbynnPgMY6ei48yqOlrw
> **Forum context**: [Custom control for envelopes anyone?](https://forum.electra.one/t/custom-control-for-envelopes-anyone/4169)
> **Revision**: 56 · **Imported**: 2026-04-15
> **License at source**: none specified — imported with attribution under the opt-out policy in [NOTICE.md](../../NOTICE.md).

## What it does

A versatile envelope generator built on the MK2's native 4-stage envelope tile (`dx7envelope`), re-rendered dynamically by Lua to present **7 selectable envelope types** from a single control: AD, AR, ADS, ADSR, AHDSR, DADSR, ADBSSR (plus an 8th hidden ALDSDSR variant in the slot table). Seven faders on CCs 11–17 provide the real MIDI output; the list tile triggers `setEG()` which reshapes labels and visibility of the layout on the fly.

## Required tiles

| Ref | Name | Type | Mode | Range | paramNum | Function | Notes |
|-----|------|------|------|-------|----------|----------|-------|
| 5 | EG | dx7envelope | - | 0-127 | 1001-1008 (virtual) | - | Native 4-stage envelope tile; 8 values (r1/l1…r4/l4) drive the visual |
| 11 | EG Type | list | - | - | 9 (CC7) | setEG | EG-variant selector (8 entries) |
| 1 | R1 | fader | - | 0-127 | 11 (CC7) | convRate | Rate 1 |
| 2 | L1 | fader | - | 0-127 | 12 (CC7) | convLevel | Level 1 |
| 12 | R2 | fader | - | 0-127 | 13 (CC7) | convRate | Rate 2 |
| 13 | L2 | fader | - | 0-127 | 14 (CC7) | convLevel | Level 2 |
| 8 | R3 | fader | - | 0-127 | 15 (CC7) | convRate | Rate 3 |
| 4 | L3 | fader | - | 0-127 | 16 (CC7) | convLevel | Level 3 |
| 6 | R4 | fader | - | 0-127 | 17 (CC7) | convRate | Rate 4 (also doubles as Release in ADS) |

The `ctls = {1,2,12,13,8,4,6}` table inside the Lua expects these exact control IDs — match them when pasting into an existing preset.

## Virtual parameters used

- `1001..1008` — the envelope-tile stages (`r1`, `l1`, `r2`, `l2`, `r3`, `l3`, `r4`, `l4`). `setEG()` writes these via `parameterMap.set(deviceId, PT_VIRTUAL, stagePar[i], …)` to draw the right shape.
- `convRate()` / `convLevel()` read the physical CC7 paramNum and write into `paramNum + 990` in the virtual bank — that's how the visual envelope stays in sync with the real faders.

## Lua code

Paste `widget.lua` into the preset's Lua tab, or copy directly from [widget.lua](widget.lua) in this repo.

## Optional customisation

- `ctls = {1,2,12,13,8,4,6}` — control IDs in R1,L1,R2,L2,R3,L3,R4 order. Change if your preset slots differ.
- `stagePar = {1001,1002,1003,1004,1005,1006,1007}` — virtual parameter bank for the graph stages.
- `ctlPar = {11,12,13,14,15,16,17}` — CC numbers of each fader.
- `slots` / `names` — the 8-row table that encodes layout and labels for each EG variant; edit to add your own custom variant.

## Notes

- Author's note: *"the visualisations use different parameters than the real controls."* The display is a remapping layer on top of the underlying 7 faders — the MIDI output is always CCs 11-17.
- The `dx7envelope` tile is a built-in MK2 envelope widget; it only draws 4 stages natively, so the Lua hides/relabels slots 1–7 depending on the selected EG Type.
- The ADS variant wires release equal to sustain automatically (see `convRate` → paramNum 15 branch).
- Tested on Electra One MK2 per preset metadata.
