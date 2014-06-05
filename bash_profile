# bash_profile - this is for login shells
# note that OS X's default Terminal.app treats each tab/window as a login shell

# if not interactive mode, don't do anything
if [ -z "$PS1" ]; then
    return
fi

# Source everything in ~/.bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

