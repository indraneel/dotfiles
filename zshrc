# zshrc — interactive zsh config

export NVM_DIR="$HOME/.nvm"
# Lazy-load nvm: the first call to any of these replaces the shims with the real thing
for cmd in nvm node npm npx; do
  eval "$cmd() { unset -f nvm node npm npx; . \"\$NVM_DIR/nvm.sh\"; [ -s \"\$NVM_DIR/bash_completion\" ] && . \"\$NVM_DIR/bash_completion\"; $cmd \"\$@\"; }"
done
unset cmd

up() {
  local d=""
  local limit=$1
  for ((i=1 ; i <= limit ; i++)); do
    d=$d/..
  done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

tabname() {
  printf "\e]1;$1\a"
}

cdls() {
  cd $1 && ls
}

# Added by LM Studio CLI (lms)
[ -d "$HOME/.lmstudio/bin" ] && export PATH="$PATH:$HOME/.lmstudio/bin"

# Local LLM helpers (per-machine, optional)
[ -f "$HOME/.config/zsh/llm.sh" ] && source "$HOME/.config/zsh/llm.sh"
