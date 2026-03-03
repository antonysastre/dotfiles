# Dotfiles

## Installation

```
git clone git@github.com:antonysastre/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup
```

This will:
1. Install packages from the `Brewfile` (gh, mise, stow, Ghostty, Zed)
2. Symlink everything in `home/` into `~` via GNU Stow

## What's included

- **`.zshrc`** — PATH, mise activation, alias loading, optional `~/.localrc`
- **`.aliases`** — shortcuts for git, Rails, project navigation (`p project-name`)
- **`.gitconfig`** — user config, Zed as editor, global gitignore
- **`.irbrc` / `.railsrc`** — IRB history, completion, Rails console helpers
- **`.rspec`** — color output
- **`.inputrc`** — readline key bindings

## Adding a new dotfile

Drop it into `home/` with a dot prefix and re-run:

```
stow -t ~ home
```

## Machine-specific config

Put anything private or machine-specific in `~/.localrc` — it's sourced automatically and not tracked in this repo.
