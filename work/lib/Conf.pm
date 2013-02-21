package Conf;

use strict;
use warnings;
use Modern::Perl;
use JSON;

sub get {
    die "Unknown env" if ($ENV{V2ENV} !~ m/^(test|debug|prod)$/);
    my $path = "/home/joris/projets/scripts/work/conf/$1.json"; # FIXME
    my $data = `cat $path`; # FIXME: Use File::Slurp

    return decode_json($data);
};

1;
