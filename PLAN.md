# Plan — Modern widget library for Electra One MK2

Roadmap for building an original, visually-modern widget library that users can drop into their own presets. Builds on the completed emulator (`docs/emulator/`) and the 11 imported reference widgets in `widgets/`.

---

## Phase 1 — Design system foundation

**Output**: `lib/theme.lua` + palette showcase in the emulator.

### Goals
- Fix the visual language before drawing anything.
- Avoid re-choosing colours and spacing for every widget.

### Deliverables
- `lib/theme.lua` — helpers: `Theme.rgb(r,g,b)`, `Theme.hex(rgb565)`, `Theme.rect(x,y,w,h,color)`, `Theme.text(x,y,str,color,size)`, `Theme.shadow(x,y,w,h)`.
- Palette (~12 colours, RGB565 native):
  - Background: `#0E0E11` (near-black) and `#1A1A22` (card surface).
  - Accents: teal `#00C7B7`, coral `#FF5E5B`, amber `#FFB400`, violet `#8B5CF6`, lime `#A3E635`.
  - Neutrals: grey-3 `#3A3A44`, grey-5 `#7A7A88`, white-ish `#E6E6E6`.
- Typography conventions:
  - Caps 10-12px for labels.
  - Regular 16-20px for values.
  - No gradients (LCD renders them poorly); flat fills + 2px strokes.
- `widgets/_theme-gallery/` — non-shipping preview widget that paints every palette entry + a sample of every typographic style. Used for QA.

### Effort estimate
1-2 days.

---

## Phase 2 — Primitives

**Output**: `lib/primitives/*.lua`, each a drop-in function + gallery page in the emulator.

### Scope: 8 primitives

**Tier 1 — must-have**

| Primitive | Signature | Notes |
|---|---|---|
| Knob | `Theme.knob(x, y, size, value01, label, color)` | Rotary, thin ring gauge, value centered. |
| Bar | `Theme.bar(x, y, w, h, value01, color)` | Horizontal fader bar with min/max labels. |
| Meter | `Theme.meter(x, y, w, h, value01, peak01)` | VU-style, peak-hold, colour zones (green/amber/red). |
| Arc | `Theme.arc(x, y, size, value01, color)` | Half-circle gauge, 270° sweep. |
| LED | `Theme.led(x, y, size, on, color)` | On/off with optional glow halo. |
| Readout | `Theme.readout(x, y, label, value, unit)` | Label + value + unit, typography-driven. |

**Tier 2 — partial**

| Primitive | Signature | Notes |
|---|---|---|
| Graph | `Theme.graph(x, y, w, h, points, color)` | Polyline through normalised points — needed for ADSR, EQ, scope. |
| Grid | `Theme.grid(x, y, cols, rows, cells, active_idx)` | N×M cells with per-cell state — needed for step-sequencer and drum-matrix widgets. |

### Deliverables
- Each primitive = one `.lua` file with the function + tiny API doc comment block.
- Gallery: one widget per primitive (`widgets/_gallery-knob/`, …) showing 3-4 instances at different sizes/colours/values. Runs in the emulator; screenshot via `scripts/screenshot.mjs`.
- `lib/README.md` — index with embedded preview thumbnails + snippet of usage per primitive.

### Out of scope for now
Ring LED, range slider, waveform/scope, tab bar, sparkline, pattern cell, matrix cell. Add later if a composed widget in Phase 3 needs them.

### Effort estimate
3-5 days.

---

## Phase 3 — Composed widgets

**Output**: 5-7 complete widgets, each in `widgets/<name>/`, using Phase 2 primitives.

### Proposed catalogue

| # | Name | Primitives used | What it does |
|---|------|----------------|--------------|
| 1 | modern-adsr | Knob × 4, Graph | 4 knobs (A/D/S/R) + live envelope curve above them. Replaces the native `dx7envelope` with a flat/modern look. |
| 2 | comp-meter | Meter × 3 | Input / gain reduction / output columns + threshold line. Reads 3 CCs from your DAW. |
| 3 | eq-3band | Knob × 9, Graph | 3 bands × (freq, gain, Q) knobs + live EQ response curve. |
| 4 | spatial-pan | Arc, Readout | Azimuth (0-360°) + distance (0-100%). Ambisonic-style circular viz. |
| 5 | step-seq-16 | Grid, LED, Readout | 16-step velocity grid + current-step highlight + BPM readout. |
| 6 | arp-viz | Graph, LED | Timeline of recent notes; scrolls left with time. Read-only viz. |
| 7 | tape-meter | Meter × 2, Readout | LUFS / true-peak meters with peak-hold. |

### Per-widget deliverables
- `widget.lua` using only Theme + primitives (no raw `graphics.drawLine` etc.).
- `demo.preset.json` with the minimum set of tiles required.
- `README.md` following the standardized template (see `widgets/cube-lfo/README.md`).
- `preview.png` captured via `scripts/screenshot.mjs`.
- Emulator-validated + (where feasible) device-validated via the Firestore push workflow.

### Primitive extension policy
If a composed widget needs a primitive not in Phase 2, add it to `lib/primitives/` as part of that widget's PR. No speculative primitives.

### Effort estimate
5-10 days.

---

## Phase 4 — Community launch

**Output**: widgets reach users; first conversation with Electra One staff.

### Deliverables
- Polish `docs/` gallery:
  - Live emulator previews (iframe or inline) for each widget.
  - One-click "Copy Lua" button per widget.
- Forum post on https://forum.electra.one/ — title suggestion: *"[Release] Modern widget library — sexy alternatives to the native tiles"*.
- Social seed: Twitter/X + Discord thread with an animated gif of 3-4 widgets in motion.
- Outreach: DM / email Martin Pavlas + Thomas Moravansky with the live demo and a soft opener on partnership intent.
- If Electra accepts, PR to their docs/awesome list when appropriate.

### Effort estimate
2-3 days.

---

## Success criteria

- v1 ships with **8 primitives + 5-7 composed widgets**.
- Every widget has a preview.png captured from the emulator at a non-trivial frame.
- READMEs let a developer copy-paste a widget into their own preset in under 10 minutes.
- A forum post + Discord seed generate at least one third-party contribution within 4 weeks.
- First dialogue with Electra One staff opens about Phase-next possibilities (co-branded MK3, distributor pricing, etc.).

## Anti-goals

- **No speculative primitives.** If a widget doesn't need it, it's out.
- **No hardware design in this phase.** Software-only.
- **No app store tooling.** Geeks copy-paste from GitHub — that's the UX for v1.
- **No animation library.** Widgets re-paint at 50 Hz, that's the animation.

## Open questions

- Do we keep the imported reference widgets (`cube-lfo`, `xt-envelopes`, etc.) in `widgets/` alongside our originals, or segment them into `widgets/references/`? Recommendation: keep flat for discoverability; add a badge in each README (`> ⭐ Original` vs `> 📦 Imported`).
- Do we version `lib/theme.lua`? If yes, pin each widget to a theme version at the top (`-- theme v0.1.0`). Otherwise breaking changes in theme break every widget silently.
