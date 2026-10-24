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
marker:#66dd44,spinner:#33B3D3,header:#B3A06D"

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

# Try exact case before falling back to case-insensitive matching. Oh My Zsh sets
# matcher-list unconditionally in lib/completion.zsh, so this has to come after it
# is sourced rather than living with the other completion styles near the top.
#
# The leading '' matters for more than tidiness: with only a case-insensitive spec,
# zsh treats C and c as the same character, so tabbing on an empty word in a
# directory holding CMakeLists.txt and code/ finds a one-character common prefix
# and inserts whichever case sorts first -- "C". fzf-tab then seeds fzf's query
# with that C, and fzf's smart-case reads the capital as deliberate and hides
# code/. Matching exact case first makes C and c distinct, so there is no common
# prefix, nothing is inserted, and the picker opens on the full list.
#
# Trade-off: a lowercase word now completes only to lowercase matches when any
# exist, so "c" resolves straight to code/ and never offers CMakeLists.txt.
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

KEYTIMEOUT=1
if (( $+widgets[autosuggest-accept] )); then
  bindkey -M viins '^F' autosuggest-accept
  bindkey -M emacs '^F' autosuggest-accept
fi

# Replaces nickeb96/puffer-fish from the Fish config: a third dot after ".."
# becomes "/..", so "....." types out as "../../../..". Oh My Zsh already ships
# global aliases for this (lib/directories.zsh), but they stop at five levels and
# are only expanded when the line is run, so "cd .../src<TAB>" cannot complete.
# Rewriting the buffer instead means completion sees a real path. The aliases stay
# harmless -- the buffer no longer contains a bare "..." for them to match.
#
# The leading delimiter check is what the published versions of this widget
# (wazum/zsh-directory-dot-expansion, the rationalise-dot snippet) leave out. They
# expand on any trailing "..", which corrupts "git diff a...b" and "git log
# HEAD~2...". Requiring the dots to start a word -- at the start of the line, or
# after whitespace, "=", ":" or "/" -- keeps those literal, while the "/" case is
# what lets an already-expanded "../.." grow another level.
#
# This has to come after oh-my-zsh.sh: vi-mode calls "bindkey -v", which resets
# the viins keymap and would drop the binding. Binding "." in isearch back to
# self-insert keeps Ctrl-R searches typeable, since the isearch keymap otherwise
# falls through to main and would run the widget against a search buffer.
_expand_dot_to_parent() {
  if [[ $LBUFFER =~ '(^|[[:space:]=:/])\.\.$' ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N _expand_dot_to_parent
bindkey -M viins '.' _expand_dot_to_parent
bindkey -M emacs '.' _expand_dot_to_parent
bindkey -M isearch '.' self-insert

# Map the checked-in Fish theme to zsh-syntax-highlighting token classes.
if (( ${+parameters[ZSH_HIGHLIGHT_STYLES]} )); then
  ZSH_HIGHLIGHT_STYLES[default]='fg=#B3B1AD'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF3333'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#33B3D3'
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

# Oh My Zsh aliases ls (lib/theme-and-appearance.zsh) and la (lib/directories.zsh).
# zsh refuses to define a function whose name is an active alias, and an alias
# would shadow the function even if it were defined, so both have to go. This must
# stay outside the block below: zsh parses a compound command in full before
# running any of it, so an unalias in there would come too late to help.
unalias ls la lst lt ltd 2>/dev/null

# Nerd Font icons live in the Unicode Private Use Area; less's default
# printable-character table treats PUA codepoints as binary and renders
# them as <U+XXXX> instead of the glyph. Mark them printable explicitly.
export LESSUTFCHARDEF='E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p'

if (( $+commands[eza] )); then
  # --icons takes an optional WHEN value, so it must be written --icons=always;
  # a bare trailing --icons swallows the first path argument as its value.
  #
  # Functions, not aliases: an alias appends its arguments after the entire body,
  # so a piped alias would hand paths to less instead of eza. less -F prints
  # normally when the output fits on one screen and only becomes scrollable when
  # it doesn't; -R keeps the colours and icons, -X leaves the output in
  # scrollback instead of clearing on exit. When stdout is not a terminal less
  # just passes everything through, so $(ls) and scripts are unaffected.
  #
  # No --width here: eza only needs it to keep grid columns when piped, and none
  # of these use grid -- long and tree views ignore width entirely.
  _ezap() { eza --color=always --icons=always "$@" | less -FRX; }
  ls()  { _ezap -a1 --group-directories-first "$@"; }
  la()  { _ezap -la --group-directories-first "$@"; }
  lst() { _ezap -a1 --group-directories-first --sort=modified "$@"; }
  lt()  { _ezap -aT --group-directories-first "$@"; }
  ltd() { _ezap -aDT "$@"; }
  alias l.='eza -a --color=always | grep -E "^\."'
fi
alias lo='/bin/ls'

# Type a tidbit from any terminal: `tidbit some idea`, or bare for $EDITOR.
# Guarded because ~/bin only exists once this repo's bin/ has been stowed.
[[ -x "$HOME/bin/tidbit" ]] && alias tidbit="$HOME/bin/tidbit"

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

# The export also redirects `p10k configure`, which would otherwise write a
# fresh ~/.p10k.zsh instead of updating this one.
export POWERLEVEL9K_CONFIG_FILE="$HOME/.config/zsh/p10k.zsh"
[[ -r "$POWERLEVEL9K_CONFIG_FILE" ]] && builtin source "$POWERLEVEL9K_CONFIG_FILE"

export EDITOR="nvim"
export VISUAL="nvim"

[ -f ~/.config/zsh/company.zsh ] && source ~/.config/zsh/company.zsh
