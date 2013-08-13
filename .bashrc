 [[ -s $HOME/.rvm/scripts/rvm ]] && . $HOME/.rvm/scripts/rvm

PATH=$PATH:~/bash
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
alias apache-start="sudo /opt/local/apache2/bin/apachectl start"
alias apache-restart="sudo /opt/local/apache2/bin/apachectl restart"
alias apache-stop="sudo /opt/local/apache2/bin/apachectl stop"

#So begins Indraneel's Aliases — call me Jennifer Garner doe
if [ -f ~/bash/bash_aliases ]; then . ~/bash/bash_aliases fi

#functions

