# Legacy placed document compatibility

The older public notes reused the native patient-report mesh: upright XY faces
with a bottom-edge origin. The original paper families use XZ faces and centered
origins. Native shelter saves preserve body coordinates, so interpreting an old
flat note through the new mesh can leave it edge-on through a floor.

The existing shelter-restore hooks now apply a bounded conversion after one
physics frame. Candidates must be newly restored, frozen, unchanged and eligible
custom pickups. Deep support penetration and a compatible old face direction
are required. The converted pose preserves the old face center, then passes
static-support and whole-envelope collision checks. Connected nearly flat old
stacks are handled bottom-up. Valid modern papers remain obstacles.

PR review found two edge cases in that first correction. Temporary exclusions
now cover only pending invalid candidates; retained and completed candidates
remain obstacles. Final validation uses no pending exclusions, and rolls back
conflicting repairs until stable. Upper layers also roll back if their repaired
support is reverted. Transform updates are flushed before later spatial queries.

Connected stack layers now admit intermediate penetration or floating gaps while
preserving the settled contact band (including the intended 1 mm clearance).
Stack spacing accounts for the unchanged padded collision boxes, not just visual
thickness. These rules remain restore-only; collider dimensions and ordinary
drop/placement behavior are not changed.

Saved data has no mesh-version marker, so a blanket rotation is unsafe. Keep
ambiguous poses, unsupported guesses, active/held/moved bodies and native reused
assets unchanged. Existing shallow-contact repair remains separate. Only the
in-memory restored transform changes; the normal native checkpoint saves it.
No save-script rewrite, per-frame legacy migration or ordinary drop retune is
introduced.

The accepted candidate passed the five-note reproduction, 64 modern controls,
mixed old/new collision, native serialization and repeated-load checks, plus
focused gameplay and full restart across three genuine older playthroughs.
The offline probe converted 28 of 36 custom placements, retaining eight
ambiguous poses; this is not a claim that all retained displays look correct.
One upright older note remains a nonblocking presentation caveat. A separate
Crayon Map stool jitter stopped after reload and remains a recurrence watch,
not a demonstrated failure of this one-shot repair.

See the [public QA summary](../qa/release_0_2_0/README.md) and
[save-safety guide](../SAVE_SAFETY.md). Private saves, logs and native game assets
are not included in this source release.
