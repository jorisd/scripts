headgrep
=

Combine un head sans filtrage, puis un grep habituel.

Usage :
$ ps axuw | headgrep -n1 yakuake
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
joris     1769  0.6  1.1 517872 42168 ?        Rl   Nov10  10:22 /usr/bin/yakuake
joris    14256  0.0  0.0  24916  2540 pts/0    R+   15:56   0:00 /usr/bin/perl /home/joris/projets/scripts/headgrep/headgrep -n1 yakuake

$ ps axuw | headgrep -n1 'kworker/u:.*5'
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     11669  0.0  0.0      0     0 ?        S    00:46   0:00 [kworker/u:15]
root     11703  0.0  0.0      0     0 ?        S    12:42   0:00 [kworker/u:45]
joris    14261  0.0  0.0  24916  2272 pts/0    R+   15:58   0:00 /usr/bin/perl /home/joris/projets/scripts/headgrep/headgrep -n1 kworker/u:.*5

$ ps axu | headgrep -n1 -v '(root|joris)'
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
102       1012  0.0  0.0  24960  2216 ?        Ss   Nov10   0:06 dbus-daemon --system --fork --activation=upstart
syslog    1049  0.0  0.0 249472  1436 ?        Sl   Nov10   0:08 rsyslogd -c5
avahi     1062  0.0  0.0  32304  1708 ?        S    Nov10   0:00 avahi-daemon: running [sam.local]
daemon    1127  0.0  0.0  16908   380 ?        Ss   Nov10   0:00 atd
snmp      1142  0.0  0.1  48212  4392 ?        S    Nov10   0:19 /usr/sbin/snmpd -Lsd -Lf /dev/null -u snmp -g snmp -I -smux -p /var/run/snmpd.pid
rtkit     1792  0.0  0.0 168872  1320 ?        SNl  Nov10   0:00 /usr/lib/rtkit/rtkit-daemon
colord    2002  0.0  0.3 500092 11724 ?        Sl   Nov10   0:00 /usr/lib/x86_64-linux-gnu/colord/colord
nobody   14203  0.0  0.0  33060  1308 ?        S    15:52   0:00 /usr/sbin/dnsmasq --no-resolv --keep-in-foreground --no-hosts --bind-interfaces --pid-file=/var/run/sendsigs.omit.d/network-manager.dnsmasq.pid --listen-address=127.0.0.1 --conf-file=/var/run/nm-dns-dnsmasq.conf --cache-size=0 --proxy-dnssec


TODO : gerer la sensibilite de la casse, gestion des arguments pour que ce soit 100% compatible avec grep etc..
