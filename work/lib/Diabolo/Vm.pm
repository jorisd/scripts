package Diabolo::Vm;

use Modern::Perl;

sub new {
    my $class = shift;
    my $self = {};

    bless($self, $class);

    my $params = { @_ };

    $self->{ host_id1 } = $params->{ host_id1 } or die "host_id1 requis";
    $self->{ host_id2 } = $params->{ host_id2 } or 1; # 1 c'est un pseudo-Host
    $self->{ ip       } = $params->{ ip       } or die "ip requis";
    $self->{ ram      } = $params->{ ram      } or die "ram requis";
    $self->{ disk     } = $params->{ disk     } or die "disk requis";
    $self->{ name     } = $params->{ name     } or die "name requis";

    # il faudra checker si les hosts peuvent supporter cette nouvelle VM
    return $self;
}


sub run {

    my $self = shift;
    my $diabolo = shift;

    my $dbh   = $self->{dbh};
    my $vm_id = $self->{vm_id};

    # trouver sur quel host la VM se trouve.

    my $sql = "select * from vm_host_pairs where vm_id = $self->{vm_id}";
    my $sth = $dbh->prepare($sql);
    $sth->execute;

    my $row = $sth->fetchrow_hashref;
    
    my $pair_id = $row->{pair_id};

    $sql = "select * from host_pairs where pair_id = $pair_id";
    $sth = $dbh->prepare($sql);
    $sth->execute;

    $row = $sth->fetchrow_hashref;
    
    my $host_id1 = $row->{host_id1};
    my $host_id2 = $row->{host_id2};

    $sql = "select * from host where host_id = $host_id1";

    $sth = $dbh->prepare($sql);
    $row = $sth->fetchrow_hashref;

    say "**** virsh -c qemu+ssh://$row->{name}/system blah!";

    return 0;

}

1;
