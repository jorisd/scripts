#!/usr/bin/perl
#

use strict;
use warnings;

use FindBin;
use Modern::Perl;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use Diabolo;
use Diabolo::Nagios;
use Diabolo::Vm;

# nouvel objet Diabolo en environnement de Test
my $obj = Diabolo->new;

say "---- vidage des tables ----";
$obj->resetenv;
say "ok";

say "---- ajout de HOSTs ----";
$obj->addhost(ip => "10.0.10.1", ram => 64, disk => 500, name => "srv-01-dc1",
                dc => 1, active => 1, host_id => 1);
$obj->addhost(ip => "10.0.10.2", ram => 32, disk => 500, name => "srv-02-dc1",
                dc => 1, active => 0, host_id => 2);

my $hosts_ref = $obj->lshosts;

print Dumper @$hosts_ref;

say "---- paire les Hosts avec id=1 et id=2 ----";
$obj->pairhosts( id1 => 1, id2 => 2);

say "---- paire les Hosts avec id=3 et id=4 ----";
$obj->pairhosts( id1 => 3, id2 => 4);


