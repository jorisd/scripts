# vim: set ts=4 sw=4 tw=0
# vim: set expandtab


package Diabolo::Vm;


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


# deploy va en fait :
# - mettre à jour les infos stockées en base
# - déployer la nouvelle VM
sub deploy {

    my $self = shift;
    my $diabolo = shift;

    deploy_sql($self, $diabolo);
    deploy_vm($self, $diabolo);

}

sub deploy_sql {

    my $dbh = $diabolo->{dbh};

    my $sql = "insert into vm (ip, ip_service, ram, disk, name)
               values ('$self->{ip}', '$self->{ip_service}', $self->{ram},
                       $self->{disk}, '$self->{name}')";

    my $sth = $dbh->prepare($sql);
    $sth->execute;

    $sql = "select vm_id from vm where ip = '$self->{ip}'
                                     AND  ip_service = '$self->{ip_service}'
                                     AND  ram = $self->{ram}
                                     AND  disk = $self->{disk}
                                     AND  name = '$self->{name}' ";
    $sth = $dbh->prepare($sql);
    $sth->execute;

    my $row = $sth->fetchrow_hashref;
    $self->{vm_id} = $row->{vm_id};

    return 0;

}

sub deploy_vm {

    # la VM est maintenant inscrite en base, je peux donc la créer

    # faire appel au module perl Sys::Virt
    # ou bien faire un script Rex séparé ?

    return 0;

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

