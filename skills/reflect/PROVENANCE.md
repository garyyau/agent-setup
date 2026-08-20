# Provenance: reflect

Vendored from upstream, then ported from Cursor to Claude Code.

**Local modifications:**

- `Task` calls became `Agent` calls; `readonly` and the MCP-stripping caveats it carried were dropped, since Claude Code has no such parameter.
- Reviewer models mapped onto the table in CLAUDE.md (judgment and divergent on fable-5, tooling on opus-5) instead of Cursor slugs.
- Transcript discovery retargeted to `~/.claude/projects/<project-slug>/`, with a note that the directory is often a symlink to shared storage.
- Cursor's built-in `create-skill` hand-offs retargeted to the `writing-for-agents` skill from the mattpocock-skills plugin this repo enables; the SKILL.md validator step became `/skill-doctor`.
- Added a step-5 rule that edits to a vendored skill must be recorded in its PROVENANCE.md, so `vet-updates` does not overwrite them.
- `references/synthesizer.md` carries the same `create-skill` -> `writing-for-agents` change. The three reviewer templates changed only in their `.cursor` -> `.claude` skill paths.

- **Upstream**: https://github.com/cursor/plugins — `pstack/skills/reflect/`
- **Pinned commit**: `fd6dd6f7276956a532bb78a748a8d2818b6eb5f4`
- **Vendored**: 2026-08-20
- **License**: MIT, Copyright (c) 2026 Lauren Tan (`pstack/LICENSE` in the upstream repo)

To check for and apply upstream changes, run the `vet-updates` skill from this repo. Any update must refresh the pinned commit and date above in the same commit, and re-apply the local modifications listed above.
