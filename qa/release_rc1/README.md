# RC1 compatibility and rollback — public summary

This is a sanitized summary of the accepted 2026-10-11 candidate evidence, not
a copy of private saves, logs, machine-specific test scripts or proprietary game
inputs. Original evidence remains with the maintainer. The RC1 archive SHA256
was `a23103f183cc67699f9914206a23966b17a7399bb110978cf9d266df83fa0e6e`.
The [final 0.2.0 promotion](../release_0_2_0/README.md) changes only version/docs.

## Accepted coverage

- All 18 stable IDs register. The 17 authored notes resolve custom artwork;
  legacy Damaged Field Note remains the native Patient Report control.
- Resource probes cover 96 resources/images/fonts and family-sized inventory
  presentation. Canonical stories, loot and pin fields remain stable. Footprint
  changes retain the agreed value-per-slot policy with nearest-25 rounding.
- Fifteen separate-process save cycles cover fresh native NewGame, an explicit
  synthetic all-18-item public-0.1.1 fixture, retained older saves and the completed
  display-test checkpoint, with Lore alone, MCM and optional private MSS.
  These cycles passed 9,725 assertions, including migration idempotence, item
  identity, inventory neighbors and saved-world resource resolution.
- Ten rollback cases passed 92 assertions. Missing Lore or an archive-only
  downgrade cannot resolve newer saved resources. Matched archive/save restores
  load correctly. Optional MSS rejects the tested incompatible Load before root
  replacement; this does not promise universal corruption recovery.
- Windows cold/restarted/warm menu checks preserve copied saves. Interrupted
  startup coverage is bounded to the tested paths, not a power-loss guarantee.
- Fresh Windows gameplay (Lore only) passed acquisition, reading/journal,
  inventory, checkpoint and full relaunch. The corrected synthetic upgrade
  fixture (Lore + MCM) passed all 18 identities and saved placement/relaunch.
  The initial upgrade fixture lacked Load eligibility and was corrected in a
  new copy before acceptance; it is not represented as a passing first attempt.

Test baseline: Steam build 25837777, Metro 3.4.2, optional MCM 2.9.3 and private
MSS 1.1.14-local-safe.1. MSS is neither bundled nor required. The journal remains
shared across slots in one userdata directory.

## Limits retained

Cold pre-mount missing-resource diagnostics can precede Metro's automatic
restart. Do not enter gameplay in a degraded session. Firm supported placement
is accepted; couches/reclined or unsuitable outdoor surfaces are not guaranteed.
Direct flashlight washout also affects native paper. Rare post-reload jitter
remains a recurrence watch. Loose loot can settle face down under physics;
blank reverses are not missing front textures.

No removal or in-place downgrade is certified safe for upgraded saves.
Use [the matched-backup procedure](../../SAVE_SAFETY.md).
