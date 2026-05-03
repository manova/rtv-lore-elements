# RTV-35 localization scaffold

RTV-35 moves Lore Elements UI chrome into `data/strings/en.json`.

## Approach

The mod loads the JSON string table at boot, builds a runtime `Translation`
resource for locale `en`, and registers it with `TranslationServer`. UI code reads
strings through `_ui_text(key)`, which checks Godot translation first and then the
loaded JSON map.

This uses JSON plus a runtime translation instead of committed `.translation`
resources because the mod ships as a VMZ and the recovered Road to Vostok project
does not currently expose a localization import pipeline to reuse.

## Included strings

RTV-35 covers player-facing UI chrome owned by this mod:

- MCM page title, page description, setting labels, and tooltips.
- Journal input display label.
- Reader navigation and close buttons.
- Journal title, close button, and empty state.
- Inventory context action phrase.

## Exclusions

Note body text, note titles, item inventory/display labels, logs, warnings, node
names, registry ids, config keys, file paths, and audio bus names are not localized
in this PR.

## Acceptance grep

After implementation, grep `Main.gd` for old chrome literals:

`Open Lore Journal|Lore Elements|Lore note spawn rate|Journal hotkey|Read|Prev|Next|Close|Journal|No notes discovered yet`

Expected remaining matches are only string-table keys, log/debug text, node names,
or non-player-facing constants.
