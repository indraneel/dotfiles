#bashrc - for non-login shells

# if not interactive, do nothing
if [ -z "$PS1" ]; then
    return
fi

## if [ -f $(brew --prefix)/etc/bash_completion ]; then
## 	. $(brew --prefix)/etc/bash_completion
## fi

## Custom-made aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

## Local things
if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi

## Primary prompts
if [ -f ~/.bash_prompt ]; then
    source ~/.bash_prompt
else
    export PS1='\u @ \h in \w \n∆ '
fi

# Vim mode
set -o vi

## Lots and lots of path magic
# Adding bash scripts
export PATH="~/dotfiles/Bash-Scripts:$PATH"

## User-defined functions
up(){
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

# Get information from NextBus courtesy V
# Example: $ rubus rsc
rubus () {
    stop="$1$2$3"

    if [ -z "$stop" ]; then
        stop="hill"
    fi

    curl "http://vverma.net/nextbus/nextbus.php?android=1&s=$stop"
}

#change the tabname
function tabname {
  printf "\e]1;$1\a"
}

cdfunc() {
    cd $1 && ls
}
