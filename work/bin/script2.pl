my $vm = new VM(host => '???'); # Create VM

$vm->run; # Run VM
$vm->installPackages; # Install v2 dependencies

my $platform = new Platform(vm => $vm);

$platform->fetchGitRepo; # Get git v2 repo
$platform->genConf; # Generate v2 conf
$platform->runInitScripts; # Run v2 initialization scripts
$platform->runTests; # Run /tests/test_all.pl
$platform->lanchDaemons; # Launch all required daemons (router, usersMgr, logger...)
$platform->liveTest; # Test the live platform

_________________________________________________________________


$vm->shutdown;
$vm->fallback;



_________________________


new VM(host => '...', cb => sub {
    endwait;
});

wait;



use AnyEvent;

my $cv = AnyEvent->condvar;

my $t; $t = AnyEvent->timer(after => 1, cb => {
    say "coucou";
    $t = undef;
});

$cv->recv;
