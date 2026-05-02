# Lore Elements

> Readable notes and environmental storytelling for Road to Vostok.

**Status**: pre-release / scaffold. See [PLANNING.md](PLANNING.md) for the full project plan.

## Quick links

- [Planning document](PLANNING.md) — read first
- [Shared context for the mod set](../rtv-mods-shared-context) — framework primer (or check the parent workspace)
- [Codex agent guide](AGENTS.md) — instructions for AI dev agent

## Dependencies

Metro Mod Loader v3.0+, Mod Configuration Menu (recommended)

## Usage

- Find lore notes through normal loot.
- Right-click a note and choose `Read` to open the paginated reader.
- Press `J` in-game or while inventory is open to view discovered notes in the persistent journal.
- If Mod Configuration Menu is installed, use the `Lore Elements` page to adjust lore note spawn rate or rebind the journal hotkey.

## Development

### Local install (Windows)

```powershell
# From the repo root, after editing.
# mod.txt must remain at archive root; source files live under rtv-lore-elements/
# because mod.txt autoloads res://rtv-lore-elements/Main.gd.
$GameDir = "C:\Program Files (x86)\Steam\steamapps\common\Road to Vostok"
New-Item -ItemType Directory -Force -Path .build\rtv-lore-elements | Out-Null
Copy-Item mod.txt .build\mod.txt -Force
Copy-Item Main.gd, README.md, PLANNING.md, LICENSE, AGENTS.md, SHARED_CONTEXT.md .build\rtv-lore-elements\ -Force
Copy-Item Items, data, assets, notes .build\rtv-lore-elements\ -Recurse -Force
Compress-Archive -Path .build\mod.txt, .build\rtv-lore-elements -DestinationPath rtv_lore_elements.zip -Force
Rename-Item rtv_lore_elements.zip rtv_lore_elements.vmz -Force
New-Item -ItemType Directory -Force -Path "$GameDir\mods" | Out-Null
Copy-Item rtv_lore_elements.vmz "$GameDir\mods\" -Force
```

In Developer Mode the loader also accepts loose folders in the game's `mods\` directory, but the folder contents still need the same package shape: `mod.txt` at root and source files under `rtv-lore-elements\`.

### Logs

- Loader log: `%APPDATA%\Road to Vostok\logs\godot.log`
- Conflicts (Developer Mode only): `%APPDATA%\Road to Vostok\modloader_conflicts.txt`

## License

MIT — see [LICENSE](LICENSE).

Bundled font: Caveat Regular by the Caveat Project Authors, licensed under SIL Open Font License 1.1. See [assets/fonts/OFL.txt](assets/fonts/OFL.txt).
