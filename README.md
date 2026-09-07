# Corbon

A lightweight, highly customizable ZSH theme.

Corbon is built around one idea:

> Your prompt should work the way you want.

It gives you control over the layout, segments, Git information, colors, symbols, path display, command timing, and more without turning configuration into a mess.

## Features

- Lightweight
- No external dependencies
- Native ZSH
- Git integration
- Smart path display
- Python virtual environment
- Node.js environment
- Command duration
- Exit status
- SSH awareness
- One-line and two-line layouts
- Configurable segment order
- Custom colors
- Custom symbols
- Custom prompt layout
- Easy configuration

## Installation

Clone the repository:

~~~sh
git clone https://github.com/spideythedev/corbon-zsh-theme.git ~/.corbon
~~~

Load Corbon from your `.zshrc`:

~~~zsh
source ~/.corbon/corbon.zsh-theme
~~~

You can also keep your configuration separate:

~~~zsh
source ~/.corbon/corbon.config.zsh
source ~/.corbon/corbon.zsh-theme
~~~

Restart ZSH:

~~~sh
exec zsh
~~~

## Configuration

Corbon is configured directly with ZSH variables.

For example:

~~~zsh
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
CORBON_PROMPT_SYMBOL="❯"
~~~

The order of the arrays controls the order of the segments.

## Layout

Corbon supports:

~~~zsh
CORBON_LAYOUT="one-line"
~~~

or:

~~~zsh
CORBON_LAYOUT="two-line"
~~~

Two-line is the default.

## Segments

Available segments include:

~~~text
context
path
git
python
node
duration
time
~~~

You can change them independently:

~~~zsh
CORBON_LEFT=(
    path
    git
)

CORBON_RIGHT=(
    node
    duration
)
~~~

You don't need to use every segment.

## Git

Git information can be customized with:

~~~zsh
CORBON_GIT_BRANCH=true
CORBON_GIT_STATUS=true
CORBON_GIT_AHEAD_BEHIND=true
~~~

Git status symbols are configurable:

~~~zsh
CORBON_GIT_CLEAN_SYMBOL="✓"
CORBON_GIT_DIRTY_SYMBOL="±"
CORBON_GIT_STAGED_SYMBOL="+"
CORBON_GIT_UNTRACKED_SYMBOL="?"
CORBON_GIT_CONFLICT_SYMBOL="!"
~~~

## Path

Corbon automatically shortens long paths when smart mode is enabled:

~~~zsh
CORBON_PATH_STYLE="smart"
CORBON_PATH_MAX=4
~~~

For example:

~~~text
~/projects/corbon/src/theme
~~~

can become:

~~~text
…/projects/corbon/src/theme
~~~

## Command Duration

Long-running commands can display their execution time.

~~~zsh
CORBON_SHOW_DURATION=true
CORBON_DURATION_THRESHOLD=1
~~~

The threshold is measured in seconds.

## Exit Status

Failed commands can display their exit code:

~~~zsh
CORBON_SHOW_EXIT=true
~~~

For example:

~~~text
2 ❯
~~~

Successful commands don't display an exit code.

## Colors

Every major part of the prompt can have its own color.

~~~zsh
CORBON_COLOR_USER="%F{white}"
CORBON_COLOR_HOST="%F{cyan}"
CORBON_COLOR_PATH="%F{245}"
CORBON_COLOR_GIT="%F{yellow}"
CORBON_COLOR_SUCCESS="%F{green}"
CORBON_COLOR_ERROR="%F{red}"
CORBON_COLOR_MUTED="%F{242}"
CORBON_COLOR_ACCENT="%F{yellow}"
~~~

Corbon does not force a specific color scheme. The default palette is intentionally simple, but you can completely change it.

## Symbols

The prompt symbol is configurable:

~~~zsh
CORBON_PROMPT_SYMBOL="❯"
CORBON_CONTINUATION_SYMBOL="·"
~~~

Git symbols are configurable as well.

This means Corbon doesn't depend on a fixed visual identity for customization.

## SSH

Host information can be shown only when connected through SSH:

~~~zsh
CORBON_SHOW_HOST="ssh"
~~~

Always show it:

~~~zsh
CORBON_SHOW_HOST=true
~~~

Disable it:

~~~zsh
CORBON_SHOW_HOST=false
~~~

## Example

A simple developer setup:

~~~zsh
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
)

CORBON_SEPARATOR="  "

CORBON_PROMPT_SYMBOL="❯"

CORBON_COLOR_ACCENT="%F{yellow}"
CORBON_COLOR_GIT="%F{yellow}"
CORBON_COLOR_PATH="%F{245}"
CORBON_COLOR_MUTED="%F{242}"
~~~

## Philosophy

Corbon is intentionally small.

It shouldn't require a framework, plugin manager, configuration generator, or a collection of external dependencies just to render a shell prompt.

The goal is simple:

**Fast by default. Configurable when you need it. Out of your way when you don't.**

## Development

Clone the repository:

~~~sh
git clone https://github.com/spideythedev/corbon-zsh-theme.git
cd corbon-zsh-theme
~~~

Test the theme directly:

~~~sh
zsh
source ./corbon.zsh-theme
~~~

## License

MIT

Copyright © 2026 Fahad Malik