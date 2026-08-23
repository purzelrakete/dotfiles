source ~/.zsh/.prompt
source ~/.common.shellrc

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then
  . $HOME/google-cloud-sdk/path.zsh.inc;
fi

# The next line enables shell command completion for gcloud.
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then
  . $HOME/google-cloud-sdk/completion.zsh.inc;
fi

# conda
# if [ -d ~/.conda ]; then
#   source ~/.conda/env
# fi

# # pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

eval "$(pyenv init -)"

# asdf
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/plugins/java/set-java-home.zsh

# direnv
eval "$(direnv hook zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ranykeddo/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ranykeddo/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ranykeddo/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ranykeddo/google-cloud-sdk/completion.zsh.inc'; fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ranykeddo/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

