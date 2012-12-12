source ~/.common.shellrc

PATH=$PATH:$HOME/.rvm/bin

# more completions
autoload -U compinit
compinit

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# 10k history across all open shells
HISTFILE=~/.zhistory
HISTSIZE=SAVEHIST=10000
setopt incappendhistory
setopt sharehistory
setopt extendedhistory

# superglobs
setopt extendedglob
unsetopt caseglob

# type "..",  "/usr/include"
setopt auto_cd

# display cpu usage stats for commands taking more than 10 seconds
REPORTTIME=10

# color listing
eval $(dircolors ~/.dir_colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# prompt
source ~/.zsh/.prompt

# cdpath
cdpath=(. ~/Projects ~/Dropbox ~/Dropbox/code ~/Projects/soundcloud)

# bindings
bindkey -e # emacs mode
bindkey " " magic-space
bindkey "[A" history-beginning-search-backward
bindkey "[B" history-beginning-search-forward

# highlighting
source ~/.zsh/syntax-highlighting/zsh-syntax-highlighting.zsh
