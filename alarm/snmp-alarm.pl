#!/usr/bin/perl

use AnyEvent;
use Email::MIME;
use File::Tail;
use Modern::Perl;
use Spreadsheet::WriteExcel;
use utf8;

binmode(STDOUT, ":utf8");


my $data = "/tmp/data";

my @logsnmp;

my $file = File::Tail->new( name               => $data,
                            ignore_nonexistant => 1,
                          );


local $SIG{ALRM} = \&process;

alarm(10);

while (defined(my $line=$file->read)) {

  push @logsnmp, $line;

}



sub process {

  unlink("/tmp/perl.xls");
  # Create a new Excel workbook
  my $workbook = Spreadsheet::WriteExcel->new('/tmp/perl.xls');
   
  # Add a worksheet
  my $worksheet = $workbook->add_worksheet();
   
  ## Write a formatted and unformatted string, row and column notation.
  my $col = 0;
  my $row = 0;

  foreach my $alarm (@logsnmp) {
  
    my ($date, $evenement, $alarm_desc, $equipement);
    say "$alarm";  
    if($alarm =~ m/^(\d{2})\.(\d{2}), (\d{2}:\d{2}),   (\d{2}),(.*),(.*),{6}$/) {
      say "ca matche";
      ($date, $evenement, $alarm_desc) = ( "$1/$2 $3:$4", "$5", "$6" );
  
      if($alarm_desc =~ "quipement:") {
        ($equipement) = reverse split / /, $alarm_desc;
      }

      say "$date, $evenement, $alarm_desc, $equipement";

      $worksheet->write($row, $col, "$alarm");
      $row++;
    }
  }

  @logsnmp = (); # vide le buffer

  alarm(30);
}




