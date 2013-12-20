# Dotfiles

A complete console based workflow. Solarized dark and light configured for
everything.

- Zsh and bash with tmux
- Emacs with calendar, org-mode
- Mutt with gnupg, notmuch, msmtp and offlineimap
- Irssi
- Newsbeuter
- Scripts & tools in bin/

## Installation

Clone the repository into

    git clone git@github.com:purzelrakete/dotfiles ~/dotfiles

Symlink dotfiles into your home directory

    cd ~/dotfiles
    ./pin

You can also archive current dotfiles that would be overwritten by running

    archive

which creates ~/.dotarchive with your current files.
