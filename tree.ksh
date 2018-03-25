#!/bin/bash
V='|'
H='_'
X='L'
Y='l'
S='.'

arbol()
{
  cd $1
  ULT[$3]=""
  for D in *  #busqueda del ultimo directorio 
  do
    if [ -d $D ]
    then
      ULT[$3]=$D
    fi
  done
  for D in *   
  do
   if [ -d $D ]   #es un directorio...
   then
     echo -n $2   #las lineas previas
     if [ ${ULT[$3]} = "$D" ]       #es el ultimo directorio
     then
       echo -n "$Y$H$H$H$D"
       if [ -r $D -a -x $D ]  #legible y accesible
       then
         echo
         arbol $D "$2$S$S$S$S" `expr $3 + 1`
       else
         echo "$H$H???"
       fi
     else
       echo -n "$X$H$H$H$D"
       if [ -r $D -a -x $D ]  #legible y accesible
       then
         echo
         arbol $D "$2$V$S$S$S" `expr $3 + 1`
       else
         echo "$H$H???"
       fi
     fi
   fi
  done
  cd .. 
}

if [ $# -gt 1 ]
then
  echo "Uso:\n\t$0 [ ruta ]"
  exit 1
fi
if [ $# -eq 0 ]
then
  DIR=`pwd`
else
  DIR=$1
fi
echo "$DIR:"
arbol $DIR "" 0
