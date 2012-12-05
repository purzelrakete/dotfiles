use strict;
use Irssi;

use vars qw($VERSION %IRSSI);

$VERSION = '0.0.1';

%IRSSI = (
  authors     => 'Purzel Rakete',
  name        => 'przl-signals',
  description => 'custom signal emitter',
  license     => 'MIT'
);

my $me = 'przl|purzel|rany';

sub message_public {
  my ($server, $msg, $nick, $address, $channel) = @_;

  if($msg =~ m/$me/i) {
    Irssi::signal_emit('przl mention', $channel, $nick, $msg);
  }
}

sub message_private {
  my ($server, $msg, $nick, $address, $target) = @_;

  Irssi::signal_emit('przl mention', $nick, $nick, $msg);
}

# subscribe

Irssi::signal_add_last("message public", "message_public");
Irssi::signal_add_last("message private", "message_private");

# publish

Irssi::signal_register({ 'przl mention' => [qw/string string string/] });

