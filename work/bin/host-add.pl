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

$obj->resetenv;

my ($hostnameDC1, $hostnameDC2) = split /:/, $hosts;

$obj->addhost(ip => "1.2.3.4", name => $hostnameDC1, ram => $ram, disk => $disk, baie => 1);
my $hostDC1 = $obj->lshosts($hostnameDC1);

$obj->addhost(ip => "1.2.3.5", name => $hostnameDC2, ram => $ram, disk => $disk, baie => 2);
my $hostDC2 = $obj->lshosts($hostnameDC2);

print Dumper $obj->lshosts;

say "---- paire les Hosts avec id=1 et id=2 ----";
$obj->pairhosts( id1 => $hostDC1->[0]->{host_id},
                 id2 => $hostDC2->[0]->{host_id} );

