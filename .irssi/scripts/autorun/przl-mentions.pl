use strict;
use Irssi;

use vars qw($VERSION %IRSSI);

$VERSION = '0.0.1';

%IRSSI = (
  authors     => 'Purzel Rakete',
  name        => 'przl-signals',
  description => 'log mentions into mentions window',
  license     => 'MIT'
);

my $win = Irssi::window_find_name('mentions');

sub przl_mention {
  my ($channel, $nick, $msg) = @_;

  $win -> print("$channel \@$nick $msg", MSGLEVEL_CLIENTCRAP);
}

$win ? Irssi::signal_add('przl mention', 'przl_mention') : print("aborting");

