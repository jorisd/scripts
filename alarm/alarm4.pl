#!/usr/bin/perl

use autodie;
use diagnostics;
use AnyEvent;
use AnyEvent::Handle;
use Data::Dumper;
use File::Tail;
use File::Temp qw/ tempfile /;
use IO::Pipe;

#use Email::MIME;
use Modern::Perl;
use Spreadsheet::WriteExcel;
#use utf8;

#use Fcntl qw/ :seek /;


#my $reader;
#my $writer;

my $pipe = IO::Pipe->new;

#pipe($reader, $writer);


$| = 1; # pour STDOUT 

sub make_excel ($) {

  my $array_ref = shift;

  my ($fh, $filename) = tempfile(SUFFIX => ".xls");
  # Create a new Excel workbook
  my $workbook = Spreadsheet::WriteExcel->new($fh);
  $workbook->set_properties(
    title    => "Rapport d'alerte",
    author   => '<plop>',
    comments => 'Created with Perl and Spreadsheet::WriteExcel',
    company  => 'RTE',
  ); 
   
  # Add a worksheet
  my $worksheet = $workbook->add_worksheet();



  my $row   = 0;
  # header commun a chaque fichier excel
  $worksheet->write_string($row, 0, 'Date et Heure');
  $worksheet->write_string($row, 1, 'Evenement');
  $worksheet->write_string($row, 2, 'Description');

  
  my $count = 0; # compteur  de ligne pour le foreach plus bas
  foreach my $h_ref (@{$array_ref}) {
    $row++;
    #say $h_ref->{day} . ' ' . $h_ref->{desc};

    $worksheet->write_string($row, 0, "$h_ref->{day}/$h_ref->{month} $h_ref->{time}:$h_ref->{sec}");
    $worksheet->write_string($row, 1, $h_ref->{event});
    $worksheet->write_string($row, 2, $h_ref->{desc});
  }

  $workbook->close();

  say "Excel file $filename generated and closed";

};









if (fork) {
  # run parent code
  $pipe->writer();
  $pipe->autoflush;

  my $file = File::Tail->new( name        => "/tmp/log123",
                              maxinterval => 1,
                              tail        => -1,
                            );

  # boucle infinie
  while (my $line = $file->read) {
      print $pipe "$line";
      #say "I just read $line and sent it to the pipe\n";
  }
} else {
  # run child code
  $pipe->reader();

  my @list = ( [] );

  my $h = AnyEvent::Handle->new( fh => $pipe );

  my $handle_line; $handle_line = sub {
    my ($h, $line, $eol) = @_;
    #warn "Got a line: $line";

    if($line =~ m/^
                     (?<day>\d{2})\.(?<month>\d{2}),
                     \s(?<time>\d{2}:\d{2}),
                     \s{3}(?<sec>\d{2}),
                     (?<event>.*),
                     (?<desc>.*),{6}
                  $
                /x
      ) { 
      say "*matches*";
      my %copy = %+;

      push @{$list[0]}, \%copy;
      #print Dumper @list;
    } else {
      warn "WARNING Got a weird line : $line";
    } 
    $h->push_read( line => $handle_line );
  };
  $h->push_read( line => $handle_line );

  my $once_per_minute; $once_per_minute = AnyEvent->timer (
   after    => 5,      # first invoke in 60seconds
   interval => 10,     # then invoke every minute
   cb       => sub {   # the callback to invoke

            
    push @list, [];              # je push une nouvelle liste anonyme

    my $array_ref = shift @list; # je recupere la précédente liste anonyme qui 
                                 # contient tous les messages logués depuis 1 minute
                                 # @list ne contient plus qu'un seul élément


    make_excel($array_ref);

   },
);
  
  
  AnyEvent->condvar->recv;
  
}






#
#
#
#
#
#
#
#
#
#
#my $in;
#
#open $in, '<', '/tmp/log123';
##seek $in, 0, SEEK_END;
#
#my $w;
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#$w = AnyEvent->io (
#   fh   => $in,
#   poll => 'r',
#   cb   => sub { 
#                  while(<$in>) {
#                     print $_ if defined $_;
#                  }
#               }
#);
#
#
#
#
#
#
#
#
#AnyEvent->condvar->recv;
