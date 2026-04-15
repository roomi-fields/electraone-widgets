# Awesome Electra One

Curated inventory of Lua widgets, frameworks, presets, and integrations that exist for the [Electra One](https://electra.one) MIDI controller, across the forum and GitHub. This page **links to sources** — it does not redistribute code. Widgets that are imported into this repo (`widgets/`) always credit and link back here.

> If you are an author listed below and want your entry modified or removed, see [NOTICE.md](NOTICE.md).

## Frameworks & libraries

| Project | Author | License | Notes |
|---|---|---|---|
| [martinpavlas/electra.lua](https://github.com/martinpavlas/electra.lua) | Martin Pavlas (Electra One founder) | none specified | Reference framework — **[imported to `examples/` →](examples/)** · `component`, `lcd_touch`, `component_touch`, `pot_touch`, `buttons`, `pots`, MIDI I/O helpers, boilerplate |
| [shankararunachalam/electra.lua](https://github.com/shankararunachalam/electra.lua) | shankar | none specified | Fork of above + `sequencer/` (Ephemera proof-of-concept, 16-step) |

## Widgets / custom controls (forum-shared)

| Widget | Author | Source | Notes |
|---|---|---|---|
| Ephemera 16-step sequencer | shankar | [forum](https://forum.electra.one/t/ephemera-sequencer-for-electra-one-standalone-lua-firmware/715) · [code](https://github.com/shankararunachalam/electra.lua/tree/main/sequencer) · **[imported →](widgets/ephemera-sequencer/)** | Standalone Lua firmware, buttons/knobs/touch/timer/MIDI |
| Multi-stage envelopes (DAHDSR / ADBSSR / DALDSDSR) | oldgearguy, NewIgnis | [forum](https://forum.electra.one/t/custom-control-for-envelopes-anyone/4169) | Graphics + touch, faders as data backing |
| XT Envelopes demo | (community) | [preset](https://app.electra.one/preset/GK6wmbgvwM6S3GanpoN7) | |
| NewIgnis envelope template | NewIgnis | [preset](https://app.electra.one/preset/HbynnPgMY6ei48yqOlrw) | |
| Modwheel/aftertouch routing, resonance compensation, simple LFO (tri/square/ramp) | NewIgnis | [forum](https://forum.electra.one/t/making-additional-modulation-and-expression-with-lua/1778) | Timer-based LFO with note-on phase reset |
| VCVRack patch visualizer | topa | [forum](https://forum.electra.one/t/instrument-preset-for-vcvrack-remote-patch-control-using-an-electra-one-mk-ii/3510) | |
| Elektron Analog Drive preset | (community) | [forum](https://forum.electra.one/t/elektron-analog-drive/3723) | Rich UI example |

## Integrations (DAW / host bridges)

| Project | Author | License | Notes |
|---|---|---|---|
| [xot/ElectraOne](https://github.com/xot/ElectraOne) | xot | — | Ableton Live MIDI Remote Script |
| [xot/ElectraOneDump](https://github.com/xot/ElectraOneDump) | xot | MIT | Dumps an Electra One JSON preset for the currently selected Ableton device |
| [jorisroling/bitwig-electra-one](https://github.com/jorisroling/bitwig-electra-one) | Joris Roling | — | Bitwig Studio controller extension, follows selected device/track, 8 controls × N pages |
| [gramster/md2electraone](https://github.com/gramster/md2electraone) | gramster | — | Markdown / CSV → Electra One preset generator |
| [SimonORorke/Continuum-Controller](https://github.com/SimonORorke/Continuum-Controller) | Simon O'Rorke | MIT | Haken Continuum + EaganMatrix preset |

## Official references

- [docs.electra.one/developers/luaext.html](https://docs.electra.one/developers/luaext.html) — Lua API
- [docs.electra.one/developers/presetformat.html](https://docs.electra.one/developers/presetformat.html) — preset JSON format
- [docs.electra.one/developers/midiimplementation.html](https://docs.electra.one/developers/midiimplementation.html) — SysEx
- [github.com/electraone](https://github.com/electraone) — official org
- [app.electra.one/presets](https://app.electra.one/presets/) — 300+ community presets with screenshots

## Contribute an entry

Open a PR editing this file. Include: project URL, author name/handle, license (or "none specified"), one-line description. If it's a widget you'd like ported into `widgets/`, open an issue using the "Port request" template.
