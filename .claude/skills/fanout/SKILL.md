---
name: fanout
description: Split a job across parallel subagents with explicit control over worker count, model, and reasoning effort — the last of which the Agent tool cannot set on its own.
argument-hint: [N agents] [model] [effort] — <task>
disable-model-invocation: true
---

# Fanout

## This invocation

    $ARGUMENTS

Session effort is `${CLAUDE_EFFORT}`. If the line above is empty, ask what to fan out
and stop.

Everything below is a standing instruction for the rest of this task, not a one-time
checklist.

## The knob that does not exist

The Agent tool accepts `prompt`, `subagent_type`, `model`, `isolation`, `description`.
There is no effort parameter. Effort comes only from a subagent definition's `effort:`
frontmatter, so five worker definitions exist, one per tier:

    fanout-low  fanout-medium  fanout-high  fanout-xhigh  fanout-max

Each sets effort and nothing else — no `model:` field — so the per-call `model`
parameter wins. Effort and model are therefore chosen independently:

    Agent(subagent_type="fanout-xhigh", model="opus", prompt=..., description=...)

Skip this and effort silently falls back to the session's. "The tool has no effort
parameter" is the reason to use `fanout-<effort>`, never a reason to drop the request.

## Required: the dispatch record

Two places, both things you already have to write.

**Every Agent call's `description`** — a required parameter — reads:

    fanout 2/6 · sonnet · xhigh

**Your answer to the user opens with one line:**

    6 workers · sonnet · fanout-xhigh · no isolation · count+model+effort asked

Every field filled, each tagged `asked` or `inferred`. A field you cannot fill is a
field you never decided.

## Reading the request

If the invocation line above carries knobs but no task, or reads like a fragment cut
short, take the task from the user's message instead of proceeding on the fragment.
Skills expand only at the start of a message, so a `/fanout` typed mid-message can
arrive with its task missing.

Honor anything stated, exactly: `6 agents`, `on opus`, `at xhigh effort`, `in worktrees`,
`read-only`, `haiku`. If a stated count looks wrong for the seams in the work, say so in
one sentence and dispatch what was asked anyway.

Infer the rest from the slice, not the session:

| Slice work | Model | Effort |
|---|---|---|
| Locate, list, extract, restate | haiku | low |
| Read one area and summarize | sonnet | medium |
| Trace across files, weigh a design call | opus | high |
| Verify a contested finding, adversarial review | opus | xhigh |
| — | | `max` only when asked |

`${CLAUDE_EFFORT}` is the fallback when no row clearly fits — not an automatic answer,
since a slice is usually narrower than the session's own work.

**Count = the number of genuinely independent slices.** Not a round number. Three real
seams means three workers even if the phrasing suggested more. When the seams are not
knowable in advance, either split by layer — state → translation → wire is knowable a
priori when the file set is not — or send one `Explore` agent to find the seams, then
fan out. Ceiling is 20 concurrent, 200 per session.

## The slice prompt

A worker sees none of this conversation. Every slice prompt has five parts, in order:

1. **Scope, with the sibling boundary.** "You own the reducer. A sibling has the axios
   layer — do not read it." Negative scope is what stops three workers returning the
   same file.
2. **Ground truth.** Absolute paths, exact symbol names, verbatim error text. Paste it.
3. **The question, as a question.** Where you have a hypothesis, label it as one:
   *"I expect this lands as a `datetime` param — confirm or correct."* A worker handed
   an assertion documents the assertion, and it returns to you as fact.
4. **Return shape.** The exact headings or fields you will merge.
5. **Budget.** How deep to go and when to stop.

## Dispatching

- **All Agent calls in one message** — that is what makes them parallel. One per message
  is sequential.
- `isolation: "worktree"` when two or more workers write files. Omit for read-only; it
  costs setup time and disk.
- Workers inherit every tool. For enforced read-only breadth, prefer the built-in
  `Explore` agent — it denies Write and Edit, at the cost of not pinning effort.
- Need a worker that already has this conversation's context? That is `fork`, which
  inherits the session's model and effort and ignores `fanout-*`.
- To follow up with a worker, `SendMessage` its agent ID. Re-dispatching throws away its
  context and spends a fresh session slot.

## Merging

Read every return before writing a word of synthesis. Then:

- **A worker contradicting your framing outranks your framing.** That is the signal you
  fanned out for. Chase it before writing it up.
- Attribute claims to the cited `file:line`. An uncited worker claim is unverified — say
  so, or verify it yourself.
- Conflicting workers mean one is wrong. Resolve it; do not report both.
- Say what a worker could not cover, and never present your own reads as worker output.

## Common mistakes

| Mistake | Instead |
|---|---|
| Answering without saying what you dispatched | Open the answer with the record line |
| Dropping effort because the tool has no parameter | `subagent_type: fanout-<effort>` |
| Defaulting every worker to the session effort | Choose from the slice's row |
| Padding to hit a requested count | Say the seams don't support it, dispatch as asked |
| Slices that overlap | Give each worker explicit negative scope |
| Stating your hypothesis as fact in the prompt | Label it, ask for confirm-or-correct |
| Worktrees for a read-only trace | Omit `isolation` |
| Pasting worker output as the answer | Merge, resolve conflicts, attribute |
