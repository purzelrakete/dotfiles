use strict;
use Irssi;
use IPC::System::Simple qw(systemx);

use vars qw($VERSION %IRSSI);

$VERSION = '0.0.1';

%IRSSI = (
  authors     => 'Purzel Rakete',
  name        => 'przl-osx-notify',
  description => 'osx notification center on mentions',
  license     => 'MIT'
);

sub przl_mention {
  my ($channel, $nick, $msg) = @_;

  # untrusted content is escaped
  systemx('notify', ('-message', "\@$nick $msg", '-title', $channel));
}

Irssi::signal_add('przl mention', 'przl_mention');

