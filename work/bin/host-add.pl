#!/usr/bin/perl
#

use strict;
use warnings;

use Getopt::Long qw(:config bundling);
use FindBin;
use Modern::Perl;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use Diabolo;
use Diabolo::Nagios;
use Diabolo::Vm;
use Ping;

my $hosts;
my $disk;
my $ram;
my $cpu;

my $result = GetOptions("hosts=s" => \$hosts,
                        "disk=i"  => \$disk,
                        "ram=i"   => \$ram,
                        "cpu=i"   => \$cpu,
                        );

# nouvel objet Diabolo en environnement de Test
my $obj = Diabolo->new;

my ($hostnameDC1, $hostnameDC2) = split /:/, $hosts;

$obj->addhost(name => $hostnameDC1, ram => $ram, disk => $disk, baie => 1);
my $hostDC1 = $obj->lshosts($hostnameDC1);

$obj->addhost(name => $hostnameDC2, ram => $ram, disk => $disk, baie => 2);
my $hostDC2 = $obj->lshosts($hostnameDC2);

say "---- paire les Hosts avec id=1 et id=2 ----";
$obj->pairhosts( id1 => $hostDC1->{host_id},
                 id2 => $hostDC2->{host_id} );

print Dumper $obj->lshosts;

