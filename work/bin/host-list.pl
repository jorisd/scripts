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
use Ping;

my $hostname;

my $result = GetOptions("host=s" => \$hostname);

# nouvel objet Diabolo 
my $obj = Diabolo->new;


my $hosts = defined($hostname) ? $obj->lshosts($hostname)  : $obj->lshosts;

die("$hostname not found") unless @$hosts;

foreach my $hashref ( @$hosts ) {

    say "------- $hashref->{name}---------------";
    foreach my $key ( keys %$hashref ) {

        say "$key : $hashref->{$key}";

    }

    # ajouter une requete SQL pour trouver toutes les VM installées sur ce
    # host, et faire la somme des CPU, ram, et disk. Ainsi qu'un pourcentage
    # d'utilisation du Host.

    my $status = (Ping::host($hashref) == 0) ? "UP" : "DOWN";
    say "This host is $status";

} 

exit 0;
