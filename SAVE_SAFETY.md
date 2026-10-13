# Save safety and rollback

Back up the complete userdata directory and the exact enabled mod archives before
upgrading. A rollback means restoring that matching set, not putting an older
Lore archive over a save written by a newer one.

Fresh-game, synthetic upgrade and three genuine older-playthrough checks passed
on isolated copies, including full relaunch. The genuine-save pass used the
private MSS safety build; it does not certify every public MSS version or make
mod removal safe. Most users only need the backup, one enabled Lore archive and
a clean modded restart described below.

## Before testing or upgrading

1. Close the game. Keep the original userdata and mod setup untouched.
2. Copy the entire userdata directory, including native saves, `Validator.tres`,
   preferences, Lore journal, MCM configuration and any MSS slots/state.
3. Retain the exact game-build identity, Metro version, enabled mod list and
   original archives alongside the backup. Keep each checkpoint separately named.
4. Use an independent setup/userdata copy for the upgrade. Enable only one Lore archive.

Do not copy only Character or Cabin between unrelated checkpoints. Keep the
complete native save set, including every visited shelter, together with MSS
slots/state if used. The Lore journal is shared within userdata, outside MSS's
per-slot save set.

Older placed notes use different mesh coordinates. This version repairs eligible
embedded poses when the shelter loads; the normal checkpoint retains the result.
Ambiguous poses may remain upright rather than risk changing a valid display.

## Cold startup and interrupted startup

Metro 3.4.2 can let the native menu inspect Lore-bearing saves before mod archives
mount. The first process may report missing Lore `.tres` resources even though
they are present in the archive. Wait for the normal modded restart to finish.
The bounded startup tests preserve the copied saves; that does not make every
partially initialized menu safe to play.

If Load is missing, hooks fail, or Metro reports restart-loop/crash-breaker
fallback, quit. Verify the intended archives are enabled and relaunch cleanly.
Do not choose New, delete the Validator, reset saves, or save from the degraded
session to try to repair it. A Load button being visible is not proof that all
save dependencies resolved. Persistent errors need diagnosis before playing.

## Downgrading or removing Lore

Saved items can reference files supplied by Lore, including the versioned
`TornNotebook/Portrait` and `FoldedDocument/Compact` resources. Older public
archives do not contain those newer paths. Removing Lore also removes the
original note resources. Do not load or save Lore-bearing userdata with those
dependencies absent, even if some unrelated save resources still load.

Removing visible notes from inventory alone is not a supported uninstall method:
shelter items, nested storage or other retained checkpoints may still refer to
them. No automatic save stripping or in-place downgrade is supplied.

## Safe recovery

1. Close the game and preserve the unsuccessful test directory for diagnosis.
2. Return to the untouched pre-upgrade setup and its matching complete userdata
   backup, or create another disposable setup from that backup.
3. Restore the matching older mod archives and loader configuration together.
   Avoid mixing generated loader state from different archive sets; a newly
   staged copy can let Metro build its own caches.
4. Confirm a clean modded boot before loading. Check inventory, journal and
   shelter contents before making a new checkpoint.

For an interrupted session with intact saves, restoring the same Lore version and other
required archives may be enough; validate on a copy first. To remove Lore
entirely, return to a pre-Lore backup or start a genuinely separate new profile.
Keep the Lore-bearing original recoverable.
