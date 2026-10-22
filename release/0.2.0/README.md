# Lore Elements 0.2.0 source and publication record

## GitHub publication status

[GitHub v0.2.0](https://github.com/manova/rtv-lore-elements/releases/tag/v0.2.0) was published as a non-draft release
on 2026-10-14 at 00:33:12 UTC, from merged commit `3cf6672` (PR #22).
The published `rtv_lore_elements-0.2.0.vmz` asset reports 42,693,560 bytes and
SHA-256 `4e77629bcbb5f3556a42bb44b2a39d77fa4b4d18294bae1bda00896ad3d5ded5`,
matching the final reviewed 115-file artifact below. That exact package passed
focused isolated Windows slot 2 testing and full relaunch on 2026-10-13; see the
[acceptance and provenance record](../../qa/release_0_2_0/final-package-windows.md).
This is narrow final-package coverage, not broad normal-play testing. The current
ModWorkshop version has not been independently verified.

The sections below retain historical package-specific evidence. Earlier Windows
acceptance and normal adoption must not be attributed to the later review fix.
Bundled and attached release documents retain preparation-time wording; the VMZ,
its checksum and historical package manifests are unchanged.

The corrected package retains 115 files. PR review adds bounded restore-only
collision/stack safeguards beyond accepted `0.2.0-legacy-placement.2`; the other
scripts are unchanged. All 99 art/resource/data files remain unchanged. Compared with
the earlier final package, only `Main.gd` and four packaged documents change
(`README.md`, `CHANGELOG.md`, `RELEASE_NOTES.md` and `SAVE_SAFETY.md`).
The earlier package and recipe remain historical evidence; earlier normal
installation is not evidence of adoption of the later reviewed package.

Version remains `0.2.0` because no 0.2.0 tag or public release existed when this
correction was prepared. The new checksum identifies the corrected archive;
the published asset matches the final reviewed checksum, not an earlier package.

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

The preparation-time review/publication gates above are historical. PR #22's
merged source is the release source; merged PR #21 alone lacks the compatibility
correction. No new platform publication or gallery change is established here.
