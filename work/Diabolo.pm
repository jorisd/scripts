# vim: set ts=4 sw=4 tw=0:
# vim: set expandtab:


package Diabolo;

=pod

=head1 NAME

Diabolo - Fournit des fonction pour exploiter les elements basiques : vm, host, 

=head1 SYNOPSIS

  my $object = Diabolo->new("test");
  
  $object->lshosts;

=head1 DESCRIPTION

En cours de dev

=head1 METHODS

=cut

use 5.010;
use strict;
use warnings;

use Data::Dumper;
use DBD::SQLite;
our $VERSION = '0.01';

=pod

=head2 new

  my $object = Diabolo->new("test");

The C<new> constructor lets you create a new B<Diabolo> object.

So no big surprises there...

Returns a new B<Diabolo> or dies on error.

=cut

sub new {
    my ( $class, $env ) = @_;
    my $this = {};
    bless($this, $class);
    $this->{ENV} = $env;

    if ( $env eq 'test' ) {
        $this->{dbh} =
          DBI->connect( "dbi:SQLite:dbname=db-$env.sqlite", "", "" )
          or die $DBI::errstr;
    }

    return $this;
}

=pod

=head2 lshosts

Affiche les hosts de l'environnement dans lequel nous nous trouvons

=cut

sub lshosts {
    my $self = shift;

    my $sql = "select * from host";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        say "Host:";
        for my $col ( keys %$row ) {
            say "\t$col is $row->{$col}";
        }
    }

}

=pod

=head2 lsvms

Affiche les vms de l'environnement dans lequel nous nous trouvons

=cut

sub lsvms {
    my $self = shift;

    my $sql = "select * from vm";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        say "vm:";
        for my $col ( keys %$row ) {
            say "\t$col is $row->{$col}";
        }
    }

}

=pod

=head2 resetenv

Remet a zero les donnees dans la base de donnees

=cut

sub resetenv {
    my $self = shift;

    my @tables = qw/ host_pairs vm host /;

    foreach my $t (@tables) {
        my $sql = "delete from $t";
        my $dbh = $self->{dbh};
        my $sth = $dbh->prepare($sql);
        $sth->execute();
    }
}

=pod

=head2 addhost

Ajoute un nouvel host

=cut

sub addhost {
    my $self = shift;

    my $params = {@_};

    print Dumper($params);

    my $sql = "insert into host (ip, ram, disk, name, dc, active) 
               VALUES ('$params->{ip}', $params->{ram}, $params->{disk}, '$params->{name}', $params->{dc}, $params->{active})";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();
}

=pod

=head2 addvm

Ajoute une nouvelle Vm

=cut

sub addvm {
    my $self = shift;

    my $params = {@_};

    my $sql = "insert into vm (ip, ip_service, ram, disk, name, dc, active)
               values ('$params->{ip}', '$params->{ip_service}', $params->{ram},
                       $params->{disk}, '$params->{name}', $params->{dc},
                       $params->{active})";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();
}

=pod

=head2 pairhosts

Associe deux hosts ensemble pour former apres un couple master/slave.

=cut

sub pairhosts {
    my $self = shift;

    my $params = {@_};

    my $sql = "insert into host_pairs (host_id1, host_id2)
               values ($params->{id1}, $params->{id2})";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();
}


#sub nagios_config {
#    my $self = shift;
#
#    my $sql = "select * from vm where active = 1";
#
#    my $dbh = $self->{dbh};
#    my $sth = $dbh->prepare($sql);
#    $sth->execute();
#
#    my $hash_ref = $sth->fetchall_hashref('vm_id');     
#
#    my $tt = Template->new();
#
#    $tt->process("nagios.tt", { vm => $hash_ref });
#
#
#    print $tt; #Dumper ($hash_ref);
#
#
#
#
#
##my ($vm_id, $ip, $ip_service, $ram, $disk, $name, $dc, $active) = $sth->fetchrow();
##    while ( my $row = $sth->fetchrow_hashref ) {
##        for my $col ( keys %$row ) {
##            print "\t$col is $row->{$col}\n";
##        }
##    }
#}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2011 Anonymous.

=cut
