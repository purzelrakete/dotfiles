use strict;
use Irssi;
use Irssi::TextUI;

use vars qw($VERSION %IRSSI);

$VERSION = '0.0.1';

%IRSSI = (
  authors     => 'Purzel Rakete',
  name        => 'przl-crap',
  description => 'filter crap',
  license     => 'MIT'
);

my @types = qw/JOINS PARTS QUITS NICKS CLIENTCRAP CRAP MODE TOPICS KICKS/;
my %remove = map { Irssi::level2bits($_) => 1 } @types;

sub bust {
  my $view = Irssi::active_win() -> view;
  my @reap = ();

  # remove_line sets line -> next to nil. collect and reap instead.
  for (my $line = $view -> get_lines; $line; $line = $line -> next) {
    if ($remove{ $line -> {info}{level} }) {
      push(@reap, $line);
    }
  }

  foreach (@reap) {
    $view -> remove_line($_);
  }

  $view -> redraw();
}

sub bustall {
  my $cmd = "^ignore * @types";
  print("running $cmd");
  Irssi::command($cmd);
}

Irssi::command_bind('bust', 'bust');
Irssi::command_bind('bustall', 'bustall');

