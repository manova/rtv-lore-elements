# RTV-8 discovery decisions

## Pickup hook

RTV-8 uses `interface-autoplace-post` to detect lore notes entering the player inventory. `Interface.AutoPlace(targetItem, targetGrid, sourceGrid, usedrop)` is the common placement path for container transfers, world pickups routed through `Create`, unequips, and other inventory moves. The callback only records discovery when `targetGrid == interface.inventoryGrid` and `targetItem.slotData.itemData.file` is one of this mod's registered note IDs.

This avoids the save-load path: `Loader.LoadCharacter()` restores inventory through `Interface.LoadGridItem()`, which places saved items directly and does not call `AutoPlace`. Journal arrays are also de-duplicated, so repeated moves of an already-discovered note are harmless.

## Journal during pause and menus

The journal hotkey is active only while `/root/Map` exists and vanilla `GameData` is not in settings, transition, cache, sleep, death, inspect, reload, insertion, checking, or placement states. It is allowed during normal gameplay and while the inventory/container UI is open. It does not open over the main menu or pause/settings.

## Sort order

The journal renders in discovery order, newest first. The persisted `discovered_ids` array remains append-only in original discovery order; rendering reverses that list. This matches the spec's play-history framing and keeps future sort modes out of scope for RTV-8.

## Default hotkey

A grep of the detokenized vanilla scripts and project dump found no `KEY_J` or journal binding. RTV-8 registers `rtv_lore_open_journal` through the Metro `INPUTS` registry with default `KEY_J`.

## Layering and focus

The journal uses a `CanvasLayer` above the Phase 2 reader layer and attaches to the visible Interface node when inventory is open, otherwise the current scene. While the journal is open, `uimanager-_input` is skipped so vanilla interface/settings hotkeys cannot affect the UI behind it; Escape/settings and `J` close only the journal. Journal close applies the same interface cleanup discipline as the reader, including clearing `gameData.isOccupied` and hiding any context menu.
