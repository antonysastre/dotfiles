---
name: merge-sync-cleanup
arguments: input
description: >
  Finish the current session's PR end-to-end: merge it to main, sync the machine's
  main checkout, then delete the feature branch (local + remote) and remove the git worktree.
  Trigger when the user says "merge-sync-cleanup", or asks to merge the current/this PR and
  clean up — wrap up the branch, ship it and tidy up, merge and remove the worktree, or finish
  and delete branches after merging. Optional $input may name the merge method (squash/merge/rebase).
---

You are finishing and tearing down the current feature branch. This is **destructive and outward-facing** (it writes to main, deletes branches on the remote, and removes a worktree). The user invoking this skill is the authorization to proceed, so do not ask for blanket permission — but you MUST hard-stop on the guardrail failures below and report instead of forcing through.

Work from the current worktree until the worktree itself must be removed. Run cleanup that targets the worktree from the **main checkout** so git isn't operating on its own cwd.

## 1. Gather context (read-only)

- `git branch --show-current` → the feature branch. If it is `main`/`master`, STOP — nothing to finish.
- `git rev-parse --show-toplevel` → the worktree path.
- `git worktree list` → the **first** entry is the primary/main checkout. Capture that path (call it MAIN).
- `gh pr view --json number,url,state,headRefName,mergeStateStatus,title,baseRefName` → the PR for this branch. If there is no PR, or its `state` is not `OPEN`, STOP and tell the user.

## 2. Guardrails — hard-stop and report if any fail

- **Working tree must be clean.** `git status --porcelain`. If there are uncommitted or untracked changes, STOP, show them, and ask for an explicit go-ahead — removing the worktree discards anything not committed. Only continue past dirty state on the user's confirmation.
- **PR must be mergeable.** Check `mergeStateStatus` and `gh pr checks <number>`. If checks are failing or the PR is blocked/conflicting, STOP, surface the failing checks, and let the user decide.
- **Base is main.** Confirm `baseRefName` is `main` (or the repo default). If it targets something else, STOP and confirm.

Print a one-line plan of what will happen (merge PR #N into main via <method>, sync MAIN, delete <branch> local+remote, remove worktree <path>) and then proceed.

## 3. Refresh the PR title and description

Before merging, make the PR title and body short and current — they should describe what actually landed, not a stale early draft. This matters especially with `--squash`, where the PR title/body become the commit message on main.

- Read what the PR really contains: `gh pr view <number> --json title,body` and `gh pr diff <number>` (and `git -C <worktree> log main..HEAD --oneline` for the commit arc).
- Rewrite the **title** to one concise, imperative line naming the change (e.g. "Add document extraction and taxonomy library"). No trailing period, no ticket noise, no AI attribution.
- Rewrite the **body** to a tight summary — one short sentence plus a handful of bullets covering what changed and anything a reviewer/future reader needs (migrations, config, follow-ups). Cut anything no longer true, resolved TODOs, and blow-by-blow history. Keep it plain: no "Generated with" / "Co-Authored-By" or any AI-attribution footer.
- Apply it: `gh pr edit <number> --title "<title>" --body "<body>"`.
- If the title and body are already short and accurate, leave them; say so and move on.

## 4. Merge the PR

- Method: default `--squash`. If `$input` names `merge` or `rebase`, use that instead.
- `gh pr merge <number> --<method> --delete-branch`
  - `--delete-branch` removes the remote branch and the local tracking ref where possible. The local branch is still checked out in the worktree, so it is deleted in step 5.
- Confirm success: `gh pr view <number> --json state` shows `MERGED`.

## 5. Sync the machine's main checkout

Run against MAIN (the primary checkout), not the worktree:

- `git -C <MAIN> fetch origin --prune`
- `git -C <MAIN> checkout main`
- `git -C <MAIN> pull --ff-only origin main`

Confirm the merge landed: `git -C <MAIN> log --oneline -1`.

## 6. Delete branches and remove the worktree

- **Remove the worktree.** git refuses to remove the worktree that is the shell's current directory, so change into MAIN first in the same command:
  `cd <MAIN> && git worktree remove <worktree-path>`
  Add `--force` only if git refuses because the worktree still holds uncommitted/untracked files the user already confirmed discarding in step 2.
  After this the old worktree directory is gone — run every later command with `cd <MAIN> && …` since the previous cwd no longer exists.
- **Prune worktree admin:** `git -C <MAIN> worktree prune`.
- **Delete the local feature branch** (now that it is no longer checked out): `git -C <MAIN> branch -D <branch>`.
- **Ensure the remote branch is gone:** `git -C <MAIN> push origin --delete <branch>` — expect it to already be deleted by `--delete-branch`; treat "remote ref does not exist" as success, not an error.

## 7. Report

State plainly: PR #N merged to main (URL), MAIN synced to <sha> on `main`, feature branch deleted local + remote, worktree removed. Note that the session's working directory is now the removed worktree — subsequent work should continue in MAIN. If any uncommitted local files were discarded with the worktree, remind the user they lived only there.

## Notes

- Never force-push, and never delete `main`/`master`.
- If `gh` isn't authenticated or the repo has no remote, STOP and say so rather than half-completing.
- Take the user's request into account: $input.
