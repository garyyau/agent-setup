---
name: reflect
description: Spawn three parallel review subagents over the current transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

- The user said "reflect" or "/reflect".
- A complex task (5+ tool calls) just landed cleanly and the recipe is worth keeping.
- The agent hit dead ends, found the working path, and the path generalizes.
- The user corrected the agent's approach mid-task.
- A non-trivial workflow emerged that isn't captured anywhere.

Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own transcript file before fanning out. Transcripts live under `~/.claude/projects/<project-slug>/`, where the slug is the current working directory with `/` replaced by `-`. Resolve the slug for this working directory only. Do not glob across `~/.claude/projects/*/`; that crosses project boundaries and reads private chats from unrelated work.

```bash
SLUG=$(pwd | sed 's|/|-|g')
ls -t ~/.claude/projects/"$SLUG"/*.jsonl ~/.claude/projects/"$SLUG"/*/subagents/*.jsonl 2>/dev/null | head -10
```

Note that `~/.claude/projects` is often a symlink to shared storage. Two layouts: session transcripts (`<session-id>.jsonl`) and subagent transcripts (`<session-id>/subagents/<child>.jsonl`).

For each candidate, read the first JSONL line and check that `message.content[0].text` contains the conversation's opening user prompt. Take the matching path. If no path resolves, write a tight digest of the session and pass that instead.

### 2. Spawn three reviewers in parallel

One message, three `Agent` calls, `subagent_type: "general-purpose"`, explicit `model` on each. Sending them in one message is what makes them run in parallel. The prompt forbids file writes; the parent applies edits.

| Lens | `model` | Prompt template |
|---|---|---|
| Judgment | `fable` | `references/judgment-reviewer.md` |
| Tooling | `opus` | `references/tooling-reviewer.md` |
| Divergent | `fable` | `references/divergent-reviewer.md` |

Models follow the table in CLAUDE.md: judgment and prose go to fable-5, precise instruction-following to opus-5. Substitute per that table when quota is short, and never use Haiku. Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `Agent` response body.

Reviewers read a full transcript, which is bulk. That is the point of fanning out: the raw payload stays in the subagents and only findings come back (the **principle-guard-the-context-window** skill).

### 3. Synthesize

One `Agent` call, `subagent_type: "general-purpose"`, `model: "fable"`. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. Prose in a skill file is the weakest rung; a check that fails loud is the strongest. The synthesizer already applies this criterion; this is a final pass before edits land.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future session on every machine that installs this setup; do not auto-apply.

Backlog items file to whatever issue tracker the project uses. Those are tracker submissions, not skill edits. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the `writing-for-agents` skill and follow its guidance for authoring agent-facing prose.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): rewrite the `description` frontmatter so it names the triggers a user would actually type, then confirm the skill fires on them.
- `new skill via writing-for-agents: <kebab-name>`: hand creation to `writing-for-agents`. Do not invent the shape ad hoc.

An edit that lands in a skill vendored from upstream must be recorded in that skill's PROVENANCE.md as a local modification, or the next `vet-updates` run will overwrite it.

Run `/skill-doctor` on every touched skill before declaring done.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
