# HOWTO — designing, testing, previewing Electra One widgets

This is the playbook we reverse-engineered while building this library. Keep it
updated. Three sections:

1. [Designing a custom-paint widget in Lua](#1-designing-a-custom-paint-widget-in-lua)
2. [Injecting a widget into app.electra.one for live testing on hardware](#2-injecting-a-widget-into-appelectraone-for-live-testing-on-hardware)
3. [Generating a preview (SVG) for the gallery](#3-generating-a-preview-svg-for-the-gallery)

---

## 1. Designing a custom-paint widget in Lua

### The real Electra Lua API (schemaVersion 3 firmware)

The API is documented at https://docs.electra.one/developers/luaext.html but we
pinned down several things the doc was vague on.

**Binding callbacks to a custom tile** — inside `preset.onLoad()`:

```lua
function preset.onLoad()
  local c = controls.get(REF)         -- REF = tile.reference in the preset JSON
  c:setBounds({0, 0, 1016, 560})      -- stretch beyond its slot if needed
  c:setPaintCallback(paintFn)
  c:setTouchCallback(touchFn)
end
```

**Paint callback signature** — `function paintFn(control, value)`:

- `control:getBounds()` returns a **table indexed with the constants `WIDTH` / `HEIGHT`** (*not* an object with `.width`/`.height` fields):

```lua
local b = control:getBounds()
local w = b[WIDTH]
local h = b[HEIGHT]
```

- The drawing coordinate system is **local to the control** (origin at 0,0 of its bounding box).
- Drawing primitives are on the **global `graphics`** module:

```lua
graphics.setColor(0xRRGGBB)
graphics.fillRect(x, y, w, h)
graphics.drawRect(x, y, w, h)
graphics.drawLine(x1, y1, x2, y2)
graphics.fillCircle(cx, cy, r)
graphics.drawCircle(cx, cy, r)
graphics.print(x, y, text, size, LEFT|RIGHT|CENTER)
```

- Colors are `0xRRGGBB` 24-bit integers. **`0x000000` renders as pure black on MK2 hardware**; `0x202020` looks noticeably gray (confirmed by photo comparison).

**Touch callback signature** — `function touchFn(control, event)`:

```lua
if event.type == DOWN or event.type == MOVE then
  -- event.x, event.y are LOCAL to the control's bounding box
  control:repaint()   -- request redraw; paintFn will run on next frame
end
```

Event types are globals: `DOWN`, `MOVE`, `UP` (and LCD-level events like `CLICK`, `LONG_HOLD` on the `onTouch*` globals).

**Sending MIDI from a widget**:

```lua
parameterMap.set(deviceId, PT_VIRTUAL, paramNumber, value)
-- or directly:
midi.sendControlChange(PORT_1, channel, cc, value)
midi.sendSysex(PORT_1, { byte1, byte2, ... })
```

The `parameterMap` indirection lets the preset's MIDI mapping (configured in the
JSON via `message.type = "cc7" | "virtual" | ...`) handle the actual MIDI; your
Lua just updates a virtual parameter number.

### Minimum preset JSON for a custom widget (schemaVersion 3)

**Do NOT try to hand-write a v3 preset from scratch** — we tried, the editor
accepts it silently but shows "Preset is empty" with no error. The schema has
implicit required fields we couldn't fully enumerate.

**Safe pattern**: clone an existing working v3 preset (e.g. EG Template
`HbynnPgMY6ei48yqOlrw`), strip its tiles down to one, and swap its type to
`"custom"`. See the Python snippet in section 2.

### Debug tips

- `print("…")` goes to the Console log in the web editor (if connected to hardware).
- A silent failure in `paintCallback` will result in a tile that draws nothing — check the console for Lua errors after upload.
- A bad `setBounds` value (non-table, missing keys) will silently skip; make sure you pass exactly `{x, y, w, h}`.
- If you see other tiles "peek through" your custom tile, you have orphan tiles in the preset — strip the `tiles` array down to yours only, AND update `layouts[].slots` to reference only that tile.

### Where the official docs live (read these first!)

A complete mirror of `docs.electra.one` lives in `.electra-docs/md/` (79
pages including the Lua crash course) and is indexed by RTFM in this
project. **Before assuming any device behaviour is "undocumented", grep
the mirror.** Lots of "gotchas" we discovered empirically (event types,
controller events, potId 1..12 numbering, etc.) are actually
documented.

Key doc files:
- `.electra-docs/md/developers/luaext.md` — full Lua API (graphics,
  controls, parameterMap, events, MIDI, controller, devices, timer,
  parameters, overlays, midi message types, touch events constants).
- `.electra-docs/md/developers/presetformat.md` — preset JSON structure
  including the `inputs` array (`{potId, valueId}` mappings), all
  control types, overlay format.
- `.electra-docs/md/developers/midiimplementation.md` — SysEx protocol.
- `.electra-docs/md/luacourse/` — MIDI/Lua tutorial chapters.
- `.electra-docs/md/userguide-mk2/` — MK2-specific UI / menu / settings
  doc (bootloader, performance mode, presetmenu, etc.).

Use `rtfm_search "<term>"` to query the mirror.

### Device-side gotchas (firmware 4.1.4, verified 2026-05-25)

**Logger is OFF by default** — `print(...)` and Lua fatal-error stack traces only appear in the web editor's **Lua tab → log window** when the logger is enabled. Toggle it on the log window UI before debugging.

**Integer coordinates only** — `graphics.fillRect / drawRect / drawLine / fillCircle / drawCircle / print` raise `"number has no integer representation"` if any coord is a float (very common after a `/ N` division). Wrap every coord in `math.floor(...)` or pre-floor your geometry helpers. The `Theme.rect / outline / line` helpers in `lib/theme.lua` do this for you.

**`graphics.print` is the only text-drawing function** — no `drawText`. Exact signature:
```lua
graphics.print(x, y, text, width, alignment)
-- alignment = LEFT | CENTER | RIGHT (global constants)
```
Width is the box width used for alignment (use a large value like 9999 for LEFT-aligned natural-width text).

**Colours are 0xRRGGBB 24-bit** — the firmware converts to RGB565 internally (the 4.1.4 release notes specifically fixed this conversion for preset bank colours). Do **not** pre-convert to RGB565 yourself.

**`controller.uptime()`** returns ms since boot. Only time API exposed to Lua. Use it for detecting double-click intervals, timeouts, etc.

### Bundling theme + primitives + widget into one Lua blob

The bundler at `scripts/bundle-preset.js` flattens `lib/theme.lua`, every `lib/primitives/*.lua`, and the widget's `widget.lua` into the preset's `lua` field for device upload.

**Avoid IIFE wrappers** (`Theme = (function() ... end)()`). Tried — the device dropped paint callbacks (tile rendered as default fader). Hypothesis: upvalues captured by closures inside the IIFE were not preserved across paint dispatch. Use flat concatenation:
- `theme.lua` must start with `Theme = Theme or {}` (not `local Theme = {}`), end **without** `return Theme` after stripping (the bundler does this).
- Each `primitives/<name>.lua` must rewrite `local function <name>(...)` → `function Theme.<name>(...)` and strip the trailing `return <name>` (the bundler does this).
- Never cache the `graphics` module in a top-level local (`local g = graphics`). Reference `graphics` directly inside each helper. Caching it crashed paint dispatch on device.

**Callbacks must be global functions, not local closures.** A factory pattern that does `control:setPaintCallback(localFn)` from inside a `makeWidget(opts)` factory will not preserve the closure on the device. Define `paintLane / touchLane / potLane` as top-level globals, and keep per-tile state in global tables keyed by `ctrl:getId()`.

### Multi-tile presets

**`slotId` is 0-indexed on the MK2 6×6 grid.** Top-left = `slotId: 0`; second row left = `slotId: 6`; etc.

**`span: "6"` (string) only enlarges the FIRST tile reliably.** A second `type:"custom"` tile with `span:"6"` is often rendered as a single slot (146×56 instead of full width). Workaround: in `preset.onLoad`, call `c:setBounds({x, y, w, h})` explicitly for every tile that needs span > 1.

**1 physical encoder per custom tile.** The firmware dispatches pot events to a custom tile only for the pot mapped to one of its `values[]`. With one value, one pot. Multi-pot custom controls are a documented feature request, not yet shipped (see forum thread #4172). Plan UX around this constraint:
- Pot turn = single action (e.g., navigate)
- Single click (TOUCH→RELEASE without MOVE) = mode toggle
- Double-click (two clicks ≤ ~400 ms apart, measured via `controller.uptime()`) = secondary action

**Encoder press is NOT distinguishable from touch.** `events.onPotTouch` fires on capacitive touch but cannot tell click vs turn. Forum threads #4116 and #4185 confirm: no `onPotClick` exists. Use the TOUCH→RELEASE-without-MOVE pattern as a proxy.

**Pot event shape**: `{ id = N, type = 1|2|3, delta = number }` where:
- `id`: 0-indexed pot number assigned to the tile (varies per tile position)
- `type = 1`: DOWN (touch starts)
- `type = 2`: MOVE (rotation; `delta` ≠ 0)
- `type = 3`: UP (touch ends)

A click without rotation = DOWN then UP with no MOVE between, and `delta == 0` throughout.

### Custom tile JSON structure (schemaVersion 2 works for custom widgets)

Reference XT envelopes (`GK6wmbgvwM6S3GanpoN7`) — its single custom tile renders Lua correctly on device. Minimal required fields:
```json
{
  "id": "<uuid>",
  "reference": 1,
  "slotId": 0,
  "type": "custom",
  "deviceId": 1,
  "color": "F45C51",
  "name": "MyTile",
  "categoryId": "control",
  "values": [{"id":"v","message":{"type":"virtual","deviceId":1,"parameterNumber":99}}],
  "visible": true,
  "span": "6",
  "vspan": 1
}
```
And the device JSON needs `"instrumentId": "generic-controls"` to be recognized:
```json
"devices": [{"id":1, "name":"Generic MIDI", "instrumentId":"generic-controls", "port":1, "channel":1}]
```

### Pushing presets via SysEx (autonomous workflow, verified 2026-05-26)

**The fast path** — push any widget in this repo to the device with one command:

```bash
python3 ~/dev/mcp/electra-one/server/win_bridge.py upload-preset \
  --preset widgets/step-seq-16/demo.preset.json \
  --port "MIDIOUT3 (Electra Controller)" \
  --bank 0 --slot 0 --mode simple
```

The widget renders end-to-end: preset.json converted from our `tiles` schema to the device's `controls` schema, Lua extracted into a separate `main.lua`, both pushed with the documented `01 01` / `01 0C` SysEx, and a slot-flip trick forces the device to cold-reload from disk. No Firestore, no web editor round-trip.

#### Why the converter exists

The widgets in this repo use a "tiles" schema (`schemaVersion`, `tiles[]`, `targetDevice`, `firstPageId`, `categoryId`) which the **device firmware doesn't parse over SysEx** — the official preset format (`presetformat.html`) is `version` (numeric) + `pages` + `devices` + `overlays` + `groups` + `controls[]`. The web editor at `app.electra.one` converts tiles → controls internally before upload; we ported that conversion in `server/preset_converter.py`.

- Source of truth: `projectToPreset` in `app.electra.one`'s JS bundle (`0c61af0.js`, offset ~127000–131000 in the unminified flow).
- MK2 6×12 layout math (slot→bounds, slot→pot, slot→set, slot→pageId): same bundle, offset ~159200. Our `_MK2Layout` class ports the formulas verbatim.
- Verified byte-identical against a live sniff: feeding step-seq-16 into our converter produces the exact same JSON the web editor sends over WebMIDI.

#### Upload sequence (what the MCP runs under the hood)

1. `09 08 bank slot` — Switch Preset Slot (arms target).
2. `01 01 <ascii preset.json>` — Upload Preset.
3. `01 0C <ascii main.lua>` — Upload Lua Script (only if the project has a `lua` field).
4. `09 08 bank (slot XOR 1)` then `09 08 bank slot` — Slot-flip reload (forces device cold init; `08 08 Reload Preset Slot` NACKs on firmware 4.1.4 so we use this trick instead).

Each step waits for ACK (`F0 00 21 45 7E 01 <txid> F7`) before proceeding; NACK (`7E 00 …`) aborts the upload.

#### Empirical limits (firmware 4.1.4)

- **Big SysEx in one shot** is fragile on Windows: USB-MIDI 1.0 class driver fragments above ~5 KB (worse since Windows updates KB5077181 / KB5074105 late 2025). The simple `01 01` path works fine for the small `controls`-schema preset (typically < 1 KB once Lua is stripped). The 40 KB Lua goes via single `01 0C` and works on this firmware over MIDIOUT3 — driver behaviour depends on host, your mileage may vary.
- **File Transfer API** (`01 2D` Open Cache → `01 2E` Register → `01 2F` Chunks → `04 2D` Commit) is implemented in the MCP for completeness (mode=`ft`) but **not the recommended path for preset+lua**: the docs scope FT to firmware / lua modules / multi-file atomic deploys, and in practice the commit silently rolls back for preset content. Forum #592 reaches the same conclusion.
- **No SysEx query for "which slot is currently displayed"**: the device only emits unsolicited `7E 02 bank slot` events on user navigation. Maintain client state via passive listen.

#### Listening for ACKs (winmm + ctypes) — two traps that cost hours

1. **Polling `MHDR_DONE` races the driver.** Use `CALLBACK_FUNCTION` with a `WINFUNCTYPE` trampoline so the driver hands you the buffer only after it's complete.
2. **`hdr.lpData` as `c_char_p` truncates at the first NUL.** Electra SysEx starts `F0 00 21 45 …` — the `00` bytes look like string terminators to ctypes. Keep a Python-side list of the `ctypes.create_string_buffer` allocations and slice `buffers[i].raw[:n]` directly. See `server/win_bridge.py` in [electra-one-mcp](https://github.com/roomi-fields/electra-one-mcp).

#### CTRL port mapping on Windows

- `MIDIOUT3 (Electra Controller)` ↔ `MIDIIN3 (Electra Controller)` = USB port 3 = **CTRL** (admin / file-transfer / events)
- `MIDIOUT2 / MIDIIN2` = port 2
- `Electra Controller` (no suffix) = port 1

#### Long-term path

Port to **Windows MIDI Services 1.0** (in-box service Microsoft shipped to Win 11 24H2 in Feb 2026; replaces `winmm.dll`) via `winsdk` / `pywinrt`. Not blocking today — the slot-flip + simple-mode pipeline works on the current driver — but it sidesteps the USB-MIDI 1.0 fragmentation issue cleanly.

---

## 2. Injecting a widget into app.electra.one for live testing on hardware

**Why this matters**: the online editor's "New Preset" UI is hostile. Editing by
hand in the UI is painful for anything but trivial presets. Writing the JSON
directly into their Firestore backend is a hundred times faster.

**Prereqs**: an account on https://app.electra.one. An empty preset you created
through the UI (any name — you'll overwrite its `project` field via the API).

### Architecture

- `app.electra.one` is a Nuxt SPA.
- Backend: **Firebase** project `electra-one-716c4`.
- Presets live in **Firestore**, collection `projects`, doc id = the preset ID in the URL `app.electra.one/preset/<id>`.
- Preview SVGs live in **Firebase Storage**, bucket `electra-one-716c4.appspot.com`, path `previews/<id>-<pageNum>.svg` (regenerated server-side when you save in the editor).
- Firebase Web API key: **do not commit it here**. Extract it from a fresh copy of the Nuxt bundle each time:

  ```bash
  for js in $(curl -s https://app.electra.one/presets/ | grep -oE '/_nuxt/[a-z0-9]+\.js' | sort -u); do
    curl -s "https://app.electra.one$js" | grep -oE 'AIza[0-9A-Za-z_-]{35}'
  done | sort -u | head -1
  # export FIREBASE_API_KEY=<the value>
  ```

  The key is technically public (it's in every user's browser tab), but GitHub secret scanning and Firebase auto-revocation react to it being committed. Keep it in your shell env, not in files.

### Step 1 — get an auth token

```bash
AUTH=$(curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$FIREBASE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email":"YOUR_EMAIL","password":"YOUR_PASSWORD","returnSecureToken":true}')
TOKEN=$(echo "$AUTH" | python3 -c "import sys,json;print(json.load(sys.stdin)['idToken'])")
```

Token is valid ~1h. Refresh the same way when it expires.

### Step 2 — read your preset doc (sanity check)

```bash
PRESET_ID="3JvRV83SMiP5uBLKVr3a"   # yours
curl -s "https://firestore.googleapis.com/v1/projects/electra-one-716c4/databases/(default)/documents/projects/$PRESET_ID" \
  -H "Authorization: Bearer $TOKEN"
```

### Step 3 — patch the preset with your widget

Clone a known-good v3 preset's structure and swap in your Lua + your custom tile:

```python
#!/usr/bin/env python3
import json

# 1. Load a reference working preset (we keep EG Template dumped locally)
ref = json.load(open("ref-eg-template.raw.json"))
proj = json.loads(ref["fields"]["project"]["stringValue"])

# 2. Swap Lua
proj["lua"] = open("my_widget.lua").read()

# 3. Replace the dx7envelope tile with a custom one, strip the rest
keep = next(t for t in proj["tiles"] if t.get("type") == "dx7envelope")
keep["type"] = "custom"
keep["name"] = "My Widget"
keep["color"] = "FFFFFF"
keep["values"] = [{"message": {"type": "virtual", "deviceId": 1, "parameterNumber": 99}}]
keep.pop("primaryValue", None)
proj["tiles"] = [keep]

# 4. Prune layout to only reference the kept tile
for L in proj["layouts"]:
    if L["id"] == "mk2-6x6":
        L["slots"] = [{"id": 0, "tile": {"id": "ref-my-0", "slotId": 0,
                                          "type": "ref", "tileId": keep["id"]}}]

# 5. Match id to target preset
proj["id"] = "3JvRV83SMiP5uBLKVr3a"
proj["name"] = "MyWidgetTest"

payload = {
  "fields": {
    "project":   {"stringValue": json.dumps(proj)},
    "name":      {"stringValue": "MyWidgetTest"},
    "schemaVersion": {"integerValue": 3},
    "revision":  {"integerValue": 99}   # bump each push
  }
}
print(json.dumps(payload))
```

Then PATCH:

```bash
curl -X PATCH \
  "https://firestore.googleapis.com/v1/projects/electra-one-716c4/databases/(default)/documents/projects/$PRESET_ID?updateMask.fieldPaths=project&updateMask.fieldPaths=name&updateMask.fieldPaths=schemaVersion&updateMask.fieldPaths=revision" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @payload.json
```

### Step 4 — test in the editor / on hardware

1. Refresh (Ctrl+Shift+R) your preset page in `app.electra.one`.
2. You should see the single custom tile you defined.
3. Click **Upload** — sends via WebMIDI SysEx to your Electra (must be USB-connected, Chrome/Edge, MIDI permission allowed).
4. Look at the MK2 screen. If empty: open the Console in the web editor for Lua errors.

### Known pitfalls

- **"Preset is empty"** after refresh → your JSON structure is invalid. Revert by patching with a known-good project, then re-clone more carefully.
- **SchemaVersion mismatch**: if the Firestore doc's `schemaVersion` field is 3 but you put a v2 `project` inside, the editor loses edit/upload buttons. Keep them consistent.
- **MIDI permission denied silently**: `Settings → Site settings → MIDI devices → Allow` for `app.electra.one`. Required.
- **Upload button missing**: usually means the preset isn't yours (public preset, view-only), or an auth/session expired. Re-login.
- **Tiles "peek through"** the custom paint: orphan tiles remain in `proj.tiles`. Strip them and fix the layout slots.

---

## 3. Generating a preview (SVG) for the gallery

Two categories of widgets, two preview strategies.

### Category A — widgets made of native tiles only (fader, pad, list, dx7envelope, label, etc.)

The official SVG from Firebase Storage is **accurate** because the editor
renders native tiles from the JSON schema:

```bash
curl -sL -o preview.svg \
  "https://firebasestorage.googleapis.com/v0/b/electra-one-716c4.appspot.com/o/previews%2F$PRESET_ID-1.svg?alt=media"
```

Drop that into `widgets/<slug>/preview.svg`. Done.

### Category B — widgets with a `type: "custom"` tile + Lua paint callback

The official SVG **misses the Lua drawing** (custom tile appears as an empty
rectangle). Two-step hybrid:

**Step 1 — download the official SVG** (same URL as above).

**Step 2 — splice the custom tile's `<g>` block with a hand-authored overlay**
rendered at the *runtime* bounds (the size after `setBounds` in your Lua), not
the tile's slot-size bounds in the JSON.

Python helper (replace the custom tile group):

```python
import re
s = open("official.svg").read()

# Find and replace the <g type="custom" ...>...</g> with balanced-tag logic
m = re.search(r'<g type="custom"[^>]*>', s)
start = m.start()
depth, i = 1, m.end()
while i < len(s) and depth > 0:
    no, nc = s.find('<g', i), s.find('</g>', i)
    if nc == -1: break
    if no != -1 and no < nc:
        depth += 1; i = no + 2
    else:
        depth -= 1; i = nc + 4
end = i

# Your hand-drawn overlay, matching runtime bounds from your Lua setBounds
overlay = '''<g type="custom" bounds="X,Y,W,H" pageId="1">
  <g transform="translate(X,Y)">
    <rect x="0" y="0" width="W" height="H" fill="#000000"/>
    <!-- your paint primitives here -->
  </g>
</g>'''

open("preview.svg","w").write(s[:start] + overlay + s[end:])
```

**Step 3 — apply Lua `setColor()` overrides** that run in `preset.onLoad()`.
These recolor native tiles but the official SVG shows pre-Lua state:

```python
# Example: Key On Loop (ref 1, slot-bounds "20,388") → BLUE 0x0000FF
BLUE = "#0000FF"
def recolor(svg, bounds_prefix, color):
    m = re.search(r'<g [^>]*bounds="' + re.escape(bounds_prefix) + r',\d+,\d+"[^>]*>', svg)
    # walk balanced </g>, replace fill="#ffffff" → fill=color in that block
    ...
```

(See `widgets/xt-envelopes/preview.svg` commit for the full working example.)

### Sizing convention

- MK2 display viewBox: `0 0 1016 560`.
- Keep SVGs at this size so the gallery can layout uniformly.

### Fonts

- Match the editor's official SVG: `font-family="'Open Sans', sans-serif"`, small sizes (8–12px) for in-tile labels, 14–16px for values.

### PNG rasters (if needed)

GitHub and some integrations render SVGs inconsistently. To export a PNG:

```bash
# Using librsvg
rsvg-convert -w 1016 -h 560 preview.svg -o preview.png
# Using Inkscape
inkscape --export-type=png --export-width=1016 preview.svg -o preview.png
# Using Chrome headless
chrome --headless --screenshot=preview.png --window-size=1016,560 \
       "file:///$PWD/preview.svg"
```

Our gallery generator (`scripts/build-index.js`) already detects
`preview.{png,jpg,jpeg,webp,svg}` in that order, so you can commit whichever.

---

## Keeping this doc alive

Every time you learn something new about the schema, the editor, or the Lua
runtime — add a bullet under the relevant section. Stale howtos are worse than
no howto.
