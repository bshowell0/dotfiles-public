function fish_user_key_bindings
    # If you use vi mode, enable it first:
    fish_vi_key_bindings

    # Load fzf.fish defaults: Ctrl-R, Ctrl-T, Alt-C
    if type -q fzf_configure_bindings
        fzf_configure_bindings
    end

    # Make Ctrl-F accept the fish autosuggestions
    bind \cf accept-autosuggestion
    bind -M insert \cf accept-autosuggestion  # also in vi insert mode

    # Optional: make Tab use fzf completion
     if type -q fzf_complete
         bind \t fzf_complete
     end
end
