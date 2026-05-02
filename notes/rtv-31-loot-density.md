# RTV-31 - Lore note loot density

Date: 2026-05-02

## Measurement

Recovered the current `RTV.pck` with GDRETools and audited vanilla `Loot/LT_Master.tres`
plus `LootContainer.gd` / `LootSimulation.gd`.

Vanilla loot generation does not read `ItemData.value` when building or rolling loot
buckets. `FillBuckets()` filters by `rarity`, matching `civilian` / `industrial` /
`military` flags, and optional `limit` / `exclude`. `GenerateLoot()` then rolls the
matching rarity bucket directly.

Current mod state before tuning:

| Bucket scope | Vanilla common items | Lore common items | Lore roll share |
|---|---:|---:|---:|
| Any ordinary `LT_Master` flags | 102 | 13 | 11.3% |
| Civilian only | 94 | 8 | 7.8% |
| Industrial only | 8 | 5 | 38.5% |
| Military only | 49 | 5 | 9.3% |

Baseline with only the legacy hello note was 1/103 = 1.0% for the all-flags common
bucket, matching the earlier RTV-29 smoke note that observed a 95-entry civilian
common bucket after adding one note.

Single-line ticket answer:

> Lore notes are 11.3% of `LT_Master` all-flags common-bucket rolls; baseline was 1.0%; target is <=3%.

## Decision

Lever A (`value`) will not move the needle because vanilla does not use `value` as
a rarity proxy.

Lever B as written ("single `lore_note_pool` registration that internally rolls one
of N notes") is blocked by Metro's registry contract: `register(Registry.LOOT, ...)`
validates `{ item: ItemData, table: String }` and appends a concrete item resource
to the loot table. It does not accept a proxy/callable item.

The smallest effective data-only tuning lever is to move lore notes from
`Rarity.Common` to `Rarity.Rare`. That removes lore notes from the common bucket
without adding a loot-generation hook, keeps all authored notes in the master table,
and avoids shipping an MCM multiplier before RTV-9.

This does reintroduce the inventory rarity tint concern from RTV-7. For RTV-31, spawn
density is the higher-priority player-facing issue; revisit display tint separately
if rare-colored lore scraps feel misleading in play.

## Compatibility check

Checked the currently installed `BetterEnemyLoot.vmz` and `LootModifier.vmz` before
the test raid.

`Better Enemy Loot` overrides `AI.gd` and adds extra loot to enemy containers by
selecting only `Consumables`, `Medical`, magazines, and ammo. It reads
`container.LT_Master.items`, but it does not select `Lore` items, so it should not
directly increase lore-note drops.

`Loot Modifier` overrides `LootContainer.gd` and `LootSimulation.gd`, then replaces
`GenerateLoot()` with configurable common / rare / legendary chances. It does not
replace `FillBuckets()`, so lore notes still move from `commonBucket` to `rareBucket`
when their `rarity` is changed from `0` to `1`. With the current local MCM config,
container and floor rare chance are both `0.05`, so this tuning still materially
reduces ordinary lore spam under Loot Modifier.

Developer Mode conflict output before reinstall reported `Conflicting resource paths:
0`. The loader does note that Better Enemy Loot uses `overrideScript()` on `AI.gd`
and Loot Modifier uses `overrideScript()` on `LootContainer.gd` / `LootSimulation.gd`,
but Lore Elements does not override those paths.

## Playtest result

After reinstalling the tuned VMZ, a fresh test run took a fair amount of looting
before a note appeared. The player briefly wondered whether Lore Elements was still
active, then found a note. That matches the RTV-31 target: notes are still effective,
but no longer feel guaranteed or spammy.

Future follow-up: consider a dedicated lore-note probability bucket configurable via
MCM, instead of relying only on vanilla rarity buckets.
