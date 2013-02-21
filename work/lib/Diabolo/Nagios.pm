# vim: set ts=4 sw=4 tw=0:
# vim: set expandtab:

package Diabolo::Nagios;

use 5.010;
use strict;
use warnings;

use Template;

use Cwd;

=pod

=head2 display_vm

Affiche une configuration utilisable par nagios pour l'objet Diabolo passe
en parametre. N'affiche que les VM active

Diabolo::Nagios->display_vm($obj);

=cut

sub display_vm {

    my ($class, $obj) = @_;

    my $sql = "select * from vm where active = 1";

    my $dbh = $obj->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $hash_ref = $sth->fetchall_hashref('vm_id');     
    
    my %config = ( RELATIVE => 1, );
    my $tt = Template->new(\%config);


    $tt->process("../templates/nagios-vm.tt", { vm => $hash_ref });

}

=pod

=head2 display_host

Affiche une configuration utilisable par nagios pour l'objet Diabolo passe
en parametre. N'affiche que les Hosts.

Diabolo::Nagios->display_hosts($obj);

=cut

sub display_host {

    my ($class, $obj) = @_;

    my $sql = "select * from host";

    my $dbh = $obj->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $hash_ref = $sth->fetchall_hashref('host_id');
    my %config = ( RELATIVE => 1, );
    my $tt = Template->new(\%config);

    $tt->process("../templates/nagios-host.tt", { host => $hash_ref });


}

1;
