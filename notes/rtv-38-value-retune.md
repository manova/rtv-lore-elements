# RTV-38 Value Retune

RTV-38 retunes lore notes for the 0.1 release economy pass. The benchmark is
vanilla antiseptic at 250 value per inventory slot. Lore notes all use a 2x2
footprint, so the new values sit in a 750-1250 band: slightly below antiseptic
VPS for humble notes, exactly at the benchmark for mid-tier notes, and slightly
above it for high-signal narrative or technical finds.

## Values

| Note ID | Value | VPS |
| --- | ---: | ---: |
| `rtv_lore_radio_transcript` | 1250 | 312.5 |
| `rtv_lore_rail_manifest` | 1250 | 312.5 |
| `rtv_lore_forest_cache_note` | 1175 | 293.75 |
| `rtv_lore_smuggler_ledger` | 1175 | 293.75 |
| `rtv_lore_border_shift_log` | 1100 | 275 |
| `rtv_lore_guard_three_lines` | 1100 | 275 |
| `rtv_lore_patrol_warning` | 1100 | 275 |
| `rtv_lore_clinic_triage_card` | 1000 | 250 |
| `rtv_lore_hamina_last_shift` | 1000 | 250 |
| `rtv_lore_evacuation_notice` | 925 | 231.25 |
| `rtv_lore_triage_unknown_male` | 875 | 218.75 |
| `rtv_lore_last_letter_leena` | 825 | 206.25 |
| `rtv_lore_letter_tampere` | 825 | 206.25 |
| `rtv_lore_schoolroom_list` | 825 | 206.25 |
| `rtv_lore_weathered_recipe` | 825 | 206.25 |
| `rtv_lore_posted_orders_layered` | 800 | 200 |
| `rtv_lore_child_kitchen_map` | 750 | 187.5 |

## Non-changes

Weight remains `0.05`, footprint remains `Vector2(2, 2)`, rarity and loot
flags remain unchanged, and RTV-33 spawn multiplier behavior is untouched.
The legacy damaged field note is not retuned because it is not one of the
production note resources and is not registered into loot.
