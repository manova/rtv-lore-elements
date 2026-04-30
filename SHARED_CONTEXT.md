# Shared context for all Road to Vostok mod projects

This file captures research and conventions that apply to **every** mod in this set. Each project's `PLANNING.md` cross-references this. Read this first.

## The game and its modding ecosystem

- **Road to Vostok** is a single-player extraction-survival shooter built on Godot 4.6.
- **Build 1** launched April 7, 2026. Roadmap on [roadtovostok.com/game](https://roadtovostok.com/game).
- **Modding hub**: [ModWorkshop — Road to Vostok](https://modworkshop.net/g/roadtovostok). ~351 mods as of April 2026.
- **Modding framework**: [Metro Mod Loader](https://github.com/ametrocavich/vostok-mod-loader) v3.1.1, MIT licensed. Replaces the original `--main-pack` injector that broke in current builds.
- **MCM (Mod Configuration Menu)** is the de-facto config-UI standard. Configs live at `%APPDATA%/Road to Vostok/MCM/<mod_id>/config.ini` on Windows.

## How Metro Mod Loader works (mental model)

Metro Mod Loader is registered via `override.cfg` as a Godot `autoload_prepend` — it runs before any vanilla code. At boot it:

1. Scans `mods/` for `.vmz` / `.zip` archives.
2. Reads each mod's `mod.txt` and scans the mod's `.gd` source for `_lib.hook(...)` calls and `lib.register(...)` calls.
3. The union of those triggers becomes the **wrap surface** — the set of vanilla scripts and methods that get rewritten with dispatch wrappers.
4. Vanilla `.gdc` bytecode is detokenized → source rewritten with method renamed to `_rtv_vanilla_<name>` + a dispatch wrapper that fires registered hooks → repacked into `user://modloader_hooks/framework_pack.zip`.
5. Pack is mounted via `ProjectSettings.load_resource_pack()` with `replace_files=true`.

If no mod opts in (no `.hook()`, no `[hooks]`, no `[registry]`), pack generation is skipped and vanilla runs byte-identical.

## The two APIs you'll use

### Hook API — for behavioral changes

Reach via `Engine.get_meta("RTVModLib")`. Hook names are `<scriptname>-<methodname>[-pre|-post|-callback]`, all lowercase.

| Suffix | Fires | Notes |
|---|---|---|
| `-pre` | Before vanilla body | Same args as vanilla; return ignored |
| (none) | **Replaces** vanilla | **Single-owner**, first registration wins (`hook()` returns `-1` if rejected). Call `_lib.skip_super()` to suppress vanilla |
| `-post` | After vanilla | Same args; return ignored |
| `-callback` | Deferred via `call_deferred()` | Use for async work |

**Inside a hook, `_lib._caller` is the vanilla object instance.** That's how you access fields/methods on the calling object.

**Auto-enrollment**: If your mod's source contains `_lib.hook("controller-jump-pre", ...)`, the loader scans that string and automatically enrolls `Controller.gd::jump` for wrapping. **You don't need a `[hooks]` section in `mod.txt`** for the common case.

### Registry API — for content/data changes

Opt in by adding `[registry]` to `mod.txt` (empty section is enough). Then:

```gdscript
var lib = Engine.get_meta("RTVModLib")
await lib.frameworks_ready
lib.register(lib.Registry.LOOT, "my_handle", {...})
lib.override(lib.Registry.ITEMS, "Potato", new_resource)
lib.patch(lib.Registry.ITEMS, "Potato", {"weight": 0.1})
lib.remove(lib.Registry.LOOT, "my_handle")
lib.revert(lib.Registry.ITEMS, "Potato")
```

**Registries available** (full docs: [Registry.md](https://github.com/ametrocavich/vostok-mod-loader/blob/main/docs/wiki/Registry.md)):

| Constant | What it modifies |
|---|---|
| `SCENES` | Scene constants on Database.gd |
| `ITEMS` | ItemData .tres entries |
| `LOOT` | LootTable.items arrays |
| `SOUNDS` | AudioLibrary @export fields |
| `RECIPES` | Recipes.tres category arrays |
| `EVENTS` | Events.tres events |
| `TRADER_POOLS` | Per-item trader boolean flags |
| `TRADER_TASKS` | TraderData.tasks arrays |
| `INPUTS` | InputMap actions |
| `SCENE_PATHS` | Named scene lookups on Loader.gd |
| `SHELTERS` | Loader.shelters list |
| `RANDOM_SCENES` | Loader.randomScenes list |
| `AI_TYPES` | Zone → agent scene overrides |
| `FISH_SPECIES` | FishPool extras |
| `RESOURCES` | Patch arbitrary .tres by absolute path |

**Critical timing**: register inside your mod's `_ready()`, BEFORE vanilla systems init their caches. `LootContainer`, `LootSimulation`, and traders all snapshot `LootTable` on their own `_ready()`. After that snapshot, registry mutations don't reach the cached copies.

## Standard mod skeleton

```
my-mod/
├── mod.txt
├── Main.gd
├── README.md
└── (your scripts / .tres files)
```

`mod.txt`:
```ini
[mod]
name="My Mod"
id="my-mod"
version="0.1.0"

[autoload]
MyMod="res://MyMod/Main.gd"

# Add only if using registry API:
# [registry]
```

`Main.gd`:
```gdscript
extends Node

var _lib = null

func _ready() -> void:
    if Engine.has_meta("RTVModLib"):
        var lib = Engine.get_meta("RTVModLib")
        if lib._is_ready:
            _on_lib_ready()
        else:
            lib.frameworks_ready.connect(_on_lib_ready)

func _on_lib_ready() -> void:
    _lib = Engine.get_meta("RTVModLib")
    # Register hooks and/or registry entries here
```

## Things that will burn you

1. **Replace hooks are single-owner.** Always check the return value of `hook()` for replace hooks (`id == -1` means rejected) and have a `-pre`/`-post` fallback.
2. **VosTac owns the replace hook on `Character.Stamina` and `Handling.WeaponHandling`.** Don't try to replace these. Use post hooks if you must touch them.
3. **Direct const access bypasses the registry.** `Database.Potato` resolves at compile time. Vanilla code calling `Database.get("Potato")` or `Database["Potato"]` picks up overrides; vanilla code using property syntax doesn't.
4. **Skip-listed scripts cannot be hooked**: `TreeRenderer`, `MuzzleFlash`, `Hit`, `ParticleInstance`, `Message`, `Mine`, `Explosion` (timing/lifecycle/`@tool` issues). Hook upstream call sites instead.
5. **Save-data scripts cannot be rewritten** (`CharacterSave`, `Preferences`, `WorldSave`, etc. — 11 scripts). `ResourceSaver` embeds the script path into save files; wrapping would make saves mod-dependent.
6. **CRLF line endings break GDScript parser.** Configure your editor to LF for `.gd` files.
7. **Priority numbers**: lower = earlier. Default 100. Simulated Ballistics uses 40 to run before defaults. Pick yours intentionally based on whether you need to run before or after other mods on the same hook.
8. **Inputs registered after gameplay starts** work but won't appear in the rebind menu without an additional hook on `Inputs-createactions-pre`.

## Reference mods worth studying

| Mod | Why it's instructive |
|---|---|
| [Simulated Ballistics (mod 56418)](https://modworkshop.net/mod/56418) | Clean callback-style hook usage. Reference for projectile spawn patterns and per-weapon profile tables. |
| [Likho's VosTac (mod 56366)](https://modworkshop.net/mod/56366) | Full spectrum of hook types across 9 vanilla scripts. Reference for replace-hook composition issues. |
| [Loot Modifier (mod 56036)](https://modworkshop.net/mod/56036) | Loot manipulation patterns (closest analog to typical loot work). |
| [Metro Mod Loader docs](https://github.com/ametrocavich/vostok-mod-loader/tree/main/docs/wiki) | Architecture, Hooks, Registry, Limitations, Mod-Format. |

## Development workflow on Windows

1. Game install: `C:\Program Files (x86)\Steam\steamapps\common\Road to Vostok` (typical).
2. User data: `%APPDATA%\Road to Vostok\` — contains `mods/` (drop your `.vmz` here), `MCM/` (config files), `modloader_hooks/` (regenerated each launch).
3. **Live iteration loop**:
   - Edit mod source in your repo
   - Pack to `.vmz` (just a renamed zip with `mod.txt` at root)
   - Copy to `%APPDATA%\Road to Vostok\mods\<your-mod>\` (loader also accepts unzipped directories there)
   - Launch game → check `%APPDATA%\Road to Vostok\modloader.log` for errors
4. **Conflict debugging**: enable Developer Mode in the loader's launcher UI to get `modloader_conflicts.txt` showing every wrap-surface clash.

## License convention

All four repos default to **MIT** to match Metro Mod Loader and the overall ecosystem culture. Change in your repo if you want different terms.
