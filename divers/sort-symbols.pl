#!/usr/bin/perl
#
# petit exercice qu'on m'a demandé
# de faire.
#
# je suis persuadé qu'on peut ffaire plus court... des idées ?
# blocs BEGIN / END a mettre à contribution

use strict;
use warnings;
use v5.10;

die "Usage: $0 /path/to/debug-lib ... " if $#ARGV < 1;

# contiendra mes symboles type "T"
my %h;

foreach my $file (@ARGV) {
  open SYMBOL, "/usr/bin/nm $file |";
  while (<SYMBOL>) {
    $h{$2} = $file if (m/^(\w+) T (.+)$/);
  }
  close SYMBOL;
}

foreach my $text (sort keys %h) {
  say "$text => $h{$text}";
}

