/*

ENIGMA ciphering machine 
Basado en la idea expuesta en Investigación y Ciencia
Based on Investigacion y Ciencia Dec/1988
(spanish edition of Scientific American)

Author:
  Miguel Angel Ibanez Mompean

NOTES:
* "item" (unsigned char) is the "char" unit here (because "char" is signed on *ix systems
* Wheel size (WHEEL_SIZE) and number of wheels (MAX_WHEELS) parameters can be changed, but encrpyted files WON'T decrypt
* this program uses pseudo-random numbers. The seed is always the number of wheels.
  If you modify this number, a completely different set of wheels will be used.

usage:
  enigma key : crypts and decrypts

example:
  ls -l | enigma u672 | enigma u672   #unscrambled output

*/

//#define DEBUG
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define START 0x1
#define END   0x2
#define NEXT  0x0

#define WHEEL_SIZE 256
#define MAX_WHEELS 256

typedef unsigned char item;
typedef struct _wheel_type
{
  item d[WHEEL_SIZE],i[WHEEL_SIZE];
  item p;
} wheel_type;

void fill_wheel (int,wheel_type*,int);
void enigma_eng(item[],unsigned,item*,int,int);
void cryptfich(FILE *in, FILE *out, item key[]);
int n(int);

int main (int,char *[]);

wheel_type *t[MAX_WHEELS];
wheel_type r; /*reflector*/
wheel_type p; /*panel de conexiones*/

int n(int x)
{
  while (x<0) x+=WHEEL_SIZE;
  return x % WHEEL_SIZE;
}

void semilla(int n)
{
	srand(n);
}

int randomnumber(void)
{
	return rand();
}

void fill_wheel (int numwheel,wheel_type *wheel,int reflector)
{
  item c;
  int i,a,b;
  if (WHEEL_SIZE%2)
  {
    fprintf(stderr,"enigma(): Código no par. No se crean wheels");
    return;
  }
  wheel->p=0;
  semilla(numwheel);
  if (reflector)
  { /*Crear reflector. El reflector no usa codificación inversa*/
    int dst1,dst2;

    //cargar la wheel con los valores iniciales
    //cargar las n/2 primeras posiciones de la wheel con las n/2 últimas	
    for (i=0 ; i<WHEEL_SIZE/2 ; i++) wheel->d[i]=i+WHEEL_SIZE/2;
    //y viceversa
    for (i=WHEEL_SIZE/2 ; i<WHEEL_SIZE ; i++) wheel->d[i]=i-WHEEL_SIZE/2;
    //permutar un  puñado de veces las conexiones
    for (i=0; i<(unsigned long)(4*WHEEL_SIZE); i++)
    {
      a=n(randomnumber());	//a nº al azar entre 0 y WHEEL_SIZE-1
      b=n(randomnumber()); //b también
      if (wheel->d[a]==b || wheel->d[b]==a)
	continue; /* No se hace nada, porque es el mismo enlace */
      dst1=wheel->d[a]; dst2=wheel->d[b];
      wheel->d[a]=dst2; wheel->d[dst2]=a;  /*hacer nuevos enlaces*/
      wheel->d[b]=dst1; wheel->d[dst1]=b;
    }
#ifdef DEBUG
    printf("\nReflector(p=%d): ",wheel->p);
    for (i=0;i<WHEEL_SIZE; i++) printf("%d,",wheel->d[i]);
    printf("\n");
    // exit(1);
#endif
  }
  else
  { /*Crear wheel o panel de conexiones*/
    for (i=0 ; i<WHEEL_SIZE ; i++) wheel->d[i]=i;
    for (i=0; i<(unsigned long)(13*WHEEL_SIZE); i++)
    {
      a=n(randomnumber());
      b=n(randomnumber());
      c=wheel->d[a]; wheel->d[a]=wheel->d[b]; wheel->d[b]=c;
    }
    for (i=0;i<WHEEL_SIZE;i++)
      wheel->i[wheel->d[i]]=i;
#ifdef DEBUG
    printf("\nWheel(%d): D=",wheel->p);
    for (i=0;i<WHEEL_SIZE; i++) printf("%d,",wheel->d[i]);
    printf("\tWheel(%d): I=",wheel->p);
    for (i=0;i<WHEEL_SIZE; i++) printf("%d,",wheel->i[i]);
#endif
  }
}

void enigma_eng(item what[],unsigned howmany,item *key,int l,int flag)
{
  int jj;
  unsigned int i;
  int wheel;
  if (flag&START)
  {
    item cksumr,cksump;//usados para crear semillas al panel y reflec.
    /* Generar panel, wheels y reflector, seg£n la key usada */
    if (l>MAX_WHEELS)  /* Excedida long. de key */
    {
      fprintf(stderr,"enigma(): Longitud de key excedida!");
      exit(1);
    }
    cksumr=cksump=0;
    for (i=0; i<l; i++)	//para cada letra de la key
    {
      cksumr+=key[i]; //computar semilla para crear reflector
      cksump^=key[i]; //computar semilla para crear panel
      if (!(t[i]=malloc(sizeof(wheel_type))))  //ubicar wheel en mecanismo
      {
	fprintf(stderr,"enigma(): Memoria Agotada!");
	exit(1);
      }
      fill_wheel(key[i]*i,t[i],0);
    }
    fill_wheel(cksump,&p,0);
    fill_wheel(cksumr,&r,1);
#ifdef DEBUG
    printf("Wheels are loaded at this point");
#endif
  }
#define D (t[wheel]->d)
#define I (t[wheel]->i)
#define P (t[wheel]->p)
  for (i=0; i<howmany; i++)
  {  /* Para cada caracter a codificar... */
    item c;
    c=p.d[what[i]];  /* Codificado por el panel */
    for (wheel=0; wheel<l; wheel++)
    {
      /* para cada wheel hacia adelante...*/
      jj=n(c+P);
      //fprintf(stderr,"jj=%d,wheel=%d/%d",jj,wheel,l);
      c=n(D[jj=n(c+P)]-P+WHEEL_SIZE);
    }

    c=r.d[c]; //rebotando en el reflector...

    for (wheel=l-1; wheel>=0; wheel--)
    {
      /* para cada wheel hacia atrás...*/
      jj=n(c+P);
      //fprintf(stderr,"jj=%d,wheel=%d",jj,wheel);
      c=n(I[jj=n(c+P)]-P+WHEEL_SIZE);
    }
    what[i]=p.i[c];  /* Codificado por el panel y guardado*/

    /*Ajustar rotores a nueva posición */
    wheel=l-1; //Ajustar la última wheel primero
    do 
    {
      P=n(P+1);
      //fprintf(stderr,"R%d=%d,",wheel,P);
      if (P==0 && wheel==0) break;
      if (P!=0) break;
      wheel--;
    } while (1);
  }
  if (flag&END)
  {
    for (i=0; i<l; i++)
      free(t[i]);
  }
  //fprintf(stderr,"me voy,",wheel,P);
}

void cryptfich(FILE *in, FILE *out, item key[])
{
  item x[256];
  int f=START,nitems;
  int l=strlen(key);
  while (!feof(in))  /* Mientras no fin de fichero */
  {
    memset(&x,0,sizeof(x));
    nitems=fread(&x,1,sizeof(x),in);
//    printf("ni=%d\n",nitems);
    if (nitems>0)
    {
      enigma_eng(x,nitems,key,l,f);
      fwrite(&x,nitems,1,out);
      f=NEXT;
    }
  }
}

#ifdef TESTING
void cryptfich(FILE *in, FILE *out, item key[])
{
  item x[]="Probando este mensaje a ver si se cuelga";
  int l=strlen(x);
  char *c;
  int q,f=START;
  enigma_eng(x,l,c="hola que tal estamos",strlen(c),f);
  printf("(%s)\n",x);
  enigma_eng(x,l,c,f);
  printf("(%s)\n",x);
}
#endif

int main(int argc, char *argv[])
{
  char op;
  if (argc!=2)
  {
    fprintf(stderr,"Usage: enigma <key>\n");
    exit(2);
  }
  cryptfich(stdin,stdout,argv[1]);
  return 0;
}
