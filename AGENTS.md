# AGENTS.md — guidance for the Codex agent working on this repo

This file gives an AI coding agent the operating context it needs to make useful changes here. Keep it short and current.

## Read these first, in order

1. [`PLANNING.md`](PLANNING.md) — full project plan, phased roadmap, technical approach, open questions.
2. The shared context document for the broader mod set (lives at the top level of the workspace alongside the four mod repos): framework primer, hook/registry API surface, common pitfalls.
3. The Metro Mod Loader docs: <https://github.com/ametrocavich/vostok-mod-loader/tree/main/docs/wiki>

## Core conventions for this codebase

- **Language**: GDScript (Godot 4.6 dialect).
- **Line endings**: LF only. Mixing CRLF/LF causes the GDScript parser to error with a misleading "Expected indented block" message.
- **Indentation**: tabs (vanilla RtV convention). Don't mix.
- **Hook registration timing**: always inside `_on_lib_ready()`, never directly in `_ready()`. Use the `frameworks_ready` signal pattern in `Main.gd` as the template.
- **Replace hooks**: single-owner. Always check the return value of `lib.hook(...)`. If it returns `-1`, fall back to a `-pre`/`-post` strategy.
- **Skip-listed scripts**: `TreeRenderer`, `MuzzleFlash`, `Hit`, `ParticleInstance`, `Message`, `Mine`, `Explosion`. Never hook these. Hook upstream.
- **Save-data scripts** (`CharacterSave`, `Preferences`, `WorldSave`, etc.) are not rewritten — don't try to mod them.
- **Direct const access bypasses registry overrides**. `Database.Foo` is compile-time; vanilla code calling `Database.get("Foo")` picks up our overrides; vanilla code with property syntax doesn't. We can't fix vanilla; just be aware when reasoning about behavior.

## File layout

```
./
├── mod.txt              # Mod manifest. With [registry] section.
├── Main.gd              # Autoload entry. Hook registration goes in _on_lib_ready().
├── README.md            # User-facing
├── PLANNING.md          # Read first
├── AGENTS.md            # This file
├── LICENSE              # MIT
└── (more files added as the project grows)
```

## Common tasks

### Adding a hook

1. In `Main.gd::_on_lib_ready()`, add `_lib.hook("scriptname-methodname-pre", _on_my_callback, priority)`.
2. Implement `_on_my_callback(args)` — args match the vanilla method's signature.
3. Use `_lib._caller` inside the callback to access the calling object.
4. The auto-enrollment scanner picks up `.hook(...)` calls in your source and enrolls the vanilla method automatically. **No `[hooks]` section needed in mod.txt for the common case.**

### Adding a registry entry

1. Confirm `mod.txt` has a `[registry]` section (this project: YES).
2. In `_on_lib_ready()`: `_lib.register(_lib.Registry.<KIND>, "unique_handle", {...data...})`.
3. Always do this synchronously inside `_on_lib_ready()`, never after scene load — vanilla consumers cache from registries in their own `_ready()`.

### Inspecting vanilla scripts

Metro Mod Loader detokenizes vanilla `.gdc` files at boot. Enable Developer Mode in the launcher to dump the rewritten output. Source location for vanilla: `res://Scripts/<Name>.gd` (read-only after detokenize).

## Out of scope for this agent (ask the human)

- Publishing the mod to ModWorkshop.
- Bumping major versions or breaking the public API of this mod (if/when one exists).
- Adding cross-cutting dependencies on other mods beyond what `PLANNING.md` documents.
- Refactoring the framework / Metro Mod Loader itself — we are a *consumer*, not a contributor to the loader.

## Output expectations

- Keep commits focused. One logical change per commit.
- Update `PLANNING.md`'s phase checklist when completing items.
- When making non-obvious decisions (e.g. choosing a hook strategy from two viable options), add a short note to a `notes/` subdirectory explaining the choice and the alternatives considered.
- When adding open questions, append to the relevant section in `PLANNING.md` rather than starting a separate doc.
