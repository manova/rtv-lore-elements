# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

While the project is below 1.0.0, the public API is unstable and minor versions may introduce breaking changes.

## [0.1.0] - 2026-05-03

First public release.

### Added

- **17 hand-authored lore notes** scattered across the zone via existing loot tables. Notes span S-tier narrative pieces (radio transcript, rail manifest) down to incidental flavor (kitchen crayon map, schoolroom list).
- **In-world note reader** - open notes from inventory, multi-page support, ESC/close button to dismiss. Reader is fully modal: mouse and scroll input is consumed by the reader, not passed through to the inventory or world underneath.
- **Map pin renderer** - notes with an authored `pinned_location` render markers on the map. v0.1 ships with a curated pin trail of 5 high-value notes anchored to recognizable landmarks (radio relay, rail depot, etc.). Pins survive save/load.
- **Journal** - opens on a configurable hotkey, lists notes the player has discovered, persists across sessions.
- **MCM (Mod Configuration Menu) integration** - runtime settings for spawn frequency multiplier and journal hotkey. Defaults are tuned for vanilla balance.
- **Localization scaffold** - all player-visible strings route through a single strings file (`data/strings/en.json`). English-only at v0.1; structure is ready for future translations.
- **Note economy tuned for adoption** - note values pegged to roughly 250 euros per slot, matching antiseptic, the most-carried vanilla item, with a 750-1250 euro narrative-weight scatter so notes are worth their 2x2 inventory footprint.
- **Coexistence with Better Maps** - pin layer renders above Better Maps' overlays without depending on or colliding with that mod.

### Compatibility

- **Road to Vostok**: tested against Steam Early Access build available at release time
- **Metro Mod Loader**: requires v3.1.1 or newer
- **Better Maps** (omegacel): compatible - pins render correctly with or without it loaded

### Known limitations

- No user-driven pinning yet - players can't pin or unpin notes themselves. Authored pins on the curated trail are the only pins in v0.1. User-driven pinning is planned for v0.2 ([RTV-44](https://linear.app/rtv-mods/issue/RTV-44)).
- No public API for other mods to register their own lore notes. Planned for v0.2 ([RTV-46](https://linear.app/rtv-mods/issue/RTV-46)).
- Note item meshes use placeholder visuals. A pass on asset realism is planned for v0.2 ([RTV-37](https://linear.app/rtv-mods/issue/RTV-37)).

### Credits

- Authored, designed, and maintained by Andrew Okoh
- Built with assistance from Codex (code execution) and Perplexity Computer (product, design, planning)
- Thanks to the Road to Vostok modding community on ModWorkshop

[0.1.0]: https://github.com/manova/rtv-lore-elements/releases/tag/v0.1.0
