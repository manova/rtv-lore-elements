# Exact final-package Windows acceptance

This public summary was reconciled on 2026-10-22 from the retained local QA
records and the October 14 final publishing review. It documents existing tests;
no new gameplay was run for this documentation update. Raw saves, screenshots,
transaction journals and gameplay logs remain private.

## Artifact and chronology

The tested `rtv_lore_elements-0.2.0.vmz` contains 115 content files and is
42,693,560 bytes, SHA-256:

```text
4e77629bcbb5f3556a42bb44b2a39d77fa4b4d18294bae1bda00896ad3d5ded5
```

- Focused Windows acceptance: **2026-10-13**. The closed-game audit is timestamped
  `2026-10-13T22:36:18.138205+00:00` and pins reviewed head
  `16997f3f7757deed32bf08df27e2b31741a4a69b` and the archive hash above.
- [PR #22](https://github.com/manova/rtv-lore-elements/pull/22) squash merge:
  **2026-10-13 at 23:33:27 UTC**, commit
  `3cf6672d6526927d599e41a85f9e8b1dd8898105`. Its tree equals the reviewed head's
  tree, `6bffd4b43997eed95f9c1ec55b8d3caa02e7e532`.
- [GitHub v0.2.0 publication](https://github.com/manova/rtv-lore-elements/releases/tag/v0.2.0):
  **2026-10-14 at 00:33:12 UTC**, October 13 in the original local records.
  The release API's asset size and digest match the tested VMZ. The October 14
  final publishing review rechecked that identity and the acceptance evidence.

The earlier offline/native verification passed 9,702 assertions and the recorded
merged-source rebuild passed 11 packaging guard tests. Its
`new_windows_gameplay: false` describes that earlier verification task; it does not negate the later
Windows acceptance. See [the package-specific QA history](README.md).

## Accepted scope

The test used an isolated copy of the original slot 2 seed on Road to Vostok
`0.2.1.0` / Steam build `25837777`, Metro `3.4.2`, MCM `2.9.3` and the private MSS
safety candidate (`1.1.14-local-safe.1`). The setup retained the original saved
note poses and the previously approved player-stat refill. The Windows logs
identify Godot `4.6.3`; the separate offline
probes used Linux Godot `4.6.2`.

Andrew accepted all three focused checks and full relaunch: the five restored
Tent notes looked correct, interaction and placement worked, and the saved
arrangement persisted. The visual review recorded the Crayon Map repositioned
upright against the stove base and retained after relaunch.

The closed-game audit records:

- **Nine committed private-MSS transactions** and **three explicit slot 2 Loads**.
  Each Load restored the exact five-file preceding checkpoint, including the
  full-process restart. These are transaction/load counts, not nine independent
  playthroughs or a repeat of the three-save matrix.
- Matching final root, slot 2 and latest committed checkpoint; unchanged Lore
  identity counts and the same five placed Tent notes.
- Stable saved poses from the first checkpoint to the final checkpoint, with a
  maximum serialized component difference of `2e-8`.
- Five legacy poses repaired once in the first gameplay session; no repeat
  legacy repair after relaunch. Both gameplay logs contained zero errors.
- A separate cold pre-mount process with **42 known missing-resource errors**
  before Metro restarted cleanly. The zero-error gameplay result does not erase
  these bootstrap errors or justify continuing through persistent errors.
- Unchanged preferences and shared journal. The audit preserved/hash-verified
  155 played-userdata files and four screenshots, and recorded unchanged normal
  setup/saves, original seeds, earlier QA profiles and reviewed distributions.

This supplements the earlier fresh-game, synthetic-upgrade and three genuine-save
acceptance on their respective packages. It does not establish broad normal-play
coverage, universal old-save/old-pose compatibility, public-MSS certification,
arbitrary mod compatibility or safe archive-only removal/downgrade. Couch support,
conservatively retained upright poses and rare jitter remain known limits.
Keep the [save-safety requirements](../../SAVE_SAFETY.md).

## Evidence provenance

The following are paths in the private authoring checkout, **not files shipped
in this public source tree**. They were read and hashed during reconciliation.
The publication manifest pins the slot 2 records, the package verification,
the handoff and merge verification. All listed hashes matched those pins.

| Local record | SHA-256 |
| --- | --- |
| `qa/live_test/2026-10-13-build25837777-pr22-slot2/manual-results.md` | `962f67db33ce3f2331aa978ecaf9393c9d8d60855a07edc73a80a5282f9b3087` |
| `qa/live_test/2026-10-13-build25837777-pr22-slot2/live-review-20261013.json` | `27d95aa4045ecda653e329c9b45a94e2dd7f0d5ca8d57a7a34ffed3b2477b5de` |
| `qa/live_test/2026-10-13-build25837777-pr22-slot2/setup-verification.json` | `e09276905b16381c5c421427779564901e950cf6223b76a0d6e799ba4b3b4e40` |
| `qa/release_pr22/verification.json` | `461d648823d358ae273b3e39a0d902059862a65061f164a5e3e365128d850fc0` |
| `build/rtv37-pr22-merge-20261013/verification.json` | `80a7bab661536e50faa65bb5193e31325ea01f1ec8d67e17a0d5b9e429322534` |
| `notes/publication-0.2.0/CLEO_HANDOFF.md` | `87383df975ad33e1b7b85b03737cb970b61145af4dfaed4e3d36c2c12af90f92` |

`notes/publication-0.2.0/manifest.json` SHA-256:
`f0889b9efaf691ab2dc07c0fff4b5bd77a494880c02ab6faf7a4b51dbc3be2f4`.
The historical final review is retained as thread
`01a12fe6-be65-72f3-9d1e-df92975390f2`, turn
`01a137bc-ee52-7787-9913-f62389e5f899`; it independently records the same artifact,
nine committed transactions, three exact Loads and focused-test limits.

These provenance references make the source of the summary explicit; they do
not make private integration tests reproducible from this checkout. Frozen
release assets and their preparation-time documentation remain unchanged.
