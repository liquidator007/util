#!/bin/sh

SERVICES=/etc/init.d

if [ $# -eq 0 ]
then
  printf "\nUso:\n\t $0 servicio parametros\n\n"
  exit 1
fi

if [ -x $SERVICES/$1 ]
then
  $SERVICES/$*
else
  ls $SERVICES
fi
