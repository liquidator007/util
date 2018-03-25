#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
	char *p;
	if (argc!=3)
	{
	printf("Error:\n\t%s %s %s\n",argv[0],"<que>","<donde>");
	exit(1);
	}
	p=strstr(argv[2],argv[1]);
	return p==NULL? 1 : 0;
}
