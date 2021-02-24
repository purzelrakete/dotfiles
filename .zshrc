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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/purzelrakete/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/purzelrakete/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/purzelrakete/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/purzelrakete/google-cloud-sdk/completion.zsh.inc'; fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/purzelrakete/.pyenv/versions/miniconda3-latest/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/purzelrakete/.pyenv/versions/miniconda3-latest/etc/profile.d/conda.sh" ]; then
        . "/Users/purzelrakete/.pyenv/versions/miniconda3-latest/etc/profile.d/conda.sh"
    else
        export PATH="/Users/purzelrakete/.pyenv/versions/miniconda3-latest/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

