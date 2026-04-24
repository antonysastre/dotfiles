# Brew (must come first on Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# API Development Keys
export GEMINI_API_KEY=$(op read "op://NC/Development/GEMINI_API_KEY")

# Path
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="zed --wait"

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

# Key bindings
bindkey "^[[1;3C" forward-word      # Option+Right
bindkey "^[[1;3D" backward-word     # Option+Left
bindkey "^[[A" history-search-backward  # Up arrow: search history matching current input
bindkey "^[[B" history-search-forward   # Down arrow: search history matching current input

# History substring search (type text, then up/down to find matching history)
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Starship prompt
eval "$(starship init zsh)"

# Aliases
[ -f ~/.aliases ] && source ~/.aliases

# Local/private config (not tracked in repo)
[ -f ~/.localrc ] && source ~/.localrc
