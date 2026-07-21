#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
[ -z "$cwd" ] && cwd=$PWD

branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
if [ -z "$branch" ]; then
  branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

dir="${cwd/#$HOME/~}"

model=$(echo "$input" | jq -r '.model.display_name // empty')

if [ -n "$branch" ]; then
  printf '\033[2m%s\033[0m  \033[36m%s\033[0m' "$dir" "$branch"
else
  printf '\033[2m%s\033[0m' "$dir"
fi

if [ -n "$model" ]; then
  printf '  \033[35m%s\033[0m' "$model"
fi
printf '\n'
