#!/bin/sh
#
#kernel.make
#
#compilar el kernel existente en /usr/src/linux, con modulos, e instalarlo.
#deja una copia del .config en /config

PATH=/bin:/sbin:$PATH
LENG=$LANG

OLD=`pwd`
CONFDIR=/config

#LOG=${OLD}/kernel.make.log
LOG=/dev/tty
UNAME=`uname -n`

if [ $# -gt 1 ]
then
  echo
  echo "Error:\n"
  echo "Uso: 	$0 [version]\n\n"
  exit 1
fi

if [ $# -eq 0 ]
then
  DIR=/usr/src/linux
else
  DIR=/usr/src/linux-$1
fi

export DOCS=$DIR/Documentation/DocBook/

export LANG=C

echo
echo "Enviando registro del proceso a $LOG"
echo

printf "Cambiando a $DIR..."
cd $DIR > $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

printf "make mrproper..."
cp .config /tmp >> $LOG 2>&1
make mrproper >> $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
cp /tmp/.config . >> $LOG 2>&1
make oldconfig 
echo OK

printf "make dep..."
make dep >> $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

printf "make clean..."
make clean >> $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

printf "make bzImage..."
make bzImage >> $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

printf "make modules..."
make modules >> $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

printf "make modules_install..."
make modules_install >> $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

printf "make install..."
make install >> $LOG 2>&1
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

#printf "make pdfdocs htmldocs psdocs ..."
#make pdfdocs  >> $LOG 2>&1
#make htmldocs >> $LOG 2>&1
#make psdocs   >> $LOG 2>&1
#echo "Documentos en $DOCS"

CONFIG=`basename $DIR`
AHORA=`date +"%F-%T"`
CONFIG=${CONFDIR}/${UNAME}-${AHORA}.config
printf "Salvando en:\n"
printf "  $CONFIG..."
cat <.config >$CONFIG
if [ $? -ne 0 ]
then
  echo ERROR:
  tail -20 $LOG
  exit 1
fi
echo OK

export LANG=$LENG

echo "SE RECOMIENDA REVISAR la configuracion de grub / lilo"

cd $OLD
