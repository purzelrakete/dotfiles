# brew.
#
# must run before compinit so homebrew's site-functions are on fpath in
# non-login shells, where .zprofile does not run.
eval "$(/opt/homebrew/bin/brew shellenv)"

# completions.
#
# must run BEFORE .common.shellrc: that sources ~/.nvm/bash_completion, which
# fires a bare `compinit` if none is loaded yet. running ours first makes nvm's
# `command -v compinit` guard skip it.
#
# -i ignores fpath dirs not owned by us instead of prompting: brew shellenv
# prepends /opt/homebrew/share/zsh/site-functions, and /opt/homebrew belongs to
# the other account on this machine (uid 503).
fpath=(~/.completions/zsh $fpath)
autoload -U compinit
compinit -i

source ~/.zsh/.prompt
source ~/.common.shellrc
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

# google cloud sdk
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then
  . $HOME/google-cloud-sdk/path.zsh.inc;
fi

if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then
  . $HOME/google-cloud-sdk/completion.zsh.inc;
fi

# conda
# if [ -d ~/.conda ]; then
#   source ~/.conda/env
# fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# asdf. guarded so machines without it still start cleanly.
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
[ -f $HOME/.asdf/plugins/java/set-java-home.zsh ] && . $HOME/.asdf/plugins/java/set-java-home.zsh

# direnv
eval "$(direnv hook zsh)"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ranykeddo/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
