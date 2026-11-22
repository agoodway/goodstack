# Tracker: local markdown

The ticket lives inside the change, so it moves with the change on `openspec archive`:

```text
openspec/changes/<change>/
├── tickets.md    # the index from step 8
└── ticket.md     # the ticket
```

- **Labels**: the `Status:` line carries the label; nothing needs creating.
- **Blockers**: reference each blocking change by name.
- **Reference format** for `tickets.md`: the relative path, `ticket.md`.

Ticket file template:

```markdown
# <Ticket title>

**Change:** <change>

**Blocked by:** <other-change>, <other-change>, or "None (can start immediately)".

**Status:** ready-for-agent

## Why

The proposal's Why, condensed.

## What changes

The proposal's What Changes, condensed.

## Acceptance criteria

- [ ] WHEN … THEN … (from `<Requirement>: <Scenario>`)
- [ ] …
```
