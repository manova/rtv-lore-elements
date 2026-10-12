# Final 0.2.0 verification — public summary

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

The distribution and source candidate are prepared locally. Publication, a
remote push, a release tag and final gallery selection still require approval.
