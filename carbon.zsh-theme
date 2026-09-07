typeset -g CORBON_VERSION="0.3.0"
typeset -gA CORBON_SEGMENTS

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
        context)     _corbon_context_segment ;;
        path)        _corbon_path_segment ;;
        git)         _corbon_git_segment ;;
        python)      _corbon_python_segment ;;
        node)        _corbon_node_segment ;;
        duration)    _corbon_duration_segment ;;
        time)        _corbon_time_segment ;;
        docker)      _corbon_docker_segment ;;
        kubernetes)  _corbon_kubernetes_segment ;;
        aws)         _corbon_aws_segment ;;
        gcp)         _corbon_gcp_segment ;;
        azure)       _corbon_azure_segment ;;
        go)          _corbon_go_segment ;;
        rust)        _corbon_rust_segment ;;
        java)        _corbon_java_segment ;;
        ruby)        _corbon_ruby_segment ;;
        os)          _corbon_os_segment ;;
        arch)        _corbon_arch_segment ;;
        jobs)        _corbon_jobs_segment ;;
        root)        _corbon_root_segment ;;
        container)   _corbon_container_segment ;;
    esac
}
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

    [[ -n "$right" ]] &&
        prompt+="${CORBON_SEPARATOR}${right}"

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

typeset -g CORBON_ICON_DOCKER="docker:"
typeset -g CORBON_ICON_KUBERNETES="k8s:"
typeset -g CORBON_ICON_AWS="aws:"
typeset -g CORBON_ICON_GCP="gcp:"
typeset -g CORBON_ICON_AZURE="az:"
typeset -g CORBON_ICON_GO="go:"
typeset -g CORBON_ICON_RUST="rs:"
typeset -g CORBON_ICON_JAVA="java:"
typeset -g CORBON_ICON_RUBY="rb:"
typeset -g CORBON_ICON_OS="os:"
typeset -g CORBON_ICON_ARCH="arch:"
typeset -g CORBON_ICON_JOBS="jobs:"
typeset -g CORBON_ICON_ROOT="root:"
typeset -g CORBON_ICON_CONTAINER="container:"

: ${CORBON_SHOW_DOCKER:=false}
: ${CORBON_SHOW_KUBERNETES:=false}
: ${CORBON_SHOW_AWS:=false}
: ${CORBON_SHOW_GCP:=false}
: ${CORBON_SHOW_AZURE:=false}
: ${CORBON_SHOW_GO:=false}
: ${CORBON_SHOW_RUST:=false}
: ${CORBON_SHOW_JAVA:=false}
: ${CORBON_SHOW_RUBY:=false}
: ${CORBON_SHOW_OS:=false}
: ${CORBON_SHOW_ARCH:=false}
: ${CORBON_SHOW_JOBS:=true}
: ${CORBON_SHOW_ROOT:=true}
: ${CORBON_SHOW_CONTAINER:=true}

_corbon_docker_segment() {
    [[ "$CORBON_SHOW_DOCKER" == true ]] || return
    command -v docker >/dev/null 2>&1 || return

    local context
    context="$(docker context show 2>/dev/null)" || return

    [[ "$context" == "default" ]] && return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_DOCKER}${context}${CORBON_RESET}"
}

_corbon_kubernetes_segment() {
    [[ "$CORBON_SHOW_KUBERNETES" == true ]] || return
    command -v kubectl >/dev/null 2>&1 || return

    local context namespace

    context="$(kubectl config current-context 2>/dev/null)" || return
    namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"

    [[ -z "$namespace" ]] && namespace="default"

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_KUBERNETES}${context}:${namespace}${CORBON_RESET}"
}

_corbon_aws_segment() {
    [[ "$CORBON_SHOW_AWS" == true ]] || return
    [[ -n "$AWS_PROFILE" ]] || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_AWS}${AWS_PROFILE}${CORBON_RESET}"
}

_corbon_gcp_segment() {
    [[ "$CORBON_SHOW_GCP" == true ]] || return

    local project="${CLOUDSDK_CORE_PROJECT:-$GCLOUD_PROJECT}"

    [[ -n "$project" ]] || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_GCP}${project}${CORBON_RESET}"
}

_corbon_azure_segment() {
    [[ "$CORBON_SHOW_AZURE" == true ]] || return
    [[ -n "$AZURE_SUBSCRIPTION_ID" ]] || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_AZURE}${AZURE_SUBSCRIPTION_ID}${CORBON_RESET}"
}

_corbon_go_segment() {
    [[ "$CORBON_SHOW_GO" == true ]] || return
    command -v go >/dev/null 2>&1 || return

    [[ -f go.mod ]] || return

    local version
    version="$(go version 2>/dev/null)" || return
    version="${version#go version go}"
    version="${version%% *}"

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_GO}${version}${CORBON_RESET}"
}

_corbon_rust_segment() {
    [[ "$CORBON_SHOW_RUST" == true ]] || return
    command -v rustc >/dev/null 2>&1 || return

    [[ -f Cargo.toml ]] || return

    local version
    version="$(rustc --version 2>/dev/null)" || return
    version="${version#rustc }"
    version="${version%% *}"

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_RUST}${version}${CORBON_RESET}"
}

_corbon_java_segment() {
    [[ "$CORBON_SHOW_JAVA" == true ]] || return
    command -v java >/dev/null 2>&1 || return

    [[ -f pom.xml || -f build.gradle || -f build.gradle.kts || -f settings.gradle ]] || return

    local version
    version="$(java -version 2>&1 | head -n 1)" || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_JAVA}${version}${CORBON_RESET}"
}

_corbon_ruby_segment() {
    [[ "$CORBON_SHOW_RUBY" == true ]] || return
    command -v ruby >/dev/null 2>&1 || return

    [[ -f Gemfile || -f .ruby-version ]] || return

    local version
    version="$(ruby --version 2>/dev/null)" || return
    version="${version#ruby }"
    version="${version%% *}"

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_RUBY}${version}${CORBON_RESET}"
}

_corbon_os_segment() {
    [[ "$CORBON_SHOW_OS" == true ]] || return

    local os="${OSTYPE}"

    case "$os" in
        darwin*)
            os="macOS"
            ;;
        linux*)
            os="Linux"
            ;;
        freebsd*)
            os="FreeBSD"
            ;;
        *)
            os="${os%%-*}"
            ;;
    esac

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_OS}${os}${CORBON_RESET}"
}

_corbon_arch_segment() {
    [[ "$CORBON_SHOW_ARCH" == true ]] || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_ARCH}${CPU_ARCH:-${MACHTYPE%%-*}}${CORBON_RESET}"
}

_corbon_jobs_segment() {
    [[ "$CORBON_SHOW_JOBS" == true ]] || return

    local jobs="${#jobstates}"

    (( jobs > 0 )) || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_JOBS}${jobs}${CORBON_RESET}"
}

_corbon_root_segment() {
    [[ "$CORBON_SHOW_ROOT" == true ]] || return
    (( EUID == 0 )) || return

    print -r -- "${CORBON_COLOR_ERROR}${CORBON_ICON_ROOT}${CORBON_RESET}"
}

_corbon_container_segment() {
    [[ "$CORBON_SHOW_CONTAINER" == true ]] || return

    if [[ -n "$container" ]]; then
        print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_CONTAINER}${container}${CORBON_RESET}"
        return
    fi

    [[ -f /.dockerenv ]] || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_CONTAINER}docker${CORBON_RESET}"
}