# 16-Step Note List

> **Credits** · Original · electraone-widgets design system · License: MIT

## What it does

A reusable 16-step custom control inspired by the Waldorf Q-style arpeggiator / step-list editor. **One instance = one single tile** (target: 5-6 slots wide × 1 deep). The cells display values directly — note names, raw 0..127 or %, no fader bars — grouped every 4 by a thin BORDER tick. Two dedicated encoders per instance: one for **step selection**, one for **value editing**. A **common RANGE** (virtual parameter 33) is shared between instances and darkens out-of-range cells without losing their stored values.

The widget is implemented as a **factory** (`makeNoteList(control, opts)`), so a single preset can host up to 6 instances on one MK2 screen, using all 12 encoders (2 per widget) for 96 simultaneously-editable parameters.

The demo instantiates two lanes (NOTES + VELOCITY) sharing the same RANGE.

Forum thread that motivated this widget: [Looking for a 16-step custom control for arp and seq](https://forum.electra.one/t/looking-for-a-16-step-custom-control-for-arp-and-seq/4425)

## Required tiles

| Ref | Name | Type | Slot | Size | Notes |
|---|---|---|---|---|---|
| 1 | NOTES | custom | 1 (row 1) | 6×1 | First lane, ENC 1+2 |
| 2 | VELOCITY | custom | 7 (row 2) | 6×1 | Second lane, ENC 3+4 |

To add more lanes, drop more custom tiles in your preset (slot 13 = row 3, etc.) and call `makeNoteList(controls.get(N), { ... })` for each, picking distinct `paramBase` + `encSelect` + `encEdit` values.

## How a single instance maps to the spec

| Forum spec line | This widget |
|---|---|
| "5-6 slots wide, 1 slot deep" | Each instance is a single 6×1 tile (~1008 × 110 px) |
| "16 parameters displayed in a single row, grouped every 4 with vertical dividers" | 16 cells horizontal, 12-px gap every 4 with a 2-px BORDER tick centred |
| "Shows only bitmaps or values (no faders)" | Each cell shows its value as text — note name / raw / %, no bar |
| "Custom control name and encoder assignments" | Header strip displays `<NAME>  ENC <s>+<e>` on the left |
| "Two dedicated encoders per control: selection + value" | `encSelect` opts field navigates 1..16, `encEdit` opts field edits 0..127 |
| "Range control: one common parameter sets max range (0-16), parameters exceeding the range are hidden or darkened" | Virtual param 33 → `commonRange.value`; out-of-range cells render with CANVAS background + dim dash |
| "All 16 parameters treated as virtual parameters" | Lane writes to params `paramBase + 1` .. `paramBase + 16` |
| "Remote control via sysex and MIDI CC callbacks" | Standard `parameterMap.set(...)` route; external CC/SysEx that targets virtual params is reflected via `parameterMap.onChange` |
| "Up to 6 controls per screen, 96 parameters per screen" | Each instance owns 16 of the 49 virtual params; 6 × 16 = 96 |
| "Common parameters shareable among multiple (not all) controls" | `commonRange` is a module-level table — multiple `makeNoteList` instances share it. Custom range tables can be passed per-instance if some widgets should not follow the common range. |

## Interaction

| Input | Effect |
|---|---|
| **Pot `encSelect`** | Navigate the selected step within this widget (1..16, one detent = one step) |
| **Pot `encEdit`** | Edit the selected step's value (0..127, accumulates with detent delta) |
| **Tap a cell** | Select that step (alternative to the encoder) |
| **Drag a cell vertically** | Edit the value 0..127 in-place (touchscreen) |
| External knob bound to virtual 33 | Drives the common RANGE; all instances re-render together |

## Virtual parameters

Each instance writes to **16 consecutive virtual params** starting at `paramBase + 1`. The demo uses:

| Range | Owner |
|---|---|
| 1..16 | NOTES lane (paramBase = 0) |
| 17..32 | VELOCITY lane (paramBase = 16) |
| 33 | Common RANGE (consumed by all instances; not owned by a lane) |

If you add a third instance for GATE, use `paramBase = 32` and the next free encoders (`encSelect = 5, encEdit = 6`). For six instances, paramBase = 0, 16, 32, 48, 64, 80 — 96 params total, leaving param 33 free as commonly bound.

> ⚠️ The demo's NOTES + VELOCITY both start at base 0 and 16 respectively. If you also want a per-lane range parameter (e.g. so NOTES can be 8 steps while VELOCITY runs 16), pass a separate `rangeRef` table per instance via the factory's options — for the demo we kept the simpler shared singleton.

## Lua code

Paste `lib/theme.lua` at the top of your preset's Lua tab (no primitives required), then [widget.lua](widget.lua). The emulator handles this transparently. The bundled `demo.preset.json` ships the complete code in its `lua` field, ready to upload via app.electra.one.

## Optional customisation

The factory accepts per-instance options:

| Opt | Default | What it does |
|---|---|---|
| `name` | `"STEPS"` | Header label, drawn on the left |
| `color` | `Theme.ACCENT` | Active-cell colour |
| `kind` | `"note"` | `"note"` (MIDI note name), `"num"` (0..127), `"pct"` (0..100%) |
| `cells` | C major scale × 2 | Initial 16-element array of 0..127 values |
| `paramBase` | `0` | Virtual params owned: `paramBase + 1` .. `paramBase + 16` |
| `encSelect` | `1` | Pot id for step navigation |
| `encEdit` | `2` | Pot id for value editing |

Tile geometry (height, padding, divider thickness) is controlled by the in-file constants `GROUP_GAP_EXTRA` and the bounds passed to `setBounds`.
