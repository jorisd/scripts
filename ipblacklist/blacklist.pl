#!/usr/bin/perl
#
# fetch APNIC IP ranges, filters by country and feed them into an ipset.
# then: iptables -A INPUT -m set --match-set <SETNAME> src -j DROP 
#
# authors: joris

use Modern::Perl;
use LWP::Simple;

my $apnicranges = get("http://ftp.apnic.net/stats/apnic/delegated-apnic-latest");

die "can't get the apnic ranges" if(! defined $apnicranges);

open(my $fh, "<", \$apnicranges);


my %cidr;

for my $i (8 .. 25) {
	$cidr{2**(32-$i)} = $i;
}


open(my $ipset, "|ipset restore") or die "Couldn't run program: $! $?";
say $ipset "destroy CN";
say $ipset "create CN hash:net family inet hashsize 4096 maxelem 4096";

while(<$fh>) {
	chomp;

	if( $_ =~ m/^apnic\|CN\|ipv4\|.*\|allocated$/i ) {
		my($registry, $country, $ipversion, $block, $maxhosts, $when, $status) = split(/\|/, $_);
		say $ipset "add CN $block/" . $cidr{$maxhosts};

	}
}

close $fh;
close $ipset;



