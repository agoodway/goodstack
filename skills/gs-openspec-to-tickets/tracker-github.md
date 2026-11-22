# Tracker: GitHub

Use the `gh` CLI. The repo comes from `git remote -v`; before the first `gh issue create` of a run, confirm the target with `gh repo view --json nameWithOwner`, and confirm with the user when it is not their own repo (a fork can default to the upstream parent).

- **Labels**: list with `gh label list --json name --jq '.[].name'`; create a missing one with `gh label create <label> --description "<meaning>"`.
- **Ticket**: `gh issue create --title "<change title>" --body-file <file> --label <label> --blocked-by <n>,<n>` (`gh` 2.94+). Write bodies to a file outside the repository, so the text never becomes shell syntax.
- **Older `gh`**:
  - Blocker: `gh api --method POST repos/<owner>/<repo>/issues/<ticket>/dependencies/blocked_by -F issue_id=<blocker-db-id>`.
  - `<db-id>` is the numeric database id from `gh api repos/<owner>/<repo>/issues/<n> --jq .id`, not the `#number` or `node_id`.
- **No dependencies on the repo**: keep the template's `## Blocked by` section listing `#<n>` references.
- **Reference format** for `tickets.md`: `#<n>` linked to the issue URL.
