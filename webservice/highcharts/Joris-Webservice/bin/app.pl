#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;


use Dancer;
use Joris::Webservice;
use DBI;

sub connect_db {
  my $dbh = DBI->connect("dbi:SQLite:dbname=db.sqlite3") or die DBI::errstr;
  return $dbh;
  
}

set serializer => 'JSON';

get '/data/:testid' => sub {
  my $testid = param('testid');
  
  { testid => $testid,
    time   => 'zero',
    list   => [qw(1 2 3 4)],
  }
};




dance;
