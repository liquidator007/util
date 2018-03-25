#!/bin/bash

#etiquetar el ultimo commit

if [ $# -ne 1 ]
then
  printf "\n\nUso:\n\t$0 etiqueta\n\n"
  exit 1
fi

git tag -a $1
