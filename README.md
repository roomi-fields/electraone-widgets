# Electra One Widgets

A community library of custom Lua widgets for the [Electra One](https://electra.one) MIDI controller (MK2 / Mini).

Native Electra presets only offer faders, knobs, pads, lists and ADSR envelopes. This repo collects **reusable Lua widgets** — XY pads, step sequencers, scopes, custom envelopes, LFO visualizers, matrices — that you can drop into any preset.

## Gallery

Browse all widgets with screenshots: **[Live gallery →](https://roomi-fields.github.io/electraone-widgets/)**

## Using a widget

Each widget lives in `widgets/<name>/` and ships with:

- `widget.lua` — the Lua code to paste / require in your preset
- `demo.preset.json` — a working Electra One preset you can upload as-is
- `preview.png` — screenshot
- `README.md` — integration notes

## Contributing

PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md). One widget = one folder = one PR. Copy `widgets/_template/` and go.

## License

MIT — see [LICENSE](LICENSE).
