#!/usr/bin/env bash

# Bootstrap only the brand-new workspace Herdr reports.  It deliberately uses
# tabs, never splits: a full-width Neovim tab plus two independent shells.
set -euo pipefail

herdr=${HERDR_BIN_PATH:-herdr}

workspace_id=''
if [[ ${HERDR_PLUGIN_EVENT:-} == 'workspace.created' && -n ${HERDR_PLUGIN_EVENT_JSON:-} ]]; then
    workspace_id=$(jq -er '.data.workspace.workspace_id' <<<"$HERDR_PLUGIN_EVENT_JSON")
elif [[ -n ${HERDR_WORKSPACE_ID:-} ]]; then
    workspace_id=$HERDR_WORKSPACE_ID
elif [[ -n ${HERDR_PLUGIN_CONTEXT_JSON:-} ]]; then
    workspace_id=$(jq -r '.workspace.workspace_id // .workspace_id // empty' <<<"$HERDR_PLUGIN_CONTEXT_JSON")
fi

if [[ -z $workspace_id ]]; then
    printf '%s\n' 'workspace-layout: no workspace context supplied by Herdr' >&2
    exit 2
fi

# A workspace creation event is emitted before the individual tab/pane events.
# The resources already exist by the time its hook runs, but tolerate a short
# delay so a future server implementation cannot turn this into a race.
for _ in {1..10}; do
    tabs_json=$($herdr tab list --workspace "$workspace_id")
    panes_json=$($herdr pane list --workspace "$workspace_id")
    root_tab=$(jq -r '(.result // .).tabs[0].tab_id // empty' <<<"$tabs_json")
    root_pane=$(jq -r '(.result // .).panes[0].pane_id // empty' <<<"$panes_json")

    if [[ -n $root_tab && -n $root_pane ]]; then
        break
    fi
    sleep 0.1
done

if [[ -z ${root_tab:-} || -z ${root_pane:-} ]]; then
    printf '%s\n' "workspace-layout: could not find root tab/pane for $workspace_id" >&2
    exit 1
fi

# Never trample a workspace that another workflow has already populated.
tab_count=$(jq '(.result // .).tabs | length' <<<"$tabs_json")
if (( tab_count != 1 )); then
    exit 0
fi

cwd=$(jq -r '(.result // .).panes[0].cwd // (.result // .).panes[0].foreground_cwd // empty' <<<"$panes_json")
if [[ -z $cwd ]]; then
    printf '%s\n' "workspace-layout: root pane for $workspace_id has no cwd" >&2
    exit 1
fi

# Create the background tabs first. --no-focus preserves the editor as the
# landing place even when the workspace itself was created with --focus.
$herdr tab rename "$root_tab" editor
$herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label test --no-focus
$herdr tab create --workspace "$workspace_id" --cwd "$cwd" --label shell --no-focus

# send-text is literal; Enter must be a separate key event.
$herdr pane send-text "$root_pane" 'nvim .'
$herdr pane send-keys "$root_pane" enter
