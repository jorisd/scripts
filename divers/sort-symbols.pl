#!/usr/bin/perl
#
# petit exercice qu'on m'a demandé
# de faire :
# - dumper les symboles d'une lib (mode débug evidemment)
# - récupérer les symboles type "T"
# - enregistrer le nom de la function et le fichier de lib
# - trier et afficher les symboles avec le fichiers associé
#
#
# je suis persuadé qu'on peut ffaire plus court... des idées ?
# blocs BEGIN / END a mettre à contribution si uniligne ?

use strict;
use warnings;
use v5.10;

die "Usage: $0 /path/to/debug-lib ... " if ($#ARGV < 0)  ;

# contiendra mes symboles type "T"
my %h;

foreach (@ARGV) {
  open SYMBOL, "/usr/bin/nm $_ |";
  while (<SYMBOL>) {
    $h{$1} = $_ if (/^\w+ T (.+)$/);
  }
  close SYMBOL;
}

foreach (sort keys %h) {
  say "$_ => $h{$_}";
}

