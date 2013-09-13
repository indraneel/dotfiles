export PATH=${PATH}:inHDD/Applications/android/tools
# Setting PATH for Python 2.7
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
export PATH

##
# Your previous /Users/indraneelpurohit/.bash_profile file was backed up as /Users/indraneelpurohit/.bash_profile.macports-saved_2012-04-24_at_16:51:38
##

# MacPorts Installer addition on 2012-04-24_at_16:51:38: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

##
# Your previous /Users/indraneelpurohit/.bash_profile file was backed up as /Users/indraneelpurohit/.bash_profile.macports-saved_2012-04-29_at_22:59:54
##

# MacPorts Installer addition on 2012-04-29_at_22:59:54: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

######
#
# 2012-09-08
# Change prompt to the following:
# [USER@HOST cwd] time
#
# PS1='\[\e[01;37m\][\u@\h \w] \t $\[\e[0m\] '
#############################
# Git color stuff ###########
#############################

# enable the git bash completion commands
source ~/.git-completion
source ~/.git-prompt.sh
 
# enable git unstaged indicators - set to a non-empty value
GIT_PS1_SHOWDIRTYSTATE="."
 
# enable showing of untracked files - set to a non-empty value
GIT_PS1_SHOWUNTRACKEDFILES="."
 
# enable stash checking - set to a non-empty value
GIT_PS1_SHOWSTASHSTATE="."
 
# enable showing of HEAD vs its upstream
GIT_PS1_SHOWUPSTREAM="auto"
 
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)
 
# set the prompt to show current working directory and git branch name, if it exists
 
# this prompt is a green username, black @ symbol, cyan host, magenta current working directory and white git branch (only shows if you're in a git branch)
# unstaged and untracked symbols are shown, too (see above)
# this prompt uses the short colour codes defined above
PS1='\[${BRIGHT}\]\u\[${WHITE}\]:\[${MAGENTA}\]\[${UNDERLINE}\]\w\[${NORMAL}\]\[${YELLOW}\]`__git_ps1 " (%s)"`\[${WHITE}\] ¬ '


# bash script folder
export PATH=~/dotfiles/Bash-Scripts/:$PATH

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
