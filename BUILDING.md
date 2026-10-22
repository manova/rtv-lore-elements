# Building the corrected 0.2.0 package

This checkout contains all 115 source files in the corrected 0.2.0 VMZ, plus
selected documentation, provenance and gallery options. It is not the private
authoring/QA archive. No game installation, saves, Blender, Godot import cache,
network access or optional mod is needed to verify or package these files.

The current branch includes post-publication documentation corrections. The
manifest intentionally hashes the original bundled prose, so verify/rebuild in a
separate checkout of the frozen release source, not this updated working tree.
With Git and Python 3.10 or newer:

```sh
git worktree add --detach ../lore-elements-v0.2.0 3cf6672d6526927d599e41a85f9e8b1dd8898105
cd ../lore-elements-v0.2.0
```

Then run from that checkout:

```sh
python3 tools/package_release.py
python3 -m unittest discover -s tools -p 'test_package_release.py' -v
python3 tools/package_release.py --output build/rtv_lore_elements-0.2.0.vmz
python3 tools/package_release.py --verify-archive build/rtv_lore_elements-0.2.0.vmz
```

The first command checks source hashes without writing anything. The builder
reads only [the explicit package manifest](release/0.2.0/package-manifest.json),
preserves archive order and metadata, verifies the result, and refuses an
existing output. Files elsewhere in the checkout never enter the package.
The expected archive is 42,693,560 bytes, SHA256:

```text
4e77629bcbb5f3556a42bb44b2a39d77fa4b4d18294bae1bda00896ad3d5ded5
```

Different zlib implementations may produce different DEFLATE bytes. In that
case the tool rejects the result even if every uncompressed file matches. Do
not relabel it as the frozen artifact. The verified authoring toolchain is
recorded in [source verification](release/0.2.0/SOURCE_VERIFICATION.md).

## Development and release boundaries

This is a frozen-release verifier, not an automatic manifest updater. A deliberate
runtime edit will fail its hash checks. Future versions need a separate reviewed
manifest and fresh compatibility tests; do not overwrite the accepted record.
Gameplay still requires a separately owned Road to Vostok installation and the
tested Metro loader. Packaging tests do not replace native or in-game QA.

The corrected recipe supersedes the unpublished pre-legacy package. Its
[previous manifest](release/0.2.0/history/pre-legacy-package-manifest.json) and
earlier source remain recoverable; do not confuse the two checksums. All runtime
scripts preserve the accepted correction except for the bounded restore
safeguards added during PR review. The recipe retains separate historical
pre-legacy and [pre-review](release/0.2.0/history/pre-review-package-manifest.json)
manifests. GitHub publication completed on 2026-10-14 (UTC); this recipe does
not establish additional gameplay testing or other platform publication. See the
[source-release index](release/0.2.0/README.md).

Raw Blender checkpoints, intermediary images, native game extracts, private logs,
userdata, local automation and MCP configuration are deliberately excluded.
Original native assets are referenced at runtime, not distributed here.
See [asset provenance](art_source/README.md), [public QA summary](qa/release_0_2_0/README.md)
and [save safety](SAVE_SAFETY.md).
