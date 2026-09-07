typeset -g CORBON_VERSION="0.5.0"
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
: ${CORBON_GIT_CACHE:=true}
: ${CORBON_GIT_CACHE_TTL:=2}

: ${CORBON_GIT_CLEAN_SYMBOL:="✓"}
: ${CORBON_GIT_DIRTY_SYMBOL:="±"}
: ${CORBON_GIT_STAGED_SYMBOL:="+"}
: ${CORBON_GIT_UNTRACKED_SYMBOL:="?"}
: ${CORBON_GIT_CONFLICT_SYMBOL:="!"}

: ${CORBON_SHOW_DURATION:=true}
: ${CORBON_DURATION_THRESHOLD:=1}

: ${CORBON_SHOW_TIME:=false}
: ${CORBON_TIME_FORMAT:="%H:%M"}

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

: ${CORBON_ICON_DOCKER:="docker:"}
: ${CORBON_ICON_KUBERNETES:="k8s:"}
: ${CORBON_ICON_AWS:="aws:"}
: ${CORBON_ICON_GCP:="gcp:"}
: ${CORBON_ICON_AZURE:="az:"}
: ${CORBON_ICON_GO:="go:"}
: ${CORBON_ICON_RUST:="rs:"}
: ${CORBON_ICON_JAVA:="java:"}
: ${CORBON_ICON_RUBY:="rb:"}
: ${CORBON_ICON_OS:="os:"}
: ${CORBON_ICON_ARCH:="arch:"}
: ${CORBON_ICON_JOBS:="jobs:"}
: ${CORBON_ICON_ROOT:="root:"}
: ${CORBON_ICON_CONTAINER:="container:"}

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

    print -r -- "${CORBON_COLOR_MUTED}node:${version}${CORBON_RESET}"
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

    local context
    local namespace

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
    [[ -f go.mod ]] || return
    command -v go >/dev/null 2>&1 || return

    local version
    version="$(go version 2>/dev/null)" || return
    version="${version#go version go}"
    version="${version%% *}"

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_GO}${version}${CORBON_RESET}"
}

_corbon_rust_segment() {
    [[ "$CORBON_SHOW_RUST" == true ]] || return
    [[ -f Cargo.toml ]] || return
    command -v rustc >/dev/null 2>&1 || return

    local version
    version="$(rustc --version 2>/dev/null)" || return
    version="${version#rustc }"
    version="${version%% *}"

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_RUST}${version}${CORBON_RESET}"
}

_corbon_java_segment() {
    [[ "$CORBON_SHOW_JAVA" == true ]] || return
    [[ -f pom.xml || -f build.gradle || -f build.gradle.kts || -f settings.gradle ]] || return
    command -v java >/dev/null 2>&1 || return

    local version
    version="$(java -version 2>&1 | head -n 1)" || return

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_JAVA}${version}${CORBON_RESET}"
}

_corbon_ruby_segment() {
    [[ "$CORBON_SHOW_RUBY" == true ]] || return
    [[ -f Gemfile || -f .ruby-version ]] || return
    command -v ruby >/dev/null 2>&1 || return

    local version
    version="$(ruby --version 2>/dev/null)" || return
    version="${version#ruby }"
    version="${version%% *}"

    print -r -- "${CORBON_COLOR_MUTED}${CORBON_ICON_RUBY}${version}${CORBON_RESET}"
}

_corbon_os_segment() {
    [[ "$CORBON_SHOW_OS" == true ]] || return

    local os="$OSTYPE"

    case "$os" in
        darwin*) os="macOS" ;;
        linux*) os="Linux" ;;
        freebsd*) os="FreeBSD" ;;
        *) os="${os%%-*}" ;;
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

    if [[ "$CORBON_LAYOUT" == "two-line" ]]; then
        PROMPT="$left"

        if (( CORBON_LAST_EXIT != 0 )) && [[ "$CORBON_SHOW_EXIT" == true ]]; then
            PROMPT+=" ${CORBON_COLOR_ERROR}${CORBON_LAST_EXIT}${CORBON_RESET}"
        fi

        PROMPT+="\n"
        PROMPT+="${CORBON_COLOR_ACCENT}${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "

        RPROMPT="$right"
    else
        PROMPT="$left"

        [[ -n "$right" ]] &&
            PROMPT+="${CORBON_SEPARATOR}${right}"

        if (( CORBON_LAST_EXIT != 0 )) && [[ "$CORBON_SHOW_EXIT" == true ]]; then
            PROMPT+=" ${CORBON_COLOR_ERROR}${CORBON_LAST_EXIT}${CORBON_RESET}"
        fi

        PROMPT+=" ${CORBON_COLOR_ACCENT}${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "
        RPROMPT=""
    fi
}

autoload -Uz add-zsh-hook

add-zsh-hook preexec _corbon_preexec
add-zsh-hook precmd _corbon_precmd

PROMPT="${CORBON_COLOR_ACCENT}${CORBON_PROMPT_SYMBOL}${CORBON_RESET} "
RPROMPT=""