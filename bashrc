#bashrc - for non-login shells

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

#change the tabname
function tabname {
  printf "\e]1;$1\a"
}

cdls() {
    cd $1 && ls
}

function git-jira-tix() {
    git log $1 | grep -Eo '([A-Z]{2,}-)([0-9]+)' | sort | uniq
}

function parse_git_branch {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
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
    # export PS1='\u @ \h in \w \n∆ '
    PS1="\$(parse_git_branch)\u @ \h in \w \n∆ "
    export PS1
fi

