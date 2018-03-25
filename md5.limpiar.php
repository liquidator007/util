#!/usr/bin/php

<?php

  // md5.limpiar.php
  // Autor: Miguel Angel Ibañez
  // dic-2008
  //
  // este modulo recibe como parametro una ruta a DocumentRoot
  // luego recorre la tabla de libros eliminando las entradas cuya ruta a ficheros no sea válida

  $host="localhost";
  $bd="iescierva";

  $document_root=$argv[1];

  if ($argc!=2)
  {
    printf("\n\nUso:\n\t${argv[0]} DocumentRoot\n\n");
    exit(1);
  }
  
  echo "DocumentRoot=$document_root\n";
  $link=mysql_connect($host,"bibliotecario","239845")
	or die ("Error al conectarse al servidor MySQL en $host");
  #printf("Link=$link\n");

  mysql_select_db($bd)
	or die ("Error al abrir la B.D. $bd");

  $ret=mysql_query("SET NAMES 'utf8'");
  #printf("Query=$ret\n");

  //consultar si existe la ruta
  $sql="select md5sum,ruta from libros order by ruta";
  $ret=mysql_query($sql);
  #printf("Query=$ret\n");

  while ($fila=mysql_fetch_array($ret,MYSQL_ASSOC) )
  {
     //ver si existe la ruta, si no es así borrar entrada de la tabla por su md5
     $f=$document_root."/".$fila['ruta'];
     #printf("\r$f...");
     if ( ! file_exists( $f) )
     {
       $md5=$fila['md5sum'];
       $sql="delete from libros where md5sum='$md5';";
       printf("Ejecutando $sql...(".$fila['ruta'].")\n");
       $borrado=mysql_query($sql);
     }
  }
  mysql_free_result($ret);
  mysql_close($link);

?>
