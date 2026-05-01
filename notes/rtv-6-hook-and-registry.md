# RTV-6 hook and registry decisions

## Inventory action

The Phase 0 discovery pass found that RtV inventory context actions are fixed buttons in `Context.gd`. `Context.Update()` shows the existing Use button when `itemData.usable` is true and uses `itemData.phrase` as the button label.

For the hello note, the item is registered as usable with `phrase = "Read"`. The mod then takes a replace hook on `Interface.Use` (`interface-use`) and only intercepts `rtv_lore_hello_note`. That keeps the vanilla context-menu UI intact while preventing the destructive consumable path from removing the note.

If another mod already owns `interface-use`, this mod falls back to a replace hook on `Interface.ContextUse` (`interface-contextuse`). If both replace hooks are unavailable, the note's `usable` flag is disabled before item registration so the context menu will not expose a Read action that would consume the item.

## Scene registration

RTV-6 only calls out `ITEMS` and `LOOT`, but the vanilla loose-loot and save/load paths call `Database.get(itemData.file)` to instantiate item scenes. The hello note therefore registers both:

- `Registry.ITEMS`, keyed by `rtv_lore_hello_note`
- `Registry.SCENES`, also keyed by `rtv_lore_hello_note`

That keeps the `ItemData.file` id, registry id, and scene lookup id aligned.

## Visual reuse

The hello note reuses the vanilla Patient Report icon, mesh, material, and 2x2 inventory layout. This avoids custom art work in the vertical slice and matches the existing `Lore` item category already present in vanilla assets.
