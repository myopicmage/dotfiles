---
name: learning-mode
description: "Kevin's working loop for implementation work he wants to learn from: plan first, then one stop at a time with the explanation arriving alongside each edit, gated on a rotating go-word. Use when a repo declares itself a learning project, when Kevin asks for learning mode by name, or when he asks to be walked through work rather than handed it."
---

# Learning mode

Kevin wants to learn *from* the implementation work, not just receive it. This is the
default for anything beyond a one-file tweak, and it stays on until he says otherwise.

## First: name the axis

Learning mode teaches one axis, and the axis is project-specific. Before the first edit,
state which one is in play.

- The repo's own `CLAUDE.md` / `AGENTS.md` may declare it. Formbuilder, for example:
  "the learning axis here is the domain patterns, not the language."
- If nothing declares it, ask in one line before planning.

**Two-sided rule for the language itself.** Don't narrate constructs Kevin already uses
fluently. But call out anything esoteric or gnarly explicitly: compiler quirks, type
inference oddities, macro or metaprogramming internals, non-obvious library idioms,
ecosystem-specific compilation traps.

## The loop

Two gates.

**1. Plan first.** Write the steps as a numbered list naming the files each one touches,
and show it before the first edit. Order the stops bottom-up, so each depends only on
stops already covered.

**2. Then work one stop at a time, explaining as you go.** For each stop: make the change
and explain it in the same message (what changed, why, and any concept it introduces),
then stop and wait for the go-word.

Do not complete the whole plan and narrate it afterwards. **The explanation arrives with
the edit, not after all the edits.**

**Make the change with the Edit/Write tools, never a script through Bash.** Only those
render a diff, so a scripted edit is invisible at the moment it lands and the explanation
arrives attached to nothing. The pull toward scripting comes from wanting match-count
assertions across files and from skipping Edit's read-first step; neither is worth the
lost diff. If a change genuinely must span many files identically, say so first and let
Kevin decide.

A stop is usually one bounded fix or one file. Batch only where batching genuinely reads
better, never where each file deserves its own explanation.

**3. One commit per stop**, naming the failure mode or concept in the message, so the git
log replays the curriculum.

## The go-word

At each gate, run `go-word`. It prints one tab-separated word and language and records
the selection in the shared recency state at `~/.agents/go-words.tsv`. Use the returned
pair exactly: "say *twende* (Swahili) when ready." Kevin advances by replying with that
word.

Do not improvise a synonym or choose from memory when the command is available. The
selector exhausts unused catalog entries first, then uses recency-weighted randomness.
If the command is unavailable, choose manually as before and do not block the stop.

## Restate position every turn

Open each stop with where we are: "Stop 3 of 6. Last one: X. This one: Y."

This is load-bearing, not ceremony. Kevin can't hold the running order between messages,
and these instructions can be compacted out of context in a long session. Restating
regenerates the state. **If you notice you have lost the plan, say so and ask for it back
rather than improvising a stop.**

## Tangents are the point

A question about a pattern, a comparison to another language, why a database does a
thing: these are why the mode exists, not a derailment. Answer fully, then re-prompt the
next stop.

Answering a question never ends learning mode and never consumes a gate.

## Decisions

Lead with the accepted best practice and who says so (the platform vendor's docs, the
framework's reference sample, the de facto community default), then give your
recommendation. Say plainly when no official guidance exists.

## Leaving

"Just do it", "skip the gates", or an explicit request to drop the loop ends it for the
current task. Otherwise it persists for the session.
