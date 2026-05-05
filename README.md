# Dotfiles

## Installation

```
git clone git@github.com:antonysastre/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup
```

This will:
1. Install Homebrew (if not present)
2. Install packages from the `Brewfile` (mise, starship, stow, Ghostty, Zed, Nerd Fonts)
3. Symlink everything in `home/` into `~` via GNU Stow
4. Remap Caps Lock to Control

Re-running `./setup` updates packages and refreshes symlinks. If a real file already exists where stow wants to place a symlink, setup aborts and lists the conflicts — resolve by removing or backing up the conflicting file, then re-run.

## What's included

- **`.zshrc`** — brew, mise, starship prompt, completions, keybindings, alias/localrc loading
- **`.aliases`** — shortcuts for git, Rails, project navigation (`p project-name`)
- **`.gitconfig`** — SSH commit signing via 1Password, nvim editor, git-lfs, global gitignore
- **`.irbrc` / `.railsrc`** — IRB history, completion, Rails console helpers
- **`.rspec`** — color output
- **`.inputrc`** — readline key bindings
- **`starship.toml`** — Nerd Font icons for the Starship prompt
- **`.claude/settings.json`** — Claude Code preferences (editor mode, plugins, permission allowlist)
- **`com.local.capslock-to-ctrl.plist`** — Caps Lock remap on login

## Adding a new dotfile

Drop it into `home/` with a dot prefix and re-run:

```
stow --no-folding -t ~ home
```

`--no-folding` ensures stow symlinks individual files rather than entire directories — important for paths like `~/.claude/` where only one file should be tracked while the rest of the dir holds local state.

## Machine-specific config

Put anything private or machine-specific in `~/.localrc` — it's sourced automatically and not tracked in this repo.
