#!/usr/bin/perl

use strict;
use warnings;
use File::Path qw(make_path);

my $port;
my $servername;
my $logdir;

while (<>) {
        if(/^\s*#/) {
                print;
                next;
        }
        
        if(/<\/VirtualHost>/) {
                $port = 80;
                $servername = "default";
                print;
                next;
        }
        
        $port       = $1 if(/\*:(\d+)>/);
        $servername = $1 if(/ServerName\s+(.*)$/);
        
        if(defined($port) && defined($servername)) {
                $logdir = "/home/logs/apache/$servername" . "_$port";
                 unless(-d $logdir) {
                        make_path($logdir, { verbose => 0 });
                 }
        }

        # suffixe
        s@/.*[^/]*?(:?-??)(access|error)(?:\.log)@$logdir/$1.log-%Y%m%d 86400"@;

        # prefixe le script rotatelog
        s@Log\s+@Log "|/usr/sbin/rotatelogs -l @;
        
        
        
        
        print;
}

