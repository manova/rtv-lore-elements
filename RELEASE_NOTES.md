# Lore Elements 0.2.0 release notes

Version `0.2.0` was [published on GitHub](https://github.com/manova/rtv-lore-elements/releases/tag/v0.2.0) on
2026-10-14 (UTC), with the legacy-placement correction
accepted on 2026-10-12 and bounded restore safeguards added during PR review.
Retained/repaired notes remain collision obstacles, final conflicts roll back,
and connected stacks handle intermediate gaps without changing settled displays.
Artwork, readers and story content remain unchanged from the asset-pass release.
The published VMZ matches the final reviewed 115-file artifact (42,693,560 bytes),
SHA-256 `4e77629bcbb5f3556a42bb44b2a39d77fa4b4d18294bae1bda00896ad3d5ded5`.
The exact package passed focused isolated Windows slot 2 testing and full
relaunch on 2026-10-13. This does not establish broad normal-play coverage.
The current ModWorkshop version has not been independently verified.

## Included

The 17 authored notes now use original folded, notebook, card, sheet or crayon-map
art, with family-sized inventory presentation and styled readers. Damaged Field
Note remains the native Patient Report control. Stable IDs, story pages and
authored map-pin meaning remain unchanged. Smaller footprints retain the agreed
narrative value-per-slot balance, with nearest-25 rounding.

Custom papers can be rotated upright and propped on suitable firm supports.
Wall-safe preview retains rotation intent while blocked. Ordinary drops remain
physical; the mod does not pin papers to furniture or change native item physics.

Eligible notes placed by older versions are reoriented on shelter load when the
old mesh coordinates would embed the new paper in its support. The repair is
bounded and saved by the ordinary checkpoint; it does not rewrite save scripts
or rotate every unmarked item. Ambiguous older poses remain unchanged.

## Compatibility boundary

This version was tested with Road to Vostok `0.2.1.0`, Steam build `25837777`, and Metro `3.4.2`.
MCM `2.9.3` is optional. MSS `1.1.14-local-safe.1` is a separately tested private
integration, not a bundled dependency or a guarantee for other MSS versions.
The Lore journal is shared across a userdata directory, not isolated per MSS slot.

Use a new isolated setup with only one Lore archive enabled. The public mod ID
is retained as `rtv_lore_elements`; test archives can use different IDs or version
keys, so explicitly disable them. This release's Metro profile key
is `rtv_lore_elements@0.2.0`.

## Completed acceptance

The accepted candidate passed Windows fresh-game and older-save upgrade
playthroughs, including reading, journal and inventory checks, saved world items
and persistence after a full quit and relaunch. Fresh gameplay used Lore alone;
the upgrade used MCM without requiring MSS. The all-18-item public-era upgrade
fixture was synthetic. A subsequent focused pass exercised three genuine older
playthroughs with the correction candidate and private MSS: existing notes,
inventory/storage, readers, placement, slot isolation and full-relaunch
persistence passed. This is bounded evidence, not a guarantee for every save.

The subsequent review safeguards passed targeted offline/native regressions.
The exact reviewed package then passed a focused Windows check from an isolated
original slot 2 seed: five restored Tent notes, interaction/repositioning,
checkpoint persistence and full relaunch. The closed-game audit records nine
committed private-MSS transactions and three exact Loads, with unchanged Lore
counts and no repeat legacy repair after relaunch. See the
[final-package acceptance and provenance](qa/release_0_2_0/final-package-windows.md).
These narrow checks supplement the earlier gameplay baseline; they do not rerun
the full fresh-game/three-save matrix on the final package or certify public MSS.

Compatibility checks cover resource loading, all 18 item identities, inventory
migration, repeated save/reload, interrupted startup and matching-backup rollback.
Removing Lore or downgrading only its archive is not a safe rollback. Read
[save safety](SAVE_SAFETY.md) before adopting the update.

The source checkout retains the candidate evidence in `qa/release_rc1/README.md`
and final-package verification in `qa/release_0_2_0/README.md`. Preparing the final
package was a preparation step; the subsequent GitHub publication does not extend
the recorded testing scope. Documents bundled in the VMZ and attached to the
release remain frozen with their preparation-time wording; these repository
notes correct publication status without replacing the package.

## Known limitations

- A cold Metro bootstrap can validate saves before Lore mounts, producing
  missing-resource errors before the automatic restart. Do not load in a
  degraded/crash-breaker session. See [save safety](SAVE_SAFETY.md).
- Cushioned or reclined couch surfaces can let propped papers tip forward.
  Firm near-level bases and near-vertical backings are the supported display case.
- Direct flashlight highlights can wash out paper, including the native Patient
  Report control. Accepted material tints remain unchanged.
- Rare settling jitter remains a watch item. One Crayon Map stool drop jittered,
  stopped after reload and did not recur during the remaining test. Capture a
  short clip if it returns; no loss was reported in that case.
- Conservative legacy-pose handling can leave an older note upright. One such
  presentation was retained in the genuine-save pass; not every old pose is
  automatically flattened or visually certified.
- Found loose papers may settle face down, showing their intentionally blank
  reverse. They are not forced into a face-up resting pose.

No additional story content, journal redesign, user-created map pins, standalone
placement mod or public lore API is part of this cut.
