# Final 0.2.0 verification — public summary

## GitHub publication status

[GitHub v0.2.0](https://github.com/manova/rtv-lore-elements/releases/tag/v0.2.0) was published as a non-draft release
on 2026-10-14 at 00:33:12 UTC, from merged commit `3cf6672` (PR #22).
The published `rtv_lore_elements-0.2.0.vmz` asset reports 42,693,560 bytes and
SHA-256 `4e77629bcbb5f3556a42bb44b2a39d77fa4b4d18294bae1bda00896ad3d5ded5`,
matching the final reviewed 115-file artifact below. That exact package passed
focused isolated Windows slot 2 testing and full relaunch on 2026-10-13.
[The acceptance and provenance record](final-package-windows.md) reconciles the
local QA audit and October 14 final review, which were absent from this public
summary. The current ModWorkshop version has not been independently verified.

The sections below retain historical package-specific evidence. Earlier Windows
acceptance and normal adoption must not be attributed to the later review fix.
Bundled and attached release documents retain preparation-time wording; the VMZ,
its checksum and historical package manifests are unchanged.

## PR review follow-up

PR 22 review on 2026-10-13 identified collision exclusions that outlived pending
reconstruction and a gap band skipped by the legacy-stack logic. Targeted native
tests reproduce both findings on the earlier runtime. The bounded fix includes
final-world rollback, dependent-stack rollback, padded stack separation and a
settled-modern-contact guard. No ordinary drop retune or artwork change is made.

Eight targeted cases pass 32 assertions: retained bodies processed earlier or
later, incompatible overlapping targets, a connected stack, negative/positive
intermediate gaps, a supported modern neighbor and a lost-support rollback
cascade. The original runtime fails the negative control. The exact new archive
also passes the same 9,670 native assertions listed below, for 9,702 total.
The genuine geometry probe still repairs all five reported Tent notes and
converts 28/36 poses while retaining eight ambiguous cases.

Reviewed VMZ: 115 files, 42,693,560 bytes, SHA256
`4e77629bcbb5f3556a42bb44b2a39d77fa4b4d18294bae1bda00896ad3d5ded5`.
The source builder reproduces it exactly and all eleven guard tests pass.
The offline review verification did not itself run new Windows gameplay.
Later on 2026-10-13, the exact archive passed the focused original-seed slot 2
Windows check and full relaunch: five restored Tent notes, interaction and
repositioning, nine committed private-MSS transactions and three exact Loads.
Lore counts were unchanged, gameplay logs had zero errors, and the restarted
gameplay session performed no repeat legacy repair. The separate cold pre-mount
process recorded 42 known missing-resource errors before Metro's clean restart.
See [the scoped results and source hashes](final-package-windows.md).

Earlier packages remain historical evidence; their broader gameplay and normal
adoption are not transferred to this archive. Merge and GitHub publication
subsequently completed. No broad normal-play or public-MSS certification follows
from the final focused check.

## Pre-review package and genuine older saves

The 2026-10-12 corrected package includes the bounded legacy-placement repair,
with all runtime scripts byte-identical to accepted `0.2.0-legacy-placement.2`.
It preserves all artwork, readers, item identities and ordinary placement rules.
Compared with the earlier final package below, only `Main.gd` and four packaged
documentation files change. The stable manifest remains version `0.2.0`.

Focused Windows gameplay across three genuine older playthroughs passed all
four checks and full quit/relaunch. The reported five embedded Tent notes now
look correct. The closed-game audit verifies 27 committed private-MSS
transactions and nine exact Loads; the restarted process performs no repeated
legacy conversion. Both gameplay logs have zero errors. Known cold-bootstrap
errors occur separately before the modded restart. This supplements, rather than
relabels, the earlier synthetic all-18-item upgrade fixture.

The accepted correction's offline evidence includes 299 legacy/modern pose
assertions, 47 restored-contact assertions, 661 supported-display assertions at
each of 60/120 FPS, and 4,905 complete genuine-save assertions. The geometry probe
converts 28 of 36 custom poses and retains eight ambiguous cases. Not every
retained pose is individually visually certified. One older note was found
upright; it remains a nonblocking presentation caveat. One Crayon Map stool
jitter stopped after reload without further recurrence and remains a watch item.

The exact corrected final archive passed a fresh offline verification:

| Scope | Assertions |
| --- | ---: |
| Final identity/resources, Lore-only and MCM | 395 |
| Four native create/reload cycles | 2,702 |
| Three genuine-save copies, slot switching and restart | 4,905 |
| Legacy/modern pose controls | 299 |
| Restored contacts | 47 |
| Supported display, 60 FPS | 661 |
| Supported display, 120 FPS | 661 |

These 9,670 assertions used Linux Godot 4.6.2 and disposable native fixtures.
They supplement the accepted Windows gameplay; they are not new in-game tests.
The corrected archive has 115 files and is 42,692,690 bytes, SHA256
`fe6bc12f36ace1b802d300261c79acbd4b65bf4ac65b67786351e94e015b5568`.
None of these checks certifies all public MSS versions, arbitrary mods or safe
archive-only removal/downgrade.

## Earlier package checkpoint

The accepted RC1 was promoted on 2026-10-11 with only `mod.txt`, README,
changelog, release notes and save-safety prose changed. All other 110 files,
including three GDScripts and 99 art/resource/data files, remain byte-identical.
The frozen archive has 115 files and is 42,690,266 bytes, SHA256
`49121927608f0498fb76008983a77e013c71709526bd33e991ce1a5a29492b7b`.

## Recorded acceptance

Final-version identity/resource probes passed 395 assertions across Lore-only
and MCM compositions. Four disposable create/reload cycles passed 2,702 assertions:

| Seed | Composition | Assertions |
| --- | --- | ---: |
| Fresh native New | Lore only | 174 |
| Synthetic all-18-item public-era fixture | Lore + MCM | 772 |
| Completed corrected upgrade checkpoint | Lore + MCM | 686 |
| Accepted supported-display checkpoint | Lore + MCM + private MSS | 1,070 |

These final native probes used Linux Godot 4.6.2 and separately owned game data;
they were not new Windows gameplay sessions. Because runtime/art were unchanged,
the accepted [RC1 Windows gameplay and rollback evidence](../release_rc1/README.md)
remains the release basis. No broader all-mod or all-loader compatibility is claimed.

Separately approved normal installation followed a complete setup/userdata
backup and 7,758 copied-normal-save assertions. Normal Load 5 and the shared
journal then passed in play. No new lore was acquired on that normal Village
run, so the earlier fresh-game test supplies acquisition/relaunch coverage.
Local source preparation does not repeat gameplay or change the normal install.

## Reproducibility and privacy

[The public package manifest](../../release/0.2.0/package-manifest.json) pins every
shipped path and byte hash. [The source builder](../../BUILDING.md) independently
reproduces the exact final archive without a game install, private QA directory
or original RC archive. Packaging guard tests are public and runnable.

This document summarizes previously recorded test results; private save fixtures,
slot transactions, logs and native test harness inputs are not published here.
It does not claim those integration tests can run from this checkout alone.
The existing missing-input-action repair warning is not suppressed or treated
as a save failure. See [release limits](../../RELEASE_NOTES.md) and
[save safety/rollback](../../SAVE_SAFETY.md).

PR #22 was subsequently merged as `3cf6672`, and GitHub v0.2.0 was published
on 2026-10-14 (UTC). The earlier packages remain historical evidence, not the
published artifact. This reconciliation adds previously recorded final-package
acceptance to the public summary; it runs no new gameplay tests and does not
confirm another distribution platform's current version.
