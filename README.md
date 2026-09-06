<details>
<summary>1, 2, 3 — CORBONNNNNNN. 🔥</summary>

Let's actually start the repo with a working lightweight core, not a mockup.

I’d start with these 3 files:

corbon-zsh-theme/
├── corbon.zsh-theme
├── corbon.config.zsh
└── README.md

## 1. corbon.zsh-theme

~~~zsh
# Corbon ZSH Theme
# https://github.com/spideythedev/corbon-zsh-theme

typeset -g CORBON_VERSION="0.1.0"

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
~~~

## 2. corbon.config.zsh

This is where Corbon becomes seriously customizable.

~~~zsh
# Corbon user configuration

# ─────────────────────────────────────
# Layout
# ─────────────────────────────────────

CORBON_LAYOUT="two-line"

CORBON_LEFT="context path git"
CORBON_RIGHT="python node duration time"

CORBON_SEPARATOR="  "

CORBON_PROMPT_SYMBOL="❯"
CORBON_CONTINUATION_SYMBOL="·"

# ─────────────────────────────────────
# Context
# ─────────────────────────────────────

CORBON_SHOW_USER=true
CORBON_SHOW_HOST="ssh"

# ─────────────────────────────────────
# Path
# ─────────────────────────────────────

CORBON_PATH_STYLE="smart"
CORBON_PATH_MAX=4
CORBON_PATH_TRUNCATE="…"

# ─────────────────────────────────────
# Git
# ─────────────────────────────────────

CORBON_GIT_BRANCH=true
CORBON_GIT_STATUS=true
CORBON_GIT_AHEAD_BEHIND=true

CORBON_GIT_CLEAN_SYMBOL="✓"
CORBON_GIT_DIRTY_SYMBOL="±"
CORBON_GIT_STAGED_SYMBOL="+"
CORBON_GIT_UNTRACKED_SYMBOL="?"
CORBON_GIT_CONFLICT_SYMBOL="!"

# ─────────────────────────────────────
# Runtime
# ─────────────────────────────────────

CORBON_SHOW_EXIT=true

CORBON_SHOW_DURATION=true
CORBON_DURATION_THRESHOLD=1

CORBON_SHOW_TIME=false
CORBON_TIME_FORMAT="%H:%M"

# ─────────────────────────────────────
# Colors
# ─────────────────────────────────────

CORBON_COLOR_USER="%F{white}"
CORBON_COLOR_HOST="%F{cyan}"
CORBON_COLOR_PATH="%F{245}"

CORBON_COLOR_GIT="%F{yellow}"

CORBON_COLOR_SUCCESS="%F{green}"
CORBON_COLOR_ERROR="%F{red}"

CORBON_COLOR_MUTED="%F{242}"
CORBON_COLOR_ACCENT="%F{yellow}"

CORBON_RESET="%f"
~~~

## 3. README.md

~~~md
# Corbon

A lightweight, highly customizable ZSH theme.

Corbon is designed to be fast, clean, dependency-free, and configurable without turning the prompt into a complicated framework.

## Features

- Lightweight
- No external dependencies
- Git integration
- Smart path display
- Python environment detection
- Node.js detection
- Command duration
- Exit status
- SSH awareness
- One-line and two-line layouts
- Custom segments
- Custom symbols
- Custom colors
- Configurable segment ordering
- Minimal defaults
- Native ZSH

## Installation

Clone the repository:

    git clone https://github.com/spideythedev/corbon-zsh-theme.git

Load the theme:

    source /path/to/corbon-zsh-theme/corbon.zsh-theme

Load your configuration before the theme:

    source ~/.config/corbon/config.zsh
    source /path/to/corbon-zsh-theme/corbon.zsh-theme

## Configuration

Corbon is designed around configurable segments.

    CORBON_LEFT="context path git"
    CORBON_RIGHT="python node duration time"

Change the layout:

    CORBON_LAYOUT="two-line"

Or:

    CORBON_LAYOUT="one-line"

Change the separator:

    CORBON_SEPARATOR=" · "

Change the prompt symbol:

    CORBON_PROMPT_SYMBOL="❯"

## Git

    CORBON_GIT_BRANCH=true
    CORBON_GIT_STATUS=true
    CORBON_GIT_AHEAD_BEHIND=true

Git symbols are configurable:

    CORBON_GIT_CLEAN_SYMBOL="✓"
    CORBON_GIT_DIRTY_SYMBOL="±"
    CORBON_GIT_STAGED_SYMBOL="+"
    CORBON_GIT_UNTRACKED_SYMBOL="?"
    CORBON_GIT_CONFLICT_SYMBOL="!"

## Path

    CORBON_PATH_STYLE="smart"
    CORBON_PATH_MAX=4

## Colors

Every major part of the prompt can use its own color.

    CORBON_COLOR_USER="%F{white}"
    CORBON_COLOR_HOST="%F{cyan}"
    CORBON_COLOR_PATH="%F{245}"
    CORBON_COLOR_GIT="%F{yellow}"
    CORBON_COLOR_SUCCESS="%F{green}"
    CORBON_COLOR_ERROR="%F{red}"
    CORBON_COLOR_MUTED="%F{242}"
    CORBON_COLOR_ACCENT="%F{yellow}"

## Philosophy

Corbon should stay small.

Customization should come from configuration, not unnecessary framework code.

The default experience is intentionally simple. Users can progressively add the information they actually want.

## License

MIT
~~~

One correction before we continue: **I would not merge this into the final repo yet.**

This is **Corbon v0.1 foundation**. Next I'd tighten the segment API, eliminate avoidable subprocesses like `grep` and `date` where practical, add proper command-duration tracking, and then build the **signature Corbon appearance**.

The goal is not merely:

    a ZSH theme that works

It's:

    CORBON
    lightweight prompt engine
    ═══════════════════════════
    simple by default
    insane when customized

**1. Core. 2. Config. 3. Corbon.**

</details>