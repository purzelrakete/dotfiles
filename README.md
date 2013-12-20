# Dotfiles

A complete console based workflow. Solarized dark and light configured for
everything.

- Zsh and bash with tmux
- Emacs with calendar, org-mode
- Mutt with gnupg, notmuch, msmtp and offlineimap
- Irssi
- Newsbeuter
- Scripts & tools in bin/

## Dark

![Dark](http://dl.dropboxusercontent.com/s/eu2bw6g3rk38pem/2013-12-20%20at%2014.33.png)

## Light

![Light](http://dl.dropboxusercontent.com/s/mozg8n588eip4dh/2013-12-20%20at%2014.52.png)

## Installation

Clone the repository into

    git clone git@github.com:purzelrakete/dotfiles ~/dotfiles

Symlink dotfiles into your home directory

    cd ~/dotfiles
    ./pin

You can also archive current dotfiles that would be overwritten by running

    archive

which creates ~/.dotarchive with your current files.

### Installing packages

A number of packages such as vim, mutt and emacs are required to run together
with these dotfiles. Have a look at dot/.install for brew, deb, cpan and other
dependencies. These lists are currently not stripped down to the minimal set.

## TODO

- Extract and parameterize email account metadata
- Update minimal list of homebrew packages to install
- Update minimal list of debian packages to install

