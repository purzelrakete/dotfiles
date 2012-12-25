source ~/.bash_prompt
source ~/.common.shellrc
for c in ~/.completions/bash/_*; do source $c; done

# global

export CDPATH=.:~/Projects:~/Dropbox:~/Dropbox/code
shopt -s globstar # bash 4.0 globs

# colors

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# history

shopt -s histappend

export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTIGNORE=' *'

if tty 1>/dev/null
  then
    bind Space:magic-space
    bind '"\e[A"':history-search-backward
    bind '"\e[B"':history-search-forward
fi

:

