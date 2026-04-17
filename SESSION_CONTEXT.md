# Session Context — electraone-widgets

> **For: next Claude Code session** — read this first before doing anything. It captures the state of the project, the plan, the workflow, and everything non-obvious that would take hours to rediscover from git history.

---

## 1. One-line pitch

A public library of custom Lua widgets for the **Electra One MK2** MIDI controller (1016×560 LCD, Lua 5.3 runtime, RGB565 colour). Two parallel tracks:

- **Open-source library** — widgets + a browser emulator + a gallery landing page so the community can use / contribute.
- **Business strategy** — use the library as a calling card to pitch Martin Pavlas (Electra One founder) for an **MK3 partnership** (3 tiers: A co-dev, B nude MK2 units, C wholesale resale).

---

## 2. Critical note — cwd vs repo

**The actual repo lives at `/mnt/d/Claude/electraone-widgets/`.** Earlier sessions started Claude Code from `/mnt/d/Claude/ElectraOneMK2/` (a stale folder), so the memory got attached to the wrong project path. On **2026-04-17** we migrated the memory to the correct path. Always open the new session with `cd /mnt/d/Claude/electraone-widgets && claude` so memory resolves cleanly.

Memory index: `/home/romi/.claude/projects/-mnt-d-Claude-electraone-widgets/memory/MEMORY.md`.

---

## 3. Remote + hosting

- **GitHub repo**: https://github.com/roomi-fields/electraone-widgets (public)
- **Gallery**: https://roomi-fields.github.io/electraone-widgets/ (GitHub Pages, served from `/docs`)
- **Emulator**: https://roomi-fields.github.io/electraone-widgets/emulator/ (appended `?w=<slug>` loads a widget)
- **CI**: `.github/workflows/pages.yml` — on push to `main` runs `node scripts/build-index.js` then publishes `docs/` as Pages. ~30-60s to propagate.

---

## 4. Repo structure

```
electraone-widgets/
├── lib/
│   ├── theme.lua                 # v0.3 palette: cool slate + warm terracotta
│   └── primitives/               # 9 reusable drawing primitives
│       ├── knob.lua
│       ├── bar.lua
│       ├── led.lua
│       ├── meter.lua             # has `inverted` option + colour zones
│       ├── slider.lua
│       ├── readout.lua
│       ├── graph.lua             # contour in ACCENT_DIM, markers option
│       ├── grid.lua              # disabledRows + column-based active-step
│       └── button.lua            # SSL-tile console: toggle + momentary
├── widgets/
│   ├── _template/                # boilerplate for new widgets
│   ├── <slug>/
│   │   ├── widget.lua            # the Lua code pasted into the preset
│   │   ├── demo.preset.json      # minimum preset importable into app.electra.one
│   │   ├── README.md             # H1 = name, first prose line = gallery blurb
│   │   └── preview.png           # 1012×561 screenshot (auto-gen via scripts/screenshot.mjs)
│   └── ...                       # 20 widgets total as of 2026-04-17
├── docs/                          # → GitHub Pages root
│   ├── index.html                 # gallery landing (JS reads widgets.json)
│   ├── style.css
│   ├── widgets.json               # auto-generated index {slug, name, description, previewExt, family}
│   ├── emulator/
│   │   ├── index.html
│   │   └── emulator.js            # Fengari UMD runtime + RGB565 + SVG canvas
│   ├── previews/                  # auto-copied from widgets/*/preview.png (.gitignored)
│   ├── lib/                       # symlink → ../lib (.gitignored, local-dev only)
│   └── widgets/                   # symlink → ../widgets (.gitignored, local-dev only)
├── scripts/
│   ├── build-index.js             # regenerate docs/widgets.json + copy previews
│   └── screenshot.mjs             # Playwright → render a widget → save preview.png
├── PLAN.md                        # the original 4-phase roadmap
├── CONTRIBUTING.md                # Phase 4 item — may need to expand
└── SESSION_CONTEXT.md             # ← this file
```

---

## 5. Phases — status

| Phase | What | Status |
|---|---|---|
| **1 — Design system** | Theme v0.3 palette (cool slate + warm terracotta), validated | ✅ done |
| **2 — Primitives library** | 9 primitives (knob / bar / led / meter / slider / readout / graph / grid / button) | ✅ done |
| **3 — Composed widgets** | 7/7 widgets shipped: modern-adsr, comp-meter, eq-3band, spatial-pan, step-seq-16, arp-viz, tape-meter | ✅ done (2026-04-17) |
| **4 — Launch + MK3 pitch** | Community launch + Martin Pavlas outreach | 🟡 in progress — see §9 |

---

## 6. Theme v0.3 (the palette)

Defined in `lib/theme.lua`. RGB565-safe (mid-saturation). Never use Theme.TEXT (cool off-white) on top of a warm ACCENT fill — that's the "blanc caca" violation. Use ACCENT_DIM (darker copper) instead.

```
CANVAS    #0A0D11   page base
SURFACE   #14181E   card / tile
ELEVATED  #232830   raised / active
BORDER    #3A4048   hairline
TEXT_DIM  #9098A3   secondary text
TEXT      #E8EBF0   primary text

ACCENT         #E5823E   hero terracotta — active / modulation / signature
ACCENT_DIM     #8F5129   deep copper — inactive / outline on accent fill
WARNING        #F5C64A   vintage VU yellow — peak-hold, warn zone
ALERT          #EB5757   red — over-threshold / critical
POSITIVE       #7EC699   cool sage — in-range / confirmed
INFO           #5B8FD4   steel blue — informational
NEUTRAL_ACCENT #6B7384   cool grey-blue — disabled
```

---

## 7. The 7 Phase-3 widgets

Each follows the same structure: **single full-page custom tile**, `paint` + `touch` + `pot` callbacks, uses `Theme.*` exclusively. All validated by the user on both the browser emulator and (where feasible) a real device.

1. **modern-adsr** — knob × 4 + live envelope graph with filled area + contour + section markers. Replaces the native dx7envelope.
2. **comp-meter** — 3 vertical VU meters (In/GR/Out), GR meter uses `inverted=true`, threshold line, 4 controls. Simulated input at 25 Hz.
3. **eq-3band** — 3 bands × (freq/gain/Q) = 9 knobs + live response curve. **Uses real RBJ biquad coefficients** + analytical `|H(e^jω)|²`. Band-order protection (LOW < MID < HIGH, half-octave margin).
4. **spatial-pan** — circular top-down pan view, equal-power L/R gain law + 1/(1+1.2d) distance roll-off, drag the source inside the circle.
5. **step-seq-16** — 32 steps (2 × 16 lanes), white playhead that only traces LIVE rows, 3 SSL-tile console buttons (RUN toggle / LINE 2 toggle / RESET momentary). First production use of `Theme.button`.
6. **arp-viz** — scrolling piano-roll of an internal arp (Cm7 chord × 1-4 octaves × UP/DOWN/UP-DN/RAND patterns). Notes fade from ACCENT to ACCENT_DIM as they age.
7. **tape-meter** — LUFS + True-Peak mastering meter with peak-hold, 3 mode presets (STREAMING −14 / BROADCAST −23 / LIVE −16), warm-up loop so LRA reads realistic on first frame.

---

## 8. Workflow — **local-first** mandatory

The user has been burned by "push-then-check" cycles. **Always preview locally first, only push after user validates.**

### Interactive browsing

```bash
# Python server (run once in background, from docs/ dir)
cd docs && python3 -m http.server 8765
```

- `docs/lib` and `docs/widgets` are **symlinks** to `../lib` and `../widgets` (gitignored).
- `docs/emulator/emulator.js` detects `location.hostname === "localhost"` and sets `RAW_BASE = ".."` so fetches hit the server root + the symlinks.
- URL: http://localhost:8765/emulator/?w=<slug>
- **Hard-refresh required** after editing `emulator.js` — browser caches JS aggressively.

### Screenshot automation

```bash
node scripts/screenshot.mjs <slug> --wait=2500
```

- Launches headless Playwright, loads the widget, waits `--wait` ms for any timer-driven animation to settle, screenshots `#stage`, saves to `widgets/<slug>/preview.png`.
- By default intercepts `raw.githubusercontent.com/roomi-fields/electraone-widgets/main/**` and serves local files via `route.fulfill` — so un-pushed edits render correctly.
- Pass `--remote` to force real-GitHub-raw fetches (parity check before shipping).
- **Browser cache killer**: `cdp.send("Network.setCacheDisabled", ...)` — essential because GitHub raw sends `cache-control: max-age=300` and plain request headers don't bypass the disk cache.

### Commit flow

1. Edit code locally
2. `node scripts/screenshot.mjs <slug>` — show user
3. User validates verbally ("ok je valide", "c'est parfait", etc.)
4. `node scripts/build-index.js` if widget metadata / previews changed
5. `git add <specific files>` + commit with message focused on **why**, not **what**
6. `git push` — CI rebuilds Pages in ~30-60s

---

## 9. Phase 4 — what's left (strategic, not yet started)

### Community launch
- **CONTRIBUTING.md** — write a proper guide (current one is thin). Widget template, naming, README template, PR expectations.
- **Gallery polish** — split `widgets.json` into `family: "design-system" | "community"` and render two sections on `docs/index.html` (Design System at top, Community ports below). I started this in session 2026-04-17 but reverted — the build-index.js part is ready to re-apply.
- **Forum post on electra.one** — announce the library. Martin Pavlas frequents the forum.

### MK3 partnership pitch (the big strategic play)
Context: see memory `project_martin_outreach.md` and `project_mk3_partnership.md`.

Three tiers to propose:
- **Tier A — co-dev of MK3** with the widgets as the reference UI layer. Dream scenario.
- **Tier B — nude MK2** (no packaging, at wholesale) to pre-load widgets on and sell as an integrated product ("ElectraOne × SpatBox" or similar branding).
- **Tier C — pure wholesale pricing** for resale/kitting.

Silent plan D: retail-buy MK2 stock and ship anyway if no partnership materialises.

### Timing
- Phase 3 just shipped — the library is now "pitchable" (showable catalogue + emulator + gallery).
- Before writing to Martin, polish Phase 4 launch items first. A thin CONTRIBUTING.md makes the repo look half-finished.

---

## 10. Tools & gotchas (the non-obvious stuff)

### Emulator architecture (`docs/emulator/emulator.js`)
- **Fengari UMD** runs Lua 5.3 in the browser.
- Widgets' `graphics.*` calls are bridged to HTML5 Canvas.
- **RGB565 bug was the great silent killer** — early versions treated 16-bit device colours as 24-bit RGB. Fixed by `hexColor()` doing proper 5-6-5 → 8-8-8 bit expansion with high-bit fold-back. This was validated ("ah mon dieu!!! je valide!!") after the user realised every widget had wrong colours the whole time.
- **Proxy pattern** via `__luaProxyByObj` WeakMap + `__jsObjByProxyId` Map + `__jsProxyId` raw tag, so Lua-held references to JS objects stay identity-stable across calls.
- **Native tiles synthesis**: when a preset has no `preview.svg`, `synthesizeNativeTiles()` builds bounds from the slot grid (`x = 20 + col·167`, `y = 28 + row·90`).
- **Per-value callbacks** fire even without `parameterMap.onChange`.
- **Pot events** are synthesised from fader drags when no `fnName` is set.

### Firebase / app.electra.one
- API key extracted from the app.electra.one Nuxt bundle — see `reference_firebase.md`.
- Presets live in Firestore `projects` collection.
- User credentials: `electraone@liance.art` / password stored in an earlier conversation memory — check memory before attempting login.

### Firmware
- The MK2 firmware is a closed SREC STM32 binary downloadable from docs.electra.one — see `reference_firmware.md`. We can't emulate native tiles beyond their documented API. Use custom tiles everywhere in our widgets.

### Playwright + GitHub raw cache
- Fastly edge caches raw.githubusercontent with `max-age=300`. Plain `cache-control: no-cache` request headers don't bypass the **browser** disk cache. **Use `Network.setCacheDisabled` via CDP** — already wired into screenshot.mjs. Stale screenshots despite fresh pushes = this was the cause.

### The "blanc caca" rule
Never place cool `Theme.TEXT` (#E8EBF0) on a warm `ACCENT` fill — the temperature clash reads as dingy beige. Use `ACCENT_DIM` (same warm family, darker) for outlines / contours on ACCENT fills. Applies throughout.

---

## 11. Conventions the user has made explicit

Each is backed by a specific incident and a memory file:

- **No rounded corners** — match real MK2 hardware flatness (`feedback_visual.md`).
- **Horizontal drag for sliders/faders** where applicable.
- **No mock values in tests** — hit real data, validated after an early incident (`feedback_workflow.md`).
- **Finish the emulator before adding features** — address the tool before the demos.
- **Generic fixes, not widget-specific hacks** — if a bug surfaces in one widget, fix the primitive.
- **Local-first preview** (see §8).
- **French conversation** by default. Code/logs stay English.
- **Terse responses** — output under 100 words unless the task demands more.
- **Be explicit about completion** — run tests, show output, don't claim success without evidence.

---

## 12. Quick-start checklist for next session

```bash
cd /mnt/d/Claude/electraone-widgets
# confirm memory resolves to the right path
ls ~/.claude/projects/-mnt-d-Claude-electraone-widgets/memory/

# start the local python server (in a long-lived terminal)
(cd docs && python3 -m http.server 8765 &)

# verify gallery
open http://localhost:8765/           # or whatever your OS command is
open http://localhost:8765/emulator/?w=tape-meter
```

First thing to ask the user: **"Phase 4 polish d'abord (CONTRIBUTING + gallery sections) ou directement le mail à Martin ?"** — this is where we left off. Phase 3 shipped, 585f437 is the last commit.

---

*Last updated: 2026-04-17 by Claude Opus 4.7 (1M context). Total of ~15 memory files under `~/.claude/projects/-mnt-d-Claude-electraone-widgets/memory/` cover the granular details (emulator quirks, visual feedback, workflow rules, strategic plans).*
