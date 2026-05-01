# Script discovery notes

Linear: RTV-5

## Environment found

- Game folder: `/mnt/c/Program Files (x86)/Steam/steamapps/common/Road to Vostok`
- User data: `/mnt/c/Users/erons/AppData/Roaming/Road to Vostok`
- Current loader config: `/mnt/c/Users/erons/AppData/Roaming/Road to Vostok/mod_config.cfg`
- Current conflict log: `/mnt/c/Users/erons/AppData/Roaming/Road to Vostok/modloader_conflicts.txt`
- Prior extracted scripts: `/mnt/c/Users/erons/Documents/Codex/2026-04-20-i-m-trying-to-back-up/rtv-extracted-scripts/Scripts`
- PCK extraction: `/home/okoh/rtv-extracted-pck`
- Focused GDRE recovery: `/home/okoh/rtv-gdre-recovered`
- Full GDRE recovery: `/home/okoh/rtv-gdre-full`

WSL now has `unzip`, `7z`, `bsdtar`, `godotpcktool`, and GDRETools available. `godotpcktool` extracted the PCK into remap files and binary exported resources, which was useful for inventorying the PCK but not enough for readable item resources. GDRETools `v2.5.0-beta.5` recovered the full project from `RTV.pck` into `/home/okoh/rtv-gdre-full`: 175 scripts decompiled, 0 failed scripts, 8726 imported resources converted, 0 failed conversions. The recovery log reports Road to Vostok's editor version as Godot 4.6.2 and bytecode revision as 4.5.0-stable.

Loader note: the public Metro Mod Loader docs and release assets for `v3.1.1` confirm the hook/registry API exists in current Metro: the release `modloader.gd` exposes `Engine.meta("RTVModLib")`, `frameworks_ready`, `.hook(...)`, `skip_super()`, and `Registry`, and the release `override.cfg` uses `[autoload_prepend] ModLoader="*res://modloader.gd"`. An older local loader install initially pointed `/mnt/c/Program Files (x86)/Steam/steamapps/common/Road to Vostok/override.cfg` at `ModLoader="user://modloader.gd"`, whose AppData bootstrap had no `RTVModLib`, hook, or registry symbols. That mismatch was resolved by installing Metro `v3.1.1` into the game folder and smoke-testing in game: `logs/godot.log` now shows `RTVModLib` registration, `frameworks_ready` emission, hook-pack generation, and a successful cabin load with the current mod list.

Developer Mode was then enabled and refreshed `modloader_conflicts.txt`. The current report shows 14 mods loaded, 0 conflicting resource paths, and only Metro/core hook registrations. Metro logs `No user opt-in declarations ([hooks] / .hook() / [registry])` for the current mod list, so existing mods run in `v2.1.0`-equivalent mode. The report also shows a `RegistryProbe` warning because no currently enabled mod declares `[registry]`; this is expected for the existing mod list and confirms this mod's manifest must keep its `[registry]` section.

## Inventory and context-menu surface

There is no separate `Inventory.gd` in the extracted script set. Inventory behavior is owned by `Interface.gd`.

Relevant vanilla file:

- `/home/okoh/rtv-gdre-full/Scripts/Interface.gd`

Key points:

- `Interface.gd` extends `Control` and owns UI nodes for inventory, container, equipment, trader, tools, and context menu. It resolves `inventoryGrid` at line 46 and `context` at line 140.
- Context-menu input is handled in `_physics_process`; pressing the `"context"` action calls `ShowContext()` when no item is dragged. See lines 286-292.
- `ShowContext()` is the exact item/right-click hook surface. It sets `contextItem`, `contextGrid` or `contextSlot`, calls `context.Update(contextItem.slotData)`, then shows the context menu. See lines 2130-2145.
- `ContextUse()` delegates to `Use(contextItem, contextGrid)` and then hides the context. See lines 2473-2482.
- `Use(targetItem, targetGrid)` is destructive consumable behavior: it marks `gameData.isOccupied`, plays use audio, creates a progress bar, calls `character.Consume(...)`, removes the item from its grid, queues it free, optionally creates `used` outputs, and resets state. See lines 2503-2551.

Context menu rendering lives in:

- `/mnt/c/Users/erons/Documents/Codex/2026-04-20-i-m-trying-to-back-up/rtv-extracted-scripts/Scripts/Context.gd`
- `/home/okoh/rtv-gdre-full/Scripts/Context.gd`

Key points:

- `Context.Update(slotData)` hides all buttons, then shows the `Use` button when `contextItem.slotData.itemData.usable` is true. The displayed button text comes from `itemData.phrase`. See lines 50-65.
- The existing context menu has fixed button nodes (`Use`, `Equip`, `Unequip`, `Unload`, `Split`, etc.) declared at lines 9-27. There is no dynamic arbitrary action list.
- `_on_use_pressed()` calls `interface.ContextUse()`. See lines 148-150.

Recommended hook strategy for Phase 1:

1. Avoid replacing `Interface.Use()` for the reader if possible because the vanilla method is destructive and asynchronous.
2. Add notes as `ItemData.usable = true` with `phrase = "Read"` so the vanilla context menu exposes the existing `Use` button.
3. Register a `interface-contextuse-pre` or `interface-use-pre` hook if Metro is active, detect our item by `slotData.itemData.file`, call the note reader, and skip vanilla consumption. If replace ownership is unavailable, fall back to a post/pre strategy around `ContextUse()` and keep notes non-consumed by restoring the item only as a last resort.
4. Verify the Metro callback skip/cancel mechanism before implementing the interception. The vanilla `Use()` path consumes/removes items, so the lore reader must stop that path before it reaches vanilla consumption.

## Existing UI patterns

Vanilla UI path references:

- `LootContainer.Interact()` opens containers through `/root/Map/Core/UI`, then `UIManager.OpenContainer(self)`. See `LootContainer.gd` lines 143-147.
- Existing mods also locate the UI through the map scene:
  - Quick Stack & Sort scans `current_scene.get_node_or_null("Core/UI")`, then looks for a child with `containerGrid` to identify `Interface`. See `/tmp/rtv-mods-review/Quick-Stack-Sort-v2/mods/QuickStack/Main.gd` lines 60-81.
  - Quick Stack & Sort injects lightweight buttons into vanilla `Container` and `Inventory` UI nodes without replacing scripts. See lines 148-192.
  - Item Clarity uses `/root/Map/Core/UI/Interface` in its refresh path and reacts to `node_added` for item UI nodes. See `/tmp/rtv-mods-review/ItemClarity/ItemClarity/Scripts/Main.gd` lines 171-183 and 220-228.

For our reader UI, the safest runtime attach point is likely `/root/Map/Core/UI/Interface` or a sibling under `/root/Map/Core/UI`, matching the existing mod precedent.

## ItemData shape and categories

Source:

- `/home/okoh/rtv-gdre-full/Scripts/ItemData.gd`

Confirmed exported fields:

- Naming: `file`, `name`, `inventory`, `rotated`, `equipment`, `display` at lines 4-10.
- Stats: `type`, `subtype`, `weight`, `value`, `rarity` at lines 12-18.
- Icons/layout: `icon`, `tetris`, `size` at lines 20-23.
- Use: `usable`, `phrase`, `audio`, `used` at lines 48-52.
- Vitals/medical/equipment/details/electronic/armor/crafting fields continue through lines 54-101.
- Loot booleans: `civilian`, `industrial`, `military`, plus trader booleans, at lines 103-113.
- Placement: `orientation`, `wallOffset` at lines 115-117.

No custom/exported `loreText` or general metadata field exists in `ItemData.gd`, and recovered `.tres` resources only serialize fields defined by `ItemData.gd`. Note text should live in this mod's own dictionary/resource keyed by `itemData.file`.

Recovered resource examples:

- `/home/okoh/rtv-gdre-full/Items/Lore/Patient_Report/Patient_Report.tres` uses `type = "Lore"`, `size = Vector2(2, 2)`, `rarity = 3`, `weight = 0.1`, and has no `usable` or `phrase` fields set.
- `/home/okoh/rtv-gdre-full/Items/Medical/Bandage/Bandage.tres` uses `type = "Medical"`, `usable = true`, `phrase = "Heal"`, `health = 25.0`, and loot/trader flags such as `civilian = true`, `military = true`, `generalist = true`, `doctor = true`.

Category decision:

- `Database.gd` already has `res://Items/Lore/...` constants for `Patient_Report`, `Oil_Sample`, and `Cat` at lines 151-153.
- `Database.gd` also has `res://Items/Books/...` constants at lines 173-176.
- Item Clarity's category list includes both `"Books"` and `"Lore"` as recognized path categories, with zero-color defaults. See Item Clarity `Main.gd` lines 144-165 and `_get_category()` at lines 232-238.

Recommended category for lore-note items: use `type = "Lore"` and place resources under `res://Items/Lore/<NoteId>/...` rather than inventing `"Documents"`.

## Loot tables and spawn targeting

Relevant vanilla files:

- `Database.gd`
- `LootContainer.gd`
- `LootSimulation.gd`
- `/home/okoh/rtv-gdre-full/Loot/LT_Master.tres`
- `/home/okoh/rtv-gdre-full/Loot/Custom/LT_Patient_Report.tres`

Key points:

- `Database.gd` has an exported `master: LootTable` and can rebuild it from `Database` constants by looking for matching `.tres` files beside item `.tscn` files. See lines 6-32.
- `LootContainer.gd` preloads `res://Loot/LT_Master.tres` at line 8. In `_ready()`, ordinary containers clear/fill buckets and generate loot. See lines 44-63.
- `LootContainer.FillBuckets()` iterates `LT_Master.items`, filters out `Rarity.Null`, then includes items when the container's `civilian`, `industrial`, or `military` flags match the item's booleans. It also honors `limit == item.type` and `exclude != item.type`. See lines 77-94.
- `LootSimulation.gd` uses the same `LT_Master` filtering pattern for simulated loose loot. See lines 58-75.

Recovered loot resources confirm vanilla lore precedent: `Loot/Custom/LT_Patient_Report.tres` contains only `res://Items/Lore/Patient_Report/Patient_Report.tres`, while `Loot/LT_Master.tres` is a large master list of item resources. Implication: a note can be placed broadly by adding it to `LT_Master` and setting its `civilian` / `industrial` / `military` booleans. Thematic placement does not require per-container tables at first; choose flags per note. Containers with `limit` set will only include notes if `limit == "Lore"`.

## Existing-mod precedent

Current enabled mods from the conflict log include Better Enemy Loot, Item Clarity, Loot Modifier, Quick Stack & Sort, and others. With Metro `v3.1.1` Developer Mode enabled, the report shows no resource path conflicts.

Reviewed mods:

- Loot Modifier: uses the older override pattern. `Main.gd` calls `overrideScript("res://LootModifier/LootContainer.gd")` and `overrideScript("res://LootModifier/LootSimulation.gd")`, then `take_over_path(...)` to replace vanilla scripts. Its replacement `LootContainer.gd` extends vanilla `res://Scripts/LootContainer.gd`, calls `super()`, clears generated loot, then applies its own loot settings. This is relevant because it touches loot generation and can affect note spawn rates.
- Quick Stack & Sort: pure autoload, no script override, locates `Interface` under `Core/UI` and injects UI controls into `Inventory` and `Container`. This is a good precedent for adding UI affordances without owning vanilla scripts.
- Item Clarity: pure/autoload-style UI augmentation. It scans item nodes, uses `item.slotData.itemData.resource_path` to infer item category, and recognizes `"Lore"` and `"Books"`.

## Open blockers / follow-ups

- Add `/home/okoh/.local/bin` to the active zsh PATH if tools need to be callable without absolute paths; the user added it to bash.
- Verify the exact Metro hook names for `Interface.ContextUse`, `Interface.Use`, and optionally `Context.Update`.
- Confirm the Metro mechanism for cancelling/skipping the vanilla `Use()` method from a pre-hook or replacement hook.
