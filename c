if [ $# -ne 1 ]
then
  echo "Uso: $0 fuente"
  exit 1
fi
cc -o $1 $1.c
strip $1
