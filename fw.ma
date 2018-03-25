#!/bin/sh
#Configuracion firewall

PATH=/sbin:/usr/local/sbin:$PATH
I=iptables

#Vaciado de cadenas
$I -t filter -F
$I -t nat -F
$I -t mangle -F
$I -X   #Borrado de las cadenas de usuario

#exit

######################################################################
# Información general
######################################################################

#Instituto: interfaces implicados y su direccion IP
#eth0: aula B25 : 172.20.225.103
#eth1: aula B21 : 172.20.221.103
#eth2: dmz      : 172.20.254.103
#eth3: Principal: 172.20.20.103 (enruta dpto, sanitaria, administrativo...)
#eth4: aula B22 : 172.20.222.0/24
#eth5: aula B24 : 172.20.222.0/24

#Casa
#eth0: internet  : 81.203.101.X (por DHCP, asi que algo parecido...)
#eth1: casa      : 172.20.20.0

######################################################################
# Parametros globales
######################################################################

EXT=eth0        #Interfaz externo (hacia el router)
LOC=lo          #Interfaz loopback
DEFAULT=DROP	#Politica por omision. Puede ser ACCEPT o DROP
#Maquinas o redes sin restricciones
ABIERTO="172.20.20.0/24"
PROXY_TRANSPARENTE_HTTP=	#3128
PROXY_TRANSPARENTE_FTP=		#3121
NAT=1		#Si =lo que sea, se activa MASQUERADE
DROPLOG=	#Registrar lo no aceptado?

######################################################################
# Puertos Permitidos
######################################################################

#Notas:
#	edonkey	: 4662/tcp y 4666/udp
#	news	: utilizan nntp y auth
#	vnc	: el servidor esta instalado en el puerto 8071
#	webmin	: el servidor esta instalado en el puerto 10000
#	msn	: 1863

#Puertos destino (TCP) accesibles desde el exterior a linux
#TCP_EXT_LIN="ssh smtp pop3 nntp auth netbios-ns netbios-dgm netbios-ssn imap imap3 smtps imaps pop3s 8081 10000 4662 1863 x11 xfs x11-ssh-offset"
TCP_EXT_LIN="auth 4661 4662 4666 1863 http"
#Puertos destino (UDP) accesibles desde el exterior a linux
UDP_EXT_LIN="auth 4661 4662 1863 4661 4662 4666 http"

#Puertos destino (TCP) accesibles desde el interior al exterior
TCP_INT_EXT="ssh nicname https pop3 smtp auth 8000"
#Puertos destino (UDP) accesibles desde el interior al exterior
UDP_INT_EXT="domain pop3 smtp auth"


#Politicas por defecto aconsejables
#$I -P INPUT ACCEPT
#$I -P FORWARD ACCEPT
#$I -P OUTPUT ACCEPT

$I -P INPUT $DEFAULT
$I -P FORWARD $DEFAULT
$I -P OUTPUT $DEFAULT

$I -t nat -P PREROUTING ACCEPT
$I -t nat -P POSTROUTING ACCEPT
$I -t nat -P OUTPUT ACCEPT

$I -t mangle -P PREROUTING ACCEPT
$I -t mangle -P OUTPUT ACCEPT

#Creacion de nuevas cadenas
$I -N int_lin	#del interior (red privada) a esta maquina linux
$I -N lin_int	#de esta maquina al interior
$I -N ext_lin	#del exterior (internet) a esta maquina
$I -N lin_ext	#de esta maquina al exterior
$I -N int_ext	#del interior al exterior
$I -N ext_int	#del exterior al interior
$I -N synflood	
$I -N pingdeath
$I -N portscan
$I -N newnotsyn
if [ $DROPLOG ]
then
  $I -N droplog
fi

######################################################################
# Reglas generales
######################################################################

#Destinos: ACCEPT, DROP, QUEUE, RETURN

if [ $NAT ]
then
  $I -t nat -A POSTROUTING -o $EXT -j MASQUERADE
fi

#Proxy transparente HTTP (squid)
if [ $PROXY_TRANSPARENTE_HTTP ]
then
  $I -t nat -A PREROUTING -p tcp --dport 80 \
	-j REDIRECT --to-port $PROXY_TRANSPARENTE_HTTP
fi

#Proxy transparente FTP (frox)
if [ $PROXY_TRANSPARENTE_FTP ]
then
  $I -t nat -A PREROUTING -p tcp --dport 21 \
	-j REDIRECT --to-port $PROXY_TRANSPARENTE_FTP
fi

#Aceptar en entrada (cualquiera) y reenvio (cualquiera) todo lo que se ha pedido
$I -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$I -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT


#
#Ataques DoS (unidades: /second, /minute, /hour o /day, o abreviaturas)
#

#anti inundacion syn (syn-flood)
$I -A INPUT -p tcp --tcp-flags SYN,RST,ACK SYN  -j synflood
$I -A synflood -m limit --limit 2/s --limit-burst 10 -j RETURN
$I -A synflood -j LOG --log-level info --log-prefix "iptables:synflood:"
$I -A synflood -j DROP

#anti ping de la muerte (ping of death)
$I -A INPUT -p icmp --icmp-type echo-request -j pingdeath
$I -A FORWARD -p icmp --icmp-type echo-request -j pingdeath

$I -A pingdeath	-m limit --limit 2/s --limit-burst 10 -j RETURN
$I -A pingdeath -j LOG --log-level info --log-prefix "iptables:pingdeath:"
$I -A pingdeath -j DROP

#anti busqueda furtiva de puertos (port scanner)
$I -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j portscan
$I -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j portscan

$I -A portscan -m limit --limit 2/s --limit-burst 10 -j RETURN
$I -A portscan -j LOG --log-level info --log-prefix "iptables:portscan:"
$I -A portscan -j DROP

#Controles MAC ADDR
#$I -A FORWARD -p tcp -m mac --mac-source 00:11:22:33:44:55 -j ACCEPT

#Descartar paquetes de inicio de sesion que no sean SYN, y registrar
$I -A INPUT -p tcp ! --syn -m state --state NEW -j newnotsyn
$I -A newnotsyn -j LOG --log-level info --log-prefix "iptables:Nuevo_no_syn:"
$I -A newnotsyn -j DROP
#$I -A newnotsyn -j RETURN

#Aceptar todo el trafico desde/hacia interfaz local
$I -A INPUT -i $LOC -j ACCEPT
$I -A OUTPUT -o $LOC -j ACCEPT

#Aceptar sistemas de trafico abierto
for IP in $ABIERTO
do
  $I -A INPUT -s $IP -j ACCEPT
  $I -A OUTPUT -d $IP -j ACCEPT
  $I -A FORWARD -s $IP -j ACCEPT
  $I -A FORWARD -d $IP -j ACCEPT
done

######################################################################
# Reglas de derivacion a las subcadenas
######################################################################

#Reenvios
$I -A FORWARD -i $EXT -j ext_int	#Forward desde el exterior
$I -A FORWARD -i ! $EXT -j int_ext	#Forward desde el interior

#Entradas
$I -A INPUT -i $EXT -j ext_lin		#Input desde el exterior
$I -A INPUT -i ! $EXT -j int_lin	#Input desde el interior

#Salidas
$I -A OUTPUT -o $EXT -j lin_ext		#Output al exterior
$I -A OUTPUT -o ! $EXT -j lin_int	#Output al interior

######################################################################
# Entradas desde el exterior
######################################################################

$I -A ext_lin -m state --state ESTABLISHED,RELATED -j ACCEPT
$I -A ext_int -p icmp -j ACCEPT 
$I -A ext_int -p tlsp -j ACCEPT 

for P in $TCP_EXT_LIN
do
  $I -A ext_lin -p TCP --dport $P -j ACCEPT
done

for P in $UDP_EXT_LIN
do
  $I -A ext_lin -p UDP --dport $P -j ACCEPT
done

######################################################################
# Entradas desde el interior
######################################################################

$I -A int_lin -j ACCEPT

######################################################################
# Salidas hacia el interior
######################################################################

$I -A lin_int -j ACCEPT

######################################################################
# Salidas hacia el exterior
######################################################################

$I -A lin_ext -j ACCEPT

######################################################################
# Reenvios del exterior al interior
######################################################################

$I -A ext_int -m state --state ESTABLISHED,RELATED -j ACCEPT
$I -A ext_int -p icmp -j ACCEPT 

######################################################################
# Reenvios del interior al exterior
######################################################################

$I -A int_ext -m state --state ESTABLISHED,RELATED -j ACCEPT
$I -A int_ext -p icmp -j ACCEPT
$I -A int_ext -p tlsp -j ACCEPT

for P in $TCP_INT_EXT
do
  $I -A int_ext -p TCP --dport $P -j ACCEPT
done

for P in $UDP_INT_EXT
do
  $I -A int_ext -p UDP --dport $P -j ACCEPT
done


######################################################################
# Reglas finales
######################################################################

if [ $DROPLOG ]
then
  $I -A INPUT -j droplog
  $I -A FORWARD -j droplog
  $I -A OUTPUT -j droplog
  $I -A droplog -j LOG --log-level info --log-prefix "iptables:no_aceptado:"
fi

######################################################################
# Otras Reglas
######################################################################

#$I -A fw_int -d 204.152.188.7 -j ACCEPT     #PRUEBAS
#$I -A fw_int -d 213.193.17.3 -j ACCEPT      #PRUEBAS
#$I -A fw_int -d 12.21.210.234 -j ACCEPT     #PRUEBAS
#$I -A fw_int -d www.samba.org -j ACCEPT     #PRUEBAS
#$I -A fw_int -d samba.sourceforge.net -j ACCEPT     #PRUEBAS
