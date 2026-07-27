# Shared Agent Work

This directory holds collaboration artifacts that should survive agent and Git
branch changes without becoming product documentation prematurely.

It is a shared notebook, not an orchestrator. Agents do not poll it, launch one
another, or infer work merely because a file exists. Kevin supplies
notification, such as "your coworker dropped a review."

## Layout

```text
~/.agents/work/
├── README.md
└── <repository-name>/
    └── <work-id>/
        ├── work.toml
        ├── 001-<topic>-<author>-<artifact-id>.md
        ├── 001-<topic>-<author>-<artifact-id>.md.sha256
        └── ...
```

`repository-name` is the actual canonical repository folder name. It must not
come from a temporary or linked worktree name.

For a linked Git worktree, derive the canonical repository from the common Git
directory:

```sh
git rev-parse --git-common-dir
```

If that resolves to `/Users/kevin/code/BRBAviation/.git`, use:

```toml
repository_name = "BRBAviation"
repository_path = "/Users/kevin/code/BRBAviation"
```

## Artifact protocol

The case directory is authoritative for **which artifacts exist**. `work.toml`
is a coordination cursor and never the artifact index.

To read a case:

1. Run `agents-work validate <case-directory>`. The validator discovers
   artifacts, parses metadata, verifies sidecars, compares any legacy manifest
   entries, and returns the verified artifact set plus anomalies.
2. Read the verified artifacts the causal graph requires.
3. Read `work.toml` as a possibly stale coordination cursor.
4. Surface anomalies. Never repair them silently.

The validator exits nonzero on malformed metadata, a missing artifact, a
missing sidecar, an orphan sidecar, or a hash mismatch. It prints the complete
discovered inventory even when validation fails, so the failure can be
explained rather than merely reported.

To contribute:

1. Run `agents-work draft <case-directory> --kind <kind> --author <agent>`. It
   writes a hidden draft beside the case, with valid front matter already
   filled in, and prints the path.
2. Write the body. Leave the generated front matter alone apart from the
   optional `source_*` and `subject_*` fields.
3. Run `agents-work publish <case-directory> <draft-path>`.
4. Update only `work.toml`'s coordination fields, and update them once.

`--responds-to` and `--supersedes` accept either a full artifact filename or a
bare sequence number. A sequence number that matches more than one artifact is
an error rather than a guess, because concurrent writers may legally share one.

Hand-writing the front matter still works, under any temporary name that does
not match the discovery pattern. `draft` exists because the sequence, the
artifact ID, the timestamp and the exact field set are all constraints stated
elsewhere in this document, and a generator cannot forget them. It validates
its own output before writing, so a generated draft fails only on what the
author adds.

The publishing command verifies the front matter, writes the integrity
sidecar, and publishes the Markdown last. Publication is no-clobber. It
generates no replacement content and never overwrites an existing artifact or
sidecar.

Artifacts are append-only. Never edit or replace another agent's artifact. A
revised plan is a new artifact that names what it supersedes, not an overwrite.

## Concurrent agents

More than one agent may be active in the same case at the same time. This is
expected, not an error, and the protocol is built to tolerate it:

- artifacts are append-only, so concurrent contributions cannot overwrite each
  other;
- filenames carry a random artifact ID and publication is no-clobber, so names
  are collision-resistant and a collision fails instead of replacing work;
- the same sequence number from different writers is legal and records that
  the work was concurrent from each writer's perspective;
- ordering within a sequence is undefined and does not need defining;
- causality is recorded by `responds_to` and `supersedes`, never inferred from
  sequence order.

Kevin is the notification layer, not a scheduler. Nothing in this protocol
requires him to serialize agents.

## Artifact front matter

Every new artifact begins with TOML front matter delimited by `+++`. It is
written once and never edited.

```toml
+++
artifact_schema_version = 1
artifact_id = "6f82a1"        # 6 random lowercase hex characters
sequence = 3
kind = "plan"                 # plan | review | proposal | decision | response
topic = "derived-state"
author = "claude"
created_at = "2026-07-27T18:07:42+09:00"
responds_to = []              # case-relative filenames this artifact read
supersedes = []               # case-relative filenames this replaces
source_branch = ""            # optional, when promoted from or to Git
source_commit = ""
source_path = ""
subject_repository = ""       # optional, what this artifact is about
subject_path = ""
subject_commit = ""
+++
```

`responds_to` records the inputs actually considered. `supersedes` records
replacement, so `kind` describes what the document is rather than how it
relates to an earlier document.

`sequence` is for human scanning and rough ordering only. It must never be
treated as a complete causal history.

## Integrity sidecars

Each artifact has a sidecar named `<artifact-filename>.sha256` containing
exactly one line:

```text
<lowercase-sha256><two spaces><artifact-filename><newline>
```

The hash covers the exact Markdown bytes. These are integrity checks against
accidental edits and interrupted writes. They are not tamper resistance.

The sidecar becomes final before the Markdown. A crash between those operations
leaves an orphan sidecar, which the validator reports as evidence of an
interrupted publication.

## Convergence

Convergence is a stopping condition. Stop producing artifacts when the next
artifact would only restate agreement, polish wording, or echo reasoning that
is already recorded.

An artifact is justified when it does at least one of these:

- records the result of an independently requested review, including a
  no-findings result;
- changes the plan or implementation;
- exposes a new risk, assumption, disagreement, or missing decision;
- answers an unresolved question;
- preserves reasoning needed for implementation or future archaeology.

When an author adopts all requested changes without qualification and
introduces no new tradeoff, the revision may mark the case converged. The
reviewer does not need to respond merely to confirm that agreement.

When a requested review finds no material issue, record that result once and
advance the coordination cursor. Do not create a response artifact agreeing
with the no-findings review.

A case is not converged while any material disagreement, unresolved risk,
missing decision, required change, or requested verification remains.

**Stop when you are just agreeing loudly.**

## Decisions are artifacts

A decision that changes whether work proceeds is recorded as an artifact, not
only as coordination state. This includes deferring, holding, cancelling,
descoping, or approving a case, and any instruction from Kevin that an agent
would otherwise have to remember.

`work.toml` may reflect such a decision. It must never be the only record of
one. When the cursor and a decision artifact disagree, the artifact wins.

This is what makes a possibly stale cursor safe. Without the durable artifact,
a stale cursor silently discards decisions instead of merely lagging them.

## Cross-channel decisions

Kevin speaks to each agent on a separate channel. No agent can see another's, so
every record of a human decision is evidence from one channel rather than the
complete picture.

An agent may record what Kevin told it, attributed and dated.

An agent must **not** correct or overwrite another agent's attributed record of
a human decision on the strength of its own channel alone, **even when it is
confident its own record is complete**. Ask Kevin to resolve the conflict and
leave both records standing.

Ask rather than infer whenever uncertain about a human decision, its scope, or
whether it still stands.

Absence of a decision in this notebook is not evidence that it was not made.

These are three mechanisms, not one, because they fire on different things. The
rule above is unconditional and does not depend on the acting agent feeling
uncertain, which is the point: both incidents that produced this section
involved an agent acting confidently. `Decisions are artifacts` makes a decision
visible to an agent that was not in the conversation. The uncertainty default
covers cases where an agent already knows its information is incomplete.

No protocol reliably catches a decision that was never recorded and that the
current agent has no reason to suspect exists. When a decision matters, the
mitigation is to tell one agent and let the artifact carry it.

## Lifecycle

### Planning

Plans, reviews, responses, and revised plans live here while the design is
being worked out.

### Implementation

When a plan is accepted for implementation, copy the accepted revision into
the implementation branch. Keep that repository copy current when
implementation changes the design.

The final implementation PR should contain the code and the plan as executed.
That plan records:

- implementation status and completion date;
- the implementing PR or merge commit;
- meaningful departures from the accepted plan;
- deferred work;
- constraints and rejected alternatives needed for future archaeology.

### PR review

Cross-agent PR reviews are new append-only artifacts in the same case. Record
the ADO PR identifier and exact reviewed commit in `work.toml`.

Post findings to ADO only when Kevin requests outward-facing review comments.
The shared case remains the working collaboration record.

### Completion

Set the case to `phase = "complete"` only after implementation and requested PR
review work have finished. Do not delete the case automatically.

## Manifest rules

Every `work.toml` records coordination state only. It contains:

- `schema_version = 2`;
- the actual repository folder name and canonical path;
- a stable work identifier and title;
- the current phase, status, and requested action;
- the next expected agent when one is known;
- implementation and PR pointers when they exist.

It must not contain an artifact index. `latest_sequence`, `latest_artifacts`,
and `[[artifacts]]` are legacy fields and are removed after migration.

Use repository-relative paths for Git artifacts. Use case-relative paths for
shared-work artifact relationships.

The phases are:

- `planning`;
- `implementation`;
- `pr_review`;
- `complete`.

The statuses are:

- active: `drafting`, `awaiting_review`, `revision_requested`;
- resting: `ready_for_implementation`, `deferred`, `complete`.

An active status requires a non-empty `next_agent`. A resting status requires
`next_agent` to be empty.

`ready_for_implementation` does not authorize action. It means planning has
converged and awaits Kevin's instruction. Artifact presence is never an
instruction to act.

`work.toml` is authoritative for the current recorded coordination state, but
it may be stale after concurrent work. Artifacts and Kevin's latest instruction
are never discarded to make the cursor look consistent.

The active/resting invariant detects malformed cursor pairs. It cannot detect a
complete valid-to-valid cursor overwrite. Durable decision artifacts expose
that semantic conflict.

## Legacy migration

The schema-1 migration is the sole authorized mutation of legacy artifact
files. For each file, record its old filename and SHA-256, preserve the
Markdown body exactly, prepend only the new front matter, rename it, and record
the new filename and SHA-256. Put that mapping in one migration artifact.

Discover the inventory when migration begins. Any count written in advance is
already stale. After migration, append-only enforcement is absolute.

During the reload boundary, legacy manifest artifact fields remain populated
with the migrated filenames and hashes. Remove them and set
`schema_version = 2` only after active agent sessions have reloaded this
guidance.

## Safety and boundaries

- Never store credentials, tokens, MFA assertions, or private keys here.
- Do not treat an artifact's presence as authorization to act.
- Do not mutate a repository or external system merely because a case requests
  it.
- Git remains authoritative for code and promoted project documentation.
- `work.toml` is coordination state, not authorization or durable history.
