 # [[ -s $HOME/.rvm/scripts/rvm ]] && . $HOME/.rvm/scripts/rvm

set -o vi

PATH=$PATH:~/bash
# PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
# alias apache-start="sudo /opt/local/apache2/bin/apachectl start"
# alias apache-restart="sudo /opt/local/apache2/bin/apachectl restart"
# alias apache-stop="sudo /opt/local/apache2/bin/apachectl stop"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export PS1="\u:[\[\e[35m\]\w\[\e[m\]]\n"
