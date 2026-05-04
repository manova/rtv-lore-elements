# RTV-42 Public Repo Prep

RTV-42 prepares the repository for public visibility before the v0.1 release.
The goal is repo hygiene and reader-facing documentation, not ModWorkshop
marketing copy.

## Audit results

- Credential scan: no credentials found. The ticket grep command only reported
  false positives such as input constants, generic audit wording, and notes
  about loader script rewriting. `gitleaks detect` also scanned 41 commits and
  found no leaks.
- Tracked-file scan: no vanilla recovery folders, `.pck` files, Godot caches,
  OS junk, or generated `.vmz` packages are tracked.
- Asset scan: no copied Road to Vostok textures, sounds, or models are tracked.
  Item resources reference vanilla `res://` scripts/icon/mesh/material paths at
  runtime, and the committed media files are in-game screenshots.
- Internal docs review: local recovery folder names were removed from
  `notes/script-discovery.md`, while keeping the useful hook and data-shape
  findings.

## Repo-facing changes

- README now targets outside readers with install, usage, configuration, media,
  links, contribution, and license sections.
- `LICENSE-CONTENT` adds CC BY 4.0 for authored lore/content while code remains
  MIT, with an explicit Road to Vostok asset attribution/disclaimer.
- `.gitignore` explicitly excludes vanilla extraction/recovery output, `.pck`
  files, Godot caches, OS junk, and packaged VMZ output.
- Contribution guidance and GitHub issue templates were added for public triage.

## Post-merge steps

After the PR merges, set the GitHub repository description and topics, then flip
the repository to public. RTV-40 replaces the README's ModWorkshop stub with the
published listing URL once the page is live.
