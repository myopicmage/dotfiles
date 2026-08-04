# Agents-work ergonomics plan as executed

## Implementation record

- Status: implemented locally on 2026-08-04.
- Implementation branch: `codex/agents-work-ergonomics`.
- Implementing commit: the commit that introduces this file.
- Pull request or merge commit: not created.
- Accepted shared-work plan: `002-agents-work-ergonomics-claude-c02b10.md`.
- Accepted review: `003-agents-work-ergonomics-codex-0ac273.md`, no findings.

## Scope

This change implements two accepted improvements to `agents-work`:

1. Malformed artifact input produces concise domain errors and directs the
   caller to `agents-work draft` when generated front matter would help.
2. Cursor readiness and resumption ownership become separate facts without a
   schema migration.

The following remain out of scope:

- a causal-context summary command;
- locking or compare-and-swap cursor protection;
- authentication or signature features;
- MCP server or dashboard work;
- autonomous scheduling or agent wakeups;
- artifact changes intended only to reduce pathological rotation volume.

## Actionable publish failures

### Observed failure

`validate_prepared_artifact` derived a canonical filename before validating
required metadata. A hand-written draft without `sequence` therefore raised a
raw `KeyError`; a string `sequence` raised a raw `ValueError`.

### Implemented design

Field validation is now a separate boundary that does not inspect the draft
filename. `publish` validates front-matter fields before any canonical filename
derivation. Missing, malformed, or mistyped front matter raises
`ValidationFailure` with a command hint for generating a valid draft.

Relationship-target failures do not receive that hint because regenerating
front matter cannot make a missing target exist. Unexpected internal exceptions
are not caught broadly, so programmer failures still produce diagnostic
tracebacks.

### Verification cases

- missing `sequence` reports the field and a draft hint;
- string `sequence` reports the required type and a draft hint;
- absent front matter reports the parse error and a draft hint;
- missing relationship targets do not receive an irrelevant draft hint;
- normal draft, publish, and validate behavior remains green.

## Gated resumption ownership

### Observed mismatch

The cursor previously treated all resting statuses as requiring an empty
`next_agent`. A learning-mode gate could therefore record either that work
awaited Kevin or which agent retained responsibility for resuming, but not
both.

### Implemented design

`status` records readiness. `next_agent` records resumption ownership.

- Active statuses still require a non-empty `next_agent`.
- `ready_for_implementation` and `deferred` may name a resumption owner.
- Resting status never grants permission to act, whether it names an owner or
  not.
- `complete` still requires an empty `next_agent` because there is nothing to
  resume.

When `cursor` moves to a resting status without an explicit `--next-agent`, it
still clears the previous value. This prevents stale ownership from riding
along by default while allowing deliberate ownership to be recorded.

Schema version 2 is unchanged. Every previously valid cursor remains valid.

### Verification cases

- ready and deferred cursors accept an explicit resumption owner;
- entering a resting status without an owner still clears the old owner;
- complete with an owner is rejected;
- active without an owner is still rejected;
- cursor output and case validation agree on every accepted state.

## Departures from the accepted plan

No design departure was required. Implementation also made `kind` validation
type-safe before set membership, closing another malformed-input traceback at
the same validation boundary.

## Deferred work

None within the accepted scope. The explicit exclusions above remain separate
future decisions.
