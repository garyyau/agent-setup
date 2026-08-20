# Personal Preferences

**Note: I don't currently have access to gpt-5.5.** Wherever this file calls for gpt-5.5 — computer use via Codex, bulk work, reviews, etc. — substitute opus-5 and use Claude's own tooling and the normal Agent/Workflow model parameter instead of the Codex CLI. The gpt-5.5 guidance is kept below for when access is restored.

## TypeScript

- Never use `any` unless 100% necessary or specifically instructed.

## Commands

- Don't run dev server commands (e.g., `pnpm run dev`) — assume it's already running.
- Don't run build commands unless specifically told to.
- Focus on checking commands like `bun run typecheck`, `bun run lint`, etc.

## Package Managers

- Use npm if the project already uses it, otherwise use pnpm.

## Tech Stack Preferences

When uncertain, prefer: Tailwind, TypeScript, React.

## Code Style

- Always strive for concise, simple solutions.
- If a problem can be solved in a simpler way, propose it.

## General preferences

- If asked to do too much work at once, stop and state that clearly.
- If computer use is helpful for completing or verifying work, shell out to gpt-5.5 with Codex for it.

## Picking the right models for workflows and subagents

Rankings, higher = better. Cost reflects what I actually pay, not list price. Intelligence is how hard a problem you can hand the model unsupervised. Taste covers UI/UX, code quality, API design, and copy.

| model    | cost | intelligence | taste |
| -------- | ---- | ------------ | ----- |
| gpt-5.5  | 9    | 8            | 5     |
| sonnet-5 | 5    | 5            | 7     |
| opus-5   | 4    | 7            | 8     |
| fable-5  | 2    | 9            | 9     |

How to apply:

- These are defaults, not limits. You have standing permission to override them: if a cheaper model's output doesn't meet the bar, rerun or redo the work with a smarter model without asking. Judge the output, not the price tag. Escalating costs less than shipping mediocre work.
- Cost is a tie-breaker only; when axes conflict for anything that ships, intelligence > taste > cost.
- Bulk/mechanical work (clear-spec implementation, data analysis, migrations): gpt-5.5 — it's effectively free.
- Anything user-facing (UI, copy, API design) needs taste ≥ 7.
- Reviews of plans/implementations: fable-5 or opus-5, optionally gpt-5.5 as an extra independent perspective.
- Never use Haiku.
- Mechanics: gpt-5.5 is only reachable through the Codex CLI — `codex exec` / `codex review` (my ~/.codex/config.toml defaults to gpt-5.5). Use the codex-implementation, codex-review, and codex-computer-use skills; for work they don't cover (investigation, data analysis), run `codex exec -s read-only` directly with a self-contained prompt.
- Claude models (sonnet-5, opus-5, fable-5) run via the Agent/Workflow model parameter.

Using gpt-5.5 inside workflows and subagents (the model parameter only takes Claude models, so use a wrapper):

- Spawn a thin Claude wrapper agent with `model: 'sonnet', effort: 'low'` whose prompt instructs it to write a self-contained codex prompt, run `codex exec` via Bash, and return the raw output verbatim. The wrapper does no reasoning of its own — it only relays — so keep effort low; the real work happens in gpt-5.5 inside codex. Give the wrapper the full task context up front, since codex can't see the workflow's conversation and its prompt has to stand alone.

## Engineering principles

Three principles live as skills in this setup. They are deliberately not model-invocable, so nothing
loads them on its own. Read the leaf file when its trigger fires. Naming a principle in a reply means
it changed a decision. A citation with no decision behind it means the leaf was never read.

| Trigger | Read |
| --- | --- |
| Concurrent actors (parallel subagents, worktrees, background jobs) might write the same file, branch, or key | `~/.claude/skills/principle-separate-before-serializing-shared-state/SKILL.md` |
| A task is about to be called done, especially work a subagent did | `~/.claude/skills/principle-prove-it-works/SKILL.md` |
| Context is filling up: large outputs, long files, repeated reads, planning a fan-out | `~/.claude/skills/principle-guard-the-context-window/SKILL.md` |

Before spawning parallel writers, assign each one its own file, branch, or worktree in the brief.
Instructions telling agents to avoid each other's files are not concurrency control.
