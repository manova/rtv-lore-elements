# RTV-29 natural loot verification

Date: 2026-05-01

## Result

RTV-29 passed. `Damaged Field Note` was verified through a real loot container path with the temporary deterministic smoke helper active, then transferred into inventory and read successfully.

## Test method

The temporary smoke build was packaged and installed as `rtv_lore_elements.vmz`. The helper hooked `lootcontainer-_ready-post`, checked the first ordinary `LT_Master` container with an eligible bucket, and injected `rtv_lore_hello_note` once only after proving that the note was present in that container's generated common bucket.

The helper selected:

```text
/root/Map/Content/Buildings/Barn_Village_A/Props/NM/Corpse_Bandit_Ledge_C
```

In game this appeared as a `Bandit Corpse` in `Barn_Village_A`.

## Log evidence

Relevant loader and registry lines from `user://logs/godot.log`:

```text
[rtv_lore_elements] registered interface-use reader hook.
[rtv_lore_elements][RTV-29] smoke hook registered for lootcontainer-_ready-post.
[ModLoader][Debug] [Registry] registered item 'rtv_lore_hello_note'
[ModLoader][Debug] [Registry] registered scene 'rtv_lore_hello_note'
[ModLoader][Debug] [Registry] registered loot 'rtv_lore_hello_note_in_master' (LT_Master -> rtv_lore_hello_note)
[rtv_lore_elements][RTV-29] natural-loot smoke proof path=/root/Map/Content/Buildings/Barn_Village_A/Props/NM/Corpse_Bandit_Ledge_C name=Bandit Corpse bucket_match=true forced=true loot_count=2 common_bucket=95
```

No relevant Lore Elements hook, registry, scene, resource, or loot errors appeared in the log. The visible errors during this run were pre-existing unrelated mod warnings/errors such as duplicate MCM input actions and `/root/Map/AI` lookup noise.

## Manual acceptance

- `Damaged Field Note` appeared in the selected `Bandit Corpse` container.
- The note was transferred into the player inventory.
- The inventory context action showed `Read`.
- `Read` opened the note reader modal.
- Closing the modal with the close button returned to inventory and the note remained in inventory.

One follow-up polish observation: pressing Escape while the note reader is open closes both the note modal and the inventory. This is outside RTV-29's acceptance criteria.

## Cleanup

The temporary RTV-29 smoke hook and force flag were removed after verification. No permanent hook, registry id, item data, or public API change was kept for this ticket.
