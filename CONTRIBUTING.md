# Contributing

Thanks for adding to the library.

## Rules

1. **One widget = one folder = one PR.** Keep PRs focused.
2. **Copy `widgets/_template/`** as your starting point. Rename the folder to your widget name (lowercase, hyphen-separated: `xy-pad`, `step-seq`, `lfo-scope`).
3. **Required files in your folder:**
   - `widget.lua` — the Lua code, self-contained, well-commented
   - `demo.preset.json` — a minimal Electra One preset that loads and runs the widget
   - `preview.png` — 480×320 or larger screenshot of the widget running on the device (or the web editor)
   - `README.md` — what it does, how to integrate, parameters, MIDI mapping
4. **Keep widget.lua dependency-free** where possible. If you need helpers, add a `lib/` sibling folder and document it.
5. **Test on real hardware or the web simulator** before opening the PR. Say which in the PR description.
6. **License**: by opening a PR you agree your contribution is MIT-licensed.

## PR template

The PR template will ask for:
- Widget name + one-line description
- Screenshot (can be dragged into the PR body)
- Test environment (MK2 / Mini / simulator)
- Related forum thread if any

## Naming conventions

- Folder: `kebab-case`
- Lua globals / tables: `PascalCase` for the widget table (`XYPad`, `StepSeq`)
- Functions: `camelCase`
