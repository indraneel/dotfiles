# alias apache-restart="sudo /opt/local/apache2/bin/apachectl restart"
# alias apache-start="sudo /opt/local/apache2/bin/apachectl start"
# alias apache-stop="sudo /opt/local/apache2/bin/apachectl stop"
alias ls="ls -G"
alias ll='ls -l'
alias cl='cd $1 && ls'
alias la='ls -la'
alias lt='ls -la | grep "^d" && ls -la | grep "^-" && ls -la | grep "^l"'
alias pdflatex='pdflatex -interaction nonstopmode -file-line-error'
alias reset="source $HOME/.bashrc && clear"
#" vim: filetype=sh
