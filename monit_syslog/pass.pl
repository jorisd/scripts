#!/usr/bin/perl
#
#
# ------------------------------------------------------------------
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public
#    License published by the Free Software Foundation.
#               (see http://www.gnu.org/licenses/gpl.html).
# ------------------------------------------------------------------
#
#   Usage : (conçu pour fonctionner via snmp en mode passpersist)
#   -------
#   pass_persist  <root_oid> /path/to/pass.pl -c config.ini
#
#   Description :
#   -------------
#   Certaines application utilisent syslog pour transmettre
#   des messages de type logs d'accès ou autre.
#   Ils sont envoyés à un serveur syslog maître dont le
#   rôle est de traiter ces messages à des fin de stats ou autres.
#   Le but de ce script est de s'assurer que l'ensemble de
#   la chaîne de traitement des ces messages (envoi + reception) est
#   fonctionnel.
#
#   Ce script parse un fichier de log de ce type :
#   date hostname program: timestamp
#   Exemple :
#   Jul 5 04:59:03 serveur-front-1 monitoring: 1341457143
#
#   S'agissant d'un script de monitoring, il faut l'interfacer avec snmp
#   en mode pass_persist.
#
#   La plupart des paramètres sont dans un fichier .ini de ce type :
#
#   [root]  # oid_racine, doit correspondre avec la config snmp
#   oid=.1.3.6.1.4.1.2021.2222
#   [hosts] # hostname=oid_feuille
#   serveur-front-web1=.0
#   serveur-front-web2=.1
#   [syslog]
#   file=/var/log/monitoring.log
#   program=monitoring-string
#
#
#   Auteur : Joris <jorisd_AT_gmail.com>

BEGIN { push @INC,'/home/joris/perl5/lib/perl5'; }


use warnings;
use strict;
use autodie;

use DateTime;
use Parse::Syslog;
use File::Tail;

use SNMP::Extension::PassPersist;
use threads;
use Thread::Queue;

use Config::IniFiles;
use Getopt::Std;

getopt('c');
my $config_file = defined $opt_c ? $opt_c : "config.ini";

tie my %cfg, 'Config::IniFiles', ( -file => $config_file );

my $syslog_file = $cfg{syslog}{file};
my $program     = $cfg{syslog}{program};

# l'arbre d'OID utilisé pour setter les mesures
my %oid_tree;
my $full_oid;

foreach my $host (sort(keys %{$cfg{hosts}})) {
    $full_oid = "$cfg{root}{oid}" . "$cfg{hosts}{$host}";
    $oid_tree{$full_oid} = [ "integer", 254 ]; # initialisation des oid en mode erreur int/255.
}


# permet une commmunication entre le thread de lecture et la sub de calcul
my $DataQueue = Thread::Queue->new();


my $read_thrd = threads->new(\&readsub, $syslog_file);
$read_thrd->detach();   # le thread de lecture devient autonome.
                        # "When the program exits, any detached threads that are
                        # still running are silently terminated."

my $extsnmp = SNMP::Extension::PassPersist->new(
    backend_collect => \&update_tree,
    idle_count      => 12,   # quit after 120s idling
    refresh         => 10,   # refresh every 10s
);

$extsnmp->run;

sub update_tree {
    my ($self) = @_;

    &calcsub;

    # directly add a whole OID tree
    $self->add_oid_tree(\%oid_tree);
}

# cette sub sera le corps du thread de lecture
# elle possède un check mineur pour eviter de passer des conn*****
# au thread de calcul
sub readsub {
    my ($filename) = @_;

    my $file = File::Tail->new(
        name => $filename,
        maxbuf => 2048,
        maxinterval => 5,
        interval => 1,
        noblock => 0,
    );

    my $parser = Parse::Syslog->new($file);

    # desactivation des warnings
    $SIG{__WARN__} = sub { 1 };
    while (my $sl = $parser->next) {
        if($sl->{program} eq $program) { # check mineur
            $DataQueue->enqueue("$sl->{host}:$sl->{text}");
        }
    }
    # reactivation des warnings
    $SIG{__WARN__} = 'DEFAULT';
}

sub calcsub {
    # _nb pour "non-bloquant"
    my $msg = $DataQueue->dequeue_nb();

    if(defined $msg) {
        my ($host, $timestamp) = split(/:/, $msg);

        if(exists $cfg{hosts}{$host}) { # anti-autovivification
            my $full_oid = "$cfg{root}{oid}" . "$cfg{hosts}{$host}";

            if($timestamp =~ m/^[0-9]+$/) {
                my $localtime = time;
                my $dt = DateTime->from_epoch( epoch => $timestamp,
                                               time_zone => "UTC");

                my $diff = abs($localtime - $timestamp);

                # print "Last syslog msg from $host received @ \
                # $dt->hms UTC ($diff" . "s ago)";

                $oid_tree{$full_oid}[1] = ($diff > 120) ? 255 : 0;
            }
            else {
                #print "No syslog msg from $host received. ERROR !!!\n";
                $oid_tree{$full_oid}[1] = 254;
            }
        }
    }
}

