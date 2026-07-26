# Review: Preventing Accidental Information Suppression

## Review request

Review the proposed changes below to both `modules/codex/AGENTS.md` and
`modules/claude/CLAUDE.md`.

The goal is narrow: preserve the existing collaboration model while closing
instructions that a model could interpret as permission to omit material
information. Please check the proposal for semantic loss, redundancy,
instruction conflicts, and wording that could produce a new literal failure
mode.

Do not treat this as a request to rewrite or further condense the files. A
smaller alternative is welcome when it preserves every distinction described
here.

## Context

The previous rule capped ranked recommendation lists at five. In practice, that
cap changed the substance of an answer: a fourteen-item assessment stopped at
five findings. The cap has now been replaced with:

> **Keep lists scannable, not artificially short.** Put no more than five items
> in one visual group. If more relevant items exist, split them by priority or
> theme. Never omit material information solely to satisfy a count.

That change revealed a broader audit question: do any other rules encourage
useful shaping but accidentally authorize information loss?

The audit found four material risks and one related uncertainty issue. None is
as directly lossy as the old numeric cap.

## Proposed mirrored diff

Apply the same textual changes to both files. In the pattern-teaching rule,
retain the agent-specific filename: `AGENTS.md` for Codex and `CLAUDE.md` for
Claude.

```diff
diff --git a/modules/codex/AGENTS.md b/modules/codex/AGENTS.md
--- a/modules/codex/AGENTS.md
+++ b/modules/codex/AGENTS.md
@@
-- **Don't disclaim being an AI or hedge about not being human.** Established; restating it is noise. Not license for false certainty in the other direction: where something is actually uncertain, say so once and move on.
+- **Don't disclaim being an AI or hedge about not being human.** Established; restating it is noise. Not license for false certainty in the other direction: state uncertainty wherever it affects the conclusion, but don't repeat the same caveat.

@@
-- **When you put a decision to me, lead with the accepted best practice.** Name what it is and who says so (the platform vendor's docs, the framework's reference sample, or the de facto community default), then give your recommendation. If there is genuinely no established answer, say that outright; "no official guidance, here's the de facto default and why" is a real answer. A neutral menu of options presented as equals costs me a round trip, because I will just ask "what's best practice?" every time. Ground it in a source rather than asserting from memory, and search when you're unsure; this guidance shifts.
+- **When you put a decision to me, lead with the accepted best practice.** Name what it is and who says so (the platform vendor's docs, the framework's reference sample, or the de facto community default), then give your recommendation. If there is genuinely no established answer, say that outright; "no official guidance, here's the de facto default and why" is a real answer. A neutral menu of options presented as equals costs me a round trip, because I will just ask "what's best practice?" every time. Ground it in a source rather than asserting from memory, and search when you're unsure; this guidance shifts. Leading is not omitting: include materially different alternatives, tradeoffs, or uncertainty that could change the decision.

@@
-- **Give the earliest useful model, not a prematurely final answer.** State the assumptions and uncertainty that matter, then revise the model as new evidence arrives. An actionable answer and a finished understanding are different things.
+- **Start with the earliest useful model, not a prematurely final answer.** State the assumptions and uncertainty that matter, continue to the level of completeness the question calls for, then revise the model as new evidence arrives. An actionable answer and a finished understanding are different things.

@@
-- **Pattern-teaching is opt-in, not ambient.** When a repo's AGENTS.md declares itself a learning project, or I ask in the moment, explanations should teach: name the reusable principle behind the change, say where else it applies, and scale the scaffolding to what I already know. The repo's own file defines its specific working loop (pacing, gates, what gets narrated); everywhere without an opt-in, just get it done.
+- **Pattern-teaching is opt-in, not ambient.** When a repo's AGENTS.md declares itself a learning project, or I ask in the moment, explanations should teach: name the reusable principle behind the change, say where else it applies, and scale the scaffolding to what I already know. The repo's own file defines its specific working loop (pacing, gates, what gets narrated); everywhere without an opt-in, just get it done. This removes pedagogical ceremony, not useful explanation: briefly explain consequential or non-obvious choices, and answer questions without treating them as a mode change.

@@
-- **Match participation to the context.** During learning and exploration, let me reconstruct ideas and ask questions only when they improve the model. During execution, do not manufacture Socratic work for me: absorb incidental complexity, preserve earned understanding in the system, and surface the decisions, risks, and consequences that genuinely require me.
+- **Match participation to the context.** During learning and exploration, let me reconstruct ideas and ask questions only when they improve the model. During execution, do not manufacture Socratic work: absorb incidental complexity without going silent. Maintain operational visibility by surfacing consequential state such as progress, changed assumptions, significant findings, risks, and outcomes, whether or not I need to act. Preserve earned understanding in the system.
```

## Reasoning

### Information completeness

1. **Uncertainty is claim-local, not reply-global.** “Say so once and move on”
   correctly rejects repetitive AI disclaimers, but it can be read as permission
   to qualify only one uncertainty. The proposed wording keeps every uncertainty
   that changes the conclusion while suppressing repetition of the same caveat.

2. **Leading with a recommendation must not erase the decision space.** The
   existing rule correctly rejects neutral option menus that force Kevin to ask
   which choice is best. It does not explicitly require material alternatives
   or tradeoffs to survive. “Leading is not omitting” protects those without
   weakening the recommendation-first behavior.

3. **“Earliest” should control when a model becomes available, not when the
   answer stops.** The existing rule supports provisional understanding, but a
   model could treat “earliest useful” as “minimum sufficient.” The proposed
   wording requires completeness proportional to the question while preserving
   iteration.

### Execution visibility

1. **Pattern-teaching and useful explanation are different.** Opt-in teaching
   should remove pedagogical scaffolding, guided reconstruction, and unsolicited
   general lessons. It should not suppress brief reasoning for a consequential
   library or architecture choice. Asking one question during execution should
   create a short explanatory tangent, not switch the entire task into learning
   mode.

2. **Consequential state matters even when Kevin does not need to act.** The
   existing participation rule surfaces only what “genuinely requires” Kevin.
   That can hide progress, discoveries, changed assumptions, and completed
   outcomes. The proposed wording establishes operational visibility without
   mandatory participation: keep Kevin oriented while continuing autonomously.

## Deliberate non-changes

- **Paragraph sizing remains unchanged.** “Two or three sentences per paragraph”
  can be applied mechanically, but the surrounding rules explicitly say “one
  idea each” and “structure, not voice.” The ChatGPT failure that put every
  sentence on a new line contradicts the local text rather than exposing a
  missing boundary.

- **The single final action remains unchanged.** It controls the last-line
  handoff, not the amount of work, context, or available options in the body.

- **The single-language analogy remains unchanged.** It asks for one best anchor
  and a committed judgment. It does not prohibit mentioning another language
  when a contrast is materially necessary.

- **Intentional scope restrictions remain unchanged.** The email ban,
  greenfield stack bans, version-control policy, and statement-versus-task rule
  deliberately constrain action or deliverables. They are not accidental
  completeness limits.

## Questions for the reviewer

1. Does any proposed sentence duplicate an existing rule strongly enough that
   the duplication is more likely to create conflict than protection?

2. Can any wording be shortened without losing the distinction that motivated
   it?

3. Does the operational-visibility wording create pressure to narrate incidental
   implementation details, despite explicitly limiting itself to consequential
   state?

4. Is there another rule in either file that can suppress material information
   through literal compliance?

## Acceptance criteria

- Material findings are never omitted solely to satisfy a shape preference.
- Recommendations still lead, but decision-changing alternatives survive.
- Routine execution remains visible without becoming a seminar.
- Questions during execution receive useful answers without changing task mode.
- Repeated disclaimers disappear while consequential uncertainty remains clear.
