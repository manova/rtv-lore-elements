# Curated source verification

## Publication and final acceptance status

PR #22 was merged as `3cf6672d6526927d599e41a85f9e8b1dd8898105` on
2026-10-13. [GitHub v0.2.0](https://github.com/manova/rtv-lore-elements/releases/tag/v0.2.0)
was published on 2026-10-14 at 00:33:12 UTC with the reviewed archive below.
Before merge, that exact package passed focused isolated Windows slot 2 testing
and full relaunch on 2026-10-13. See the
[final-package acceptance and provenance](../../qa/release_0_2_0/final-package-windows.md)
for scope, dates and local evidence hashes.

The preparation checkpoints and source-file counts below are historical. They
describe their respective source/package verification runs, which did not
themselves run new Windows gameplay. Post-publication documentation differs
from the frozen bundled prose; use the
[frozen-source checkout instructions](../../BUILDING.md) for exact reproduction.

## PR review correction

The 2026-10-13 review follow-up keeps temporary collision exclusions limited to
pending invalid candidates, validates the final world and rolls back conflicts
and dependent stack layers. It also handles intermediate stack gaps while
preserving settled modern displays. No artwork, collider dimensions or ordinary
drop behavior changes. Only Main.gd, changelog and release notes differ from the
pre-review package below.

The reviewed archive has 115 files in 130 ZIP entries and is 42,693,560 bytes:

```text
4e77629bcbb5f3556a42bb44b2a39d77fa4b4d18294bae1bda00896ad3d5ded5
```

The clean source export reproduces it exactly and passes all eleven packaging
guard tests. The frozen reviewed source has 184 files; the added file preserves the
[pre-review package recipe](history/pre-review-package-manifest.json).
[QA](../../qa/release_0_2_0/README.md) distinguishes earlier-package Windows
gameplay, the offline/native review regressions and the subsequent exact-package
Windows slot 2/relaunch acceptance. Merge and GitHub publication subsequently
completed as recorded above; this does not establish broad normal-play coverage
or another distribution platform's current status.

## Pre-review package checkpoint

Prepared on 2026-10-12 from merged PR #21 plus the exact accepted
`0.2.0-legacy-placement.2` runtime. No additional physics changes are included.
All 99 art/resource/data files and the other two scripts are unchanged from
the earlier final package. Only `Main.gd` and four packaged documents differ.

The corrected archive has 115 files in 130 ZIP entries and is 42,692,690 bytes:

```text
fe6bc12f36ace1b802d300261c79acbd4b65bf4ac65b67786351e94e015b5568
```

The explicit package recipe and all eleven packaging guard tests pass. A clean
export of the staged source tree reproduces the corrected VMZ byte-for-byte.
All 183 source paths pass the machine-path/private-fixture audit; changed text
uses LF endings, and the changed Markdown links resolve within the source tree.
The runtime delta is one existing restore function plus two bounded helpers;
all three packaged scripts are byte-identical to the accepted test candidate.
The
earlier recipe is retained in [history](history/pre-legacy-package-manifest.json).
The corrected native and genuine-save evidence is summarized in
[QA](../../qa/release_0_2_0/README.md). GitHub review and publication were still
pending at this checkpoint; the later completed status is recorded above.

## Earlier package checkpoint

Prepared locally on 2026-10-11 from the accepted final 0.2.0 source allowlist.
This is source/package verification, not a new game session or mod publication.
On 2026-10-12 the release commit was carried onto upstream `main` for the approved
GitHub PR, retaining the exact original source tree while leaving out a local-only
MCP setup commit. At that checkpoint, PR-status documentation changes were outside
the 115 frozen package inputs; the original preparation branch is retained.

- All 115 packaged source files match the frozen archive's SHA256 manifest.
- The standalone source builder reproduces all 130 ZIP entries (115 files and
  15 directory entries), including order and metadata, byte-for-byte.
- Rebuilt VMZ: 42,690,266 bytes; SHA256
  `49121927608f0498fb76008983a77e013c71709526bd33e991ce1a5a29492b7b`.
- Verification toolchain: Python 3.10.12, zlib build/runtime 1.2.11.
- Eleven isolated packaging tests pass: exact rebuild, ambient-file exclusion,
  source drift/missing source, output overwrite refusal, source symlink rejection,
  duplicate members, parent/absolute paths, extra archive members and wrong final
  archive hash. None requires native game data or writes live userdata.

The source subset also includes five byte-identical gallery candidates, selected
origin records/prompts, licenses, existing public contribution/issue files and
sanitized QA summaries. Workstation configuration is excluded from this tree;
Git history is not rewritten. Raw authoring files and private operational evidence
remain in the original working checkout.

Run [the documented commands](../../BUILDING.md) to repeat corrected-package verification.
The integration/playtest assertion counts in the public QA summaries are
historical evidence, not results of these packaging tests.
