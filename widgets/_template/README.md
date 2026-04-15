# Template widget

Copy this folder, rename it, and fill in the blanks.

## What it does

<Describe the widget in 2-3 sentences.>

## Integration

1. Load `demo.preset.json` in the Electra One editor to see it working.
2. Copy `widget.lua` into your own preset's Lua script.
3. Attach callbacks on a host control (pad or fader used as canvas):

```lua
local W = require("widget")
local host = controls.get(1)
host:setPaintCallback(function(c, g) W.paint(c, g) end)
host:setTouchCallback(function(c, e) W.touch(c, e) end)
host:setPotCallback(function(c, v)  W.pot(c, v)  end)
```

## Parameters

| Name | Type | Default | Description |
|------|------|---------|-------------|

## MIDI mapping

<What messages does it send/receive?>

## Tested on

- [ ] Electra One MK2
- [ ] Electra One Mini
- [ ] Web simulator
