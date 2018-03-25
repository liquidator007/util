#include <stdio.h>
#include <stdlib.h>

int main(int argc, char argv[])
{
  int i;
  srand(100);
  for (i=0; i<10; i++)
	printf("%d\n",rand());
  return 0;
}
