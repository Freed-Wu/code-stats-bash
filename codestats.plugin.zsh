# https://gitlab.com/code-stats/code-stats-zsh

_codestats_version="0.3.1"

declare -g -i _codestats_xp=0
declare -g -i _codestats_pulse_time
_codestats_pulse_time=$(date +%s)

# Because each `curl` call is forked into a subshell to keep the interactive
# shell responsive, the consecutive error count cannot be updated in a
# variable. So we use a temp file, one error per line.
_codestats_consecutive_errors=$(mktemp)

# Logging: write to file if CODESTATS_LOG_FILE is set and exists
_codestats_log()
{
    if [ -w "${CODESTATS_LOG_FILE}" ]; then
        echo "$(date +%Y-%m-%dT%H:%M:%S) ($$) $*" >> "${CODESTATS_LOG_FILE}"
    fi
}

# Widget wrapper: add a keypress and call original widget
_codestats_call_widget()
{
    _codestats_xp+=1
    builtin zle "$@"
}

# Rebind widgets
_codestats_rebind_widgets()
{
    local w
    for w in \
        self-insert \
        delete-char \
        backward-delete-char \
        accept-line
    do
        # call the internal version, ie. the one beginning with `.`
        eval "_codestats_${w} () { _codestats_call_widget .${w} -- \"\$@\" }"
        zle -N ${w} _codestats_${w}

        _codestats_log "Wrapped and rebound the ${w} widget."
    done
}

# Pulse sending function
_codestats_send_pulse()
{
    # Check that error count hasn't been exceeded
    local -i error_count
    error_count=$(wc -l < "${_codestats_consecutive_errors}")
    if (( error_count > 4 )); then
        >&2 echo "code-stats-zsh: received ${error_count}" \
                "consecutive errors when trying to save XP. Stopping."
        _codestats_log "Received too many consecutive errors! Stopping..."
        _codestats_stop
        return
    fi

    # If there's accumulated XP, send it
    if (( _codestats_xp > 0 )); then
        local url
        url="$(_codestats_pulse_url)"

        _codestats_log "Sending pulse (${_codestats_xp} xp) to ${url}"

        local payload
        payload=$(_codestats_payload ${_codestats_xp})

        curl \
            --header "Content-Type: application/json" \
            --header "X-API-Token: ${CODESTATS_API_KEY}" \
            --user-agent "code-stats-zsh/${_codestats_version}" \
            --data "${payload}" \
            --request POST \
            --silent \
            --output /dev/null \
            --write-out "%{http_code}" \
            "${url}" \
            | _codestats_handle_response_status \
            &|

        _codestats_xp=0
    fi
}

# Error handling based on HTTP status
_codestats_handle_response_status()
{
    local _status
    _status=$(cat -)
    case ${_status} in
        200 | 201 )
            _codestats_log "Success (${_status})!"
            # clear error count
            echo -n >! "${_codestats_consecutive_errors}"
            ;;
        000)
            _codestats_log "No response from server!"
            echo "${_status}" >> "${_codestats_consecutive_errors}"
            ;;
        *)
            _codestats_log "Server responded with error ${_status}!"
            echo "${_status}" >> "${_codestats_consecutive_errors}"
            ;;
    esac
}

_codestats_pulse_url()
{
    echo "${CODESTATS_API_URL:-https://codestats.net}/api/my/pulses"
}

# Create API payload
_codestats_payload()
{
    cat <<EOF
{
    "coded_at": "$(date +%Y-%m-%dT%H:%M:%S%z)",
    "xps": [{"language": "Terminal (Zsh)", "xp": $1}]
}
EOF
}

# Check time since last pulse; maybe send pulse
_codestats_poll()
{
    local now
    now=$(date +%s)
    if (( now - _codestats_pulse_time > 10 )); then
        _codestats_send_pulse
        _codestats_pulse_time=${now}
    fi
}

_codestats_exit()
{
    _codestats_log "Shell is exiting. Calling _codestats_send_pulse one last time."
    _codestats_send_pulse
}

_codestats_init()
{
    _codestats_log "Initializing code-stats-zsh@${_codestats_version}..."

    _codestats_rebind_widgets

    # Call the polling function on each new prompt
    autoload -U add-zsh-hook
    add-zsh-hook precmd _codestats_poll

    # Send pulse on shell exit
    add-zsh-hook zshexit _codestats_exit

    _codestats_log "Initialization complete."
}

# Stop because there was an error. Overwrite handler functions.
_codestats_stop()
{
    _codestats_log "Stopping zsh-code-stats. Overwriting hook functions with no-ops."
    _codestats_poll() { true; }
    _codestats_exit() { true; }
}

if [ -n "${CODESTATS_API_KEY}" ]; then
    _codestats_init
else
    echo "code-stats-zsh requires CODESTATS_API_KEY to be set!"
    false
fi

if [ -n "${CODESTATS_LOG_FILE}" ] && [ ! -w "${CODESTATS_LOG_FILE}" ]; then
    echo "Warning: CODESTATS_LOG_FILE needs to exist and be writable!"
fi
