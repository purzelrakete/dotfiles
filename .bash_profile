# global

export CDPATH=.:~/Projects:~/Dropbox:~/Dropbox/code:~/Projects/s*
shopt -s globstar # bash 4.0 globs

# colors

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# completion

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
for c in ~/.completions/bash/_*; do source $c; done

# moob completion

_moob() {
  local opts=`moob ls`
  local cur=${COMP_WORDS[COMP_CWORD]}

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _moob moob

# articles completion

_articles() {
  local opts=`articles ls`
  local cur=${COMP_WORDS[COMP_CWORD]}

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _articles articles

# glossary completion

_glossary() {
  local opts=`glossary ls`
  local cur=${COMP_WORDS[COMP_CWORD]}

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _glossary glossary

# dev completion

_dev() {
  local opts=`dev ls`
  local cur=${COMP_WORDS[COMP_CWORD]}

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _dev dev

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

# includes

source ~/.bash_prompt
source ~/.common.shellrc

# no hn
alias nhn="sudo ipfw add 70000 deny tcp from any to news.ycombinator.com"

:
