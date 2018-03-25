#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
  if (argc !=3 )
  {
     fprintf(stderr,"\nUso:\n\t%s min_int max_int\n\n",argv[0]);
     exit(1);
  }
  else {
  char buf[256];
  unsigned long min=strtoul(argv[1],NULL,0);
  unsigned long max=strtoul(argv[2],NULL,0);
  srand(time(0));
  unsigned long r=min+rand()%(max-min+1);
  sprintf(buf,"%lu",r);
  printf("%s (%d)\n",(char*)buf,strlen((char*)buf));
  }
}
