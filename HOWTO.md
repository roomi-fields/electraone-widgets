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
- Firebase Web API key (public, from Nuxt bundle): `$FIREBASE_API_KEY`

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
