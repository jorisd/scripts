#!/usr/bin/perl
#
#
# ------------------------------------------------------------------
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of version 2 of the GNU General Public
#    License published by the Free Software Foundation.
#               (see http://www.gnu.org/licenses/gpl.html).
# ------------------------------------------------------------------
#
#       Author
#               jorisd
#
#       Description du script
#               Calcule le pourcentage d'utilisation des threads mysql.
#               Renvoie ce pourcentage en code de sortie
#               Renvoie 100 en cas d'erreur
#
#       Initial release
#               17 nov 2010
#
#       Changelog
#               5 mai 2011 : ajout d'une section tuyau
#
#       Contributeurs/Mainteneurs
#               Joris
#
#       Tuyaux
#               Ce script peut ne pas marcher 'out-of-the-box' sur
#               certaines distributions. DBD::mysql est configurable :
#
#               Exemple, si le fichier de socket mysql n'est pas là ou dbd l'attend,
#               on peut modifier le DSN pour le spécifier :
#
#               $dbh = DBI->connect('DBI:mysql:mysql;mysql_socket=/var/run/mysql.sock', $login, $pass) ;
#
#               La doc est dispo sur http://search.cpan.org/~capttofu/DBD-mysql-4.018/lib/DBD/mysql.pm
# 
# vim:ts=4:sw=4


use DBI;

# A decommenter si vous utiliser un mysql maison.
# Mettre à jour le chemin.
#use lib '/usr/local/maison/mysql/perllib/lib/perl/5.10.0/';
use Getopt::Long;


# Version du script
my $version = '0.1';

# Identifiants mysql
my $login = 'root';
my $pass = '';

# Compte les erreurs rencontrees
my $erreur = 0;

# switches pour l'aide, la version et le mode debug
my $h = 0; my $v = 0; my $d = 0;
GetOptions('h' => \$h, 'd' => \$d, 'v' => \$v);


if($h) {
  print "Je sers a calculer le pourcentage d'utilisation des threads mysql.\n";
  print "Ce pourcentage est ensuite utilisé comme code retour de fin de programme.\n";
  exit 0;
}
if($v) {
  print "Version $version\n";
  exit 0;
}
if($d) {
  print "Pas de mode debug. Ce script n'effectue que du read-only.\n";
  exit 0;
}


$dbh = DBI->connect('DBI:mysql:mysql', $login, $pass) ;

$sth = $dbh->prepare("SHOW GLOBAL STATUS LIKE 'Threads_connected'");
$rc = $sth->execute();

if($rc == 1) {
  (undef, $threads) = $sth->fetchrow_array();
}
else {
  print "Probleme pour recuperer Threads_connected!";
  $erreur++;
}

$sth = $dbh->prepare("SHOW GLOBAL VARIABLES LIKE 'max_connections'");
$rc = $sth->execute();

if($rc == 1) {
  (undef, $maxconns) = $sth->fetchrow_array();
}
else {
  print "Probleme pour recuperer max_connections!";
  $erreur++; 
}

if($maxconns > 0) {
  $seuil=int(($threads/$maxconns)*100);
}
else {
  $erreur++;
}

$sth->finish();
$dbh->disconnect();

exit 100 if $erreur;

print "Threads_connected: $threads\n";
print "max_connections: $maxconns\n";
print "Seuil de connections : $seuil %\n";
exit $seuil;


