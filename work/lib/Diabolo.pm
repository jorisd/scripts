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

Retourne une ref de liste qui contient les hosts de l'environnement dans lequel nous nous trouvons

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

Retourne une ref de liste qui contient les vm de l'environnement dans lequel nous nous
trouvons

Peut prendre un paramètre qui ne retourne que le resultat en base pour un name
donné

Ex. $obj->lsvms("vmclientX");


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

    return $liste_ref;  # il faudrait peut-être renvoyer une liste 
                        # d'objets Diabolo::Vm pour être consistent 
}

=pod

=head2 resetenv

Remet a zero les donnees dans la base de donnees

=cut

sub resetenv {
    my $self = shift;

    my @tables = qw/ host_pairs vm host vm_host_pairs /;

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

    #print Dumper($params);

    my $sql;

    if(exists($params->{host_id})) {
        $sql = "insert into host (ip, ram, disk, name, dc, active, host_id) 
               VALUES ('$params->{ip}', $params->{ram}, $params->{disk},
               '$params->{name}', $params->{dc}, $params->{active},
               $params->{host_id})";
    } else {
        $sql = "insert into host (ip, ram, disk, name, dc, active) 
               VALUES ('$params->{ip}', $params->{ram}, $params->{disk},
               '$params->{name}', $params->{dc}, $params->{active})";

    }

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    return 0;
}

=pod

=head2 addvm

Ajoute une nouvelle Vm. Prend en paramètre un obj. Diabolo::Vm

=cut

sub addvm {
    my $self = shift;

    my $vm = shift;

    die("Il faut passer un obj Diabolo::Vm") if(ref($vm) ne 'Diabolo::Vm');

    my $sql = "insert into vm (ip, ip_service, ram, disk, name, dc, active)
               values ('$vm->{ip}', '$vm->{ip_service}', $vm->{ram},
                       $vm->{disk}, '$vm->{name}', $vm->{dc},
                       $vm->{active})";

    my $dbh = $self->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    return 0;
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

# deploy va en fait :
# - mettre à jour les infos stockées en base
# - déployer la nouvelle VM
sub deploy {

    my $self = shift; # self c'est mon obj $diabolo
    my $vm = shift;   # normalement obj Diabolo::Vm;

    if(ref($vm) eq 'Diabolo::Vm') {

        deploy_vm_sql($self, $vm);
        deploy_vm_real($self, $vm);

    } else {
      die "deploy ne marche qu'avec un objet Diabolo::Vm";
    }
    
    return 0;

}

sub deploy_vm_sql {

    my ($diabolo, $vm) = @_ ;

    my $dbh = $diabolo->{dbh};

    my $sql = "insert into vm (ip, ip_service, ram, disk, name)
               values ('$vm->{ip}', '$vm->{ip_service}', $vm->{ram},
                       $vm->{disk}, '$vm->{name}')";

    my $sth = $dbh->prepare($sql);
    $sth->execute;

    $sql = "select vm_id from vm where ip = '$vm->{ip}'
                                     AND  ip_service = '$vm->{ip_service}'
                                     AND  ram = $vm->{ram}
                                     AND  disk = $vm->{disk}
                                     AND  name = '$vm->{name}' ";
    $sth = $dbh->prepare($sql);
    $sth->execute;

    my $row = $sth->fetchrow_hashref;
    $diabolo->{vm_id} = $row->{vm_id};

    return 0;

}

sub deploy_vm_real {

    # la VM est maintenant inscrite en base, je peux donc la créer en vrai

    # faire appel au module perl Sys::Virt
    # ou bien faire un script Rex séparé ?
    
    return 0;

}

