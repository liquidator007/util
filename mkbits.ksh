case $# in
  1) b=$1 ;;
  *) echo "Uso:\n\t$0 numero" 
     exit 1 ;;
esac
a=1
while [ $a != 0 ]
do
  ((c=b&a))
  ((a=a<<1))
  if [ $c -ne 0 ] ; then
    bitpattern=1$bitpattern
  else 
    bitpattern=0$bitpattern
  fi
done
echo $bitpattern
exit 0
