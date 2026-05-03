# rtv-lore-elements — Planning Document

> Readable notes and environmental storytelling for Road to Vostok.

## Why this mod exists

Road to Vostok's official roadmap commits to **lore elements** in Build 3 (Q4 2026) — readable notes, environmental storytelling, and similar atmospheric content. As of April 2026 (Build 1), nothing on the workshop ([351 mods surveyed](https://modworkshop.net/g/roadtovostok)) addresses this. The genre's standout games (S.T.A.L.K.E.R., Metro, Tarkov) rely heavily on found-document storytelling, and RtV's empty interiors are conspicuously silent.

This mod ships ahead of the official feature with a community version: collectible notes, letters, journals, propaganda posters, and similar lore artifacts that the player can find in the world and read in a UI.

## Goals

**Must-have (v0.1)**:
- Spawn readable note items in existing loot containers
- Add a "Read" inventory action that opens a UI showing the note's text
- Ship 10–20 hand-written lore notes that fit the existing game tone (post-apocalyptic Finland-Russia border)
- Support multi-page notes
- Persistent: notes the player picks up are added to a personal "journal" they can re-read

**Should-have (v0.2)**:
- Pinned/discoverable notes at fixed map locations (not just loot drops)
- Audio voiceover support per note (optional)
- Stained / weathered visual styling (paper backgrounds, ink runs)

**Nice-to-have (v1.0)**:
- Modders can register their own notes via this mod's API (i.e., this mod becomes a framework for other lore mods)
- Localization scaffold (string tables, not hardcoded text)
- Note categories (military reports, civilian letters, scientific logs, bandit notes)
- Achievements / journal completion stats

**Explicit non-goals**:
- Voiced dialogue with NPCs (that's Build 7's dialogue system)
- Quest items / active mission text (that's the existing trader-task system)
- Dynamic / procedurally generated notes

## Technical approach

This mod uses **both** the registry API (to add note items) and the hook API (to add the "Read" UI). See [`SHARED_CONTEXT.md`](../SHARED_CONTEXT.md) for the framework primer.

### Note item — Registry approach

Each lore note is an `ItemData` resource. The registry's `ITEMS` verb adds them, and the `LOOT` verb places them in tables.

```gdscript
# Main.gd, in _on_lib_ready()
var note_field_report = preload("res://lore-elements/items/Note_FieldReport_01.tres")

_lib.register(_lib.Registry.ITEMS, "lore_field_report_01", note_field_report)

# Drop into the master loot table
_lib.register(_lib.Registry.LOOT, "lore_field_report_01_in_master", {
    "item": note_field_report,
    "table": "LT_Master",
})
```

**ItemData fields needed** (verify against `res://Items/Consumables/Potato/Potato.tres` shape — note that the script is in the data-resource skip list, so we mod the .tres not the .gd):
- `file = "lore_field_report_01"` (must match registry id)
- `displayName = "Field Report (Damaged)"`
- `category = "Documents"` (need to check what categories exist; may need to register a new one or reuse "Misc")
- `weight = 0.05`
- `value = ?` (low — these aren't trader-valuable in vanilla)
- Custom field `loreText` (multi-page array of strings) — **TBD: ItemData may not support custom fields**. If not, store text in a separate dictionary keyed by `file`.

### "Read" action — Hook approach

The player's inventory UI lives in `Interface.gd` / `Inventory.gd` (need to confirm exact script). When the player right-clicks or context-menus a note item, we want a "Read" option.

**Two viable hook strategies**, pick after inspecting the inventory script:

1. **Hook the inventory item-action handler** — likely a method like `Interface::OnItemRightClick` or `Inventory::ShowContextMenu`. Inject a "Read" option for items in our category, open our UI on click.
2. **Override the item's "use" verb** — most consumables have a `use` action (`Potato` → eat). If notes are categorized as a usable item, we hook `WeaponRig` or `Inventory`'s use handler and route notes to our UI instead.

**Codex agent task**: dump the relevant scripts to find the right hook point. Start with `pck_enumeration.gd`'s discovery output if Metro Mod Loader logs it; otherwise grep the detokenized script dump for `right_click`, `context`, `use`, `interact`.

### Note reader UI

Standard Godot `CanvasLayer` + `Control` with a `RichTextLabel`. Spawned as a child of the current scene's `Core/UI` node.

Reference [Custom Trader Prices example](https://github.com/ametrocavich/vostok-mod-loader/blob/main/docs/wiki/Hooks.md#custom-trader-prices) — it accesses `scene.get_node("Core/UI/Interface")`. The same pattern applies for our reader.

### Persistent journal

Save to `user://lore-elements-journal.cfg` (Godot ConfigFile). Two lists:
- `discovered_ids`: array of note ids the player has picked up
- `read_ids`: array of note ids they've actually opened

The journal UI is a separate menu accessible from the main inventory or via a registered keybind.

### Keybind registration

```gdscript
var key_j = InputEventKey.new()
key_j.keycode = KEY_J
_lib.register(_lib.Registry.INPUTS, "lore_open_journal", {
    "display_label": "Open Journal",
    "default_event": key_j,
})
```

Note the UI caveat from `Limitations.md`: the action is functional but won't appear in the rebind menu without hooking `Inputs-createactions-pre`. That's a v0.2+ task.

## Implementation phases

### Phase 0 — Local environment + script discovery (1–2 hours)

- [ ] Install Metro Mod Loader on dev machine; verify clean game launch with empty mod.
- [ ] Enable Developer Mode in the launcher UI to dump rewritten scripts.
- [x] Inspect `Interface.gd`, `Inventory.gd`, and `Database.gd` to confirm:
  - ItemData shape (custom field support)
  - Inventory context-menu / right-click hook surface
  - Item category enum
  - Existing UI scene patterns (look for `Core/UI/Interface` access)
- [x] Inspect a vanilla item .tres (`Potato.tres`, `Bandage.tres`) to confirm the resource shape.

**Output**: `notes/script-discovery.md` documenting exact method names and data shapes.

### Phase 1 — Hello note (4–6 hours)

- [x] One hardcoded `Note_HelloWorld.tres` registered into `LT_Master`.
- [x] Pick up the note in-game, see it in inventory.
- [x] Right-click → "Read" → modal dialog showing fixed text.
- [x] Confirm `_lib.skip_super()` semantics if hooking a replace surface.

**Acceptance**: Pick up note, click read, see text, close, gameplay resumes.

### Phase 2 — Authored notes + multi-page reader (4–6 hours)

- [x] Build out 10 hand-written notes (text in `data/notes.json` — keeps content separate from code).
- [x] Multi-page navigation in reader UI (next/prev, page counter).
- [x] Visual styling (paper background, slight rotation, faux-handwriting font from a CC-licensed source).
- [x] Notes spawn in appropriate tables — military reports in army crates, civilian letters in residential containers (requires multiple LootTable registrations once tables are mapped).

### Phase 3 — Persistent journal (3–4 hours)

- [x] ConfigFile-backed journal save/load.
- [x] Journal UI showing discovered notes and re-read capability.
- [x] Keybind to open journal from gameplay/inventory.

### Phase 4 — Polish (variable)

- [x] Audio voiceover hooks (optional per note).
- [x] Pinned-location notes via map pin layer (see `notes/rtv-pinned-discovery.md`).
- [x] MCM config: spawn rate multiplier, journal hotkey customization.
- [x] Localization scaffold.
- [x] Reader visual refresh with per-type paper treatments.
- [x] 0.1 release value retune against the antiseptic VPS benchmark.
- [x] Reader and journal modal input blocking for release QA.
- [x] Curated v0.1 pinned-location note trail for Area 05.

### Phase 5 — Public lore framework (v1.0)

- [ ] Refactor so other mods can `register_lore_note(id, text, table)` via a public API on this mod's autoload.
- [ ] Document the API in README.
- [ ] Ship to ModWorkshop.

## Open questions for Codex agent to resolve

1. **Does `ItemData` support custom fields?** If not, store note text in a separate Dictionary on this mod's autoload, keyed by item `file` id.
2. **Inventory context-menu hook surface** — what's the exact script and method?
3. **Item category system** — is "Documents" a valid existing category, or do we reuse "Misc"?
4. **Loot table coverage** — `LT_Master` is one big pool. Are there per-container tables we can target for thematic placement (military notes in mil crates), or does that require hooking `LootContainer::GenerateLoot`?
5. **Audio playback** — preferred path: register sounds via `SOUNDS` registry, play via `AudioLibrary.play_event(id)`, or instantiate `AudioStreamPlayer` directly?
6. **Save-game compatibility** — picking up a note adds an item to the player's inventory. If a player removes this mod, do they get an "unknown item" error? Check `WorldSave` resilience.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| `ItemData` doesn't support custom fields | Side-channel storage in mod autoload; keys = item `file` ids |
| Inventory hook conflicts with other mods | Use `-pre` or `-post`, never replace; audit conflicts via Developer Mode |
| Build 3 ships and obsoletes the mod | This is *fine* — releasing first builds reputation; can pivot to "extra notes pack" once vanilla supports it |
| Note text is loud / breaks tone | Curate in collaboration with the community; ship with content guidelines for the v1.0 framework |

## References

- [Shared context](../SHARED_CONTEXT.md) — read first
- [Hooks docs](https://github.com/ametrocavich/vostok-mod-loader/blob/main/docs/wiki/Hooks.md)
- [Registry docs](https://github.com/ametrocavich/vostok-mod-loader/blob/main/docs/wiki/Registry.md)
- [Mod Format docs](https://github.com/ametrocavich/vostok-mod-loader/blob/main/docs/wiki/Mod-Format.md)
- [Roadmap](https://roadtovostok.com/game)
- Reference mods: [Loot Modifier (mod 56036)](https://modworkshop.net/mod/56036) for ItemData + LootTable patterns
