use strict;
use Irssi;
use IPC::System::Simple qw(capturex);

use vars qw($VERSION %IRSSI);

$VERSION = '0.0.1';

%IRSSI = (
  authors     => 'Purzel Rakete',
  name        => 'przl-notify',
  description => 'notification on mentions',
  license     => 'MIT'
);

sub przl_mention {
  my ($channel, $nick, $msg) = @_;

  # untrusted content is escaped
  capturex('notify-desktop', ('--message', "\@$nick $msg"));
}

Irssi::signal_add('przl mention', 'przl_mention');
