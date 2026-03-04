# Brew (must come first on Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Path
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="nvim"

# Language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Mise (manages Ruby, Node, Python runtimes)
eval "$(mise activate zsh)"

# Completions
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qNmh+24) ]]; then
    compinit
else
    compinit -C
fi

# Key bindings (Option+Arrow for word navigation)
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Starship prompt
eval "$(starship init zsh)"

# Aliases
[ -f ~/.aliases ] && source ~/.aliases

# Local/private config (not tracked in repo)
[ -f ~/.localrc ] && source ~/.localrc
