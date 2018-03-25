#include <stdio.h>
#include <stdlib.h>

/* mcd(): Maximo comun divisor */

unsigned long mcd(unsigned long, unsigned long);
int main(int,char*[]);

unsigned long mcd(unsigned long a, unsigned long b)
{
  unsigned long resto;
  if (a<b)
  {  /* intercambio */
    unsigned long tmp=a;
    a=b;
    b=tmp;
  }
  if (!(resto=a%b))  /* resto es 0 */
    return b;  /* b es el mcd */
  else return mcd(b,resto);
}

int main(int argc, char *argv[])
{
  if (argc!=3)
  {
    fprintf(stderr,"Uso:\n\tmcd n1 n2\n");
    exit(1);
  }
  else
   printf("%lu\n",mcd(atol(argv[1]),atol(argv[2])));
  return 0;
}
