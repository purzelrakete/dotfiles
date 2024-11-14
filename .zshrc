source ~/.zsh/.prompt
source ~/.common.shellrc

# brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# completions
fpath=(~/.completions/zsh $fpath)
autoload -U ~/.completions/zsh(:t)
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

# comments
setopt interactivecomments

# type "..",  "/usr/include"
setopt auto_cd

# color listing
eval $(dircolors ~/.dir_colors)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# cdpath
cdpath=(
  .
  ~/Dropbox
  ~/src

  # github
  ~/src/github.com/
  ~/src/github.com/feldberlin
  ~/src/github.com/purzelrakete
  ~/src/github.com/reflectionlabs

  # gitlab
  ~/src/gitlab.com/
  ~/src/gitlab.com/purzelrakete
  ~/src/gitlab.com/reflectionlabs
)

# bindings
bindkey -e # emacs mode
bindkey " " magic-space
bindkey "[A" history-beginning-search-backward
bindkey "[B" history-beginning-search-forward

# needs to be at the bottom, or completion will break highlighting.
source ~/.zsh/syntax-highlighting/zsh-syntax-highlighting.zsh

# fuzzy finder in readline
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# direnv
eval "$(direnv hook zsh)"

# conda
if [ -d ~/.conda ]; then
  source ~/.conda/env
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

