 # [[ -s $HOME/.rvm/scripts/rvm ]] && . $HOME/.rvm/scripts/rvm

PATH=$PATH:~/bash
# PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
# alias apache-start="sudo /opt/local/apache2/bin/apachectl start"
# alias apache-restart="sudo /opt/local/apache2/bin/apachectl restart"
# alias apache-stop="sudo /opt/local/apache2/bin/apachectl stop"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# You were missing this - Kyle
# export PS1='[ KYLE IS MY FAVE ]\$ '
