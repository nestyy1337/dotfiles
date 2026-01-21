if status is-interactive
    # Set fzf default command as environment variable
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude .steam --exclude node_modules'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

    # Keybindings
    function tmux_fzf
        command tmux_fzf
        commandline -f repaint
    end

    function fzf_file_search
        set -l result (fd --type f --hidden --follow --exclude .git --exclude .steam --exclude node_modules | fzf)
        if test -n "$result"
            commandline -i "$result"
        end
        commandline -f repaint
    end


    bind \cf tmux_fzf


    # Word movement with Ctrl+Left/Right
    bind \e\[1\;5C forward-word
    bind \e\[1\;5D backward-word

    # Aliases
    alias ls='exa -l'
    alias vim='nvim'
    alias c='clear'
    alias cat='bat'

    # Shell integrations
    # fzf_key_bindings
    # zoxide init fish | source
    fzf_key_bindings

    # Starship prompt
    # set -gx STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
    # starship init fish | source

    set -gx UV_NATIVE_TLS true

    # Path
    set -gx PATH $HOME/go/bin $PATH
    set -gx PATH $HOME/.local/bin $PATH
    set -gx PATH $HOME/.cargo/bin $PATH
    set -gx PATH $HOME/.local/share/nvim/mason/bin $PATH


    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx MANPAGER "nvim +Man!"

    fish_vi_key_bindings
end
