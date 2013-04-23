Scripts (jorisd)
=

Ces scripts ont pour vocation a être utilisé en prod. En fait, c'est déjà le cas.

Une documentation plus précise est dans chaque sous-répertoire.

monit_syslog/
-

Monitoring applicatif basé sur Syslog.
Si votre application génère des messages syslogs, qui sont ensuite centralisés sur un serveur Syslog, ce script
est fait pour vous.

mysql-thread_count/
-

Monitore un serveur MySQL sur le nombre de connexions actives.
Permet donc d'alerter si on approche dangereusement du max_connections

headgrep/
-

Combine un head puis un grep.


gitplop/
-

C'est un bot qui notifie sur IRC lors d'un commit.
Il s'inspire de irkerd



