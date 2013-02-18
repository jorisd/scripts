# vim: set ts=4 sw=4 tw=0:
# vim: set expandtab:

package Diabolo::Nagios;

use 5.010;
use strict;
use warnings;

use Template;

sub display_vm {

    my ($class, $obj) = @_;

    my $sql = "select * from vm where active = 1";

    my $dbh = $obj->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $hash_ref = $sth->fetchall_hashref('vm_id');     
    my $tt = Template->new();

    $tt->process("nagios-vm.tt", { vm => $hash_ref });


}

sub display_host {

    my ($class, $obj) = @_;

    my $sql = "select * from host";

    my $dbh = $obj->{dbh};
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $hash_ref = $sth->fetchall_hashref('host_id');
    my $tt = Template->new();

    $tt->process("nagios-host.tt", { host => $hash_ref });


}
1;
