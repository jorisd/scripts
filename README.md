cripts (jorisd)
=======

Pass*pl
-------

1. Ouvre un fichier syslog, dont le format dépend d'un autre script pas publié.
2. Vérifie l'heure du dernier message reçu pour un Host donné
3. Renvoie 255 si Delta trop grand, 0 si OK.

Ce script ont  pour vocation a être utilisé en prod. En fait, c'est déjà le cas mais avec du code moins optimisé.

J'utilise différent module :

- un thread de lecture
- un File::Tail couplé à un Parse::Syslog
- SNMP::Extension::PassPersist
- Threads::DataQueue

On m'a parlé de remplacer mon thread de lecture par un select ou IO::Select, mais Parse::Syslog ne gère pas cela.


