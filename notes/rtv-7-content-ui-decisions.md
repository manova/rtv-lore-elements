# RTV-7 content and UI decisions

## Data shape

RTV-7 keeps authored note text in `data/notes.json` rather than adding custom fields to `ItemData`. Phase 0 confirmed that vanilla `ItemData.gd` does not expose arbitrary note metadata, so the mod keeps a side-channel dictionary keyed by `itemData.file`.

Each JSON entry contains the registry id, inventory labels, rarity/value, loot flags, and a page array. Authored notes have matching `ItemData` resources under `Items/Lore/Notes/`, and `Main.gd` loads those resources before syncing metadata from JSON. This keeps note item data as external resources in saves instead of inline runtime duplicates, which avoids typed-array load failures when a save contains picked-up lore notes.

The legacy damaged field note still uses the original `Note_HelloWorld` template for compatibility. Authored note pickup scenes continue to be packed at runtime from the hello-note scene template, but they now point at stable external `ItemData` resources.

## Loot placement

Thematic placement uses `LT_Master` plus vanilla `civilian`, `industrial`, and `military` item flags. This follows the Phase 0 discovery that ordinary containers filter `LT_Master` by those booleans and by item type limits. No new loot-generation hook is needed for this phase.

All RTV-7 authored notes use common rarity. Early smoke testing showed that mixed common/rare notes made the inventory tint imply a loot-quality hierarchy between scraps of lore. Placement remains controlled by the vanilla loot flags instead.

## Reader styling

The reader stays built in code because Phase 1 already used a lightweight runtime `CanvasLayer`. RTV-7 adds page state, Prev/Next buttons, a page counter, and a paper-style panel with a subtle rotation.

Caveat Regular is bundled under SIL Open Font License 1.1 for note body text only. If the font fails to load, the reader falls back to the vanilla/Godot UI font instead of blocking note registration.
