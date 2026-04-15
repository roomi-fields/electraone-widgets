# Examples — Electra One Lua API demos

Minimal reference demos for the Electra One standalone Lua firmware. **Not reusable widgets** — these are pedagogical snippets that show how each callback / module works.

## Source & attribution

All files in this folder are imported from **Martin Pavlas's** reference repo:
https://github.com/martinpavlas/electra.lua

Martin is the creator of Electra One. No license is specified at source — files are imported verbatim with attribution, under the opt-out policy in [NOTICE.md](../NOTICE.md).

## Contents

| File | Demonstrates |
|---|---|
| `boilerplate.lua` | Minimal app skeleton with every major callback stubbed |
| `component.lua` | Create / show / style a UI Component |
| `component_touch.lua` | Touch events with component identification |
| `lcd_touch.lua` | Raw LCD touch callbacks (down / hold / up / click / long-hold / double-click) |
| `buttons.lua` | Hardware button callbacks (`onButtonDown`, `onButtonUp`, `onButtonLongHold`) |
| `pots.lua` | Relative pot rotation (`onPotMove`) |
| `pot_touch.lua` | Pot touch-sensing (`onPotTouchDown`, `onPotTouchUp`) |
| `midi_in.lua` | Full inventory of `midi.on*` incoming callbacks |
| `midi_out.lua` | Full inventory of `midi.send*` outgoing functions |
| `printing.lua` | Console `print()` debug output |

## Use

Pick one, paste into a standalone-firmware Lua slot, watch the console for output as you interact.
