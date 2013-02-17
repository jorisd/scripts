#!/usr/bin/perl
#

use 5.010;
use strict;
use warnings;
use Data::Dumper;
use Diabolo;

# nouvel objet Diabolo en environnement de Test
my $obj = Diabolo->new("test");

say "---- liste des VM ----";
$obj->lsvms;

say "---- liste des HOSTS ----";
$obj->lshosts;

say "---- vidage des tables ----";
$obj->resetenv;


say "---- ajout de HOSTs ----";
$obj->addhost(ip => "10.0.10.1", ram => 64, disk => 500, name => "srv01dc1", dc => 1, active => 1);
$obj->addhost(ip => "10.0.10.2", ram => 32, disk => 500, name => "srv02dc1", dc => 1, active => 0);
$obj->addhost(ip => "20.0.10.1", ram => 64, disk => 500, name => "srv01dc2", dc => 2, active => 0);
$obj->addhost(ip => "20.0.10.2", ram => 32, disk => 500, name => "srv02dc2", dc => 2, active => 1);


$obj->lshosts;

