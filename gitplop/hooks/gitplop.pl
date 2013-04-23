#!/usr/bin/perl
#

use strict;
use warnings;
use 5.010;
use autodie;
use Data::Dumper;
use Fcntl;
use File::Basename;
use HTML::TreeBuilder;
use POSIX qw(ENXIO); 
use WWW::Mechanize;

### Requeteur pour faire un minilien
my $m = WWW::Mechanize->new(
  stack_depth => 0,
  timeout => 3,
  ssl_opts => { verify_hostname => 0 },
  autocheck => 0,
);

### renvoie un minilien
sub tinyfy {

  my $commit = shift;
  my $repo   = shift;

  my $p;

  eval {
    # it's a lilurl tinyfier
    $m->get('http://tinyurl.lan/index.php');
   
    # it's a gitweb url
    $m->field('longurl', "http://gitweb.corp.lan/?p=$repo;a=commit;h=$commit" );
    $m->submit;
  
    my $tree = HTML::TreeBuilder->new_from_content( $m->content );
    $p = $tree->look_down( _tag => 'p', class => 'success', )->as_text;
  };

  if($@) {
    say "Error tinyurl detected.\n";
  }

  return $1 if($p =~ m@(http://.*)$@);
  
  return 'Error';

}



my ($refname, $old, $new) = @ARGV;

my @commits = split /\s/, qx/git rev-list --reverse $old..$new/;
chomp(my $proj      = qx/git config --get ii.project/);
chomp(my $repo      = qx/git config --get ii.repo/);
chomp(my $channel   = qx/git config --get ii.channel/);
chomp(my $tinyurl   = qx/git config --get ii.tinyifier/);
chomp(my $revformat = qx/git config --get ii.revformat/);
chomp(my $ircpath   = qx/git config --get ii.ircpath/);


### verifie si 'ii' fonctionne
if( -p "$ircpath/in") {

  ### rejoint le channel si gitplop n'y est pas encore
  if( ! -p "$ircpath/#$channel/in" ) {
    sysopen(FIFO, "$ircpath/in", O_WRONLY|O_NONBLOCK); # or die...
    die "ii daemon down" if($! == ENXIO);
    close(FIFO);

    open(my $ircctl, '>', "$ircpath/in");
    select $ircctl; $| = 1;
    select STDOUT;
    say $ircctl "/join #$channel";
    close $ircctl;
    sleep 3;
  }
  ### on quitte si le channel n'est pas créé, il y a un pb 
  if( ! -p "$ircpath/#$channel/in") {
    die "ii daemon down";
  } else {

    sysopen(FIFO, "$ircpath/#$channel/in", O_WRONLY|O_NONBLOCK); # or die...
    #sysopen(FIFO, "/dev/null", O_WRONLY|O_NONBLOCK); # or die...
    die "ii daemon down" if($! == ENXIO);
    close(FIFO);
  } 

} else {
  die "ii daemon down";
}

### jusque là, on est bon !
open(my $fh, '>', "$ircpath/#$channel/in");
select $fh; $| = 1;

select STDOUT;

foreach my $c (@commits) {

  my @files = qx/git diff-tree -r --name-only $c/;
  shift @files; # 1st line is the commit ID, I don't need this
  chomp(@files);
  chomp(my $temp = qx/git log -1 '--pretty=format:%an <%ae>|%s' $c/);
  my ($author, $logmsg) = split /\|/, $temp;
  my ($email) = ($author =~ m/<(.*\@.*)>/);
  ($author) = split /\@/, $email;
  my $branch = basename $refname;
  my $commit = substr $c, 0, 7;

  my $minilien = tinyfy($commit, $repo);

  my $ircmsg = "$proj: $author $repo:$branch * $commit / @files: $logmsg $minilien";

  # si le message est trop gros, on vire la liste des fichiers
  $ircmsg = "$proj: $author $repo:$branch * $commit / $logmsg $minilien" if(length($ircmsg) > 510); 
  
  say $fh $ircmsg;
}

close($fh);

exit 0;

