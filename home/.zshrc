# Path
export PATH="$HOME/.local/bin:$PATH"

# Mise
eval "$(mise activate zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Aliases
[ -f ~/.aliases ] && source ~/.aliases

# Local config
[ -f ~/.localrc ] && source ~/.localrc
