# Provenance: blast-radius

Vendored from upstream, then ported from Cursor to Claude Code.

**Local modifications:**

- Dropped the dependency on the un-vendored `how` and `why` skills: the companion framing became prose, and step 1 now pulls the PR with `gh pr view` and `git log -p` directly.
- Step 6's `arena` hand-off became an `Agent`-per-model pass using the model table in CLAUDE.md.

- **Upstream**: https://github.com/cursor/plugins — `pstack/skills/blast-radius/`
- **Pinned commit**: `fd6dd6f7276956a532bb78a748a8d2818b6eb5f4`
- **Vendored**: 2026-08-20
- **License**: MIT, Copyright (c) 2026 Lauren Tan. Full text: [`LICENSES/pstack-MIT.txt`](../../LICENSES/pstack-MIT.txt) — a verbatim copy of [`pstack/LICENSE` at `fd6dd6f`](https://github.com/cursor/plugins/blob/fd6dd6f7276956a532bb78a748a8d2818b6eb5f4/pstack/LICENSE).

To check for and apply upstream changes, run the `vet-updates` skill from this repo. Any update must refresh the pinned commit and date above in the same commit, and re-apply the local modifications listed above.
