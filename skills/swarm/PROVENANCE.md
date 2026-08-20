# Provenance: swarm

Vendored from upstream, then ported from Cursor to Claude Code.

**Local modifications:**

- Cursor cloud workers became Claude Code subagents: `Task` + `environment: "cloud"` + `cloud_base_branch` replaced by one `Agent` call per worker in a single message, with `isolation: "worktree"` for writers.
- Worker model now comes from the model table in CLAUDE.md instead of `~/.cursor/rules/pstack-models.mdc`; added a `/usage` quota check before large fan-outs.
- Added a pointer to the `Workflow` tool for fan-outs whose shape is known up front, and a cross-reference to `principle-separate-before-serializing-shared-state` in phase A.5.

- **Upstream**: https://github.com/cursor/plugins — `pstack/skills/swarm/`
- **Pinned commit**: `fd6dd6f7276956a532bb78a748a8d2818b6eb5f4`
- **Vendored**: 2026-08-20
- **License**: MIT, Copyright (c) 2026 Lauren Tan. Full text: [`LICENSES/pstack-MIT.txt`](../../LICENSES/pstack-MIT.txt) — a verbatim copy of [`pstack/LICENSE` at `fd6dd6f`](https://github.com/cursor/plugins/blob/fd6dd6f7276956a532bb78a748a8d2818b6eb5f4/pstack/LICENSE).

To check for and apply upstream changes, run the `vet-updates` skill from this repo. Any update must refresh the pinned commit and date above in the same commit, and re-apply the local modifications listed above.
