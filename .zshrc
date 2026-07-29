# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] &&
  builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Keep updates quiet and avoid changing the shell from inside Oh My Zsh.
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

# Fish-like history and suggestions.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt append_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#878787'

# Match the Fish fzf source and theme.
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }\
--color=fg:#B3B1AD,bg:#1c1c20,hl:#E6B450,\
fg+:#1c1c20,bg+:#E6B450,hl+:#1c1c20,\
info:#B3A06D,prompt:#af87ff,pointer:#ff5fff,\
marker:#66dd44,spinner:#39BAE6,header:#B3A06D"

# Configure completion before Oh My Zsh runs compinit.
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -a1 --color=always --group-directories-first $realpath 2>/dev/null || command ls -A $realpath'

# Reuse the Fish z database and notification threshold.
ZSHZ_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/z/data"
bgnotify_bell=false
bgnotify_threshold=5

# Use the cursor as the only Vi mode indicator.
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_INSERT=6
VI_MODE_CURSOR_NORMAL=2
VI_MODE_CURSOR_VISUAL=2
VI_MODE_CURSOR_OPPEND=2

plugins=(
  git
  vi-mode
  z
  fzf
  bgnotify
  colored-man-pages
  fzf-tab
  zsh-autopair
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  builtin source "$ZSH/oh-my-zsh.sh"
else
  bindkey -v
fi

KEYTIMEOUT=1
if (( $+widgets[autosuggest-accept] )); then
  bindkey -M viins '^F' autosuggest-accept
  bindkey -M emacs '^F' autosuggest-accept
fi

# Map the checked-in Fish theme to zsh-syntax-highlighting token classes.
if (( ${+parameters[ZSH_HIGHLIGHT_STYLES]} )); then
  ZSH_HIGHLIGHT_STYLES[default]='fg=#B3B1AD'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF3333'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#39BAE6'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff8700'
  ZSH_HIGHLIGHT_STYLES[command]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#af87ff'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#00afff,underline'
  ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#00afff,underline'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#B3B1AD'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#B3B1AD'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#66dd44'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#66dd44'
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#66dd44'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#95E6CB'
  ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#95E6CB'
  ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#95E6CB'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=#E6B450'
  ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#E6B450'
  ZSH_HIGHLIGHT_STYLES[assign]='fg=#00afff'
  ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ff5fff'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#b4bd68'
fi

typeset -U path PATH

[[ -d "$HOME/.lmstudio/bin" ]] && path+=("$HOME/.lmstudio/bin")
[[ -d "$HOME/.antigravity/antigravity/bin" ]] &&
  path+=("$HOME/.antigravity/antigravity/bin")

if [[ "$OSTYPE" == darwin* ]]; then
  android_studio_java='/Applications/Android Studio.app/Contents/jbr/Contents/Home'
  [[ -d "$android_studio_java" ]] && export JAVA_HOME="$android_studio_java"
  [[ -d "$HOME/Library/Android/sdk" ]] &&
    export ANDROID_HOME="$HOME/Library/Android/sdk"
elif [[ -d "$HOME/Android/Sdk" ]]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
fi
unset android_studio_java

if (( $+commands[bat] )); then
  export MANROFFOPT='-c'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

if (( $+commands[eza] )); then
  alias ls='eza -a1 --color=always --group-directories-first --icons'
  alias la='eza -la --color=always --group-directories-first --icons'
  alias lst='eza -a1 --color=always --group-directories-first --icons --sort=modified'
  alias lt='eza -aT --color=always --group-directories-first --icons'
  alias ltd='eza -aDT --color=always --icons'
  alias l.='eza -a --color=always | grep -E "^\."'
fi
alias lo='/bin/ls'

y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# Let Powerlevel10k render the active Conda environment instead of altering PS1.
export CONDA_CHANGEPS1=false
for conda_exe in \
  /opt/homebrew/Caskroom/miniforge/base/bin/conda \
  "$HOME/miniforge3/bin/conda" \
  "$HOME/mambaforge/bin/conda" \
  /home/linuxbrew/.linuxbrew/Caskroom/miniforge/base/bin/conda
do
  if [[ -x "$conda_exe" ]]; then
    eval "$("$conda_exe" shell.zsh hook 2>/dev/null)"
    break
  fi
done
unset conda_exe

[[ -r "$HOME/.p10k.zsh" ]] && builtin source "$HOME/.p10k.zsh"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] &&
  builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
