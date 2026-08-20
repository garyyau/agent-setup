# Provenance: create-verification-skill

Vendored from upstream, then ported from Cursor to Claude Code.

**Local modifications:**

- Generated-skill path changed from `.cursor/skills/verify-<app>/` to `.claude/skills/verify-<app>/`.
- Step 5 no longer points at the un-vendored `maintain-verification-skill`; the maintenance loop it describes is inlined, with a note on vendoring the upstream skill if the feature map starts drifting.
- `references/feature-map-example/` is unmodified.

- **Upstream**: https://github.com/cursor/plugins — `pstack/skills/create-verification-skill/`
- **Pinned commit**: `fd6dd6f7276956a532bb78a748a8d2818b6eb5f4`
- **Vendored**: 2026-08-20
- **License**: MIT, Copyright (c) 2026 Lauren Tan (`pstack/LICENSE` in the upstream repo)

To check for and apply upstream changes, run the `vet-updates` skill from this repo. Any update must refresh the pinned commit and date above in the same commit, and re-apply the local modifications listed above.
