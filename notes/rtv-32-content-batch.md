# RTV-32 content batch

RTV-32 adds five Notion-authored notes after the RTV-31 loot retune. Each note ships with `rarity: 1` / `rarity = 1` so the batch stays in the Rare bucket rather than increasing common-note density.

The batch follows the RTV-7 save/load fix: every JSON definition in `data/notes.json` has a matching persistent resource under `Items/Lore/Notes/`. Runtime registration remains unchanged because `Main.gd` already loads note metadata from JSON and item resources by matching note id.

## Notes

- `rtv_lore_hamina_last_shift` — Hamina Dispatch, industrial.
- `rtv_lore_guard_three_lines` — Guard's Notebook, military.
- `rtv_lore_child_kitchen_map` — Crayon Map, civilian.
- `rtv_lore_posted_orders_layered` — Posted Orders, civilian.
- `rtv_lore_triage_unknown_male` — Triage Tag, civilian.

## Smoke test note

The expedited RTV-32 smoke build used a temporary local helper in `Main.gd`.
It hooked `lootcontainer-_ready-post`, waited for `Outpost`, scanned military
loot containers under `/root/Map`, selected the nearest crate-like military
container to `GameData.playerPosition`, cleared its generated contents, and
injected only the five RTV-32 notes.

This worked, but the tester initially checked only the crates on the left after
exiting the tent shelter and missed the selected crate. For future deterministic
smoke tests, include the selected log path and a simple in-game landmark in the
test instruction, for example "nearest military crate on the right/left after
exiting the tent shelter." Keep the helper log lines searchable by ticket id and
include candidate distances so the chosen container can be confirmed quickly.

Reusable pattern:

- Add or enable the ticket-scoped smoke helper only in a local test build.
- Prefer a real container on the target map instead of player inventory spawn.
- Wait until the map is active before spending retry attempts.
- Clear the chosen container's generated loot/storage before injection so the
  smoke items do not compete with the regular loot pool.
- Log candidate paths, distances, display names, and the final injected target.
- Remove the helper again before committing or merging. A disabled `.hook(...)`
  call in source may still be seen by Metro's hook scanner, so keeping disabled
  smoke code in `Main.gd` is not zero-footprint.
