CORBON_THEME="ember"
CORBON_COLOR_MODE="palette"

CORBON_LAYOUT="two-line"

CORBON_LEFT=(
    context
    path
    git
)

CORBON_RIGHT=(
    python
    node
    duration
    time
)

CORBON_SEPARATOR="  "

CORBON_PROMPT_SYMBOL="⟫"
CORBON_CONTINUATION_SYMBOL="·"

CORBON_SHOW_USER=true
CORBON_SHOW_HOST="ssh"
CORBON_SHOW_EXIT=true

CORBON_PATH_STYLE="smart"
CORBON_PATH_MAX=4

CORBON_GIT_BRANCH=true
CORBON_GIT_STATUS=true
CORBON_GIT_AHEAD_BEHIND=true

CORBON_GIT_ARROW_SYMBOL="⟫"
CORBON_GIT_CLEAN_SYMBOL="✓"
CORBON_GIT_DIRTY_SYMBOL="±"
CORBON_GIT_STAGED_SYMBOL="+"
CORBON_GIT_UNTRACKED_SYMBOL="?"
CORBON_GIT_CONFLICT_SYMBOL="!"

CORBON_GIT_CACHE=true
CORBON_GIT_CACHE_TTL=2

CORBON_SHOW_DURATION=true
CORBON_DURATION_THRESHOLD=1

CORBON_SHOW_TIME=false
CORBON_TIME_FORMAT="%H:%M"

CORBON_SHOW_DOCKER=false
CORBON_SHOW_KUBERNETES=false
CORBON_SHOW_AWS=false
CORBON_SHOW_GCP=false
CORBON_SHOW_AZURE=false

CORBON_SHOW_GO=false
CORBON_SHOW_RUST=false
CORBON_SHOW_JAVA=false
CORBON_SHOW_RUBY=false

CORBON_SHOW_OS=false
CORBON_SHOW_ARCH=false
CORBON_SHOW_JOBS=true
CORBON_SHOW_ROOT=true
CORBON_SHOW_CONTAINER=true

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