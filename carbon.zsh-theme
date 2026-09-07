typeset -g CORBON_VERSION="0.2.0"

: ${CORBON_LAYOUT:="two-line"}

: ${CORBON_LEFT:=(context path git)}
: ${CORBON_RIGHT:=(python node duration time)}

: ${CORBON_SEPARATOR:="  "}
: ${CORBON_PROMPT_SYMBOL:="❯"}
: ${CORBON_CONTINUATION_SYMBOL:="·"}

: ${CORBON_SHOW_USER:=true}
: ${CORBON_SHOW_HOST:="ssh"}
: ${CORBON_SHOW_EXIT:=true}

: ${CORBON_PATH_STYLE:="smart"}
: ${CORBON_PATH_MAX:=4}

: ${CORBON_GIT_BRANCH:=true}
: ${CORBON_GIT_STATUS:=true}
: ${CORBON_GIT_AHEAD_BEHIND:=true}

: ${CORBON_GIT_CLEAN_SYMBOL:="✓"}
: ${CORBON_GIT_DIRTY_SYMBOL:="±"}
: ${CORBON_GIT_STAGED_SYMBOL:="+"}
: ${CORBON_GIT_UNTRACKED_SYMBOL:="?"}
: ${CORBON_GIT_CONFLICT_SYMBOL:="!"}

: ${CORBON_SHOW_DURATION:=true}
: ${CORBON_DURATION_THRESHOLD:=1}

: ${CORBON_SHOW_TIME:=false}
: ${CORBON_TIME_FORMAT:="%H:%M"}

: ${CORBON_COLOR_USER:="%F{white}"}
: ${CORBON_COLOR_HOST:="%F{cyan}"}
: ${CORBON_COLOR_PATH:="%F{245}"}
: ${CORBON_COLOR_GIT:="%F{yellow}"}
: ${CORBON_COLOR_SUCCESS:="%F{green}"}
: ${CORBON_COLOR_ERROR:="%F{red}"}
: ${CORBON_COLOR_MUTED:="%F{242}"}
: ${CORBON_COLOR_ACCENT:="%F{yellow}"}
: ${CORBON_RESET:="%f"}

typeset -g CORBON_COMMAND_STARTED=0
typeset -g CORBON_LAST_DURATION=0
typeset -g CORBON_LAST_EXIT=0

_corbon_git_root() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

_corbon_git_branch() {
    git symbolic-ref --quiet --short HEAD 2>/dev/null ||
        git rev-parse --short HEAD 2>/dev/null
}

_corbon_git_status() {
    local line
    local result=""

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        case "${line[1,2]}" in
            UU|AA|DD|AU|UA)
                result+="${CORBON_GIT_CONFLICT_SYMBOL}"
                ;;
            \?\?)
                result+="${CORBON_GIT_UNTRACKED_SYMBOL}"
                ;;
            *)
                [[ "${line[1]}" != " " ]] &&
                    result+="${CORBON_GIT_STAGED_SYMBOL}"

                [[ "${line[2]}" != " " ]] &&
                    result+="${CORBON_GIT_DIRTY_SYMBOL}"
                ;;
        esac
    done < <(git status --porcelain=v1 2>/dev/null)

    [[ -z "$result" ]] &&
        result="${CORBON_GIT_CLEAN_SYMBOL}"

    print -r -- "$result"
}

_corbon_git_segment() {
    _corbon_git_root || return

    local branch=""
    local status=""
    local result=""
    local ahead=0
    local behind=0

    if [[ "$CORBON_GIT_BRANCH" == true ]]; then
        branch="$(_corbon_git_branch)"
        result="$branch"
    fi

    if [[ "$CORBON_GIT_STATUS" == true ]]; then
        status="$(_corbon_git_status)"

        [[ -n "$status" ]] &&
            result+="${result:+ }${status}"
    fi

    if [[ "$CORBON_GIT_AHEAD_BEHIND" == true ]]; then
        ahead="$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)" || ahead=0
        behind="$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null)" || behind=0

        (( ahead > 0 )) &&
            result+=" ↑${ahead}"

        (( behind > 0 )) &&
            result+=" ↓${behind}"
    fi

    [[ -n "$result" ]] &&
        print -r -- "${CORBON_COLOR_GIT}${result}${CORBON_RESET}"
}

_corbon_context_segment() {
    local result=""

    if [[ "$CORBON_SHOW_USER" == true ]]; then
        result+="${CORBON_COLOR_USER}%n${CORBON_RESET}"
    fi

    if [[ "$CORBON_SHOW_HOST" == true ]]; then
        if [[ "$CORBON_SHOW_HOST" != "ssh" || -n "$SSH_CONNECTION" ]]; then
            result+="${CORBON_COLOR_MUTED}@${CORBON_RESET}"
            result+="${CORBON_COLOR_HOST}%m${CORBON_RESET}"
        fi
    fi

    [[ -n "$result" ]] &&
        print -r -- "$result"
}

_corbon_path_segment() {
    local path="$PWD"

    if [[ "$path" == "$HOME" ]]; then
        path="~"
    elif [[ "$path" == "$HOME/"* ]]; then
        path="~/${path#$HOME/}"
    fi

    if [[ "$CORBON_PATH_STYLE" == "smart" ]]; then
        local parts=("${(@s:/:)path}")

        if (( ${#parts[@]} > CORBON_PATH_MAX + 1 )); then
            path="…/${(j:/:)parts[-$CORBON_PATH_MAX,-1]}"
        fi
    fi

    print -r -- "${CORBON_COLOR_PATH}${path}${CORBON_RESET}"
}

_corbon_python_segment() {
    [[ -n "$VIRTUAL_ENV" ]] || return

    print -r -- "${CORBON_COLOR_MUTED}py:${VIRTUAL_ENV:t}${CORBON_RESET}"
}

_corbon_node_segment() {
    [[ -n "$NODE_VERSION" ]] || return

    print -r -- "${CORBON_COLOR_MUTED}node:${NODE_VERSION}${CORBON_RESET}"
}

_corbon_duration_segment() {
    [[ "$CORBON_SHOW_DURATION" == true ]] || return

    (( CORBON_LAST_DURATION >= CORBON_DURATION_THRESHOLD )) || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_LAST_DURATION}s${CORBON_RESET}"
}

_corbon_time_segment() {
    [[ "$CORBON_SHOW_TIME" == true ]] || return

    print -r -- "${CORBON_COLOR_MUTED}$(strftime "$CORBON_TIME_FORMAT")${CORBON_RESET}"
}

_corbon_render_segment() {
    case "$1" in
        context)  _corbon_context_segment ;;
        path)     _corbon_path_segment ;;
        git)      _corbon_git_segment ;;
        python)   _corbon_python_segment ;;
        node)     _corbon_node_segment ;;
        duration) _corbon_duration_segment ;;
        time)     _corbon_time_segment ;;
    esac
}

_corbon_render_list() {
    local segment
    local value
    local output=()

    for segment in "${(@)1}"; do
        value="$(_corbon_render_segment "$segment")"

        [[ -n "$value" ]] &&
            output+=("$value")
    done

    print -r -- "${(j:$CORBON_SEPARATOR:)output}"
}

_corbon_preexec() {
    CORBON_COMMAND_STARTED=$SECONDS
}

_corbon_precmd() {
    CORBON_LAST_EXIT=$?

    if (( CORBON_COMMAND_STARTED > 0 )); then
        CORBON_LAST_DURATION=$((SECONDS - CORBON_COMMAND_STARTED))
    else
        CORBON_LAST_DURATION=0
    fi

    CORBON_COMMAND_STARTED=0

    local left="$(_corbon_render_list "${CORBON_LEFT}")"
    local right="$(_corbon_render_list "${CORBON_RIGHT}")"
    local prompt="$left"

    if [[ -n "$right" ]]; then
        prompt+="${CORBON_SEPARATOR}${right}"
    fi

    if [[ "$CORBON_LAYOUT" == "two-line" ]]; then
        prompt+="\n"
    else
        prompt+=" "
    fi

    if (( CORBON_LAST_EXIT != 0 )) && [[ "$CORBON_SHOW_EXIT" == true ]]; then
        prompt+="${CORBON_COLOR_ERROR}${CORBON_LAST_EXIT}${CORBON_RESET} "
    fi

    prompt+="${CORBON_COLOR_ACCENT}${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "

    PROMPT="$prompt"
}

autoload -Uz add-zsh-hook

add-zsh-hook preexec _corbon_preexec
add-zsh-hook precmd _corbon_precmd

PROMPT="${CORBON_COLOR_ACCENT}${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "