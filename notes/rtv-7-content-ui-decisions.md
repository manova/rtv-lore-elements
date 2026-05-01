# RTV-7 content and UI decisions

## Data shape

RTV-7 keeps authored note text in `data/notes.json` rather than adding custom fields to `ItemData`. Phase 0 confirmed that vanilla `ItemData.gd` does not expose arbitrary note metadata, so the mod keeps a side-channel dictionary keyed by `itemData.file`.

Each JSON entry contains the registry id, inventory labels, rarity/value, loot flags, and a page array. `Main.gd` clones the existing hello-note `ItemData` template and packs a matching pickup scene per note so `Registry.ITEMS`, `Registry.SCENES`, and save/load lookups all share the same id.

## Loot placement

Thematic placement uses `LT_Master` plus vanilla `civilian`, `industrial`, and `military` item flags. This follows the Phase 0 discovery that ordinary containers filter `LT_Master` by those booleans and by item type limits. No new loot-generation hook is needed for this phase.

All RTV-7 authored notes use common rarity. Early smoke testing showed that mixed common/rare notes made the inventory tint imply a loot-quality hierarchy between scraps of lore. Placement remains controlled by the vanilla loot flags instead.

## Reader styling

The reader stays built in code because Phase 1 already used a lightweight runtime `CanvasLayer`. RTV-7 adds page state, Prev/Next buttons, a page counter, and a paper-style panel with a subtle rotation.

Caveat Regular is bundled under SIL Open Font License 1.1 for note body text only. If the font fails to load, the reader falls back to the vanilla/Godot UI font instead of blocking note registration.
