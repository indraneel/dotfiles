# llm.sh — local LLM helpers. Sourced from ~/.zshrc when present.
# Per-machine model paths/ports go in llm.local.sh (not in dotfiles), which
# this file sources first so its exports override the defaults below.

# Per-machine overrides: export QWEN_MODEL_PATH, GPT_MODEL, ports, etc.
[ -f "$HOME/.config/zsh/llm.local.sh" ] && source "$HOME/.config/zsh/llm.local.sh"

# qwen: local Qwen via mlx_lm.server + claude-code-proxy
[ -f "$HOME/.config/zsh/qwen.sh" ] && source "$HOME/.config/zsh/qwen.sh"

# gpt-oss: local gpt-oss model on Ollama
[ -f "$HOME/.config/zsh/gpt-oss.sh" ] && source "$HOME/.config/zsh/gpt-oss.sh"

# pi against local qwen via mlx_lm.server
pic() {
  if ! _qwen_pid >/dev/null; then qwen-start || return 1; qwen-warm || return 1; fi
  pi --provider qwen-local --model "$QWEN_MODEL_PATH" "$@"
}
