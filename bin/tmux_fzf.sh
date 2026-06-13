#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 1 ]]; then
    selected=$1
else
    roots=()
    [[ -d "$HOME/personal" ]] && roots+=("$HOME/personal")
    [[ -d "$HOME/work" ]] && roots+=("$HOME/work")

    if [[ ${#roots[@]} -eq 0 ]]; then
        exit 0
    fi

    selected=$(find "${roots[@]}" -mindepth 1 -maxdepth 4 -type d ! -name ".*" | fzf)
fi
if [[ -z $selected ]]; then
    exit 0
fi

selected=$(realpath "$selected")
relative_name=${selected#"$HOME"/}
selected_name=$(printf '%s' "$relative_name" | tr '/.' '__' | tr -c '[:alnum:]_' '_')

create_session() {
    tmux new-session -ds "$selected_name" -c "$selected" -n editor

    if [[ "${TMUX_FZF_OPEN_NVIM:-1}" == "1" ]]; then
        tmux send-keys -t "$selected_name:editor" "nvim ." C-m
    fi

    tmux new-window -t "$selected_name" -c "$selected" -n test
    tmux new-window -t "$selected_name" -c "$selected" -n shell
    tmux select-window -t "$selected_name:editor"
}

if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    create_session
fi

if [[ -z ${TMUX:-} ]]; then
    tmux attach-session -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
