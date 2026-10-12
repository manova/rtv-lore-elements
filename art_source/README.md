# Curated asset source records

This directory contains selected, sanitized origin records and exact image
prompts for the 0.2.0 document families. Runtime geometry, artwork, inventory
scenes and portable resources live in `assets/` and `Items/`; all shipped bytes
are pinned in [the package manifest](../release/0.2.0/package-manifest.json).

It is not the complete authoring archive. Raw `.blend` checkpoints, GLB
intermediates, duplicate atlas copies, render evidence and local execution
scripts are deliberately omitted. JSON summaries retain origin hashes and
generation decisions while removing workstation paths and private QA links.
Historical creation-stage wording describes that stage, not current release
acceptance. The [final QA summary](../qa/release_0_2_0/README.md) covers acceptance.

## Families and prompt records

- [Hamina dispatch](../notes/rtv-asset-realism-discovery.md): original scripted
  Blender geometry and procedural paper pixels, not a repainted native asset.
- [Folded documents](folded_documents/provenance-v001.json): four original atlases,
  [generation prompts](folded_documents/prompts-v001.json), and a UV-only derivative
  of Hamina's original geometry.
- [Notebook surface](notebook_page/provenance.md) and
  [optimized mesh](notebook_page/export-handoff-v001.md): a shared ruled atlas
  and a closed torn-page mesh.
- [Blank triage stock](triage_card/provenance-v001.json) and
  [inked identities](triage_card/identity-provenance-v001.json), with
  [base edit prompts](triage_card/identity-prompts-v001.json). The raw blank-stock
  atlas is not duplicated here; the runtime reader uses a derived stock texture.
- [Evacuation sheet](report_sheet/provenance-v001.json), its
  [prompt](report_sheet/evacuation-prompt-v001.txt), and
  [five additional sheet identities](report_sheet/identities-v001/provenance.json).
  Each additional identity's exact `*-prompt.txt` is beside that record.
- [Crayon Map](crayon_map/provenance-v001.json) and
  [prompt](crayon_map/prompt-v001.txt): original drawing and folded-sheet geometry.

Image-generation prompts are historical production inputs, not commands for
repository contributors. AI-generated outputs are not reproducible from prompts
alone; the exact selected runtime images are included and hashed. Origin records
describe the workflow, not exclusive authorship or a new license grant.

The canonical story stays in `data/notes.json` and the reader. Small surface
excerpts, unreadable notebook marks and the child's approximate house drawing
are not new narrative or navigation claims. Geometry and material integration
provide folds, thickness and lighting response rather than replacing readable text.

Original native Patient Report geometry/textures are not included. That asset
remains an installed-game runtime reference for Damaged Field Note and fallback
presentation. Font notices and the existing license split remain as described
in [asset credits](../ASSET_CREDITS.md).
