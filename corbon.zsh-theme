typeset -g CORBON_VERSION="0.6.0"

typeset -gA CORBON_SEGMENTS
typeset -gA CORBON_PALETTE

setopt prompt_subst

: ${CORBON_THEME:="ember"}
: ${CORBON_COLOR_MODE:="palette"}

CORBON_PALETTE=(
    foreground "%F{255}"
    muted "%F{242}"
    accent "%F{214}"

    success "%F{114}"
    warning "%F{214}"
    error "%F{203}"
    info "%F{117}"

    user "%F{255}"
    host "%F{117}"
    path "%F{250}"
    path_home "%F{255}"
    separator "%F{242}"

    git "%F{214}"
    git_branch "%F{255}"
    git_arrow "%F{214}"
    git_clean "%F{114}"
    git_dirty "%F{214}"
    git_staged "%F{117}"
    git_untracked "%F{221}"
    git_conflict "%F{203}"
    git_stash "%F{176}"
    git_ahead "%F{117}"
    git_behind "%F{176}"

    python "%F{117}"
    node "%F{114}"
    go "%F{117}"
    rust "%F{221}"
    java "%F{203}"
    ruby "%F{203}"

    docker "%F{117}"
    kubernetes "%F{117}"
    aws "%F{221}"
    gcp "%F{117}"
    azure "%F{117}"

    os "%F{242}"
    arch "%F{242}"
    shell "%F{255}"
    jobs "%F{176}"
    root "%F{203}"
    container "%F{221}"

    duration "%F{242}"
    time "%F{242}"
    date "%F{242}"

    prompt "%F{214}"
    continuation "%F{242}"
)

_corbon_color() {
    local name="$1"
    local fallback="${2:-muted}"

    [[ -n "${CORBON_PALETTE[$name]}" ]] &&
        print -r -- "${CORBON_PALETTE[$name]}" ||
        print -r -- "${CORBON_PALETTE[$fallback]}"
}

_corbon_theme_ember() {
    CORBON_PALETTE=(
        foreground "%F{255}"
        muted "%F{242}"
        accent "%F{214}"

        success "%F{114}"
        warning "%F{214}"
        error "%F{203}"
        info "%F{117}"

        user "%F{255}"
        host "%F{117}"
        path "%F{250}"
        path_home "%F{255}"
        separator "%F{242}"

        git "%F{214}"
        git_branch "%F{255}"
        git_arrow "%F{214}"
        git_clean "%F{114}"
        git_dirty "%F{214}"
        git_staged "%F{117}"
        git_untracked "%F{221}"
        git_conflict "%F{203}"
        git_stash "%F{176}"
        git_ahead "%F{117}"
        git_behind "%F{176}"

        python "%F{117}"
        node "%F{114}"
        go "%F{117}"
        rust "%F{221}"
        java "%F{203}"
        ruby "%F{203}"

        docker "%F{117}"
        kubernetes "%F{117}"
        aws "%F{221}"
        gcp "%F{117}"
        azure "%F{117}"

        os "%F{242}"
        arch "%F{242}"
        shell "%F{255}"
        jobs "%F{176}"
        root "%F{203}"
        container "%F{221}"

        duration "%F{242}"
        time "%F{242}"
        date "%F{242}"

        prompt "%F{214}"
        continuation "%F{242}"
    )
}

_corbon_theme_mono() {
    CORBON_PALETTE=(
        foreground "%F{255}"
        muted "%F{242}"
        accent "%F{250}"

        success "%F{255}"
        warning "%F{255}"
        error "%F{255}"
        info "%F{255}"

        user "%F{255}"
        host "%F{250}"
        path "%F{250}"
        path_home "%F{255}"
        separator "%F{242}"

        git "%F{255}"
        git_branch "%F{255}"
        git_arrow "%F{250}"
        git_clean "%F{255}"
        git_dirty "%F{255}"
        git_staged "%F{255}"
        git_untracked "%F{255}"
        git_conflict "%F{255}"
        git_stash "%F{255}"
        git_ahead "%F{255}"
        git_behind "%F{255}"

        python "%F{250}"
        node "%F{250}"
        go "%F{250}"
        rust "%F{250}"
        java "%F{250}"
        ruby "%F{250}"

        docker "%F{250}"
        kubernetes "%F{250}"
        aws "%F{250}"
        gcp "%F{250}"
        azure "%F{250}"

        os "%F{242}"
        arch "%F{242}"
        shell "%F{255}"
        jobs "%F{250}"
        root "%F{255}"
        container "%F{250}"

        duration "%F{242}"
        time "%F{242}"
        date "%F{242}"

        prompt "%F{255}"
        continuation "%F{242}"
    )
}

_corbon_apply_theme() {
    case "$CORBON_THEME" in
        ember)
            _corbon_theme_ember
            ;;
        mono)
            _corbon_theme_mono
            ;;
        custom)
            ;;
        *)
            _corbon_theme_ember
            ;;
    esac
}

_corbon_apply_theme

: ${CORBON_LAYOUT:="two-line"}

: ${CORBON_LEFT:=(context path git)}
: ${CORBON_RIGHT:=(python node duration time)}

: ${CORBON_SEPARATOR:="  "}

: ${CORBON_PROMPT_SYMBOL:="⟫"}
: ${CORBON_CONTINUATION_SYMBOL:="·"}

: ${CORBON_SHOW_USER:=true}
: ${CORBON_SHOW_HOST:="ssh"}
: ${CORBON_SHOW_EXIT:=true}

: ${CORBON_PATH_STYLE:="smart"}
: ${CORBON_PATH_MAX:=4}

: ${CORBON_GIT_BRANCH:=true}
: ${CORBON_GIT_STATUS:=true}
: ${CORBON_GIT_AHEAD_BEHIND:=true}
: ${CORBON_GIT_CACHE:=true}
: ${CORBON_GIT_CACHE_TTL:=2}

: ${CORBON_GIT_BRANCH_SYMBOL:=""}
: ${CORBON_GIT_ARROW_SYMBOL:="⟫"}
: ${CORBON_GIT_CLEAN_SYMBOL:="✓"}
: ${CORBON_GIT_DIRTY_SYMBOL:="±"}
: ${CORBON_GIT_STAGED_SYMBOL:="+"}
: ${CORBON_GIT_UNTRACKED_SYMBOL:="?"}
: ${CORBON_GIT_CONFLICT_SYMBOL:="!"}

: ${CORBON_SHOW_DURATION:=true}
: ${CORBON_DURATION_THRESHOLD:=1}

: ${CORBON_SHOW_TIME:=false}
: ${CORBON_TIME_FORMAT:="%H:%M"}

typeset -g CORBON_COMMAND_STARTED=0
typeset -g CORBON_LAST_DURATION=0
typeset -g CORBON_LAST_EXIT=0

typeset -g CORBON_GIT_CACHE_TIME=0
typeset -g CORBON_GIT_CACHE_DIR=""
typeset -g CORBON_GIT_CACHE_VALUE=""

corbon_segment() {
    local name="$1"
    local function="$2"

    [[ -n "$name" && -n "$function" ]] || return 1

    CORBON_SEGMENTS[$name]="$function"
}

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

_corbon_git_build() {
    _corbon_git_root || return

    local branch=""
    local status=""
    local result=""
    local ahead=0
    local behind=0

    if [[ "$CORBON_GIT_BRANCH" == true ]]; then
        branch="$(_corbon_git_branch)"

        [[ -n "$branch" ]] &&
            result="${branch}"
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

    [[ -n "$result" ]] || return

    local branch_color="$(_corbon_color git_branch)"
    local arrow_color="$(_corbon_color git_arrow)"
    local status_color="$(_corbon_color git_clean)"

    [[ "$status" == *"$CORBON_GIT_DIRTY_SYMBOL"* ]] &&
        status_color="$(_corbon_color git_dirty)"

    [[ "$status" == *"$CORBON_GIT_STAGED_SYMBOL"* ]] &&
        status_color="$(_corbon_color git_staged)"

    [[ "$status" == *"$CORBON_GIT_UNTRACKED_SYMBOL"* ]] &&
        status_color="$(_corbon_color git_untracked)"

    [[ "$status" == *"$CORBON_GIT_CONFLICT_SYMBOL"* ]] &&
        status_color="$(_corbon_color git_conflict)"

    if [[ -n "$branch" ]]; then
        print -r -- "${branch_color}${branch}${CORBON_RESET} ${arrow_color}${CORBON_GIT_ARROW_SYMBOL}${CORBON_RESET} ${status_color}${status}${CORBON_RESET}"
    else
        print -r -- "${status_color}${status}${CORBON_RESET}"
    fi
}

_corbon_git_segment() {
    _corbon_git_root || return

    if [[ "$CORBON_GIT_CACHE" != true ]]; then
        _corbon_git_build
        return
    fi

    local now="$SECONDS"
    local age=$((now - CORBON_GIT_CACHE_TIME))

    if [[ "$CORBON_GIT_CACHE_DIR" == "$PWD" ]] &&
       (( age < CORBON_GIT_CACHE_TTL )) &&
       [[ -n "$CORBON_GIT_CACHE_VALUE" ]]; then
        print -r -- "$CORBON_GIT_CACHE_VALUE"
        return
    fi

    local value="$(_corbon_git_build)"

    CORBON_GIT_CACHE_TIME="$now"
    CORBON_GIT_CACHE_DIR="$PWD"
    CORBON_GIT_CACHE_VALUE="$value"

    print -r -- "$value"
}

_corbon_context_segment() {
    local result=""

    if [[ "$CORBON_SHOW_USER" == true ]]; then
        result+="$(_corbon_color user)%n${CORBON_RESET}"
    fi

    if [[ "$CORBON_SHOW_HOST" == true ]]; then
        if [[ "$CORBON_SHOW_HOST" != "ssh" || -n "$SSH_CONNECTION" ]]; then
            result+="$(_corbon_color separator)@${CORBON_RESET}"
            result+="$(_corbon_color host)%m${CORBON_RESET}"
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

    local color="$(_corbon_color path)"

    [[ "$path" == "~" || "$path" == "~/"* ]] &&
        color="$(_corbon_color path_home)"

    print -r -- "${color}${path}${CORBON_RESET}"
}

_corbon_python_segment() {
    [[ -n "$VIRTUAL_ENV" ]] || return

    print -r -- "$(_corbon_color python)py:${VIRTUAL_ENV:t}${CORBON_RESET}"
}

_corbon_node_segment() {
    local version=""

    if [[ -n "$NODE_VERSION" ]]; then
        version="$NODE_VERSION"
    elif [[ -f .nvmrc ]]; then
        version="$(<.nvmrc)"
    elif [[ -f package.json ]] && command -v node >/dev/null 2>&1; then
        version="$(node --version 2>/dev/null)"
        version="${version#v}"
    fi

    [[ -n "$version" ]] || return

    print -r -- "$(_corbon_color node)node:${version}${CORBON_RESET}"
}

_corbon_duration_segment() {
    [[ "$CORBON_SHOW_DURATION" == true ]] || return
    (( CORBON_LAST_DURATION >= CORBON_DURATION_THRESHOLD )) || return

    print -r -- "$(_corbon_color duration)${CORBON_LAST_DURATION}s${CORBON_RESET}"
}

_corbon_time_segment() {
    [[ "$CORBON_SHOW_TIME" == true ]] || return

    print -r -- "$(_corbon_color time)$(strftime "$CORBON_TIME_FORMAT")${CORBON_RESET}"
}

_corbon_render_segment() {
    local segment="$1"

    if [[ "$segment" == custom:* ]]; then
        local name="${segment#custom:}"
        local function="${CORBON_SEGMENTS[$name]}"

        [[ -n "$function" ]] || return

        "$function"
        return
    fi

    case "$segment" in
        context)    _corbon_context_segment ;;
        path)       _corbon_path_segment ;;
        git)        _corbon_git_segment ;;
        python)     _corbon_python_segment ;;
        node)       _corbon_node_segment ;;
        duration)   _corbon_duration_segment ;;
        time)       _corbon_time_segment ;;
    esac
}

_corbon_render_list() {
    local segment
    local value
    local output=()

    for segment in "$@"; do
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

    local left="$(_corbon_render_list "${CORBON_LEFT[@]}")"
    local right="$(_corbon_render_list "${CORBON_RIGHT[@]}")"

    if [[ "$CORBON_LAYOUT" == "two-line" ]]; then
        PROMPT="$left"

        if (( CORBON_LAST_EXIT != 0 )) && [[ "$CORBON_SHOW_EXIT" == true ]]; then
            PROMPT+=" $(_corbon_color error)${CORBON_LAST_EXIT}${CORBON_RESET}"
        fi

        PROMPT+=$'\n'
        PROMPT+="$(_corbon_color prompt)${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "

        RPROMPT="$right"
    else
        PROMPT="$left"

        [[ -n "$right" ]] &&
            PROMPT+="${CORBON_SEPARATOR}${right}"

        if (( CORBON_LAST_EXIT != 0 )) && [[ "$CORBON_SHOW_EXIT" == true ]]; then
            PROMPT+=" $(_corbon_color error)${CORBON_LAST_EXIT}${CORBON_RESET}"
        fi

        PROMPT+=" $(_corbon_color prompt)${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "
        RPROMPT=""
    fi
}

autoload -Uz add-zsh-hook

add-zsh-hook preexec _corbon_preexec
add-zsh-hook precmd _corbon_precmd

PROMPT="$(_corbon_color prompt)${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "
RPROMPT=""