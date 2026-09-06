# Corbon ZSH Theme
# https://github.com/spideythedev/corbon-zsh-theme

typeset -g CORBON_VERSION="0.1.0"

# ─────────────────────────────────────
# Defaults
# ─────────────────────────────────────

: ${CORBON_LAYOUT:="two-line"}

: ${CORBON_LEFT:="context path git"}
: ${CORBON_RIGHT:="python node duration time"}

: ${CORBON_SEPARATOR:="  "}
: ${CORBON_PROMPT_SYMBOL:="❯"}
: ${CORBON_CONTINUATION_SYMBOL:="·"}

: ${CORBON_SHOW_USER:=true}
: ${CORBON_SHOW_HOST:="ssh"}
: ${CORBON_SHOW_EXIT:=true}

: ${CORBON_PATH_STYLE:="smart"}
: ${CORBON_PATH_MAX:=4}
: ${CORBON_PATH_TRUNCATE:="…"}

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

# ─────────────────────────────────────
# Helpers
# ─────────────────────────────────────

_corbon_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

_corbon_git_branch() {
    git symbolic-ref --short HEAD 2>/dev/null ||
        git rev-parse --short HEAD 2>/dev/null
}

_corbon_git_status() {
    local status

    status="$(git status --porcelain=v1 2>/dev/null)" || return

    if [[ -z "$status" ]]; then
        print -r -- "${CORBON_GIT_CLEAN_SYMBOL}"
        return
    fi

    local result=""

    if print -r -- "$status" | grep -q '^.[MADRCU]'; then
        result+="${CORBON_GIT_STAGED_SYMBOL}"
    fi

    if print -r -- "$status" | grep -q '^.[MDU]'; then
        result+="${CORBON_GIT_DIRTY_SYMBOL}"
    fi

    if print -r -- "$status" | grep -q '^??'; then
        result+="${CORBON_GIT_UNTRACKED_SYMBOL}"
    fi

    if print -r -- "$status" | grep -q '^[U][U]'; then
        result+="${CORBON_GIT_CONFLICT_SYMBOL}"
    fi

    print -r -- "$result"
}

_corbon_git_segment() {
    _corbon_git_root >/dev/null || return

    local branch status ahead behind result

    branch="$(_corbon_git_branch)"
    status="$(_corbon_git_status)"

    result="${branch}"

    if [[ -n "$status" && "$CORBON_GIT_STATUS" == true ]]; then
        result+=" ${status}"
    fi

    if [[ "$CORBON_GIT_AHEAD_BEHIND" == true ]]; then
        ahead="$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)"
        behind="$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null)"

        [[ "$ahead" -gt 0 ]] 2>/dev/null && result+=" ↑${ahead}"
        [[ "$behind" -gt 0 ]] 2>/dev/null && result+=" ↓${behind}"
    fi

    print -r -- "${CORBON_COLOR_GIT}${result}${CORBON_RESET}"
}

_corbon_context_segment() {
    local context=""

    if [[ "$CORBON_SHOW_USER" == true ]]; then
        context+="${CORBON_COLOR_USER}%n${CORBON_RESET}"
    fi

    if [[ "$CORBON_SHOW_HOST" == true ]]; then
        if [[ "$CORBON_SHOW_HOST" == "ssh" && -z "$SSH_CONNECTION" ]]; then
            :
        else
            context+="${CORBON_COLOR_MUTED}@${CORBON_RESET}"
            context+="${CORBON_COLOR_HOST}%m${CORBON_RESET}"
        fi
    fi

    print -r -- "$context"
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
    command -v python >/dev/null 2>&1 || return

    local version

    version="$(python --version 2>/dev/null | awk '{print $2}')" || return

    [[ -n "$VIRTUAL_ENV" ]] &&
        print -r -- "${CORBON_COLOR_MUTED}py:${version}${CORBON_RESET}"
}

_corbon_node_segment() {
    command -v node >/dev/null 2>&1 || return

    local version

    version="$(node --version 2>/dev/null)" || return

    print -r -- "${CORBON_COLOR_MUTED}node:${version#v}${CORBON_RESET}"
}

_corbon_duration_segment() {
    [[ "$CORBON_SHOW_DURATION" == true ]] || return

    local elapsed="${CORBON_LAST_DURATION:-0}"

    (( elapsed >= CORBON_DURATION_THRESHOLD )) || return

    print -r -- "${CORBON_COLOR_MUTED}${elapsed}s${CORBON_RESET}"
}

_corbon_time_segment() {
    [[ "$CORBON_SHOW_TIME" == true ]] || return

    print -r -- "${CORBON_COLOR_MUTED}$(date +"$CORBON_TIME_FORMAT")${CORBON_RESET}"
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
    local list="$1"
    local segment
    local output=()
    local value

    for segment in ${(z)list}; do
        value="$(_corbon_render_segment "$segment")"

        [[ -n "$value" ]] && output+=("$value")
    done

    print -r -- "${(j:$CORBON_SEPARATOR:)output}"
}

# ─────────────────────────────────────
# Prompt
# ─────────────────────────────────────

_corbon_precmd() {
    local exit_code=$?

    CORBON_LAST_DURATION=$SECONDS
    SECONDS=0

    local left right prompt

    left="$(_corbon_render_list "$CORBON_LEFT")"
    right="$(_corbon_render_list "$CORBON_RIGHT")"

    if [[ "$CORBON_LAYOUT" == "one-line" ]]; then
        prompt="${left}"

        [[ -n "$right" ]] &&
            prompt+="  ${right}"

        prompt+="\n${CORBON_COLOR_ACCENT}${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "
    else
        prompt="${left}"

        [[ -n "$right" ]] &&
            prompt+="  ${right}"

        prompt+="\n"

        if (( exit_code != 0 )) && [[ "$CORBON_SHOW_EXIT" == true ]]; then
            prompt+="${CORBON_COLOR_ERROR}${exit_code}${CORBON_RESET} "
        fi

        prompt+="${CORBON_COLOR_ACCENT}${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "
    fi

    PROMPT="$prompt"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _corbon_precmd

PROMPT="%F{yellow}❯%f "