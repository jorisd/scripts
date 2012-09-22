#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;


use Dancer;
use Joris::Webservice;
use DBI;
use DateTime;

sub connect_db {
  my $dbh = DBI->connect("dbi:SQLite:dbname=./db.sqlite3") or die DBI::errstr;
  return $dbh;
  
}

set serializer => 'JSON';

get '/data/:testid' => sub {

#  my $dbh = connect_db();
  
#  my $testid = param('testid');

#  my $sth = $dbh->prepare('select jour, duree from historique where fk_id = ? ORDER BY jour ASC') or die $dbh->errstr;
#  $sth->execute($testid) or die $sth->errstr;
#  my $data = $sth->fetchall_hashref('jour');
  
  
#  return $data;
  
  my $unixepoch = time ;

  header('Access-Control-Allow-Origin', '*');
  { jour  => $unixepoch,
    duree => 1,
  }
  
  #  time   => 'zero',
  #  list   => [qw(1 2 3 4)],
  #}
};




dance;
