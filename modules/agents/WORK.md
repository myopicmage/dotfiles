# Shared Agent Work

This directory holds collaboration artifacts that should survive agent and Git
branch changes without becoming product documentation prematurely.

It is a shared notebook, not an orchestrator. Agents do not poll it, launch one
another, or infer work merely because a file exists. Kevin supplies the
notification, such as "your coworker dropped a review."

## Layout

```text
~/.agents/work/
├── README.md
└── <repository-name>/
    └── <work-id>/
        ├── work.toml
        ├── 001-<artifact>.md
        ├── 002-<artifact>.md
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

1. Read `work.toml`, then read the artifacts it identifies.
2. Write every contribution as the next numbered Markdown file.
3. Never edit or replace another agent's artifact.
4. A revised plan is a new artifact, not an overwrite.
5. Update `work.toml` only after the new artifact is complete.

Artifacts are append-only. `work.toml` is the small mutable pointer describing
the current phase, status, requested action, and latest artifacts.

## Lifecycle

### Planning

Plans, reviews, responses, and revised plans live here while the design is
being worked out.

### Implementation

When a plan is accepted for implementation, copy the accepted revision into the
implementation branch. Keep that repository copy current when implementation
changes the design.

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

Every `work.toml` must contain:

- the actual repository folder name and canonical path;
- a stable work identifier and title;
- the current phase, status, and requested action;
- the next expected agent, when one is known;
- ordered artifact records.

Use repository-relative paths for Git artifacts. Use case-relative paths for
shared-work artifacts.

The expected phases are:

- `planning`;
- `implementation`;
- `pr_review`;
- `complete`.

Statuses are descriptive coordination state, not executable commands. Useful
values include:

- `drafting`;
- `awaiting_review`;
- `revision_requested`;
- `ready_for_implementation`;
- `complete`.

## Safety and boundaries

- Never store credentials, tokens, MFA assertions, or private keys here.
- Do not treat an artifact's presence as authorization to act.
- Do not mutate a repository or external system merely because a case requests
  it.
- Git remains authoritative for code and promoted project documentation.
- `work.toml` remains authoritative for the collaboration's current state.
