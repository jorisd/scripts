#!/usr/bin/perl
#
# TODO: Gerer les exceptions malgré l'utilisation de File::Tail
#
#

use autodie;
use diagnostics;
use utf8;

use AnyEvent;
use AnyEvent::Handle;
use Data::Dumper;
use Email::MIME;
use File::Tail;
use File::Temp qw/ tempfile /;
use IO::Pipe;
use Modern::Perl;
use Spreadsheet::WriteExcel;

# chemin du fichier a lire
my $snmplogfile = '/tmp/log123';

my $debug = 1;



# pour la communication parent/fils après le fork
my $pipe = IO::Pipe->new;

# flushe STDOUT
$| = 1; 
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");


# make_excel - necessite en paramètre un array_ref
#   creer un fichier excel formmaté avec les nouvelles  alertes
#   
#   retourne le chemin complet du fichier .xls, ou undef si pas de fichier
#
sub make_excel {

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
  my $ws = $workbook->add_worksheet();
  my $row   = 0;
  
  # header commun a chaque fichier excel
  $ws->write_string($row, 0, 'Date et Heure');
  $ws->write_string($row, 1, 'Evenement');
  $ws->write_string($row, 2, 'Description');

  # formatage / couleur des cellules
  my $format_red = $workbook->add_format();
  $format_red->set_bg_color('red');
  my $format_yellow = $workbook->add_format();
  $format_yellow->set_bg_color('yellow');

  foreach my $h_ref (@{$array_ref}) {
    $row++;

    if($h_ref->{event} =~ /major/) {
      $ws->write_string($row, 0, "$h_ref->{day}/$h_ref->{month} $h_ref->{time}:$h_ref->{sec}", $format_red);
      $ws->write_string($row, 1, $h_ref->{event}, $format_red);
      $ws->write_string($row, 2, $h_ref->{desc}, $format_red);
    } elsif($h_ref->{event} =~ /minor/) {
      $ws->write_string($row, 0, "$h_ref->{day}/$h_ref->{month} $h_ref->{time}:$h_ref->{sec}", $format_yellow);
      $ws->write_string($row, 1, $h_ref->{event}, $format_yellow);
      $ws->write_string($row, 2, $h_ref->{desc}, $format_yellow);
    } else {
      $ws->write_string($row, 0, "$h_ref->{day}/$h_ref->{month} $h_ref->{time}:$h_ref->{sec}");
      $ws->write_string($row, 1, $h_ref->{event});
      $ws->write_string($row, 2, $h_ref->{desc});
    }
    

    #$format->set_bg_color();
  }

  $workbook->close();

  if($row) {
    # on a eu au moins 1 ligne snmp
    warn "INFO: Excel file $filename generated and closed" if $debug;
    return $filename; 
  } else {
    warn "INFO: No new SNMP lines found" if $debug;
    unlink $filename;
    return undef;
  } 

};


if (fork) {
  # run parent code
  $pipe->writer();
  $pipe->autoflush;

  my $file = File::Tail->new( name        => $snmplogfile,
                              maxinterval => 1,
                              tail        => -1, # FIXME  -1 pour tout lire, a supprimer en passage en prod
                            );

  # boucle infinie
  while (my $line = $file->read) {
      print $pipe "$line";
      warn "I just read $line and sent it to the pipe" if $debug;
  }
} else {
  # run child code
  $pipe->reader();
  #binmode $pipe, ':utf8';

  my @list = ( [] );

  my $h = AnyEvent::Handle->new( fh => $pipe );

  my $handle_line; $handle_line = sub {
    my ($h, $line, $eol) = @_;
    warn "Child got a line from pipe: $line" if $debug;

    if($line =~ m/^
                     (?<day>\d{2})\.(?<month>\d{2}),
                     \s(?<time>\d{2}:\d{2}),
                     \s{3}(?<sec>\d{2}),
                     (?<event>.*),
                     (?<desc>.*),{6}
                  $
                /x
      ) { 
      warn "*matches*" if $debug;
      my %copy = %+;

      push @{$list[0]}, \%copy;
    } else {
      warn "WARNING: Got a weird line : $line";
    } 
    $h->push_read( line => $handle_line );
  };
  $h->push_read( line => $handle_line );

  my $once_per_minute; $once_per_minute = AnyEvent->timer (
   after    => 5,      # first invoke in 5 seconds
   interval => 10,     # then invoke every 10 seconds
   cb       => sub {   # the callback to invoke

            
    push @list, [];              # je push une nouvelle liste anonyme

    my $array_ref = shift @list; # puis je recupere la précédente liste anonyme qui 
                                 # contient tous les messages logués depuis 1 minute
                                 # @list ne contient plus qu'un seul élément


    my $xls = make_excel($array_ref);


    # TODO envoyer un mail
    #sendemail $xls if defined $xls;

   },
);
  
  
  AnyEvent->condvar->recv;
  
}

