# Lore Elements

> Readable notes and environmental storytelling for Road to Vostok.

**Status**: pre-release / scaffold. See [PLANNING.md](PLANNING.md) for the full project plan.

## Quick links

- [Planning document](PLANNING.md) — read first
- [Shared context for the mod set](../rtv-mods-shared-context) — framework primer (or check the parent workspace)
- [Codex agent guide](AGENTS.md) — instructions for AI dev agent

## Dependencies

Metro Mod Loader v3.0+, Mod Configuration Menu (recommended)

## Development

### Local install (Windows)

```powershell
# From the repo root, after editing
Compress-Archive -Path mod.txt, Main.gd, * -DestinationPath rtv_lore_elements.zip
Rename-Item rtv_lore_elements.zip rtv_lore_elements.vmz -Force
Copy-Item rtv_lore_elements.vmz "$env:APPDATA\Road to Vostok\mods\" -Force
```

Or simply place the unzipped repo directory at `%APPDATA%\Road to Vostok\mods\rtv-lore-elements\` — the loader accepts both.

### Logs

- Loader log: `%APPDATA%\Road to Vostok\modloader.log`
- Conflicts (Developer Mode only): `%APPDATA%\Road to Vostok\modloader_conflicts.txt`

## License

MIT — see [LICENSE](LICENSE).
