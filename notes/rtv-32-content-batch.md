# RTV-32 content batch

RTV-32 adds five Notion-authored notes after the RTV-31 loot retune. Each note ships with `rarity: 1` / `rarity = 1` so the batch stays in the Rare bucket rather than increasing common-note density.

The batch follows the RTV-7 save/load fix: every JSON definition in `data/notes.json` has a matching persistent resource under `Items/Lore/Notes/`. Runtime registration remains unchanged because `Main.gd` already loads note metadata from JSON and item resources by matching note id.

## Notes

- `rtv_lore_hamina_last_shift` — Hamina Dispatch, industrial.
- `rtv_lore_guard_three_lines` — Guard's Notebook, military.
- `rtv_lore_child_kitchen_map` — Crayon Map, civilian.
- `rtv_lore_posted_orders_layered` — Posted Orders, civilian.
- `rtv_lore_triage_unknown_male` — Triage Tag, civilian.
