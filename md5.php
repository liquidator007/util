<?php

  // md5.php
  // Autor: Miguel Angel Ibañez
  // febrero-2005
  //
  // este modulo recibe como parametro una ruta a un fichero en el sistema de archivos, convierte dicha ruta
  // a una ruta absoluta en el servidor web, y si el fichero no se encuentra en la b.d. lo inserta con su md5

  $host="localhost";
  $bd="iescierva";

/*
  //acceso a los argumentos de la linea de comandos y carga en _REQUEST
  //echo "argv[] = ";
  //print_r($argv); 

  if ($argc > 0)
  {
    for ($i=1;$i < $argc;$i++)
    {
       parse_str($argv[$i],$tmp);
       $_REQUEST = array_merge($_REQUEST, $tmp);
    }
  }

  //echo "\$_REQUEST = ";
  //print_r($_REQUEST);

*/

#IMPORTANTE: las rutas que se introduzcan en la BD seran relativas a $document_root
  //$document_root=$_REQUEST['DocumentRoot'];
  $document_root=$argv[1];
  
  //echo "DocumentRoot=$document_root\n";
  $link=mysql_connect($host,"bibliotecario","239845")
	or die ("Error al conectarse al servidor MySQL en $host");

  mysql_select_db($bd)
	or die ("Error al abrir la B.D. $bd");

  @mysql_query("SET NAMES 'utf8'");

  //recuperar el nombre de fichero a controlar
  //$f=$_REQUEST['fichero'];
  $f=$argv[2];
  //$ff=addcslashes($f,"'()=\\&\"");
  $ff=addcslashes($f,"'\"");
  #echo "fichero=$ff\n";
  #printf(".");

  //dejar la ruta como absoluta de apache, no del sist. de fich
  $url=ereg_replace("^$document_root", "", $ff);

  //consultar si existe la ruta
  $sql="select md5sum from libros where ruta='$url'";
  $ret=mysql_query($sql);
  $num=mysql_num_rows($ret);
  mysql_free_result($ret);

  if ($num==0)	//la ruta no esta en la tabla
  {
    $md5=md5_file("$f");	//calcular md5
    //consultar si existe el md5
    $sql="select ruta from libros where md5sum='$md5'";
    $ret=mysql_query($sql);
    $num=mysql_num_rows($ret);
    $fila=mysql_fetch_array($ret,MYSQL_ASSOC);
    $old=$fila['ruta'];
    mysql_free_result($ret);
    if ($num==0)
    { //no existe, insertarlo
      $titulo=basename($ff);
      echo "insertando $url...\n";
      $sql="insert into libros (md5sum,ruta,privado,titulo,titulo_original) values ('$md5','$url',1,'$titulo','$titulo')";
      //echo "$sql\n";
      $ret=mysql_query($sql);
    }
    else
    { //existe, cambiar la ruta y borrar la otra copia
      if ( file_exists("$document_root$old") )
      {
        echo "enlazando $document_root$old -> $f...\n";
        @unlink("$f");
        link("$document_root$old",$f);
      }
      else
      {
        echo "Hay MD5s en la B.D. que no existen en la ruta especificada. ¡¡¡Haga limpieza!!!\n";
        exit(1);
      }
    }
  }
  mysql_close($link);

?>
