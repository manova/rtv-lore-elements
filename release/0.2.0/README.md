# Lore Elements 0.2.0 corrected source preparation

This local correction follows merged PR #21 and the accepted genuine-save
legacy-placement pass. It is based on merged commit `e0026b7` and is under review
in [PR 22](https://github.com/manova/rtv-lore-elements/pull/22), opened with approval
on 2026-10-13. Normal installation, merge,
tagging and publication remain separately approved actions. No publication date
is set. Vostok Mods is the intended new listing; ModWorkshop remains on hold.

The corrected package retains 115 files. PR review adds bounded restore-only
collision/stack safeguards beyond accepted `0.2.0-legacy-placement.2`; the other
scripts are unchanged. All 99 art/resource/data files remain unchanged. Compared with
the earlier final package, only `Main.gd` and those four documents change.
The earlier package, recipe and normal installation remain untouched.

Version remains `0.2.0` because no 0.2.0 tag or public release existed when this
correction was prepared. The new checksum identifies the corrected archive;
do not overwrite or upload the earlier package by mistake.

## Review entry points

- [Build and verify](../../BUILDING.md): offline allowlist-based packaging.
- [Source verification](SOURCE_VERIFICATION.md): exact rebuild and guard checks.
- [Package manifest](package-manifest.json): every shipped path, hash and ZIP entry.
- [Asset origins](../../art_source/README.md): curated provenance, not a full Blender archive.
- [Final QA summary](../../qa/release_0_2_0/README.md): scope, evidence limits and rollback.
- [Gallery options](GALLERY.md): five unaltered in-game screenshots, not uploads.
- [Save safety](../../SAVE_SAFETY.md): matched-backup rollback, not archive-only downgrade.
- [Legacy placement decision](../../notes/legacy-placement-compatibility.md):
  bounded conversion, protected modern poses and retained ambiguity.

## Deliberately outside this source candidate

Private saves, MSS transactions, gameplay logs, profile launchers, local game
paths, Blender checkpoints, intermediate artwork, extracted game assets, game
binaries, local MCP configuration and the private QA/automation trees are not
included. The selected public QA summaries report earlier results; they do not
pretend the private test harness or proprietary native inputs ship with this repo.
The correction branch starts from the merged public source, excluding the
local-only tooling commit and configuration. Previous preparation and PR
branches remain unchanged.

Before publication, finish GitHub review, obtain merge/tag/release approval and
select the final gallery/cover. Only the approved final source should receive
a release tag, and only the verified VMZ should become a release download.
Source-branch publication is not a mod-release announcement. Neither the old
pre-asset commit nor merged PR #21 alone includes this compatibility correction.
