# Agent rules

Rules every agent follows in this repository. The README describes the project.

## Review and merge

- Changes reach the default branch through a pull request with its required checks green. Add
  Devin or Reece as a reviewer.
- When a reviewer requests changes, the author pushes the fixes and answers every finding with
  the fixing commit and its proof. A finding in a review thread gets its reply there, and the
  author then resolves the thread. Findings in a review's body get one reply on the pull request
  that answers each of them. That counts as the reviewer's approval. Do not request a re-review
  or wait for a new approval.
- Merge with a merge commit pinned to the head you checked:
  `gh pr merge <n> --merge --match-head-commit <sha>`. If GitHub still blocks the merge on the
  old review, a repo admin adds `--admin`.
- `--admin` gets past every rule on the branch, required checks included. Use it only for the
  old review, never to merge past a red or pending check. Where the branch has no protection,
  these lines are the only control.
- Never force-push. Never merge a pull request that another session is still pushing to.

The `team-process` plugin's `review-and-merge` skill has the reasons (MILLIT-826).
