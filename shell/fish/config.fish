if status is-interactive
    # FZF defaults
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude .steam --exclude node_modules'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -g fish_greeting

    # Keybindings
    function tmux_fzf
        command tmux_fzf
        commandline -f repaint
    end

    bind \cf tmux_fzf
    bind \e\[1\;5C forward-word
    bind \e\[1\;5D backward-word

    # Aliases (vim handled by nix viAlias/vimAlias)
    alias ls='eza -l'
    alias c='clear'
    alias cat='bat'

    set -gx UV_NATIVE_TLS true
    set -gx MANPAGER "nvim +Man!"

    # Path
    fish_add_path -g \
        $HOME/.local/bin \
        $HOME/.cargo/bin \
        $HOME/go/bin \
        $HOME/.local/share/nvim/mason/bin

    fish_vi_key_bindings
end
