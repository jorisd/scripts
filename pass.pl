#!/usr/bin/perl
#
#
# TODO: Si le syslog grossi, le scan du fichier prendra un moment :
#       possibilité de faire un seek dans le fichier de syslog ??
#       Ou d'utiliser passpersist

use warnings;
use strict;
use POSIX;

use DateTime;
use Parse::Syslog;
use File::Tail;
#use IO::Handle; # pour Parse::Syslog, mais plus utile grace a File::Tail
use SNMP::Extension::PassPersist;

use threads;
use threads::shared;

my $count = 0;

my @monitoring_strings = ( "web1", "web2", );
my $root_oid = ".1.3.6.1.4.1.8072.2222.";

my %oid_tree;

foreach (0..@#monitoring_strings) {
        my $key = $root_oid . $_;
        %oid_tree{"$root_oid$key"} => [ "integer", 0 ]
}


my %monitoring = (
                   'web1' => ".1.3.6.1.4.1.8072.2222.0" ,
                   'web2' => ".1.3.6.1.4.1.8072.2222.1",
                 );

my %oid_tree = (
                 $monitoring{'web1'}    => [ "integer", 0 ],
                 $monitoring{'web2'}    => [ "integer", 0 ],
               );
    
my $extsnmp = SNMP::Extension::PassPersist->new(
    backend_collect => \&update_tree,
    refresh         => 30,      # refresh every 30 sec
);  
    
$extsnmp->run;


sub update_tree {
    my ($self) = @_;

    $oid_tree{".1.3.6.1.4.1.8072.0"}[1] = $count++ ;
    $oid_tree{".1.3.6.1.4.1.8072.1"}[1] = $count++ ;

    # add a serie of OID entries
    #$self->add_oid_entry($oid, $type, $value);
    #$self->add_oid_entry(".1.3.6.1.4.1.32272.20", "counter", $count);
    # or directly add a whole OID tree
    $self->add_oid_tree(\%oid_tree);
}





# -----------------
my $syslogfile = "/var/log/monitoring";
my $remotesrv = $ARGV[0];
my $lastlogline = undef;

$file=File::Tail->new($syslogfile);

my $parser = Parse::Syslog->new($file);

# desactivation temporaire des warnings
$SIG{__WARN__} = sub { 1 };
while (my $sl = $parser->next) {
        $lastlogline = $sl->{text} if($sl->{host} eq "$remotesrv" && $sl->{program} eq "monitoring");
}

# reactivation des warnings
$SIG{__WARN__} = 'DEFAULT';

#print "$lastlogline";

$io->close();
undef $io;
close $fd;


if(isdigit $lastlogline) {
        my $localtime = time;
        my $dt = DateTime->from_epoch( epoch => $lastlogline, time_zone => "UTC" );

        my $diff = abs( $localtime - $lastlogline );

        print "Last syslog msg from $remotesrv received @ " . $dt->hms . " UTC ($diff" . "s ago)";

        # On accepte un écart de +/- 120secs
        if($diff > 120) {
                print " Delta TOO BIG !!!\n";
                exit 255;
        }
        else {
                print " OK\n";
                exit 0;
        }
}
else {
        print "No syslog msg from $remotesrv received. ERROR !!!\n";
        exit 255;
}

 
