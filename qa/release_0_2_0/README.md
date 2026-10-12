# Final 0.2.0 verification — public summary

## Corrected package and genuine older saves

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

The corrected distribution and source are prepared locally. A new GitHub PR,
merge, normal adoption, tagging, publication and gallery choice remain separate
approval gates. The earlier package remains historical evidence, not the new
upload target.
