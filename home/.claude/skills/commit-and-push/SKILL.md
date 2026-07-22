---
name: commit-and-push
arguments: input
description: Commits by context, pushes to origin. 
---

1. Before staging, scan the diff and remove every explanatory/narrative code comment (doc blocks, inline "why" notes, comments restating the code) — including pre-existing ones in the lines you touched. Keep only functional pragmas (`# frozen_string_literal: true`, `# rubocop:...`, shebangs, schema/codegen annotations, required license headers). Code gets committed comment-free.
2. Commit the current stash. Separate by context.
3. Push when done.
4. Take the users request into account: $input.
