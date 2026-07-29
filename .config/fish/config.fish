# 3rd party tools in this config:
# fzf, fd, lolcat, bat, eza, conda

if status is-interactive
    fzf_configure_bindings
end

function fish_greeting
    echo Welcome to fish\nThe time is (date +%T) on machine $hostname | lolcat
end

# use the running fish binary each session
set -gx fish_path (status fish-path)

alias rrm='rm'

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND

# Things added inspired by CachyOS defaults

## Format man pages
set -x MANROFFOPT "-c"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

## Environment setup
### Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

# Replace ls with eza
alias ls='eza -a1 --color=always --group-directories-first --icons' # preferred listing
# alias la is a fish builtin alias for `ls -lAh $argv`              # long format
alias lst='eza -a1 --color=always --group-directories-first --icons --sort=modified'
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias ltd='eza -aDT --color=always --icons'                         # tree directories
alias l.="eza -a | grep -e '^\.'"                                   # show only dotfiles
alias lo='/bin/ls'                                                  # original ls command


set -gx JAVA_HOME '/Applications/Android\ Studio.app/Contents/jbr/Contents/Home'

set -gx ANDROID_HOME "$HOME/Library/Android/sdk"

# Added by LM Studio CLI (lms)
set -gx PATH $PATH $HOME/.lmstudio/bin
# End of LM Studio CLI section

# Added by Antigravity
# this line failed:
# fish_add_path $HOME/.antigravity/antigravity/bin
set -gx PATH $PATH $HOME/.antigravity/antigravity/bin

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if status is-interactive
    if test -f /opt/homebrew/Caskroom/miniforge/base/bin/conda
        eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" "hook" $argv | source
    else
        if test -f "/opt/homebrew/Caskroom/miniforge/base/etc/fish/conf.d/conda.fish"
            source "/opt/homebrew/Caskroom/miniforge/base/etc/fish/conf.d/conda.fish"
        else
            set -x PATH "/opt/homebrew/Caskroom/miniforge/base/bin" $PATH
        end
    end
end
# <<< conda initialize <<<
