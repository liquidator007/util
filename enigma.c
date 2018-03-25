/*programa encriptador -ENIGMA- */
/*Basado en la idea expuesta en Investigación y Ciencia
  Diciembre/1988.
*/
//OJO: Se usa "item" (unsigned char) como unidad de caracter.
//Esto porque en DOS el tipo char no tiene signo, pero en Unix si,
//lo cual daba ENORMES problemas de portabilidad.

//#define DEBUG
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define START 0x1
#define END   0x2
#define NEXT  0x0

#define TAMARUEDA 256
#define MAXRUEDAS 256

typedef unsigned char item;
typedef struct _tipo_rueda
{
  item d[TAMARUEDA],i[TAMARUEDA];
  item p;
} tipo_rueda;

void rellena_rueda (int,tipo_rueda*,int);
void enigma_eng(item[],unsigned,item*,int,int);
void cryptfich(FILE *in, FILE *out, item key[]);
int n(int);

int main (int,char *[]);

tipo_rueda *t[MAXRUEDAS];
tipo_rueda r; /*reflector*/
tipo_rueda p; /*panel de conexiones*/

int n(int x)
{
  while (x<0) x+=TAMARUEDA;
  return x % TAMARUEDA;
}

void semilla(int n)
{
	srand(n);
}

int aleatorio(void)
{
	return rand();
}

void rellena_rueda (int numrueda,tipo_rueda *rueda,int reflector)
{
  item c;
  int i,a,b;
  if (TAMARUEDA%2)
  {
    fprintf(stderr,"enigma(): Código no par. No se crean ruedas");
    return;
  }
  rueda->p=0;
  semilla(numrueda);
  if (reflector)
  { /*Crear reflector. El reflector no usa codificación inversa*/
    int dst1,dst2;

    //cargar la rueda con los valores iniciales
    //cargar las n/2 primeras posiciones de la rueda con las n/2 últimas	
    for (i=0 ; i<TAMARUEDA/2 ; i++) rueda->d[i]=i+TAMARUEDA/2;
    //y viceversa
    for (i=TAMARUEDA/2 ; i<TAMARUEDA ; i++) rueda->d[i]=i-TAMARUEDA/2;
    //permutar un  puñado de veces las conexiones
    for (i=0; i<(unsigned long)(4*TAMARUEDA); i++)
    {
      a=n(aleatorio());	//a nº al azar entre 0 y TAMARUEDA-1
      b=n(aleatorio()); //b también
      if (rueda->d[a]==b || rueda->d[b]==a)
	continue; /* No se hace nada, porque es el mismo enlace */
      dst1=rueda->d[a]; dst2=rueda->d[b];
      rueda->d[a]=dst2; rueda->d[dst2]=a;  /*hacer nuevos enlaces*/
      rueda->d[b]=dst1; rueda->d[dst1]=b;
    }
#ifdef DEBUG
    printf("\nReflector(p=%d): ",rueda->p);
    for (i=0;i<TAMARUEDA; i++) printf("%d,",rueda->d[i]);
    printf("\n");
    // exit(1);
#endif
  }
  else
  { /*Crear rueda o panel de conexiones*/
    for (i=0 ; i<TAMARUEDA ; i++) rueda->d[i]=i;
    for (i=0; i<(unsigned long)(13*TAMARUEDA); i++)
    {
      a=n(aleatorio());
      b=n(aleatorio());
      c=rueda->d[a]; rueda->d[a]=rueda->d[b]; rueda->d[b]=c;
    }
    for (i=0;i<TAMARUEDA;i++)
      rueda->i[rueda->d[i]]=i;
#ifdef DEBUG
    printf("\nRueda(%d): D=",rueda->p);
    for (i=0;i<TAMARUEDA; i++) printf("%d,",rueda->d[i]);
    printf("\tRueda(%d): I=",rueda->p);
    for (i=0;i<TAMARUEDA; i++) printf("%d,",rueda->i[i]);
#endif
  }
}

void enigma_eng(item que[],unsigned cuantos,item *clave,int l,int flag)
{
  int jj;
  unsigned int i;
  int rueda;
  if (flag&START)
  {
    item cksumr,cksump;//usados para crear semillas al panel y reflec.
    /* Generar panel, ruedas y reflector, seg£n la clave usada */
    if (l>MAXRUEDAS)  /* Excedida long. de clave */
    {
      fprintf(stderr,"enigma(): Longitud de clave excedida!");
      exit(1);
    }
    cksumr=cksump=0;
    for (i=0; i<l; i++)	//para cada letra de la clave
    {
      cksumr+=clave[i]; //computar semilla para crear reflector
      cksump^=clave[i]; //computar semilla para crear panel
      if (!(t[i]=malloc(sizeof(tipo_rueda))))  //ubicar rueda en mecanismo
      {
	fprintf(stderr,"enigma(): Memoria Agotada!");
	exit(1);
      }
      rellena_rueda(clave[i]*i,t[i],0);
    }
    rellena_rueda(cksump,&p,0);
    rellena_rueda(cksumr,&r,1);
#ifdef DEBUG
    printf("Ruedas cargadas");
#endif
  }
#define D (t[rueda]->d)
#define I (t[rueda]->i)
#define P (t[rueda]->p)
  for (i=0; i<cuantos; i++)
  {  /* Para cada caracter a codificar... */
    item c;
    c=p.d[que[i]];  /* Codificado por el panel */
    for (rueda=0; rueda<l; rueda++)
    {
      /* para cada rueda hacia adelante...*/
      jj=n(c+P);
      //fprintf(stderr,"jj=%d,rueda=%d/%d",jj,rueda,l);
      c=n(D[jj=n(c+P)]-P+TAMARUEDA);
    }

    c=r.d[c]; //rebotando en el reflector...

    for (rueda=l-1; rueda>=0; rueda--)
    {
      /* para cada rueda hacia atrás...*/
      jj=n(c+P);
      //fprintf(stderr,"jj=%d,rueda=%d",jj,rueda);
      c=n(I[jj=n(c+P)]-P+TAMARUEDA);
    }
    que[i]=p.i[c];  /* Codificado por el panel y guardado*/

    /*Ajustar rotores a nueva posición */
    rueda=l-1; //Ajustar la última rueda primero
    do 
    {
      P=n(P+1);
      //fprintf(stderr,"R%d=%d,",rueda,P);
      if (P==0 && rueda==0) break;
      if (P!=0) break;
      rueda--;
    } while (1);
  }
  if (flag&END)
  {
    for (i=0; i<l; i++)
      free(t[i]);
  }
  //fprintf(stderr,"me voy,",rueda,P);
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

#ifdef MACHOTU
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
    fprintf(stderr,"Uso: enigma <clave>\n");
    exit(2);
  }
  cryptfich(stdin,stdout,argv[1]);
  return 0;
}
