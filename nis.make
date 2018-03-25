#!/bin/sh
if [ $# -ne 0 ]
then
  printf "Uso:\n\t$0\n\n"
  exit 1
fi

PATH=$PATH:/util
DIR=`pwd`
pwconv	#Crear /etc/shadow con la información de claves de /etc/passwd
pwunconv	#Pasar las claves otra vez a /etc/passwd
cd /var/yp	#Añadir la nueva cuenta a la B.D. NIS/YP
make

cd $DIR

echo "Información NIS/YP consolidada"
#ypcat passwd 
