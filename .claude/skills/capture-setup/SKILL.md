---
name: capture-setup
description: Diff this machine's live ~/.claude against the repo and adopt, delete, or ignore each difference with the user.
disable-model-invocation: true
---

# Capture setup

Reconcile the machine's live `~/.claude` with this repo, in both directions: drift in repo-managed artifacts, and local-only material worth adopting. The run is complete when every difference found has a user decision applied — adopt, delete locally, or ignore.

## Survey

Build the full difference list before putting anything to the user:

1. **Repo-managed artifacts** — every `skills/*` directory, `claude/statusline.sh`, `claude/CLAUDE.md`. For each, check its `~/.claude` target: correctly symlinked, a diverged real file, or missing. `git status` in this repo also shows drift, since symlinked edits land here.
2. **Settings** — diff `~/.claude/settings.json` keys against the `claude/settings.json` fragment. Local-only keys are candidates; `model`, `effortLevel`, `voice`, and `voiceEnabled` are machine-specific by policy — leave them local and off the list.
3. **Local-only skills** — directories in `~/.claude/skills/` the repo doesn't carry.

## Resolve

Work the list item by item:

- A real file identical to its repo counterpart: replace it with the symlink directly — behaviorally a no-op.
- Everything else goes to the user, one item at a time, with a short description of what it is and what each choice means. Offer **adopt into the repo**, **delete locally**, or **ignore**. Each deletion needs its own explicit yes.
- Adoptions land as files in the right place (`skills/` for agent-neutral skills, `claude/` for Claude-specific artifacts, fragment keys for settings), the local copy becomes a symlink where the repo's install would make one, and third-party material gets a `PROVENANCE.md` (follow the format of `skills/unslop/PROVENANCE.md`).

## Finish

Run `./setup.sh` and confirm it reports zero warnings, then commit the adoptions with a message listing what was captured. Report the decision taken for every item on the list.
