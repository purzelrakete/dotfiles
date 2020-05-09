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

# added by Anaconda2 4.4.0 installer
export PATH="/Users/purzelrakete/anaconda/bin:$PATH"
# added by Anaconda3 2019.07 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/anaconda3/etc/profile.d/conda.sh" ]; then
# . "/anaconda3/etc/profile.d/conda.sh"  # commented out by conda initialize
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/purzelrakete/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/purzelrakete/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/purzelrakete/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/purzelrakete/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# added by Anaconda3 2019.10 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/opt/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<
