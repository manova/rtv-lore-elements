# Contributing

Thanks for helping make Lore Elements better.

For the frozen 0.2.0 source and offline packaging checks, see [BUILDING.md](BUILDING.md).
The curated repository does not include private save fixtures, game extracts or
raw Blender checkpoints. Do not add those, local MCP settings or gameplay logs
to a public pull request. A changed runtime needs fresh integration QA, not only
a successful package build.

Please open an issue before starting non-trivial work. Trivial fixes may go
straight to a pull request: typo fixes, broken-link fixes, or a single-string
copy edit that does not change lore meaning or gameplay behavior.

Anything else should start with an issue so we can agree on scope first. Pull
requests that touch `data/notes.json` or `Items/Lore/Notes/*.tres` always need
issue-first discussion, regardless of size, because authored lore has to stay
coherent in tone and placement.

When reporting bugs, include your Road to Vostok build, Metro Mod Loader
version, installed related mods, reproduction steps, and any relevant
`godot.log` lines.
