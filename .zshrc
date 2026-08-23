# cached eval.
#
# tools like brew and direnv print the same shell snippet every time but cost a
# fork each to ask, which adds up to a third of startup. keep their output in a
# cache file and source that, re-running the tool only when it is newer than
# the cache.
cache_eval() {
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$1 bin=$2
  shift 2

  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p ${cache:h}
    $bin "$@" > $cache
  fi

  source $cache
}

# brew.
#
# must run before compinit so homebrew's site-functions are on fpath in
# non-login shells, where .zprofile does not run.
cache_eval brew-shellenv.zsh /opt/homebrew/bin/brew shellenv zsh

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
autoload -Uz compinit

# compinit's own dump check never passes here, so it rebuilds the 50k dump on
# every single shell -- 230ms. the reason: -i drops the ten completion files
# under /opt/homebrew (owned by the other account, uid 503) from the dump but
# still counts them when comparing against it, so the counts always differ.
#
# -C skips the check and just sources the dump. rebuild for real once a day so
# newly installed completions still get picked up.
zcompdump_stale=(${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24))
if [[ -f ${ZDOTDIR:-$HOME}/.zcompdump && $#zcompdump_stale -eq 0 ]]; then
  compinit -C -i
else
  compinit -i
fi
unset zcompdump_stale

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
  ~/src/github.com/voicelayerai

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

# completion.zsh.inc pulls in bashcompinit and costs 25ms, so bind a stub that
# loads it on the first completion attempt for a gcloud command instead. the
# stub then hands off to whatever the real script just registered.
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then
  gcloud_lazy_completion() {
    compdef -d gcloud gsutil bq
    unfunction gcloud_lazy_completion
    source $HOME/google-cloud-sdk/completion.zsh.inc

    local -a handler=(${(z)_comps[$words[1]]})
    (( $#handler )) && "$handler[@]"
  }

  compdef gcloud_lazy_completion gcloud gsutil bq
fi

# conda
# if [ -d ~/.conda ]; then
#   source ~/.conda/env
# fi

# pyenv.
#
# `eval "$(pyenv init -)"` costs 50ms: it forks pyenv, and the script pyenv
# prints then forks bash again purely to strip a stale shims entry out of PATH.
# below is the same setup written natively -- put bin and shims at the front,
# load the completion, and define the wrapper that `pyenv shell` and
# `pyenv rehash` need in order to affect the current shell.
#
# the init script also runs `pyenv rehash` on every startup. that is dropped:
# pyenv rehashes itself when a version or package is installed.
export PYENV_ROOT="$HOME/.pyenv"
export PYENV_SHELL=zsh

# (N/) drops $PYENV_ROOT/bin when it does not exist, as with a brew install.
path=($PYENV_ROOT/bin(N/) $PYENV_ROOT/shims ${path:#($PYENV_ROOT/bin|$PYENV_ROOT/shims)})

[[ -r /opt/homebrew/opt/pyenv/completions/pyenv.zsh ]] &&
  source /opt/homebrew/opt/pyenv/completions/pyenv.zsh

pyenv() {
  case ${1:-} in
    rehash|shell) eval "$(command pyenv "sh-$1" "${@:2}")" ;;
    *)            command pyenv "$@" ;;
  esac
}

# asdf. guarded so machines without it still start cleanly.
[ -f $HOME/.asdf/asdf.sh ] && . $HOME/.asdf/asdf.sh
[ -f $HOME/.asdf/plugins/java/set-java-home.zsh ] && . $HOME/.asdf/plugins/java/set-java-home.zsh

# direnv
cache_eval direnv-hook.zsh direnv hook zsh

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/ranykeddo/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# nvm is set up lazily in .common.shellrc -- do not source nvm.sh here.

# postgres
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# tex
export PATH="/Library/TeX/texbin:$PATH"
