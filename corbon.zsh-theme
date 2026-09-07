typeset -g CORBON_VERSION="0.7.0"

typeset -gA CORBON_SEGMENTS
typeset -gA CORBON_PALETTE
typeset -gA CORBON_SYMBOL
typeset -gA CORBON_STYLE

setopt prompt_subst

: ${CORBON_THEME:="ember"}
: ${CORBON_COLOR_MODE:="truecolor"}

CORBON_PALETTE=(
    background "#0D0F12"
    foreground "#F1F0EB"
    secondary "#B7B8B3"
    muted "#6E716F"

    accent "#FF8A3D"
    accent_soft "#FFB454"
    gold "#E7C66A"

    success "#72C98A"
    warning "#E7B85C"
    error "#E87575"
    info "#72B7D9"

    user "#E8C98B"
    host "#B9B6AC"

    path "#F1F0EB"
    path_home "#FFB454"
    path_root "#E87575"
    path_truncation "#6E716F"

    separator "#35393F"

    git_branch "#F1F0EB"
    git_arrow "#FF9A4A"
    git_clean "#78C98B"
    git_dirty "#E7B85C"
    git_staged "#D6A45E"
    git_untracked "#A8A9A4"
    git_conflict "#E87575"
    git_stash "#C39A68"
    git_ahead "#72B7D9"
    git_behind "#8E91A0"

    python "#7FAF9A"
    node "#91B875"
    go "#72B7A4"
    rust "#C9826B"
    java "#D18B6F"
    ruby "#B87883"

    docker "#72AEB7"
    kubernetes "#7899C7"
    aws "#D9A15F"
    gcp "#719BC7"
    azure "#6EA8C8"
    terraform "#967FC2"

    os "#A7ABB2"
    arch "#858A93"
    shell "#F1F0EB"
    jobs "#D4A85E"
    root "#E87575"
    container "#7FB5B0"

    duration "#858A93"
    time "#858A93"
    date "#858A93"

    prompt "#FF8A3D"
    prompt_arrow "#FFB454"
    continuation "#B97845"

    exit_success "#72C98A"
    exit_error "#E87575"
)

CORBON_SYMBOL=(
    prompt "╰─⟫"
    continuation "·"

    git_branch "⎇"
    git_arrow "⟫"
    git_clean "✓"
    git_dirty "±"
    git_staged "+"
    git_untracked "?"
    git_conflict "✗"

    ssh "@"
    root "#"
    jobs "*"
    container "⧉"
)

CORBON_STYLE=(
    foreground "normal"
    muted "normal"
    accent "bold"
    prompt "normal"

    git_branch "normal"
    git_arrow "normal"
    git_clean "normal"
    git_dirty "bold"
    git_staged "normal"
    git_untracked "normal"
    git_conflict "bold"

    error "bold"
    warning "normal"
)

_corbon_color() {
    local name="$1"
    local fallback="${2:-muted}"
    local value="${CORBON_PALETTE[$name]}"

    [[ -n "$value" ]] || value="${CORBON_PALETTE[$fallback]}"

    case "$CORBON_COLOR_MODE" in
        truecolor)
            print -r -- "%F{${value}}"
            ;;
        palette)
            case "$name" in
                foreground|path|shell)
                    print -r -- "%F{255}"
                    ;;
                muted|secondary|duration|time|date|separator)
                    print -r -- "%F{242}"
                    ;;
                accent|prompt|git_arrow)
                    print -r -- "%F{214}"
                    ;;
                accent_soft|gold|warning|git_dirty)
                    print -r -- "%F{221}"
                    ;;
                success|git_clean)
                    print -r -- "%F{114}"
                    ;;
                error|git_conflict|root)
                    print -r -- "%F{203}"
                    ;;
                info|git_ahead)
                    print -r -- "%F{117}"
                    ;;
                *)
                    print -r -- "%F{250}"
                    ;;
            esac
            ;;
        *)
            print -r -- "%F{${value}}"
            ;;
    esac
}

_corbon_style() {
    local name="$1"
    local style="${CORBON_STYLE[$name]}"

    case "$style" in
        bold)
            print -r -- "%B"
            ;;
        dim)
            print -r -- "%S"
            ;;
        underline)
            print -r -- "%U"
            ;;
        inverse)
            print -r -- "%S"
            ;;
        *)
            print -r -- ""
            ;;
    esac
}

_corbon_reset() {
    print -r -- "%f%b%s%u%k"
}

_corbon_paint() {
    local color="$1"
    local value="$2"
    local style="${3:-}"

    [[ -n "$value" ]] || return

    print -r -- "$(_corbon_color "$color")$(_corbon_style "$style")${value}$(_corbon_reset)"
}

_corbon_symbol() {
    local name="$1"

    [[ -n "${CORBON_SYMBOL[$name]}" ]] &&
        print -r -- "${CORBON_SYMBOL[$name]}"
}

_corbon_theme_ember() {
    CORBON_PALETTE=(
        background "#0D0F12"
        foreground "#F1F0EB"
        secondary "#B7B8B3"
        muted "#6E716F"

        accent "#FF8A3D"
        accent_soft "#FFB454"
        gold "#E7C66A"

        success "#72C98A"
        warning "#E7B85C"
        error "#E87575"
        info "#72B7D9"

        user "#E8C98B"
        host "#B9B6AC"

        path "#F1F0EB"
        path_home "#FFB454"
        path_root "#E87575"
        path_truncation "#6E716F"

        separator "#35393F"

        git_branch "#F1F0EB"
        git_arrow "#FF9A4A"
        git_clean "#78C98B"
        git_dirty "#E7B85C"
        git_staged "#D6A45E"
        git_untracked "#A8A9A4"
        git_conflict "#E87575"
        git_stash "#C39A68"
        git_ahead "#72B7D9"
        git_behind "#8E91A0"

        python "#7FAF9A"
        node "#91B875"
        go "#72B7A4"
        rust "#C9826B"
        java "#D18B6F"
        ruby "#B87883"

        docker "#72AEB7"
        kubernetes "#7899C7"
        aws "#D9A15F"
        gcp "#719BC7"
        azure "#6EA8C8"
        terraform "#967FC2"

        os "#A7ABB2"
        arch "#858A93"
        shell "#F1F0EB"
        jobs "#D4A85E"
        root "#E87575"
        container "#7FB5B0"

        duration "#858A93"
        time "#858A93"
        date "#858A93"

        prompt "#FF8A3D"
        prompt_arrow "#FFB454"
        continuation "#B97845"

        exit_success "#72C98A"
        exit_error "#E87575"
    )
}

_corbon_theme_mono() {
    CORBON_PALETTE=(
        background "#0D0F12"
        foreground "#F1F0EB"
        secondary "#B7B8B3"
        muted "#6E716F"

        accent "#F1F0EB"
        accent_soft "#B7B8B3"
        gold "#B7B8B3"

        success "#F1F0EB"
        warning "#F1F0EB"
        error "#F1F0EB"
        info "#F1F0EB"

        user "#F1F0EB"
        host "#B7B8B3"

        path "#F1F0EB"
        path_home "#F1F0EB"
        path_root "#F1F0EB"
        path_truncation "#6E716F"

        separator "#35393F"

        git_branch "#F1F0EB"
        git_arrow "#B7B8B3"
        git_clean "#F1F0EB"
        git_dirty "#F1F0EB"
        git_staged "#F1F0EB"
        git_untracked "#B7B8B3"
        git_conflict "#F1F0EB"
        git_stash "#B7B8B3"
        git_ahead "#B7B8B3"
        git_behind "#6E716F"

        python "#B7B8B3"
        node "#B7B8B3"
        go "#B7B8B3"
        rust "#B7B8B3"
        java "#B7B8B3"
        ruby "#B7B8B3"

        docker "#B7B8B3"
        kubernetes "#B7B8B3"
        aws "#B7B8B3"
        gcp "#B7B8B3"
        azure "#B7B8B3"
        terraform "#B7B8B3"

        os "#6E716F"
        arch "#6E716F"
        shell "#F1F0EB"
        jobs "#B7B8B3"
        root "#F1F0EB"
        container "#B7B8B3"

        duration "#6E716F"
        time "#6E716F"
        date "#6E716F"

        prompt "#F1F0EB"
        prompt_arrow "#B7B8B3"
        continuation "#6E716F"

        exit_success "#F1F0EB"
        exit_error "#F1F0EB"
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

: ${CORBON_SHOW_USER:=false}
: ${CORBON_SHOW_HOST:="ssh"}
: ${CORBON_SHOW_EXIT:=true}

: ${CORBON_PATH_STYLE:="smart"}
: ${CORBON_PATH_MAX:=4}

: ${CORBON_GIT_BRANCH:=true}
: ${CORBON_GIT_STATUS:=true}
: ${CORBON_GIT_AHEAD_BEHIND:=true}
: ${CORBON_GIT_CACHE:=true}
: ${CORBON_GIT_CACHE_TTL:=2}

: ${CORBON_GIT_SHOW_ICON:=true}
: ${CORBON_GIT_SHOW_ARROW:=true}

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

corbon_symbol() {
    local name="$1"
    local value="$2"

    [[ -n "$name" ]] || return 1

    CORBON_SYMBOL[$name]="$value"
}

corbon_color() {
    local name="$1"
    local value="$2"

    [[ -n "$name" && -n "$value" ]] || return 1

    CORBON_PALETTE[$name]="$value"
}

corbon_style() {
    local name="$1"
    local value="$2"

    [[ -n "$name" ]] || return 1

    CORBON_STYLE[$name]="$value"
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
                result+="${CORBON_SYMBOL[git_conflict]}"
                ;;
            \?\?)
                result+="${CORBON_SYMBOL[git_untracked]}"
                ;;
            *)
                [[ "${line[1]}" != " " ]] &&
                    result+="${CORBON_SYMBOL[git_staged]}"

                [[ "${line[2]}" != " " ]] &&
                    result+="${CORBON_SYMBOL[git_dirty]}"
                ;;
        esac
    done < <(git status --porcelain=v1 2>/dev/null)

    [[ -z "$result" ]] &&
        result="${CORBON_SYMBOL[git_clean]}"

    print -r -- "$result"
}

_corbon_git_status_color() {
    local status="$1"

    [[ "$status" == *"${CORBON_SYMBOL[git_conflict]}"* ]] &&
        print -r -- "git_conflict" && return

    [[ "$status" == *"${CORBON_SYMBOL[git_staged]}"* ]] &&
        print -r -- "git_staged" && return

    [[ "$status" == *"${CORBON_SYMBOL[git_untracked]}"* ]] &&
        print -r -- "git_untracked" && return

    [[ "$status" == *"${CORBON_SYMBOL[git_dirty]}"* ]] &&
        print -r -- "git_dirty" && return

    print -r -- "git_clean"
}

_corbon_git_build() {
    _corbon_git_root || return

    local branch=""
    local status=""
    local result=""
    local ahead=0
    local behind=0
    local status_color="git_clean"

    if [[ "$CORBON_GIT_BRANCH" == true ]]; then
        branch="$(_corbon_git_branch)"
    fi

    if [[ "$CORBON_GIT_STATUS" == true ]]; then
        status="$(_corbon_git_status)"
        status_color="$(_corbon_git_status_color "$status")"
    fi

    if [[ "$CORBON_GIT_AHEAD_BEHIND" == true ]]; then
        ahead="$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)" || ahead=0
        behind="$(git rev-list --count 'HEAD..@{upstream}' 2>/dev/null)" || behind=0
    fi

    if [[ "$CORBON_GIT_SHOW_ICON" == true && -n "$branch" ]]; then
        result+="$(_corbon_paint git_arrow "${CORBON_SYMBOL[git_branch]}") "
    fi

    if [[ -n "$branch" ]]; then
        result+="$(_corbon_paint git_branch "$branch" git_branch)"
    fi

    if [[ "$CORBON_GIT_SHOW_ARROW" == true && -n "$status" && -n "$branch" ]]; then
        result+=" $(_corbon_paint git_arrow "${CORBON_SYMBOL[git_arrow]}")"
    fi

    if [[ -n "$status" ]]; then
        result+=" $(_corbon_paint "$status_color" "$status")"
    fi

    if (( ahead > 0 )); then
        result+=" $(_corbon_paint git_ahead "↑${ahead}")"
    fi

    if (( behind > 0 )); then
        result+=" $(_corbon_paint git_behind "↓${behind}")"
    fi

    [[ -n "$result" ]] &&
        print -r -- "$result"
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
        result+="$(_corbon_paint user "%n")"
    fi

    if [[ "$CORBON_SHOW_HOST" == true ]]; then
        if [[ "$CORBON_SHOW_HOST" != "ssh" || -n "$SSH_CONNECTION" ]]; then
            [[ -n "$result" ]] &&
                result+="$(_corbon_paint separator " ")"

            result+="$(_corbon_paint host "%m")"
        fi
    fi

    if [[ "$EUID" == 0 ]]; then
        [[ -n "$result" ]] &&
            result+="$(_corbon_paint separator " ")"

        result+="$(_corbon_paint root "${CORBON_SYMBOL[root]}" root)"
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

    local color="path"

    [[ "$path" == "~" || "$path" == "~/"* ]] &&
        color="path_home"

    [[ "$PWD" == "/" ]] &&
        color="path_root"

    print -r -- "$(_corbon_paint "$color" "$path")"
}

_corbon_python_segment() {
    [[ -n "$VIRTUAL_ENV" ]] || return

    print -r -- "$(_corbon_paint python "py:${VIRTUAL_ENV:t}")"
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

    print -r -- "$(_corbon_paint node "node:${version}")"
}

_corbon_duration_segment() {
    [[ "$CORBON_SHOW_DURATION" == true ]] || return
    (( CORBON_LAST_DURATION >= CORBON_DURATION_THRESHOLD )) || return

    print -r -- "$(_corbon_paint duration "${CORBON_LAST_DURATION}s")"
}

_corbon_time_segment() {
    [[ "$CORBON_SHOW_TIME" == true ]] || return

    print -r -- "$(_corbon_paint time "$(strftime "$CORBON_TIME_FORMAT")")"
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
        context)
            _corbon_context_segment
            ;;
        path)
            _corbon_path_segment
            ;;
        git)
            _corbon_git_segment
            ;;
        python)
            _corbon_python_segment
            ;;
        node)
            _corbon_node_segment
            ;;
        duration)
            _corbon_duration_segment
            ;;
        time)
            _corbon_time_segment
            ;;
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
            PROMPT+=" $(_corbon_paint exit_error "${CORBON_LAST_EXIT}" error)"
        fi

        PROMPT+=$'\n'
        PROMPT+="$(_corbon_paint prompt "${CORBON_SYMBOL[prompt]}" prompt) "

        RPROMPT="$right"
    else
        PROMPT="$left"

        [[ -n "$right" ]] &&
            PROMPT+="${CORBON_SEPARATOR}${right}"

        if (( CORBON_LAST_EXIT != 0 )) && [[ "$CORBON_SHOW_EXIT" == true ]]; then
            PROMPT+=" $(_corbon_paint exit_error "${CORBON_LAST_EXIT}" error)"
        fi

        PROMPT+=" $(_corbon_paint prompt "${CORBON_SYMBOL[prompt]}" prompt) "
        RPROMPT=""
    fi
}

autoload -Uz add-zsh-hook

add-zsh-hook preexec _corbon_preexec
add-zsh-hook precmd _corbon_precmd

PROMPT="$(_corbon_paint prompt "${CORBON_SYMBOL[prompt]}" prompt) "
RPROMPT=""