#!/usr/bin/perl
#
# Usage : ./syslog.pl
#
# Ce script envoie au démon syslog local :
# - un mot clé "monitoring" (qui doit être commun aux scripts)
# - le timestamp local
# - en utilisant la facility local6, priorité notice
#
# Ensuite le démon syslog local relaie les messages au serveur syslog centralisé
#
# Seul, ce script est inutile : le monitoring s'effectue sur 
# le serveur syslog avec un autre script : pass.pl
#

use strict;
use warnings;

use Sys::Syslog qw(:DEFAULT);
use DateTime;

my $time = time;

openlog "monitoring", "ndelay", "local6";
syslog "notice", "$time";

closelog;

