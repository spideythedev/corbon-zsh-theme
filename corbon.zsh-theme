# Corbon ZSH Theme
# Lightweight, configurable ZSH prompt engine
# MIT License © 2026 Fahad Malik

CORBON_VERSION="1.0.0"

typeset -gA CORBON_SEGMENTS
typeset -gA CORBON_PALETTE
typeset -gA CORBON_SYMBOL
typeset -gA CORBON_STYLE
typeset -gA CORBON_CUSTOM_SEGMENTS
typeset -gA CORBON_CACHE
typeset -gA CORBON_CACHE_TIME

CORBON_THEME="${CORBON_THEME:-ember}"
CORBON_COLOR_MODE="${CORBON_COLOR_MODE:-truecolor}"
CORBON_PERFORMANCE="${CORBON_PERFORMANCE:-balanced}"

CORBON_LAYOUT="${CORBON_LAYOUT:-two-line}"
CORBON_GIT_CACHE_TTL="${CORBON_GIT_CACHE_TTL:-2}"
CORBON_RUNTIME_CACHE_TTL="${CORBON_RUNTIME_CACHE_TTL:-5}"

CORBON_SHOW_USER="${CORBON_SHOW_USER:-false}"
CORBON_SHOW_HOST="${CORBON_SHOW_HOST:-false}"
CORBON_SHOW_TIME="${CORBON_SHOW_TIME:-false}"
CORBON_SHOW_DATE="${CORBON_SHOW_DATE:-false}"
CORBON_SHOW_DURATION="${CORBON_SHOW_DURATION:-true}"
CORBON_SHOW_EXIT="${CORBON_SHOW_EXIT:-true}"
CORBON_SHOW_BATTERY="${CORBON_SHOW_BATTERY:-false}"
CORBON_SHOW_JOBS="${CORBON_SHOW_JOBS:-true}"
CORBON_SHOW_OS="${CORBON_SHOW_OS:-false}"
CORBON_SHOW_ARCH="${CORBON_SHOW_ARCH:-false}"
CORBON_SHOW_SHELL="${CORBON_SHOW_SHELL:-false}"
CORBON_SHOW_CONTAINER="${CORBON_SHOW_CONTAINER:-true}"

CORBON_SHOW_PYTHON="${CORBON_SHOW_PYTHON:-true}"
CORBON_SHOW_NODE="${CORBON_SHOW_NODE:-true}"
CORBON_SHOW_GO="${CORBON_SHOW_GO:-false}"
CORBON_SHOW_RUST="${CORBON_SHOW_RUST:-false}"
CORBON_SHOW_JAVA="${CORBON_SHOW_JAVA:-false}"
CORBON_SHOW_RUBY="${CORBON_SHOW_RUBY:-false}"

CORBON_SHOW_DOCKER="${CORBON_SHOW_DOCKER:-false}"
CORBON_SHOW_KUBERNETES="${CORBON_SHOW_KUBERNETES:-false}"
CORBON_SHOW_TERRAFORM="${CORBON_SHOW_TERRAFORM:-false}"
CORBON_SHOW_AWS="${CORBON_SHOW_AWS:-false}"
CORBON_SHOW_GCP="${CORBON_SHOW_GCP:-false}"
CORBON_SHOW_AZURE="${CORBON_SHOW_AZURE:-false}"

CORBON_LS_COLORS="${CORBON_LS_COLORS:-true}"

CORBON_CONTINUATION_SYMBOL="${CORBON_CONTINUATION_SYMBOL:-╰─⟫}"
CORBON_PROMPT_SYMBOL="${CORBON_PROMPT_SYMBOL:-╰─⟫}"

CORBON_LEFT=(
  context
  path
  git
)

CORBON_RIGHT=(
  python
  node
  duration
  exit
  jobs
  time
)

CORBON_PALETTE=(
  bg "#0D0F12"
  fg "#F1F0EB"
  secondary "#B7B8B3"
  muted "#6E716F"
  accent "#FF8A3D"
  accent_soft "#FFB454"
  gold "#E7C66A"
  success "#72C98A"
  warning "#E7B85C"
  error "#E87575"
  info "#72B7D9"
  separator "#35393F"

  user "#E8C98B"
  host "#B9B6AC"
  path "#F1F0EB"
  home "#FFB454"
  root "#E87575"
  truncation "#6E716F"

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
  terraform "#967FC2"
  aws "#D9A15F"
  gcp "#719BC7"
  azure "#6EA8C8"

  os "#A7ABB2"
  arch "#858A93"
  shell "#F1F0EB"
  jobs "#D4A85E"
  container "#7FB5B0"
  duration "#858A93"
  time "#858A93"
  date "#858A93"
  prompt "#FF8A3D"
  continuation "#B97845"
)

CORBON_SYMBOL=(
  prompt "╰─⟫"
  arrow "⟫"
  separator "·"

  git "⎇"
  git_clean "✓"
  git_dirty "±"
  git_staged "+"
  git_untracked "?"
  git_conflict "✗"
  git_stash "⌥"
  git_ahead "↑"
  git_behind "↓"
  git_detached "⌘"

  user "@"
  host "@"
  root "#"
  ssh "@"
  jobs "*"
  container "⧉"

  python "Py"
  node "Node"
  go "Go"
  rust "Rs"
  java "Java"
  ruby "Rb"

  docker "Docker"
  kubernetes "K8s"
  terraform "Tf"
  aws "AWS"
  gcp "GCP"
  azure "Az"

  os "OS"
  arch "Arch"
  shell "Sh"
  duration "t"
  time "T"
  date "D"
)

CORBON_STYLE=(
  prompt "bold"
  git "bold"
  git_clean "bold"
  git_conflict "bold"
  error "bold"
  root "bold"
)

_corbon_color() {
  local name="$1"
  local value="${CORBON_PALETTE[$name]}"

  [[ -z "$value" ]] && value="$name"

  case "$CORBON_COLOR_MODE" in
    truecolor)
      print -Pn "%F{$value}"
      ;;
    256)
      case "$name" in
        accent|prompt|git_arrow) print -Pn "%F{214}" ;;
        success|git_clean) print -Pn "%F{114}" ;;
        warning|git_dirty) print -Pn "%F{179}" ;;
        error|git_conflict|root) print -Pn "%F{203}" ;;
        info|git_ahead|path|node) print -Pn "%F{75}" ;;
        muted|duration|time|date) print -Pn "%F{243}" ;;
        *) print -Pn "%F{252}" ;;
      esac
      ;;
    16)
      case "$name" in
        error|git_conflict|root) print -Pn "%F{red}" ;;
        success|git_clean) print -Pn "%F{green}" ;;
        warning|git_dirty|accent|prompt) print -Pn "%F{yellow}" ;;
        info|path|git_ahead) print -Pn "%F{cyan}" ;;
        *) print -Pn "%F{white}" ;;
      esac
      ;;
    mono)
      print -Pn "%f"
      ;;
  esac
}

_corbon_style() {
  case "$1" in
    bold) print -Pn "%B" ;;
    dim) print -Pn "%S" ;;
    underline) print -Pn "%U" ;;
    inverse) print -Pn "%K{white}%F{black}" ;;
    *) print -Pn "%f%b%s%u" ;;
  esac
}

_corbon_reset() {
  print -Pn "%f%b%s%u%k"
}

_corbon_paint() {
  local color="$1"
  local text="$2"
  local style="${3:-}"

  _corbon_color "$color"
  [[ -n "$style" ]] && _corbon_style "$style"
  print -Pn "$text"
  _corbon_reset
}

_corbon_symbol() {
  print -Pn "${CORBON_SYMBOL[$1]:-}"
}

_corbon_enabled() {
  local key="$1"
  [[ "${CORBON_SEGMENTS[$key]}" != disabled ]]
}

corbon_segment() {
  local name="$1"
  local function="$2"

  [[ -z "$name" || -z "$function" ]] && return 1
  CORBON_CUSTOM_SEGMENTS[$name]="$function"
}

corbon_symbol() {
  [[ -z "$1" ]] && return 1
  CORBON_SYMBOL[$1]="$2"
}

corbon_color() {
  [[ -z "$1" ]] && return 1
  CORBON_PALETTE[$1]="$2"
}

corbon_style() {
  [[ -z "$1" ]] && return 1
  CORBON_STYLE[$1]="$2"
}

corbon_enable() {
  CORBON_SEGMENTS[$1]=enabled
}

corbon_disable() {
  CORBON_SEGMENTS[$1]=disabled
}

corbon_layout() {
  case "$1" in
    one-line|two-line)
      CORBON_LAYOUT="$1"
      ;;
    *)
      return 1
      ;;
  esac
}

corbon_theme() {
  case "$1" in
    ember)
      CORBON_THEME="ember"
      CORBON_PALETTE[bg]="#0D0F12"
      CORBON_PALETTE[fg]="#F1F0EB"
      CORBON_PALETTE[accent]="#FF8A3D"
      CORBON_PALETTE[accent_soft]="#FFB454"
      CORBON_PALETTE[muted]="#6E716F"
      ;;
    mono)
      CORBON_THEME="mono"
      CORBON_COLOR_MODE="mono"
      ;;
    *)
      return 1
      ;;
  esac
}

_corbon_git_branch() {
  git symbolic-ref --quiet --short HEAD 2>/dev/null ||
    git rev-parse --short HEAD 2>/dev/null
}

_corbon_git_status() {
  local status line x y

  status="$(git status --porcelain=v1 --branch 2>/dev/null)" || return

  local staged=0
  local unstaged=0
  local untracked=0
  local conflict=0

  while IFS= read -r line; do
    [[ "$line" == "## "* ]] && continue

    x="${line[1]}"
    y="${line[2]}"

    if [[ "$x" == "?" && "$y" == "?" ]]; then
      ((untracked++))
      continue
    fi

    case "$x$y" in
      UU|AA|DD|AU|UA|DU|UD)
        ((conflict++))
        ;;
    esac

    [[ "$x" != " " ]] && ((staged++))
    [[ "$y" != " " ]] && ((unstaged++))
  done <<< "$status"

  local result=""

  ((conflict > 0)) && result+=" $( _corbon_symbol git_conflict )$conflict"
  ((staged > 0)) && result+=" $( _corbon_symbol git_staged )$staged"
  ((unstaged > 0)) && result+=" $( _corbon_symbol git_dirty )$unstaged"
  ((untracked > 0)) && result+=" $( _corbon_symbol git_untracked )$untracked"

  print -r -- "$result"
}

_corbon_git_ahead_behind() {
  local counts ahead behind

  counts="$(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)" || return

  ahead="${counts%%	*}"
  behind="${counts##*	}"

  [[ "$ahead" == "$behind" ]] && return

  ((behind > 0)) && print -Pn " $(_corbon_symbol git_behind)$behind"
  ((ahead > 0)) && print -Pn " $(_corbon_symbol git_ahead)$ahead"
}

_corbon_segment_git() {
  local branch status ahead

  branch="$(_corbon_git_branch)" || return

  status="$(_corbon_git_status)"
  ahead="$(_corbon_git_ahead_behind)"

  _corbon_color git_branch
  _corbon_style "${CORBON_STYLE[git]}"

  print -Pn " $(_corbon_symbol git) $branch"

  if [[ -z "$status" && -z "$ahead" ]]; then
    _corbon_color git_clean
    print -Pn " $(_corbon_symbol git_clean)"
  else
    [[ -n "$status" ]] && print -Pn "$status"
    [[ -n "$ahead" ]] && _corbon_paint git_ahead "$ahead"
  fi

  _corbon_reset
}

_corbon_segment_path() {
  local path="$PWD"

  if [[ "$path" == "$HOME" ]]; then
    _corbon_paint home "~"
    return
  fi

  path="${path/#$HOME/~}"

  _corbon_paint path "$path"
}

_corbon_segment_context() {
  local ssh=false root=false container=false
  local value=""

  [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]] && ssh=true
  [[ "$EUID" == 0 ]] && root=true

  if [[ -n "$container" || -f /.dockerenv || -f /run/.containerenv ]]; then
    container=true
  fi

  if $ssh; then
    value+=" $(_corbon_symbol ssh) "
    value+="$(_corbon_paint info "SSH" bold)"
  fi

  if $root; then
    value+=" "
    value+="$(_corbon_paint root "$(_corbon_symbol root)" bold)"
  fi

  if $container && [[ "$CORBON_SHOW_CONTAINER" == true ]]; then
    value+=" "
    value+="$(_corbon_paint container "$(_corbon_symbol container) container")"
  fi

  print -Pn "$value"
}

_corbon_runtime_version() {
  local key="$1"
  local command="$2"
  local version=""

  if [[ -n "${CORBON_CACHE[$key]}" ]]; then
    local age=$((SECONDS - ${CORBON_CACHE_TIME[$key]:-0}))
    (( age < CORBON_RUNTIME_CACHE_TTL )) && print -r -- "${CORBON_CACHE[$key]}" && return
  fi

  case "$key" in
    python)
      if [[ -n "$VIRTUAL_ENV" ]]; then
        version="${VIRTUAL_ENV:t}"
      elif [[ -f pyproject.toml || -f requirements.txt || -f .python-version ]]; then
        version="$(python --version 2>/dev/null | awk '{print $2}')"
      fi
      ;;
    node)
      if [[ -f .nvmrc ]]; then
        version="$(<.nvmrc)"
      elif [[ -f package.json ]]; then
        version="$(node --version 2>/dev/null | sed 's/^v//')"
      fi
      ;;
    go)
      [[ -f go.mod ]] && version="$(go version 2>/dev/null | awk '{print $3}' | sed 's/^go//')"
      ;;
    rust)
      [[ -f Cargo.toml ]] && version="$(rustc --version 2>/dev/null | awk '{print $2}')"
      ;;
    java)
      [[ -f pom.xml || -f build.gradle || -f build.gradle.kts ]] &&
        version="$(java -version 2>&1 | awk -F '"' '/version/ {print $2; exit}')"
      ;;
    ruby)
      [[ -f Gemfile || -f .ruby-version ]] &&
        version="$(ruby --version 2>/dev/null | awk '{print $2}')"
      ;;
  esac

  if [[ -n "$version" ]]; then
    CORBON_CACHE[$key]="$version"
    CORBON_CACHE_TIME[$key]=$SECONDS
    print -r -- "$version"
  fi
}

_corbon_runtime_segment() {
  local key="$1"
  local symbol="$2"
  local color="$3"
  local command="$4"
  local version

  version="$(_corbon_runtime_version "$key" "$command")"
  [[ -z "$version" ]] && return

  _corbon_color "$color"
  print -Pn " $(_corbon_symbol "$symbol") $version"
  _corbon_reset
}

_corbon_segment_python() {
  _corbon_runtime_segment python python python python
}

_corbon_segment_node() {
  _corbon_runtime_segment node node node node
}

_corbon_segment_go() {
  _corbon_runtime_segment go go go go
}

_corbon_segment_rust() {
  _corbon_runtime_segment rust rust rust rust
}

_corbon_segment_java() {
  _corbon_runtime_segment java java java java
}

_corbon_segment_ruby() {
  _corbon_runtime_segment ruby ruby ruby ruby
}

_corbon_segment_docker() {
  command -v docker >/dev/null 2>&1 || return
  docker context show 2>/dev/null | grep -qv '^default$' || [[ -f .docker-compose.yml || -f docker-compose.yml ]] || return

  _corbon_paint docker " $(_corbon_symbol docker) docker"
}

_corbon_segment_kubernetes() {
  [[ -n "$KUBECONFIG" || -f "$HOME/.kube/config" ]] || return
  command -v kubectl >/dev/null 2>&1 || return

  local context
  context="$(kubectl config current-context 2>/dev/null)"
  [[ -z "$context" ]] && return

  _corbon_paint kubernetes " $(_corbon_symbol kubernetes) $context"
}

_corbon_segment_terraform() {
  [[ -f main.tf || -f terraform.tf || -d .terraform ]] || return
  command -v terraform >/dev/null 2>&1 || return

  local version
  version="$(terraform version 2>/dev/null | head -1 | awk '{print $2}' | sed 's/^v//')"

  _corbon_paint terraform " $(_corbon_symbol terraform) ${version:-terraform}"
}

_corbon_segment_aws() {
  [[ -n "$AWS_PROFILE" || -n "$AWS_DEFAULT_REGION" ]] || return

  _corbon_paint aws " $(_corbon_symbol aws) ${AWS_PROFILE:-default}"
}

_corbon_segment_gcp() {
  [[ -n "$CLOUDSDK_ACTIVE_CONFIG_NAME" || -n "$GOOGLE_CLOUD_PROJECT" ]] || return

  _corbon_paint gcp " $(_corbon_symbol gcp) ${GOOGLE_CLOUD_PROJECT:-gcp}"
}

_corbon_segment_azure() {
  [[ -n "$AZURE_SUBSCRIPTION_ID" || -n "$AZURE_DEFAULTS_GROUP" ]] || return

  _corbon_paint azure " $(_corbon_symbol azure) azure"
}

_corbon_segment_os() {
  local os

  case "$(uname -s)" in
    Linux) os="Linux" ;;
    Darwin) os="macOS" ;;
    FreeBSD) os="FreeBSD" ;;
    OpenBSD) os="OpenBSD" ;;
    *) os="$(uname -s)" ;;
  esac

  _corbon_paint os " $(_corbon_symbol os) $os"
}

_corbon_segment_arch() {
  _corbon_paint arch " $(_corbon_symbol arch) $(uname -m)"
}

_corbon_segment_shell() {
  _corbon_paint shell " $(_corbon_symbol shell) zsh $ZSH_VERSION"
}

_corbon_segment_battery() {
  local battery=""

  if command -v termux-battery-status >/dev/null 2>&1; then
    battery="$(termux-battery-status 2>/dev/null | sed -n 's/.*"percentage": \([0-9]*\).*/\1/p')"
  elif command -v acpi >/dev/null 2>&1; then
    battery="$(acpi -b 2>/dev/null | grep -o '[0-9]*%' | tr -d '%')"
  fi

  [[ -z "$battery" ]] && return

  _corbon_paint info " $battery%"
}

_corbon_segment_jobs() {
  local count="${${jobstates:#}:-0}"

  (( count == 0 )) && return

  _corbon_paint jobs " $(_corbon_symbol jobs)$count"
}

_corbon_segment_time() {
  _corbon_paint time " $(_corbon_symbol time) $(date +%H:%M)"
}

_corbon_segment_date() {
  _corbon_paint date " $(_corbon_symbol date) $(date +%Y-%m-%d)"
}

_corbon_segment_duration() {
  [[ "$CORBON_SHOW_DURATION" == true ]] || return

  local elapsed=$((SECONDS - CORBON_COMMAND_START))

  (( elapsed < 2 )) && return

  _corbon_paint duration " $(_corbon_symbol duration) ${elapsed}s"
}

_corbon_segment_exit() {
  local code="$1"

  [[ "$CORBON_SHOW_EXIT" == true ]] || return
  (( code == 0 )) && return

  _corbon_paint error " ✗ $code" bold
}

_corbon_render_custom() {
  local name="$1"
  local function="${CORBON_CUSTOM_SEGMENTS[$name]}"

  [[ -z "$function" ]] && return
  (( $+functions[$function] )) || return

  "$function"
}

_corbon_render_segment() {
  local name="$1"
  local exit_code="$2"

  [[ "${CORBON_SEGMENTS[$name]}" == disabled ]] && return

  case "$name" in
    context) _corbon_segment_context ;;
    path) _corbon_segment_path ;;
    git) _corbon_segment_git ;;

    python) [[ "$CORBON_SHOW_PYTHON" == true ]] && _corbon_segment_python ;;
    node) [[ "$CORBON_SHOW_NODE" == true ]] && _corbon_segment_node ;;
    go) [[ "$CORBON_SHOW_GO" == true ]] && _corbon_segment_go ;;
    rust) [[ "$CORBON_SHOW_RUST" == true ]] && _corbon_segment_rust ;;
    java) [[ "$CORBON_SHOW_JAVA" == true ]] && _corbon_segment_java ;;
    ruby) [[ "$CORBON_SHOW_RUBY" == true ]] && _corbon_segment_ruby ;;

    docker) [[ "$CORBON_SHOW_DOCKER" == true ]] && _corbon_segment_docker ;;
    kubernetes) [[ "$CORBON_SHOW_KUBERNETES" == true ]] && _corbon_segment_kubernetes ;;
    terraform) [[ "$CORBON_SHOW_TERRAFORM" == true ]] && _corbon_segment_terraform ;;
    aws) [[ "$CORBON_SHOW_AWS" == true ]] && _corbon_segment_aws ;;
    gcp) [[ "$CORBON_SHOW_GCP" == true ]] && _corbon_segment_gcp ;;
    azure) [[ "$CORBON_SHOW_AZURE" == true ]] && _corbon_segment_azure ;;

    os) [[ "$CORBON_SHOW_OS" == true ]] && _corbon_segment_os ;;
    arch) [[ "$CORBON_SHOW_ARCH" == true ]] && _corbon_segment_arch ;;
    shell) [[ "$CORBON_SHOW_SHELL" == true ]] && _corbon_segment_shell ;;
    battery) [[ "$CORBON_SHOW_BATTERY" == true ]] && _corbon_segment_battery ;;
    jobs) [[ "$CORBON_SHOW_JOBS" == true ]] && _corbon_segment_jobs ;;
    time) [[ "$CORBON_SHOW_TIME" == true ]] && _corbon_segment_time ;;
    date) [[ "$CORBON_SHOW_DATE" == true ]] && _corbon_segment_date ;;
    duration) _corbon_segment_duration ;;
    exit) _corbon_segment_exit "$exit_code" ;;

    custom:*) _corbon_render_custom "${name#custom:}" ;;
    *) _corbon_render_custom "$name" ;;
  esac
}

_corbon_render_list() {
  local side="$1"
  local exit_code="$2"
  local segment

  if [[ "$side" == left ]]; then
    for segment in "${CORBON_LEFT[@]}"; do
      _corbon_render_segment "$segment" "$exit_code"
    done
  else
    for segment in "${CORBON_RIGHT[@]}"; do
      _corbon_render_segment "$segment" "$exit_code"
    done
  fi
}

_corbon_ls_colors() {
  [[ "$CORBON_LS_COLORS" == true ]] || return

  export LS_COLORS='di=01;38;5;75:ln=01;38;5;81:so=01;38;5;213:pi=01;38;5;221:ex=01;38;5;114:bd=38;5;221;48;5;237:cd=38;5;221;48;5;237:su=38;5;15;48;5;203:sg=38;5;15;48;5;221:tw=38;5;15;48;5;75:ow=38;5;15;48;5;75:*.tar=01;38;5;179:*.tgz=01;38;5;179:*.gz=01;38;5;179:*.bz2=01;38;5;179:*.xz=01;38;5;179:*.zip=01;38;5;179:*.7z=01;38;5;179:*.jpg=01;38;5;213:*.jpeg=01;38;5;213:*.png=01;38;5;213:*.gif=01;38;5;213:*.webp=01;38;5;213:*.svg=01;38;5;213:*.mp3=01;38;5;141:*.wav=01;38;5;141:*.flac=01;38;5;141:*.mp4=01;38;5;141:*.mkv=01;38;5;141:*.mov=01;38;5;141:*.pdf=01;38;5;203:*.md=01;38;5;75:*.mdx=01;38;5;75:*.txt=01;38;5;252:*.log=01;38;5;252:*.json=01;38;5;221:*.jsonc=01;38;5;221:*.js=01;38;5;221:*.mjs=01;38;5;221:*.cjs=01;38;5;221:*.ts=01;38;5;75:*.mts=01;38;5;75:*.cts=01;38;5;75:*.jsx=01;38;5;75:*.tsx=01;38;5;75:*.py=01;38;5;114:*.pyw=01;38;5;114:*.sh=01;38;5;114:*.bash=01;38;5;114:*.zsh=01;38;5;114:*.fish=01;38;5;114:*.html=01;38;5;203:*.htm=01;38;5;203:*.css=01;38;5;213:*.scss=01;38;5;213:*.sass=01;38;5;213:*.yaml=01;38;5;221:*.yml=01;38;5;221:*.toml=01;38;5;221:*.xml=01;38;5;75'
}

_corbon_apply_preset() {
  case "$1" in
    minimal)
      CORBON_LEFT=(path)
      CORBON_RIGHT=(exit)
      CORBON_SHOW_DURATION=false
      CORBON_SHOW_JOBS=false
      ;;
    compact)
      CORBON_LEFT=(path git)
      CORBON_RIGHT=(python node exit)
      CORBON_SHOW_DURATION=false
      CORBON_SHOW_JOBS=false
      ;;
    developer)
      CORBON_LEFT=(context path git)
      CORBON_RIGHT=(python node go rust duration exit jobs)
      ;;
    power)
      CORBON_LEFT=(context path git)
      CORBON_RIGHT=(python node go rust java ruby docker kubernetes terraform aws gcp azure duration exit jobs time)
      ;;
    *)
      return 1
      ;;
  esac
}

_corbon_prompt() {
  local exit_code="$?"
  CORBON_LAST_EXIT="$exit_code"

  if [[ "$CORBON_LAYOUT" == one-line ]]; then
    print -Pn "\n"
    _corbon_render_list left "$exit_code"
    _corbon_render_list right "$exit_code"
    _corbon_paint prompt " $CORBON_PROMPT_SYMBOL " bold
    return
  fi

  print -Pn "\n"
  _corbon_render_list left "$exit_code"
  _corbon_paint prompt "\n$CORBON_PROMPT_SYMBOL " bold

  local right
  right="$(_corbon_render_list_capture right "$exit_code")"

  if [[ -n "$right" ]]; then
    RPROMPT="$right"
  else
    RPROMPT=""
  fi
}

_corbon_render_list_capture() {
  local side="$1"
  local exit_code="$2"
  local segment
  local output

  if [[ "$side" == left ]]; then
    for segment in "${CORBON_LEFT[@]}"; do
      output+="$(_corbon_capture_segment "$segment" "$exit_code")"
    done
  else
    for segment in "${CORBON_RIGHT[@]}"; do
      output+="$(_corbon_capture_segment "$segment" "$exit_code")"
    done
  fi

  print -Pn "$output"
}

_corbon_capture_segment() {
  local name="$1"
  local exit_code="$2"

  [[ "${CORBON_SEGMENTS[$name]}" == disabled ]] && return

  case "$name" in
    python) [[ "$CORBON_SHOW_PYTHON" == true ]] && _corbon_segment_python ;;
    node) [[ "$CORBON_SHOW_NODE" == true ]] && _corbon_segment_node ;;
    go) [[ "$CORBON_SHOW_GO" == true ]] && _corbon_segment_go ;;
    rust) [[ "$CORBON_SHOW_RUST" == true ]] && _corbon_segment_rust ;;
    java) [[ "$CORBON_SHOW_JAVA" == true ]] && _corbon_segment_java ;;
    ruby) [[ "$CORBON_SHOW_RUBY" == true ]] && _corbon_segment_ruby ;;
    docker) [[ "$CORBON_SHOW_DOCKER" == true ]] && _corbon_segment_docker ;;
    kubernetes) [[ "$CORBON_SHOW_KUBERNETES" == true ]] && _corbon_segment_kubernetes ;;
    terraform) [[ "$CORBON_SHOW_TERRAFORM" == true ]] && _corbon_segment_terraform ;;
    aws) [[ "$CORBON_SHOW_AWS" == true ]] && _corbon_segment_aws ;;
    gcp) [[ "$CORBON_SHOW_GCP" == true ]] && _corbon_segment_gcp ;;
    azure) [[ "$CORBON_SHOW_AZURE" == true ]] && _corbon_segment_azure ;;
    os) [[ "$CORBON_SHOW_OS" == true ]] && _corbon_segment_os ;;
    arch) [[ "$CORBON_SHOW_ARCH" == true ]] && _corbon_segment_arch ;;
    shell) [[ "$CORBON_SHOW_SHELL" == true ]] && _corbon_segment_shell ;;
    battery) [[ "$CORBON_SHOW_BATTERY" == true ]] && _corbon_segment_battery ;;
    jobs) [[ "$CORBON_SHOW_JOBS" == true ]] && _corbon_segment_jobs ;;
    time) [[ "$CORBON_SHOW_TIME" == true ]] && _corbon_segment_time ;;
    date) [[ "$CORBON_SHOW_DATE" == true ]] && _corbon_segment_date ;;
    duration) _corbon_segment_duration ;;
    exit) _corbon_segment_exit "$exit_code" ;;
    custom:*) _corbon_render_custom "${name#custom:}" ;;
    *) _corbon_render_custom "$name" ;;
  esac
}

_corbon_preexec() {
  CORBON_COMMAND_START=$SECONDS
}

_corbon_precmd() {
  _corbon_prompt
  _corbon_ls_colors
}

_corbon_init_segments() {
  local segment

  for segment in \
    context path git python node go rust java ruby \
    docker kubernetes terraform aws gcp azure \
    os arch shell battery jobs time date duration exit
  do
    CORBON_SEGMENTS[$segment]=enabled
  done
}

_corbon_detect_color_mode() {
  [[ -n "$CORBON_COLOR_MODE" && "$CORBON_COLOR_MODE" != auto ]] && return

  if [[ "$COLORTERM" == *truecolor* || "$COLORTERM" == *24bit* ]]; then
    CORBON_COLOR_MODE=truecolor
  elif [[ "$TERM" == *256color* ]]; then
    CORBON_COLOR_MODE=256
  else
    CORBON_COLOR_MODE=16
  fi
}

_corbon_install_hooks() {
  autoload -Uz add-zsh-hook

  add-zsh-hook preexec _corbon_preexec
  add-zsh-hook precmd _corbon_precmd
}

_corbon_init() {
  _corbon_init_segments
  _corbon_detect_color_mode
  _corbon_apply_preset "${CORBON_PRESET:-}" 2>/dev/null
  _corbon_ls_colors
  _corbon_install_hooks

  PROMPT=""
  RPROMPT=""
  CONTINUE_PROMPT="$CORBON_CONTINUATION_SYMBOL "
}

_corbon_init

unset -f _corbon_init