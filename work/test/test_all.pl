#!/usr/bin/env perl

use strict;
use warnings;
use Modern::Perl;

for my $path (glob("*/test*.pl")) {
    my $res = system($path);

    if ($res) {
        die "Test $path failed";
    }
}

