# agent-setup

Repo-scoped instructions for working in this repo.

Global preferences live in `claude/CLAUDE.md`, which `setup.sh` symlinks to `~/.claude/CLAUDE.md`. Edits there apply to every project on this machine, so repo-specific rules belong in this file instead.

This repo is **public** and every skill under `skills/` is third-party code it redistributes. Attribution is therefore a licensing obligation, not bookkeeping.

## Vendoring a skill from a third party

All five steps land in the same commit as the skill itself. A skill in `skills/` without a `PROVENANCE.md` is a licensing defect, not a TODO.

1. **Pin the source.** Resolve an exact 40-character commit SHA. Never a branch or tag — both move, which breaks the verbatim claim in step 3 and leaves `vet-updates` no baseline to diff against.

2. **Find the license that actually governs the path you copied.** Check the vendored subdirectory and each parent for a license file before assuming the repo root's applies, and confirm the root has one at all. A monorepo subtree often carries its own license while the root carries none — that is the case for `pstack`, whose license sits at `pstack/LICENSE` while `cursor/plugins` has none at the root. If no license governs the path, **stop and ask**. Absent a license there is no permission to redistribute, and the skill cannot be vendored regardless of how permissive the project feels.

3. **Vendor the license text.** Copy it verbatim to `LICENSES/<source>-<SPDX-id>.txt` if that source is new to the repo; reuse the existing file if it already covers this source, after diffing to confirm the text is identical at this pin. A link is not sufficient — MIT and its relatives require the notice ship inside the copy.

4. **Confirm the terms allow public redistribution and check compatibility with MIT** (this repo's own license, see `LICENSE`). Permissive licenses (MIT, BSD, Apache-2.0, ISC) are fine. Anything copyleft (GPL, AGPL, MPL) or source-available (BSL, SSPL, Commons Clause), or any "non-commercial" or "no derivatives" restriction, changes what this repo may do as a whole — **stop and ask** before vendoring it.

5. **Write `PROVENANCE.md`** in the skill's directory and **update the README** — add a row to the provenance table and, for a new source, an entry under **Sources**.

### `PROVENANCE.md` template

```markdown
# Provenance: <skill-name>

Vendored from upstream, unmodified.

- **Upstream**: <repo URL> — `<path/within/repo>`
- **Pinned commit**: `<40-char sha>`
- **Vendored**: <YYYY-MM-DD>
- **License**: <SPDX>, Copyright (c) <year> <holder>. Full text: [`LICENSES/<file>`](../../LICENSES/<file>) — a verbatim copy of [`<upstream license path>` at `<short-sha>`](<permalink at the pinned sha>).

To check for and apply upstream changes, run the `vet-updates` skill from this repo. Any update must refresh the pinned commit and date above in the same commit.
```

The license permalink must point at the pinned SHA, not `main`, so a reader can verify the local copy against exactly the commit the skill came from.

## Modifying a vendored skill

Replace the "unmodified" line with `Vendored from upstream, then <what changed and why>.` followed by a `**Local modifications:**` list, one bullet per change, naming the file when the change is not in `SKILL.md`. Add the same list to any existing `PROVENANCE.md` you edit.

This list is load-bearing: `vet-updates` re-applies it on the next sync, so a change that isn't recorded gets silently reverted the next time upstream moves. Close the modification note with the sentence about re-applying local modifications, matching `skills/reflect/PROVENANCE.md`.

## Do not

- Edit any file under `LICENSES/` except to refresh it from upstream at a new pin. The text is a verbatim copy; changing it makes the attribution false.
- Add a copyright header naming Gary to a vendored file, or a vendored source's copyright to original work.
- Bump a pinned commit without diffing the upstream license at the new SHA. `vet-updates` does this; if you update by hand, do it by hand.
