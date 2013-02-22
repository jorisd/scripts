#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Modern::Perl;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Diabolo;
use Diabolo::Vm;

plan tests => 2;

my $obj = Diabolo->new();

$obj->resetenv;


$obj->addhost(ip => '10.0.10.1', ram => 64, disk => 500, name => 'serveurplop-01',
                baie => 1, active => 1, host_id => 2468);

my $host_ref1 = $obj->lshosts('serveurplop-01');

my $resultat_test1 = 0;


if(@$host_ref1 == 1) {

    my $h_ref = $host_ref1->[0];
    #print Dumper $h_ref;
    $resultat_test1 = 1 if($h_ref->{host_id} == 2468);

}

ok($resultat_test1 == 1, 'Checking if serveurplop-01 is found and has expected id');

$obj->addhost(ip => "10.0.10.2", ram => 32, disk => 500, name => "srv-42-dc2",
               baie  => 6, active => 0);


my $host_ref2 = $obj->lshosts;

my $resultat_test2 = 0;
if(scalar(@{$host_ref2}) == 2) {

    foreach my $h_ref (@{$host_ref2}) {
        if($h_ref->{name} =~ m/(srv-42-dc2|serveurplop-01)/ ) {
            $resultat_test2++;
        }
    }

}

ok($resultat_test2 == 2, "srv-42-dc2 et serveurplop-01 trouvés");

