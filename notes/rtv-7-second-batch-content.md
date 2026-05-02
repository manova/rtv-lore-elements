# RTV-7 — Second Batch (Smuggler's Ledger + Letter from Tampere)

## Scope

Two additional authored notes added to `data/notes.json`, bringing the total to 12.
Both notes were drafted from starter ideas seeded in the lore-bible Notion database
and ran through the 18-question found-doc-craft checklist before merging.

## Notes added

| ID | Name | Voice | Placement (loot flags) |
|---|---|---|---|
| `rtv_lore_smuggler_ledger` | Smuggler's Ledger | Smuggler (paranoid, fragmented) | industrial only |
| `rtv_lore_letter_tampere` | Letter from Tampere | Elder mother (tender) | civilian only |

## Content rationale

These notes target two voice gaps in the original 10:

- **Smuggler-perspective scrap.** The first batch covered border guards, dispatchers,
  patrols, and clinic staff but had no shadow-economy voice. Run 14 establishes the
  smuggler register and triangulates the Bandits / foreign Guards / civilian
  cross-border traffic implied by canon, without naming the Guards' nationality
  or any canonical NPC.
- **Outside-the-zone civilian voice.** The original civilian letters all came from
  inside Area 05. The Tampere letter widens the world by giving us a voice writing
  *into* the zone from a city the catastrophe hasn't reached. Anchors the player's
  awareness that there are people still waiting on the other side of an evacuation.

## Canon guardrails honored

- No traders named (Generalist / Doctor / Gunsmith remain titles only).
- No Transmission resolution.
- No Finnish-state forces in zone (the Guards remain "the man at the gate who
  isn't from here").
- No supernatural or sci-fi tropes.

## Loot placement decisions

- **Smuggler's Ledger:** `industrial = true` only. Naturally fits warehouses, freight
  yards, vehicle compartments, the back rooms of trader stalls — not bedrooms, not
  army crates.
- **Letter from Tampere:** `civilian = true` only. Apartments, abandoned homes,
  jacket pockets — domestic-only.

Rarity locked at common (`0`) per the RTV-7 PR #5 normalization decision; mixed
rarities created an inadvertent loot-quality hierarchy among lore scraps.

## Format conformance

- Two pages each, 50–80 words per page, matching PR #5 conventions.
- Plain text only. The reader runs `RichTextLabel.bbcode_enabled = false`, so no
  markup or strikethrough characters are used — the smuggler note communicates
  the "scratched-out name" beat with sentence-level self-correction
  ("The third one — no.") instead.
- Unicode characters (€, ₽, —, ä) render as literal text and are safe to ship.
