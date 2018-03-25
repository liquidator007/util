MAKEDIR=~/mediatomb
VERSION=0.12.1
MTURL=http://downloads.sourceforge.net/project/mediatomb/MediaTomb/$VERSION/mediatomb-$VERSION.tar.gz

sudo apt-get --yes update

#se necesita:
#	mysql_config
#	expat
#	magic
#	ffmpegthumbnailer
#	libjs
#	libexif
#	liblastfm
#	libextractor
#	libid3
#	libmp4v2
#	libcurl
#	libtag

sudo apt-get --yes install \
	libmysqlclient-dev \
	libexpat1-dev \
	libmagic-dev \
	libffmpegthumbnailer-dev \
	libmozjs185-dev libjs-prototype \
	libexif-dev \
	liblastfm-dev \
	libextractor-dev \
	libid3tag0-dev libid3-3.8.3-dev \
	libmp4v2-dev \
	libcurl4-openssl-dev \
	libtag1-dev

mkdir -p $MAKEDIR
cd $MAKEDIR
wget $MTURL

#mediatomb 
tar zxvf `ls -1 mediatomb*.gz`
cd mediatomb-$VERSION
./configure \
	--with-mysql-cfg=/usr/bin/mysql_config \
	--enable-libextractor 

pwd
