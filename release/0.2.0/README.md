# Lore Elements 0.2.0 source preparation

This is the curated source candidate for the accepted asset-pass release.
The branch push and GitHub PR are authorized as of 2026-10-12. Review and merge
remain ahead; a release tag, GitHub release assets and publication on Vostok Mods
or ModWorkshop remain separate actions. No publication date is set.

The 115 packaged files are byte-identical to the frozen final VMZ. Its three
GDScripts and 99 art/resource/data files are unchanged from accepted RC1. The
root README, changelog and release notes intentionally retain packaging-time
wording. Subsequently, backed-up normal installation with Metro 3.4.2, normal
Load 5 and shared-journal access passed; that does not imply publication or a
new normal-play acquisition test.

## Review entry points

- [Build and verify](../../BUILDING.md): offline allowlist-based packaging.
- [Source verification](SOURCE_VERIFICATION.md): exact rebuild and guard checks.
- [Package manifest](package-manifest.json): every shipped path, hash and ZIP entry.
- [Asset origins](../../art_source/README.md): curated provenance, not a full Blender archive.
- [Final QA summary](../../qa/release_0_2_0/README.md): scope, evidence limits and rollback.
- [Gallery options](GALLERY.md): five unaltered in-game screenshots, not uploads.
- [Save safety](../../SAVE_SAFETY.md): matched-backup rollback, not archive-only downgrade.

## Deliberately outside this source candidate

Private saves, MSS transactions, gameplay logs, profile launchers, local game
paths, Blender checkpoints, intermediate artwork, extracted game assets, game
binaries, local MCP configuration and the private QA/automation trees are not
included. The selected public QA summaries report earlier results; they do not
pretend the private test harness or proprietary native inputs ship with this repo.
The PR branch starts from upstream `main`, excluding the local-only tooling
commit from its ancestry as well as excluding configuration from the file tree.
The original local preparation branch is retained unchanged.

Before publication, finish GitHub review, obtain merge/tag/release approval and
select the final gallery/cover. Only the approved final source should receive
a release tag, and only the verified VMZ should become a release download.
Source-branch publication through this PR is not a mod-release announcement.
A tag on the old pre-asset-pass commit would not describe 0.2.0.
