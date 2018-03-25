#include <stdio.h>

int main(int argc, char *argv[])
{
  if (argc==2)
  {
    int num=atoi(argv[1]);
    int n, primo=1;
    for (n=2;n<=num/2 && primo;n++)
      if ( num%n==0) 
        primo=0;
    if (primo)
      printf("primo\n");
    else
      printf("divisible por %d\n",n-1);
    return 0;
  }
  else return 1;
}
