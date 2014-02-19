if [ -z "$PS1" ]; then
    return
fi

# Load RVM function
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    . "$HOME/.rvm/scripts/rvm"
fi

# Vim mode
set -o vi


## Custom-made aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


## Lots and lots of path magic
# Adding bash scripts
export PATH="~/bash:$PATH"
export PATH="~/dotfiles/Bash-Scripts/:$PATH"

# Android
export PATH="$PATH:inHDD/Applications/android/tools"

# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
export PATH="$PATH:/Library/Frameworks/Python.framework/Versions/2.7/bin"

# MacPorts Installer addition on 2012-04-24_at_16:51:38: adding an appropriate PATH variable for use with MacPorts.
# Finished adapting your PATH environment variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# Old path stuff
# export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

## Primary prompts
export PS1='\u @ \h in \w \n∆ '

# With color
# export PS1="\u:[\[\e[35m\]\w\[\e[m\]]\n"

## Git things
# enable the git bash completion commands
# source ~/.git-completion
# source ~/.git-prompt.sh

######
# Git prompt
# 2012-09-08
# Change prompt to the following:
# [USER@HOST cwd] time
#
# PS1='\[\e[01;37m\][\u@\h \w] \t $\[\e[0m\] '
#############################
# Git color stuff ###########
#############################

# enable git unstaged indicators - set to a non-empty value
# GIT_PS1_SHOWDIRTYSTATE="."
 
# enable showing of untracked files - set to a non-empty value
# GIT_PS1_SHOWUNTRACKEDFILES="."
 
# enable stash checking - set to a non-empty value
# GIT_PS1_SHOWSTASHSTATE="."
 
# enable showing of HEAD vs its upstream
# GIT_PS1_SHOWUPSTREAM="auto"
 
# BLACK=$(tput setaf 0)
# RED=$(tput setaf 1)
# GREEN=$(tput setaf 2)
# YELLOW=$(tput setaf 3)
# LIME_YELLOW=$(tput setaf 190)
# POWDER_BLUE=$(tput setaf 153)
# BLUE=$(tput setaf 4)
# MAGENTA=$(tput setaf 5)
# CYAN=$(tput setaf 6)
# WHITE=$(tput setaf 7)
# BRIGHT=$(tput bold)
# NORMAL=$(tput sgr0)
# BLINK=$(tput blink)
# REVERSE=$(tput smso)
# UNDERLINE=$(tput smul)

# this prompt is a green username, black @ symbol, cyan host, magenta current working directory and white git branch (only shows if you're in a git branch)
# unstaged and untracked symbols are shown, too (see above)
# this prompt uses the short colour codes defined above
# export PS1='\[${BRIGHT}\]\u\[${WHITE}\]:\[${MAGENTA}\]\[${UNDERLINE}\]\w\[${NORMAL}\]\[${YELLOW}\]`__git_ps1 " (%s)"`\[${WHITE}\] ¬ '

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
