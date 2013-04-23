#!/bin/bash
#
# script launched by supervisord

DAEMON=/usr/local//ii/ii
NAME=instance

rm -rf /tmp/$NAME/

exec $DAEMON -s server -p 9000 -n gitplop -i $NAME

