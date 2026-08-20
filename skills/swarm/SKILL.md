---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

Fan out N parallel workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Set N from the user or derive it from the shape. N is total workers, not the cloud concurrency limit.
4. Pick the worker model from the model table in CLAUDE.md. Default to `sonnet` for mechanical slices and `opus` for slices needing judgment. For a model race, name each arm's model up front. Check remaining quota with `/usage` before committing to a large fan-out.
5. Give each worker its own writable output when it writes. Use a worktree, a branch, or `/tmp/swarm-<slug>/worker-<n>/`. Never let two workers write the same file, branch, or key: see the **principle-separate-before-serializing-shared-state** skill. Assign file ownership per worker in the brief.

## Phase B: Fan out

Spawn all N workers in one message, one `Agent` call each, with `subagent_type: "general-purpose"` and an explicit `model`. Sending them in a single message is what makes them run concurrently.

When workers write to the same repo, pass `isolation: "worktree"` so each gets its own checkout and they cannot collide. It costs setup time and disk per worker, so use it only for writers; read-only workers don't need it.

For a fan-out whose control flow is fixed up front (one worker per item, then a verify stage per result), the `Workflow` tool is the better instrument: it scripts the fan-out deterministically and keeps worker output out of the parent context. Reach for it when the shape is known before the work starts, and for `Agent` fan-out when it isn't.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

Keep a compact result table, one-line evidenced issues, and explicit gaps or dropouts.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
