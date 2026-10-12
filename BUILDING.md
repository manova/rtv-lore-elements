# Building the corrected 0.2.0 package

This checkout contains all 115 source files in the corrected 0.2.0 VMZ, plus
selected documentation, provenance and gallery options. It is not the private
authoring/QA archive. No game installation, saves, Blender, Godot import cache,
network access or optional mod is needed to verify or package these files.

From the repository root, with Python 3.10 or newer:

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
The expected archive is 42,692,690 bytes, SHA256:

```text
fe6bc12f36ace1b802d300261c79acbd4b65bf4ac65b67786351e94e015b5568
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
scripts match the accepted correction candidate. Only the version manifest and
four packaged documentation files differ from that test archive. This does not
authorize installation or publication; see the
[source-release index](release/0.2.0/README.md).

Raw Blender checkpoints, intermediary images, native game extracts, private logs,
userdata, local automation and MCP configuration are deliberately excluded.
Original native assets are referenced at runtime, not distributed here.
See [asset provenance](art_source/README.md), [public QA summary](qa/release_0_2_0/README.md)
and [save safety](SAVE_SAFETY.md).
