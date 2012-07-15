monit_syslog/
=

Monitoring applicatif basé sur Syslog.
Si votre application génère des messages syslogs, qui sont ensuite centralisés sur un serveur Syslog, ce script
est fait pour vous.

Vous avez besoin d'un script client (écrit en perl ou autre, un exemple est fourni : syslog.pl ).
Ce dernier envoie un message avec syslog() contenant un mot-clé de votre choix ainsi que le timestamp courant en UTC.

Le mot-clé correspond au stanza "program" du fichier config.ini

Ce message doit ensuite être relayé à votre serveur Syslog central, et enregistré dans un fichier.

Le script de monitoring pass.pl va donc :

1. Ouvre ce fichier syslog
2. Vérifie l'heure du dernier message reçu pour un Host donné
3. Renvoie 255 si l'écart est > 120s, 254 si host inconnu, 0 si OK.

J'utilise différents modules dont je remercie les auteurs respectifs :

- un File::Tail couplé à un Parse::Syslog
- SNMP::Extension::PassPersist de Maddingue
- un thread de lecture 

On m'a parlé de remplacer mon thread de lecture par un select ou IO::Select, mais Parse::Syslog ne gère pas cela apparemment.

