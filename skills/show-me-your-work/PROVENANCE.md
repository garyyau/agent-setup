# Provenance: show-me-your-work

Vendored from upstream, then ported from Cursor to Claude Code.

**Local modifications:**

- Transcript discovery retargeted from Cursor's `agent-transcripts/` to `~/.claude/projects/<project-slug>/`, including the subagent layout.
- The cross-model reviewer requirement now names a concrete pairing (opus-5 <-> fable-5) instead of "a different model family".
- Dropped a cross-reference to the un-vendored `encode-lessons-in-structure` principle; the bullet keeps its substance as plain prose.
- `scripts/log.sh` and `references/decision-log-template.tsv` are unmodified.

- **Upstream**: https://github.com/cursor/plugins — `pstack/skills/show-me-your-work/`
- **Pinned commit**: `fd6dd6f7276956a532bb78a748a8d2818b6eb5f4`
- **Vendored**: 2026-08-20
- **License**: MIT, Copyright (c) 2026 Lauren Tan (`pstack/LICENSE` in the upstream repo)

To check for and apply upstream changes, run the `vet-updates` skill from this repo. Any update must refresh the pinned commit and date above in the same commit, and re-apply the local modifications listed above.
