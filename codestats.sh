# shellcheck shell=bash disable=SC2317
# Refer https://gitlab.com/code-stats/code-stats-bash

_codestats_version="0.0.1"

declare -g -i _codestats_xp=0
declare -g -i _codestats_pulse_time=${EPOCHSECONDS}

# Because each `curl` call is forked into a subshell to keep the interactive
# shell responsive, the consecutive error count cannot be updated in a
# variable. So we use a temp file, one error per line.
_codestats_consecutive_errors=$(mktemp)

# Logging: write to file if CODESTATS_LOG_FILE is set and exists
_codestats_log()
{
    if [[ -w "${CODESTATS_LOG_FILE}" ]]; then
        # EPOCHSECONDS is an integer, so disable globbing/splitting warning
        # shellcheck disable=SC2086
        echo "$(\date +%FT%T%:z) ($$) $*" >> "${CODESTATS_LOG_FILE}"
    fi
}

# Pulse sending function
_codestats_send_pulse()
{
    # Check that error count hasn't been exceeded
    local -i error_count=0
    if [[ -r "${_codestats_consecutive_errors}" ]]; then
        error_count=$(wc -l < "${_codestats_consecutive_errors}")
    fi
    if ((error_count > 4)); then
        _codestats_log "Received too many consecutive errors! Stopping..."
        _codestats_stop "Received ${error_count} consecutive errors when trying to save XP."
        return
    fi

    # If there's accumulated XP, send it
    if ((_codestats_xp > 0)); then
        local url
        url="$(_codestats_pulse_url)"

        _codestats_log "Sending pulse (${_codestats_xp} xp) to ${url}"

        local payload
        payload=$(_codestats_payload ${_codestats_xp})

        \curl \
            --max-time 5 \
            --header "Content-Type: application/json" \
            --header "X-API-Token: ${CODESTATS_API_KEY}" \
            --user-agent "code-stats-bash/${_codestats_version}" \
            --data "${payload}" \
            --request POST \
            --silent \
            --output /dev/null \
            --write-out "%{http_code}" \
            "${url}" |
            _codestats_handle_response_status \
            &

        _codestats_xp=0
    fi
}

# Error handling based on HTTP status
_codestats_handle_response_status()
{
    local _status
    _status=$(\cat -)
    case ${_status} in
    000)
        _codestats_log "Network error!"
        # don't stop; maybe the network will start working eventually
        ;;
    200 | 201)
        _codestats_log "Success (${_status})!"
        # clear error count
        echo -n "${_codestats_consecutive_errors}" > !
        ;;
    3*)
        _codestats_log "Unexpected redirect ${_status}!"
        _codestats_stop "Server responded with a redirect. Perhaps code-stats-bash is out of date?"
        # this problem will probably not go away. stop immediately.
        ;;
    4* | 5*)
        _codestats_log "Server responded with error ${_status}!"
        # some of 4xx and 5xx statuses may indicate a temporary problem
        echo "${_status}" "${_codestats_consecutive_errors}" >> !
        ;;
    *)
        _codestats_log "Unexpected response status ${_status}!"
        # whatever happened, stop if it persists
        echo "${_status}" "${_codestats_consecutive_errors}" >> !
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
    # shellcheck disable=SC2086
    cat << EOF
{
    "coded_at": "$(\date +%FT%T%:z)",
    "xps": [{"language": "Terminal (Bash)", "xp": $1}]
}
EOF
}

# Check time since last pulse; maybe send pulse
_codestats_poll()
{
    _codestats_xp+=1
    if ((EPOCHSECONDS - _codestats_pulse_time > 10)); then
        _codestats_send_pulse
        _codestats_pulse_time=${EPOCHSECONDS}
    fi
}

_codestats_exit()
{
    _codestats_log "Shell is exiting. Calling _codestats_send_pulse one last time."
    _codestats_send_pulse

    # remove temp file
    rm -f "${_codestats_consecutive_errors}"
}

_codestats_init()
{
    _codestats_log "Initializing code-stats-bash@${_codestats_version}..."

    PROMPT_COMMAND="_codestats_poll; $PROMPT_COMMAND"

    _codestats_log "Initialization complete."
}

# Stop because there was an error. Overwrite handler functions.
_codestats_stop()
{
    _codestats_log "Stopping bash-code-stats. Overwriting hook functions with no-ops."
    echo >&2 "code-stats-bash: $* Stopping."
    _codestats_poll()
    {
        true
    }
    _codestats_exit()
    {
        true
    }

    # remove temp file
    rm -f "${_codestats_consecutive_errors}"
}

if [[ -n "${CODESTATS_API_KEY}" ]]; then
    _codestats_init
else
    echo "code-stats-bash requires CODESTATS_API_KEY to be set!"
    false
fi

if [[ -n "${CODESTATS_LOG_FILE}" && ! -w "${CODESTATS_LOG_FILE}" ]]; then
    echo "Warning: CODESTATS_LOG_FILE needs to exist and be writable!"
fi
