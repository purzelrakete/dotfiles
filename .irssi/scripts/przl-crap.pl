use strict;
use Irssi;
use Irssi::TextUI;

use vars qw($VERSION %IRSSI);

$VERSION = '0.1.0';

%IRSSI = (
  authors     => 'Purzel Rakete',
  name        => 'przl-crap',
  description => 'filter crap',
  license     => 'MIT'
);

my @types = qw/JOINS PARTS QUITS NICKS CLIENTCRAP CRAP MODE TOPICS KICKS/;
my %remove = map { Irssi::level2bits($_) => 1 } @types;

sub bust {
  my $window = $_[0];
  my $view =  $window -> view;
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

sub bust_current {
  bust(Irssi::active_win());
}

sub bust_all {
  my @windows = Irssi::windows();

  foreach (@windows) {
    bust($_);
  }
}

Irssi::command_bind('bust', 'bust_current');
Irssi::command_bind('bust_all', 'bust_all');

