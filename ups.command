if [ $# -eq 0 ]
then
  echo
  upscmd -l ups1@localhost 
  printf "\n\nUso:\n\t$0 comando...\n\n\n"
  exit 1
fi

for C in $*
do 
  echo comando $C...
  upscmd -u admin -p secretillo123 ups1@localhost $C
done
