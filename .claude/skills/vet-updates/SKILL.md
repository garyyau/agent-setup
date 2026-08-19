---
name: vet-updates
description: Check vendored skills and declared plugins for upstream changes, then propose vetted update commits.
disable-model-invocation: true
---

# Vet updates

Compare everything this repo pins or declares against its upstream, and turn approved changes into commits. The run is complete when every vendored skill and every declared plugin has a verdict: **current**, **update applied**, or **update declined by user**.

## Vendored skills

For each directory under `skills/` with a `PROVENANCE.md`:

1. Read the pinned commit and upstream path from `PROVENANCE.md`.
2. Fetch the latest upstream commit touching that path (GitHub API: `/repos/<owner>/<repo>/commits?path=<path>&per_page=1`).
3. Same commit → verdict **current**, move on.
4. Newer commit → fetch the file at both commits, diff them, and summarize for the user what changed and whether it alters the skill's behavior. Vet, then judge: flag anything that would conflict with how Gary uses the skill or that smells like an unwanted direction change, and give a recommendation.
5. On the user's yes: replace the vendored copy with the upstream version, update `PROVENANCE.md`'s pinned commit and date, and commit — one commit per skill, message naming the skill and the upstream range.

## Declared plugins

For each key under `enabledPlugins` in `claude/settings.json`:

1. Read the locally installed version from `~/.claude/plugins/installed_plugins.json` and the marketplace's current version (marketplace clone under `~/.claude/plugins/marketplaces/`, or `claude plugin` CLI output).
2. Versions match → verdict **current**.
3. Marketplace is ahead → summarize the version jump for the user (changelog or marketplace diff when reachable). Plugins follow latest by policy, so the action offered is `claude plugin update`, not a repo change — unless the update looks breaking, in which case say so and recommend holding.

## Report

End with a table: item, pinned/installed, upstream/marketplace, verdict. Every row carries one of the three verdicts.
