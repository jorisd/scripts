package Objs;

use strict;
use warnings;
use Modern::Perl;

our $sqlHnd;

sub getSqlHnd {
    if (!$sqlHnd) {
        $sqlHnd = new DBI();
    }

    return $sqlHnd;
}

1;
