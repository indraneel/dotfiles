# zshenv — sourced for all zsh invocations (incl. non-interactive)

# uv
export PATH="$HOME/.local/bin:$PATH"

# rust / cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
