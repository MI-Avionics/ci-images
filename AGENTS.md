# Agent rules

Rules every agent follows in this repository. The README describes the project.

## Review and merge

- Changes reach the default branch through a pull request with its required checks green. Add
  Devin or Reece as a reviewer.
- When a reviewer requests changes, the author pushes the fixes, answers each thread with the
  fixing commit and its proof, and resolves the thread. That counts as the reviewer's approval.
  Do not request a re-review or wait for a new approval.
- Merge with a merge commit pinned to the head you checked:
  `gh pr merge <n> --merge --match-head-commit <sha>`. If GitHub still shows the old review as
  blocking, a repo admin adds `--admin`. The rulesets let admins bypass through a pull request
  only.
- Never force-push. Never merge a pull request that another session is still pushing to.

The `team-process` plugin's `review-and-merge` skill has the reasons (MILLIT-826).
