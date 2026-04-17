# Contributing

Thanks for adding to the library. This guide covers everything you need to ship a widget the rest of the community can drop into a preset.

## Two tracks

The library has two parallel tracks, with slightly different bars for entry. Pick the one that fits your widget.

### 1. Community ports

A widget you wrote (or rescued from the forum) that doesn't depend on `lib/`. Self-contained `widget.lua`, free style. The bar is *it works on real hardware and the source / author is credited*.

Use this track if:
- You're porting an existing forum widget (with permission / clear attribution).
- You have a working widget but don't want to rewrite it against the design-system primitives.
- The widget intentionally uses its own visual language.

### 2. Design system widgets

A widget built on `lib/theme.lua` + `lib/primitives/`. Shared palette (RGB565-safe), reusable building blocks, MK2-native 1016×560 layout.

Use this track if:
- You want your widget to feel coherent with the rest of the design-system catalogue.
- Your widget needs a knob, fader, meter, graph, grid, LED, button, readout, slider, or bar — they're already in `lib/primitives/`.

You can start as a community port and graduate to the design system later by swapping primitives in.

---

## Folder layout

One widget = one folder under `widgets/<slug>/`. Required files:

```
widgets/<your-widget>/
├── widget.lua           # the Lua code, self-contained
├── demo.preset.json     # minimal preset that loads + runs the widget
├── README.md            # H1 = display name, first prose line = gallery blurb
└── preview.png          # 1012×561 (auto-generated, see below)
```

Copy `widgets/_template/` as a starting point and rename.

---

## Local-first dev workflow

The repo is set up so you can preview your widget instantly without pushing to GitHub. **Always validate locally before opening a PR.**

### One-time setup

The `docs/` directory has symlinks `docs/lib → ../lib` and `docs/widgets → ../widgets` so a static server rooted at `docs/` can reach the library and widget sources. They're gitignored — recreate if missing:

```bash
cd docs
ln -s ../lib lib
ln -s ../widgets widgets
```

### Browse interactively

```bash
cd docs && python3 -m http.server 8765
# then open http://localhost:8765/emulator/?w=<your-slug>
```

`docs/emulator/emulator.js` detects `localhost` / `127.0.0.1` and switches its asset base to `..` — so it loads your **uncommitted** working copy, not GitHub. Hard-refresh (Ctrl+Shift+R) after editing `emulator.js` itself; widget edits pick up on a normal refresh.

### Capture a preview screenshot

```bash
node scripts/screenshot.mjs <your-slug> --wait=2500
```

This launches headless Playwright, loads the widget through the emulator, waits `--wait` ms for any animation to settle, and writes `widgets/<slug>/preview.png` at native MK2 resolution. Pass `--remote` to fetch from real GitHub raw instead (parity check before shipping).

### Regenerate the gallery index

After adding/updating a widget:

```bash
node scripts/build-index.js
```

This rescans `widgets/`, copies previews into `docs/previews/`, and emits `docs/widgets.json`. CI runs the same script on push to `main`.

### Bundle a preset for direct device upload (design-system widgets)

Design-system widgets depend on `lib/theme.lua` + `lib/primitives/*`, which aren't loaded automatically by `app.electra.one` or by the device firmware. To produce a preset that runs out of the box when uploaded, run:

```bash
node scripts/bundle-preset.js <slug>   # one widget
node scripts/bundle-preset.js --all    # every design-system widget
```

The script concatenates `theme.lua` + all primitives + `widget.lua` and writes the result into the preset's `lua` field. Re-run after editing any of the sources. CI fails a PR if a design-system widget's `demo.preset.json` ships with an empty `lua` field.

---

## The design-system track in detail

### Theme

`lib/theme.lua` exposes a 13-colour palette and small drawing helpers. Use `Theme.*` for every colour — never raw hex. The palette is RGB565-safe (mid-saturation), so what you see in the emulator matches the device.

Key rule: **never use cool `Theme.TEXT` (#E8EBF0) on top of warm `Theme.ACCENT` (#E5823E).** The temperature clash reads as dingy beige. Use `Theme.ACCENT_DIM` (same warm family, darker) for outlines / contours on accent fills.

### Primitives

`lib/primitives/` has 9 building blocks. Each is a single file with a `draw(...)` function and a doc comment. Currently:

| Primitive | What it draws |
|---|---|
| `knob` | rotary with value arc + label |
| `bar` | horizontal level bar |
| `slider` | vertical fader with cap + scale |
| `meter` | VU/peak meter (supports `inverted`, colour zones, peak-hold) |
| `led` | on/off indicator with optional glow |
| `button` | SSL-tile console button (toggle or momentary) |
| `readout` | label + value + unit, typography-driven |
| `graph` | filled area + contour curve, with section markers |
| `grid` | N×M cell grid with active/disabled rows |

Use them rather than reaching for `graphics.*` directly. If your widget needs something the catalogue doesn't have, add the primitive in the same PR — but only if a real widget needs it (no speculative primitives).

### Drawing API

Inside `paint(control, g)` your widget gets the `g` graphics object. Coordinates are in device pixels (1016×560). Lua arrays are 1-indexed. The emulator pre-loads `lib/theme.lua` and `lib/primitives/` automatically — `require("lib.theme")` works in both the emulator and the device.

### Wiring `PT_VIRTUAL` parameters to real MIDI

Design-system widgets write their state to `PT_VIRTUAL` parameters — internal to the preset, not sent on the MIDI port by themselves. Two ways to get real CC/NRPN out:

**1. Map the virtuals to a real message in the preset editor.** In `app.electra.one`, add an entry in the preset's `parameterMap` that binds each virtual (e.g. `param 1`) to an outgoing message (e.g. `CC 74 on channel 1, device 1`). The widget's writes then flow through the map and emit real MIDI.

**2. Or edit `parameterMap.set` calls in `widget.lua`** to write a real message type directly:

```lua
-- before (virtual)
parameterMap.set(1, PT_VIRTUAL, PARAM_A, math.floor(v * 127))
-- after (CC 74)
parameterMap.set(1, PT_CC7, 74, math.floor(v * 127))
```

In both calls, `deviceId = 1` refers to the first entry of the preset's `devices[]` array — change it if your preset routes through another device. Available message types: `PT_CC7`, `PT_CC14`, `PT_NRPN`, `PT_PROGRAM`, `PT_SYSEX`, `PT_VIRTUAL`.

---

## Widget README template

The `README.md` H1 becomes the display name in the gallery. The first prose line becomes the blurb. Keep both short.

```markdown
# Display name

One-line blurb that shows on the gallery card.

## What it does

2-3 sentences.

## Integration

How to drop it into a preset (paste widget.lua into the script editor, attach to a host control, etc.).

## Parameters

| Name | Type | Default | Description |
|------|------|---------|-------------|

## MIDI mapping

What CCs / NRPNs it sends or reacts to.

## Tested on

- [ ] Electra One MK2
- [ ] Electra One Mini
- [ ] Browser emulator
```

---

## Naming conventions

- **Folder slug**: `kebab-case` (e.g. `step-seq-16`, `tape-meter`)
- **Lua tables**: `PascalCase` (`StepSeq`, `TapeMeter`)
- **Lua functions / methods**: `camelCase`
- **No `_` prefix** on shipped folders — `widgets/_template/` is excluded from the gallery on purpose

---

## PR checklist

- [ ] Folder under `widgets/<slug>/` with all 4 required files
- [ ] Tested in the browser emulator (URL in the PR description)
- [ ] Tested on real hardware where possible (note which model)
- [ ] `node scripts/build-index.js` ran cleanly and `docs/widgets.json` is updated
- [ ] `preview.png` is up to date
- [ ] Original author credited if this is a community port

In the PR body include: widget name, one-line description, screenshot, test environment, and any related forum thread.

---

## License

By opening a PR you agree your contribution is MIT-licensed. If your widget is a port of someone else's work, get their consent (a forum post acknowledgement is fine) and credit them in the README.
