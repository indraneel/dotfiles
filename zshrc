# zshrc — interactive zsh config

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

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
