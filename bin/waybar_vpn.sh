#!/usr/bin/env bash

set -euo pipefail

PKEXEC_BIN="$(command -v pkexec)"
VPN_HOST="vpn.networkexpert.pl"
WAYBAR_SIGNAL="${WAYBAR_VPN_SIGNAL:-8}"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="${STATE_DIR}/waybar_vpn.state"
OVERRIDE_TTL_SECONDS=20

refresh_waybar() {
    pkill --signal "RTMIN+${WAYBAR_SIGNAL}" -x waybar > /dev/null 2>&1 || true
}

has_openconnect() {
    pgrep -af "openconnect.*${VPN_HOST}" > /dev/null || pgrep -x openconnect > /dev/null
}

has_tunnel() {
    ip -o link show up 2> /dev/null | grep -Eq ':[[:space:]]+tun[0-9]+:'
}

actual_state() {
    local has_proc=0
    local has_tun=0

    if has_openconnect; then
        has_proc=1
    fi

    if has_tunnel; then
        has_tun=1
    fi

    if (( has_proc == 1 && has_tun == 1 )); then
        echo "connected"
    elif (( has_proc == 1 )); then
        echo "connecting"
    elif (( has_tun == 1 )); then
        echo "disconnecting"
    else
        echo "disconnected"
    fi
}

write_override() {
    mkdir -p "${STATE_DIR}"
    printf '%s %s\n' "$1" "$(date +%s)" > "${STATE_FILE}"
}

clear_override() {
    rm -f "${STATE_FILE}"
}

read_override() {
    local state
    local timestamp
    local now

    [[ -r "${STATE_FILE}" ]] || return 1
    read -r state timestamp < "${STATE_FILE}" || return 1

    case "${state}" in
        connecting|disconnecting)
            ;;
        *)
            clear_override
            return 1
            ;;
    esac

    now="$(date +%s)"
    if (( now - timestamp > OVERRIDE_TTL_SECONDS )); then
        clear_override
        return 1
    fi

    printf '%s\n' "${state}"
}

display_state() {
    local current_state
    local override_state

    current_state="$(actual_state)"

    if override_state="$(read_override)"; then
        case "${override_state}:${current_state}" in
            connecting:connected)
                clear_override
                echo "connected"
                return
                ;;
            disconnecting:disconnected)
                clear_override
                echo "disconnected"
                return
                ;;
            connecting:disconnected|connecting:connecting|disconnecting:connected|disconnecting:disconnecting)
                echo "${override_state}"
                return
                ;;
            *)
                clear_override
                ;;
        esac
    fi

    echo "${current_state}"
}

emit_status() {
    case "$(display_state)" in
        connected)
            echo '{"text": "󰖂  CONNECTED", "class": "connected", "tooltip": "VPN: Connected (click to disconnect)"}'
            ;;
        connecting)
            echo '{"text": "󰖂  CONNECTING", "class": "connecting", "tooltip": "VPN: Connecting..."}'
            ;;
        disconnecting)
            echo '{"text": "󰖂  DISCONNECTING", "class": "disconnecting", "tooltip": "VPN: Disconnecting..."}'
            ;;
        *)
            echo '{"text": "󰖂  DISCONNECTED", "class": "disconnected", "tooltip": "VPN: Disconnected (click to connect)"}'
            ;;
    esac
}

settle_state() {
    local target_state="${1:?missing target state}"
    local current_state

    for _ in {1..20}; do
        current_state="$(actual_state)"

        if [[ "${current_state}" == "${target_state}" ]]; then
            clear_override
            refresh_waybar
            return 0
        fi

        if [[ "${current_state}" == "connected" || "${current_state}" == "disconnected" ]]; then
            break
        fi

        refresh_waybar
        sleep 1
    done

    clear_override
    refresh_waybar
}

toggle_vpn() {
    case "$(actual_state)" in
        connected|connecting)
            write_override "disconnecting"
            refresh_waybar
            "${PKEXEC_BIN}" pkill -x openconnect || true
            nohup "$0" settle disconnected > /dev/null 2>&1 &
            ;;
        *)
            write_override "connecting"
            refresh_waybar
            nohup ~/.config/bin/connect_vpn.sh > /dev/null 2>&1 &
            nohup "$0" settle connected > /dev/null 2>&1 &
            ;;
    esac
}

case "${1:-}" in
    toggle)
        toggle_vpn
        ;;
    settle)
        settle_state "${2:-}"
        ;;
    *)
        emit_status
        ;;
esac
