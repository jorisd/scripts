#!/usr/bin/perl
#


BEGIN { push @INC,'/home/joris/perl5/lib/perl5'; }

use warnings;
use strict;
use SNMP::Extension::PassPersist;
use File::Tail;

use threads;
use threads::shared;

my $count :shared = 0;

my $rdthrd = threads->new(\&readsub, "read_thread");
    
my $extsnmp = SNMP::Extension::PassPersist->new(
    backend_collect => \&update_tree,
    idle_count      => 10,
    # backend_fork    => 1,
    refresh         => 5,      # refresh every 30 sec
);

my $file=File::Tail->new(
         name => "/tmp/zzz",
         maxbuf => 2048,
         maxinterval => 30,
         interval => 1,
         noblock => 1,
);

    
$extsnmp->run;

sub update_tree {
    my ($self) = @_;

       
    # add a serie of OID entries
    #$self->add_oid_entry($oid, $type, $value);
    $self->add_oid_entry(".1.3.6.1.4.1.2021.2222.0", "integer", $count);
    # or directly add a whole OID tree
    # $self->add_oid_tree(\%oid_tree);
    
}


sub readsub {
    while (defined(my $line=$file->read)) {
      $count++;
    }
}

$quit = 1;

$rdthrd->join();

