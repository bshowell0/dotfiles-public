# Homebrew is not on the default PATH on Apple Silicon or Linuxbrew systems.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
elif (( $+commands[brew] )); then
  eval "$(brew shellenv zsh)"
fi
