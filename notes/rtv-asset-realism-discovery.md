# Hamina dispatch — curated origin and integration record

Hamina was the first custom paper family in the asset pass: original scripted
Blender geometry, procedural paper pixels and a selected-object export. The
existing pinned Blender bridge supported reviewed Python-file execution with
Safe Mode on and inline code disabled. Local bridge configuration and the raw
authoring/QA history are outside this public source subset.

The accepted v003 Blender checkpoint SHA256 was
`122cc3cbb6f1466fa9b9f74cb71790664680e90e89836ce800447329880c486d`;
its original selected GLB SHA256 was
`e0fdff304e22f4b1189d42d3de00feea26e541c5e037c8b846fb81ad41b61821`.
Those intermediate files are not distributed here.

The [Godot mesh](../assets/models/hamina_dispatch_mesh.tres) contains 1,004
triangles and has SHA256
`ca0444e83f082f99792bdb6fb1cba1efa351ecc6f7ab40f92e82165eaf8cb3d7`.
The [procedural 512² paper texture](../assets/textures/hamina_dispatch_albedo.png)
has SHA256 `40892b8f349e9e2b26c0850d384f6c83a7b81962738b5be65af37244d811b703`.
Neither derives from an extracted native model or texture. Other folded
identities use a separate split-UV derivative of this mesh and original generated
atlases; Hamina's original pixels remain unchanged.

World scale was increased by 30% during integration. Later iterations replaced
early flat-locking drop experiments with physical collision/settling and bounded
supported display behavior. This origin record is not a specification for those
superseded experiments: the exact accepted implementation is in `Main.gd` and
the [0.2.0 package manifest](../release/0.2.0/package-manifest.json).

Readable Hamina content remains in the reader, not baked onto its paper surface.
See [asset credits](../ASSET_CREDITS.md), [public QA summary](../qa/release_rc1/README.md)
and [save safety](../SAVE_SAFETY.md) for release boundaries.
