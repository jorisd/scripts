#!/usr/bin/perl
#
#
# TODO: Si le syslog grossi, le scan du fichier prendra un moment :
#       possibilité de faire un seek dans le fichier de syslog ??
#       Ou d'utiliser passpersist avec un file::tail

BEGIN { push @INC,'/home/joris/perl5/lib/perl5'; }


use warnings;
use strict;
use POSIX;

use DateTime;
use Parse::Syslog;
use File::Tail;
use SNMP::Extension::PassPersist;

use threads;
use threads::shared;
use Thread::Queue;

my $syslogfile = "/tmp/zzz";

my $root_oid = ".1.3.6.1.4.1.8072.2222";

# permet une commmunication entre le thread de lecture et celui de calcul
my $DataQueue = Thread::Queue->new();


# liste des hosts à monitorer avec leur OID
my %monitoring :shared = (
                   web1 => "${root_oid}.0",
                   web2 => "${root_oid}.1",
                 );

# l'arbre d'OID utilisé pour setter les mesures
# Attention, ça doit correspondre avec le hash %monitoring
# J'ai pas encore trouvé le moyen de réunir ces 2 hashes ensemble
my %oid_tree = (
                 $monitoring{web1}    => [ "integer", 0 ],
                 $monitoring{web2}    => [ "integer", 0 ],
               );

#my $calc_thrd = threads->new(\&calcsub);
my $read_thrd = threads->new(\&readsub, "/tmp/zzz");
$read_thrd->detach();   # le thread de lecture devient autonome.
                        # "When the program exits, any detached threads that are
                        # still running are silently terminated."
#$calc_thrd->detach();

my $extsnmp = SNMP::Extension::PassPersist->new(
    backend_collect => \&update_tree,
    idle_count      => 20,  # quit after 120s    
    refresh         => 6,   # refresh every 6 sec
);

$extsnmp->run;


sub update_tree {
    my ($self) = @_;

    #$oid_tree{ $monitoring{'web1'}  }[1] = $count++ ;
    #$oid_tree{".1.3.6.1.4.1.8072.1"}[1] = $count++ ;

    &calcsub;


    # add a serie of OID entries
    #$self->add_oid_entry($oid, $type, $value);
    #$self->add_oid_entry(".1.3.6.1.4.1.32272.20", "counter", $count);
    # or directly add a whole OID tree
    $self->add_oid_tree(\%oid_tree);
}

# cette sub sera le corps du thread de lecture
# y'a juste un check mineur pour eviter de passer des conneries au thread
# de calcul
sub readsub {
        my ($filename) = @_;

        my $file = File::Tail->new(
             name => $filename,
             maxbuf => 2048,
             maxinterval => 30,
             interval => 1,
             noblock => 0,
        );

        my $parser = Parse::Syslog->new($file);

        # desactivation temporaire des warnings
        $SIG{__WARN__} = sub { 1 };
        while (my $sl = $parser->next) {
                if($sl->{program} eq "monitoring") { # check mineur
                        $DataQueue->enqueue("$sl->{host}:$sl->{text}");
                }
        }
        # reactivation des warnings
        $SIG{__WARN__} = 'DEFAULT';
}

sub calcsub {
        #print Dumper($oid_tree{ $monitoring{ web1 } }[1]);
        
        my $msg = $DataQueue->dequeue_nb();
        
        if(defined $msg) {        
            my ($host, $timestamp) = split(/:/, $msg); 

            if(exists($monitoring{$host})) { # test anti-pollution à cause de l'autovivification
                    if(isdigit $timestamp) {
                            my $localtime = time;
                            my $dt = DateTime->from_epoch( epoch => $timestamp, time_zone => "UTC" );

                            my $diff = abs( $localtime - $timestamp );

                            #print "Last syslog msg from $remotesrv received @ " . $dt->hms . " UTC ($diff" . "s ago)";

                            # On accepte un écart de +/- 120secs
                            if($diff > 120) {
                            #        print " Delta TOO BIG !!!\n";
                            
                                    $oid_tree{ $monitoring{ $host } }[1] = 255;
                                #exit 255;
                            }
                            else {
                            #        print " OK\n";
                            #        exit 0;
                                    $oid_tree{ $monitoring{ $host } }[1] = 0; 
                            }
                    }
                    else {
                            #print "No syslog msg from $remotesrv received. ERROR !!!\n";
                            #exit 255;
                            $oid_tree{ $monitoring{ $host } }[1] = 254;
                    }
            }
        }        
}
