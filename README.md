# agent-setup

Gary's portable agent setup: the skills, settings, and instructions installed on every machine and VM. Clone it anywhere, run `setup.sh`, and the machine is set up; `git pull` + re-run updates it.

## Layout

| Path | Role |
| --- | --- |
| `setup.sh` | Idempotent installer — symlinks, settings merge, plugin installs. Its header comment is the authoritative description of what it does. |
| `skills/` | Agent-neutral skills, symlinked into each agent's skill directory (currently `~/.claude/skills/`). Vendored skills carry a `PROVENANCE.md` with their upstream pin. |
| `claude/` | Claude Code-specific artifacts: `CLAUDE.md`, `statusline.sh` (both symlinked into `~/.claude/`), and `settings.json` — the portable settings fragment merged into `~/.claude/settings.json`. |
| `.claude/skills/` | Repo-management skills, active only when working inside this repo: `vet-updates` and `capture-setup`. |

## Setting up a machine (agent instructions)

1. Run `./setup.sh` from the repo root. It is additive and re-runnable; it never deletes anything.
2. Read its output. Setup is complete when it reports zero warnings; each warning names a target it skipped because something already exists there.
3. Resolve every warning through the cleanup pass below. The machine is set up when every warning has a user decision applied.

## Cleanup pass (agent instructions)

`setup.sh` skips any target that exists and isn't a symlink into this repo. For each skipped target, and for any local-only extras you find in `~/.claude` (settings keys, skills the repo doesn't carry):

1. Diff it against the repo counterpart, if one exists. When the contents are identical, replace the local copy with the symlink — that is a no-op for behavior and needs no confirmation.
2. When contents differ or the item is local-only, put it to the user per item: **adopt into the repo**, **delete locally**, or **ignore**. Apply only what they choose; every deletion needs its own yes.
3. Deliberately machine-specific settings keys stay local and are not offered for adoption: `model`, `effortLevel`, `voice`, `voiceEnabled`.

The `capture-setup` skill in this repo runs this pass end to end — prefer invoking it when working here.

## Keeping it current

- `vet-updates` — checks vendored skills against their upstream pins and declared plugins against the marketplace, and proposes update commits.
- `capture-setup` — inspects this machine's live `~/.claude`, diffs it against the repo, and proposes adoptions.

Plugins follow the marketplace's latest version by design; the repo pins only what it vendors.

## Licensing

This repo is MIT licensed — see [`LICENSE`](./LICENSE). That covers the original work here: `setup.sh`, `claude/`, and `.claude/skills/`.

Every skill under `skills/` is vendored from a third party and carries its own `PROVENANCE.md` with the upstream path, pinned commit, license, and any local modifications. That file is authoritative; the table below is a summary.

| Skill | Source | Pin | Local changes |
| --- | --- | --- | --- |
| [`blast-radius`](./skills/blast-radius/PROVENANCE.md) | pstack | `fd6dd6f` | ported to Claude Code |
| [`create-verification-skill`](./skills/create-verification-skill/PROVENANCE.md) | pstack | `fd6dd6f` | ported to Claude Code |
| [`principle-guard-the-context-window`](./skills/principle-guard-the-context-window/PROVENANCE.md) | pstack | `fd6dd6f` | none |
| [`principle-prove-it-works`](./skills/principle-prove-it-works/PROVENANCE.md) | pstack | `fd6dd6f` | none |
| [`principle-separate-before-serializing-shared-state`](./skills/principle-separate-before-serializing-shared-state/PROVENANCE.md) | pstack | `fd6dd6f` | none |
| [`reflect`](./skills/reflect/PROVENANCE.md) | pstack | `fd6dd6f` | ported to Claude Code |
| [`show-me-your-work`](./skills/show-me-your-work/PROVENANCE.md) | pstack | `fd6dd6f` | ported to Claude Code |
| [`swarm`](./skills/swarm/PROVENANCE.md) | pstack | `fd6dd6f` | ported to Claude Code |
| [`technical-writing`](./skills/technical-writing/PROVENANCE.md) | pstack | `fd6dd6f` | none |
| [`unslop`](./skills/unslop/PROVENANCE.md) | pstack | `99559f2` | none |

**Sources:**

- **pstack** — [cursor/plugins](https://github.com/cursor/plugins), path `pstack/skills/`. MIT, Copyright (c) 2026 Lauren Tan. License text: [`LICENSES/pstack-MIT.txt`](./LICENSES/pstack-MIT.txt). Identical at both pins above.

Both this repo and pstack are MIT, so the terms are the same throughout; the upstream copyright notice is retained for the vendored skills as MIT requires. Plugins listed in `claude/settings.json` are marketplace-installed rather than vendored, so this repo does not redistribute them and they carry no obligation here.

Adding a skill from a new source means adding its license text under `LICENSES/` and a row to **Sources** above. `vet-updates` re-checks each upstream license on every sync and stops if it changed. The full procedure is in [`CLAUDE.md`](./CLAUDE.md).

## Scope

This repo is **public** — nothing private or organization-specific goes in it. Claude Code is the only agent configured today; skills live in the agent-neutral `skills/` so a future `codex/` (or other agent) directory can share them.
