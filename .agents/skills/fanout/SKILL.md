---
name: fanout
description: Split a user-specified task across parallel Codex subagents with explicit or inferred worker count, model, and reasoning effort, then merge and verify their results. Use only when the user explicitly invokes `$fanout` to parallelize independent research, review, analysis, or implementation slices.
---

# Fanout

Treat the user's message that invoked `$fanout` as the task. If it supplies controls but no complete task, recover the task from the surrounding user message. If no task is available, ask what to fan out and stop.

## Preserve the authority boundary

Treat explicit `$fanout` invocation as authorization to create and coordinate subagents for the requested task. Do not treat it as authorization for destructive actions, external writes, production changes, credential use, or any action outside the user's existing request. Give every worker the same authority boundary.

## Know what fanout buys before dispatching

Three separate benchmarks on this machine measured fanout against the same work done inline: a file inventory, a dependency trace, and a code review over a fixture with seeded defects. In every run, fanout cost 3–10× the tokens and returned the same accuracy. No arm, fanned out or inline, at any reasoning effort, found a defect the others missed.

Fanout does not buy correctness. It buys parent-thread context, in proportion to how much each slice compresses before it reports back. Apply the compression test: will each worker read far more than it reports?

| Each worker | Fanout buys | Action |
|---|---|---|
| Reads a large surface and reports a short verdict, such as "which of these twelve modules touch auth" | A real context saving | Fan out |
| Reads a large surface and reports proportionally, such as inventorying every file or tracing every hop | 5–18% of the parent window | State this in one sentence and dispatch as asked |
| Requires a finding that a sibling worker holds | Nothing, because workers cannot exchange context | Reshape the slices, or state that inline work fits better |

When compression is low, tell the user in one sentence that inline work at high reasoning effort matched fanout in the benchmark at a fraction of the tokens. Then dispatch what the user asked for. The user invoked `$fanout`; this is a note, not a veto.

Wall-clock speed is not an established reason to fan out. In the code-review benchmark the fanned-out arms were slower than every inline arm, though limited concurrent slots make that timing pessimistic. Claim a latency benefit only when the available slots let every worker run at once.

## Decide the dispatch

Honor each explicit control exactly when the collaboration API supports it:

- Treat phrases such as `6 agents`, `on <model>`, and `at xhigh effort` as requested controls.
- Inspect the collaboration tool descriptions for the currently available model overrides and reasoning-effort values. Do not assume model names from another agent product.
- Inspect `list_agents` and the session's collaboration limits before dispatch. Do not hard-code a concurrency ceiling.
- If a requested count exceeds the available concurrent slots, state the limit and run the requested total in waves as slots become available.
- If a requested count does not match the natural seams, say so in one sentence and still dispatch the requested total. Give surplus workers distinct verification or adversarial-review scopes instead of overlapping implementation scopes.

When the user omits a control, apply these defaults:

| Control | Default | Reason |
|---|---|---|
| Worker model class | Strongest suitable available model | Weaker models iterate — the lightest model tested needed 71 tool calls where the strongest needed 35, spending roughly 1.8× the tokens |
| Worker reasoning effort | `medium` | Measured flat from `low` to `xhigh`; raising it buys output, not accuracy |
| Your own reasoning effort when merging | `high` or above | Effort pays where one agent holds the whole problem |

Spend the reasoning-effort budget on yourself rather than on the workers. The token figures above are **raw counts, not costs** — per-token prices differ by model class and again between agent products, so apply current rates before stating any conclusion about spend.

Honor an explicitly requested tier exactly. These defaults record a measurement, not a veto. Use `max` only when the user asks for it. Omit a model override when the available API does not expose a justified choice.

Set the worker count to the number of genuinely independent slices when the user omits it. If the seams are unclear, either split by known layers or send one discovery worker first, then dispatch the discovered slices.

Choose `fork_turns` deliberately:

- Use `none` when the prompt can contain all required context and isolation from the parent conversation improves independence.
- Use a positive turn count when the worker needs only recent conversation context.
- Use `all` only when full conversation history is essential and no model or reasoning-effort override is required.
- Use `none` or a positive turn count whenever setting `model` or `reasoning_effort`; a full-history fork inherits both and does not accept those overrides.

## Create disjoint slices

Give each worker one independent ownership boundary. Because Codex subagents share the same workspace, never assign concurrent workers to edit the same file. Assign one writer and make competing analyses read-only when ownership cannot be separated safely.

Build every worker message with these parts, in order:

1. State the owned scope and every sibling boundary. Include explicit negative scope such as “Own the reducer; do not read or edit the sibling-owned API layer.”
2. Supply ground truth: absolute paths, exact symbols, verbatim errors, relevant user constraints, and the authority boundary.
3. Ask the question. Label hypotheses and require confirm-or-correct treatment.
4. Specify the exact return headings or fields needed for merging.
5. Set a depth budget and stopping condition.

Tell each worker not to spawn additional agents unless its slice explicitly requires delegation. Require implementation workers to preserve unrelated and pre-existing user changes.

## Record and dispatch

Decide every field before spawning. Record whether count, model, reasoning effort, and `fork_turns` were `asked` or `inferred`.

Use a unique lowercase `task_name` such as `fanout_2_of_6_reducer`. Start each worker message with a compact record such as:

```text
Dispatch: worker 2/6 · <model> · xhigh · fork_turns none · model asked · effort asked · fork inferred
```

Call `spawn_agent` with `task_name`, `message`, and `fork_turns`, plus `model` and `reasoning_effort` only when chosen and supported. Issue all initial `spawn_agent` calls back-to-back without waiting between them so their work overlaps.

Use the collaboration controls intentionally:

- Use `send_message` to clarify or redirect a worker that is still running.
- Use `followup_task` to give a completed or idle worker another task while retaining its context.
- Use `wait_agent` and `list_agents` to collect every result and to fill later waves as slots open.
- Use `interrupt_agent` only when a worker is pursuing the wrong scope, acting unsafely, or no longer provides useful progress.

## Merge and verify

Read every worker return before drafting the synthesis. Then:

- Investigate any worker result that contradicts the original framing before choosing a conclusion.
- Verify claims against cited `file:line` evidence or the equivalent primary evidence for the task.
- Treat uncited claims as unverified until checking them locally or labeling the limitation.
- Resolve conflicting worker findings; do not merely report both.
- Report uncovered scope explicitly.
- Distinguish worker findings from checks performed by the parent agent.
- For code changes, inspect the combined diff and run proportionate tests after all worker edits finish.

Open the final answer with a complete dispatch record in this form:

```text
6 workers · <model or mixed> · <effort or mixed> · fork <value or mixed> · count asked · model inferred · effort asked · fork inferred
```

Report the actual worker count and tag every control. Follow that line with the merged, verified answer rather than pasted worker output.
