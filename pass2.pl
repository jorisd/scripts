#!/usr/bin/perl
#


BEGIN { push @INC,'/home/joris/perl5/lib/perl5'; }

use warnings;
use strict;
use SNMP::Extension::PassPersist;
use File::Tail;

use threads;
use threads::shared;

my $count :shared = 0;  # variable partagée entre le thread de lecture
                        # et le processus principal

my $rdthrd = threads->new(\&readsub, "/tmp/zzz");
$rdthrd->detach();  # le thread de lecture devient autonome.
                    # "When the program exits, any detached threads that are
                    # still running are silently terminated."



my $extsnmp = SNMP::Extension::PassPersist->new(
    backend_collect => \&update_tree,
    idle_count      => 1,
    # backend_fork    => 1,
    refresh         => 6,      # refresh every 6 sec
);

$extsnmp->run;

# sub pour mise à jour de l'arbre d'oid
sub update_tree {
    my ($self) = @_;


    # add a serie of OID entries
    #$self->add_oid_entry($oid, $type, $value);
    
    $self->add_oid_entry(".1.3.6.1.4.1.2021.2222.0", "integer", $count);
    
    
    # or directly add a whole OID tree
    # $self->add_oid_tree(\%oid_tree);

}

# cette sub sera le corps du thread de lecture
sub readsub {
    my ($filename) = @_;
    
    my $file = File::Tail->new(
         name => $filename,
         maxbuf => 2048,
         maxinterval => 30,
         interval => 1,
         noblock => 0,
    );

    while (defined(my $line=$file->read)) {
      $count++;
    }
}

