Scripts (jorisd)
=

monit_syslog/
-

1. Ouvre un fichier syslog, dont le format dépend d'un autre script pas publié.
2. Vérifie l'heure du dernier message reçu pour un Host donné
3. Renvoie 255 si Delta trop grand, 254 si host inconnu, 0 si OK.

Ce script ont pour vocation a être utilisé en prod. En fait, c'est déjà le cas :)

J'utilise différents modules dont je remercie les auteurs respectifs :

- un File::Tail couplé à un Parse::Syslog
- SNMP::Extension::PassPersist de Maddingue
- Threads::DataQueue
- un thread de lecture 

On m'a parlé de remplacer mon thread de lecture par un select ou IO::Select, mais Parse::Syslog ne gère pas cela.
Cela dit, rien n'est impossible en perl :p


mysql-thread_count/
-

Monitore un serveur MySQL sur le nombre de connexions actives.
Permet donc d'alerter si on approche dangereusement du max_connections

