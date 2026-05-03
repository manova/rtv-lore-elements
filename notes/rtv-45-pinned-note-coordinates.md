# RTV-45 Pinned Note Coordinates

RTV-45 authors a sparse set of production note pins for the v0.1 release. The
goal is to exercise the RTV-36 map pin renderer with real content while keeping
the map readable and the smoke test practical.

## Area 05-first choice

Pins stay in the Area 05 / early-route neighborhood: Outpost, Highway, School,
Village, and the Hamina/Fredrikshamn freight area. This keeps QA reachable from
the current test save and avoids implying a full-world trail before v0.2 user
pinning work.

## Coordinate source

Coordinates are authored in map-pixel space against
`res://UI/Sprites/World_Map.png`, which is `3840x2160`. The vanilla
`res://UI/Elements/Map.tscn` markers provide confirmed anchor points for
Village, Highway, School, and Outpost. Hamina Freight Yard is a visual authored
estimate from the same map texture.

| Note ID | Pin label | Coordinate |
| --- | --- | --- |
| `rtv_lore_radio_transcript` | Radio Transcript | `{ "x": 2463, "y": 1123 }` |
| `rtv_lore_rail_manifest` | Rail Manifest Fragment | `{ "x": 1548, "y": 1030 }` |
| `rtv_lore_schoolroom_list` | Schoolroom List | `{ "x": 1376, "y": 994 }` |
| `rtv_lore_child_kitchen_map` | Crayon Map | `{ "x": 1248, "y": 1123 }` |
| `rtv_lore_posted_orders_layered` | Posted Orders | `{ "x": 1248, "y": 930 }` |

Pins render only after the corresponding note is discovered through the
existing journal persistence path. RTV-45 does not add fixed-world note spawns,
proximity discovery, a separate pin save file, or renderer behavior changes.
The pin label intentionally falls back to the note title so the map points back
to the discovered journal entry rather than naming the underlying landmark.
