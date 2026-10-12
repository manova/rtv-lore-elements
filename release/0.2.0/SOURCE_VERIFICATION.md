# Curated source verification

Prepared locally on 2026-10-11 from the accepted final 0.2.0 source allowlist.
This is source/package verification, not a new game session or mod publication.
On 2026-10-12 the release commit was carried onto upstream `main` for the approved
GitHub PR, retaining the exact original source tree while leaving out a local-only
MCP setup commit. Subsequent PR-status documentation changes are outside the
115 frozen package inputs; the original preparation branch is retained.

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

Run [the documented commands](../../BUILDING.md) to repeat packaging verification.
The integration/playtest assertion counts in the public QA summaries are
historical evidence, not results of these packaging tests.
