# RTV-30 Reader Visual Refresh

RTV-30 keeps the reader code-driven, but moves visual treatment data into
`data/note_types.json`. This lets new document types be added by assigning a
`note_type` in `data/notes.json` and adding one style entry, without touching
note registration, journal persistence, or item resources.

## Style schema

Each note type defines paper, ink, border, accent, font mode, font sizes,
canvas size, margins, rotation, decoration, and optional stamp text key.
Colors are HTML hex strings. `canvas_size` is `[width, height]`; `margins` uses
`left`, `top`, `right`, and `bottom` pixel values.

Unknown or missing note types fall back to `notice`. A missing or malformed
`note_types.json` warns once and uses built-in notice styling so the reader
still opens.

## Type assignments

- `dispatch`: border shift, patrol warning, radio transcript, Hamina dispatch,
  posted orders.
- `notice`: evacuation notice, schoolroom list, legacy hello note.
- `letter`: Leena letter, Tampere letter.
- `notebook`: forest cache note, guard notebook, weathered recipe.
- `manifest`: rail manifest, smuggler ledger.
- `map`: crayon map.
- `triage_tag`: clinic triage card, triage tag.

## Visual choices

Decorations are procedural Godot controls only: header rules, stamps, ruled
lines, clean stationery hints, ledger lines, a map fold hint, and a triage
grommet. RTV-30 deliberately does not add external paper textures, animated
page turns, sound effects, or world-pickup mesh/material parity; those belong
in a later asset realism pass.

Caveat remains limited to handwritten-style types. Dispatch, manifest, and
triage styles attempt a monospaced system font at smaller sizes, which gives
them a more printed/form-like feel while preserving Godot fallback behavior.

RTV-36 map pins reuse only each type's accent color. The marker shape, label
position, zoom scaling, and screen-space placement are unchanged to avoid
reintroducing the map drift/zoom issues found during RTV-36 smoke testing.

## Smoke test

Package and install a VMZ that includes `data/note_types.json`. In game, open
at least one dispatch, notebook, map, and triage-tag note, then spot-check
notice, letter, and manifest. Verify page navigation, close button,
Escape/settings close, journal re-read, and inventory/container transfer after
closing the reader. For pin color, temporarily add a `pinned_location` to one
note of two different types and confirm only the marker color changes.
