#!/usr/bin/env bash

set -euo pipefail

if [[ ${HERDR_ENV:-} != 1 ]]; then
    printf '%s\n' 'herdr-workspace must be run inside an attached Herdr pane.' >&2
    exit 1
fi

if [[ $# -gt 1 ]]; then
    printf 'usage: %s [project-directory]\n' "${0##*/}" >&2
    exit 2
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    roots=()
    [[ -d "$HOME/personal" ]] && roots+=("$HOME/personal")
    [[ -d "$HOME/work" ]] && roots+=("$HOME/work")

    if [[ ${#roots[@]} -eq 0 ]]; then
        exit 0
    fi

    # List project roots (git/jj checkouts), not every directory under $roots -
    # otherwise node_modules, target/, .venv, etc. drown out actual projects.
    # fd's own errors (e.g. permission-denied subdirs) must not be allowed to
    # taint the pipeline's exit status, since that's how we detect an fzf cancel
    # below - so they're captured and discarded here rather than piped into fzf.
    projects=$(fd --hidden --absolute-path --type d --max-depth 6 '^\.(git|jj)$' "${roots[@]}" 2>/dev/null \
        | sed -E 's#/\.(git|jj)/?$##' \
        | sort -u) || true

    if [[ -z $projects ]]; then
        exit 0
    fi

    if ! selected=$(printf '%s\n' "$projects" | fzf); then
        exit 0
    fi
fi

if [[ -z $selected || ! -d $selected ]]; then
    exit 0
fi

selected=$(realpath "$selected")
workspace_label=${selected#"$HOME"/}

# Switching between already-open workspaces is Herdr's job (prefix+w / prefix+g),
# not this script's - it only opens projects that don't have a workspace yet.
herdr workspace create --cwd "$selected" --label "$workspace_label" --focus
