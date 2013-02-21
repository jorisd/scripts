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

use Conf;
use Data::Dumper;
use DBD::SQLite;
our $VERSION = '0.01';

=pod

=head2 new

  my $object = Diabolo->new("test");

=cut

sub new {
    my ( $class, $env ) = @_;
    my $self = {};
    bless($self, $class);
    $self->{ENV} = $env;

    my $conf = Conf::get();

    my $dbString = $conf->{db_path};

    $self->{dbh} =
        DBI->connect( "dbi:SQLite:dbname=$dbString", "", "" )
        or die $DBI::errstr;

#    $conf->{db_path};
#    $conf->{test}->{foo}

    return $self;
}

=pod

=head2 lshosts

Retourne les hosts de l'environnement dans lequel nous nous trouvons

Peut prendre un paramètre qui ne retourne que le resultat en base pour un name donné

Ex. $obj->lshost("srv02dc1");

=cut

sub lshosts {
    my ($self,$host_name) = @_;

    my $liste_ref = [];
    my $moresql = '';
    if(defined($host_name)) {
        $moresql = "where name like '$host_name'";
    }

    my $sql = "select * from host $moresql";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        push($liste_ref, $row);
    }

    return $liste_ref;
}

=pod

=head2 lsvms

Affiche les vms de l'environnement dans lequel nous nous trouvons

=cut

sub lsvms {
    my $self = shift;

    my $liste_ref = [];

    my $sql = "select * from vm";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    while ( my $row = $sth->fetchrow_hashref ) {
        push($liste_ref, $row);
    }

    return $liste_ref;
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

1;

