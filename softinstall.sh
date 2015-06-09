#!/bin/bash
#author: xuzhigui
#version: v1.0
#email: xuzhigui1991@163.com

set -e

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)

#define variables
SOFTDIR='/tmp/softenv'
CURDIR=$(cd "$(dirname "$0")"; pwd)

#check if the user is root
echo -e '\E[31;31m\n====== check if the user is root ======';tput sgr0
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

#begin master process to install
mkdir -p $SOFTDIR

function install_nginx {
	#change to software dir
	cd $SOFTDIR

	#prepare for installing nginx
	echo -e '\E[31;31m\n====== prepare for installing nginx ======';tput sgr0
	yum -y install pcre.x86_64 pcre-devel.x86_64
	yum -y install zlib.x86_64 zlib-devel.x86_64
	yum -y install gd.x86_64 gd-devel.x86_64
	yum -y install openssl*

	#adding www user
#	echo -e '\E[31;31m\n====== checking if user www exist and add ======';tput sgr0
#	if [ $(id www | wc -l) == '0' ];then
#		/usr/sbin/useradd -M www
#	fi
	
	echo -e '\E[31;31m\n====== checking if nginx tar file exist and download ======';tput sgr0
	if [ ! -e "nginx-1.6.0.tar.gz" ];then
		wget -c http://nginx.org/download/nginx-1.6.0.tar.gz
	fi

	/bin/rm -rf nginx-1.6.0 && tar xf nginx-1.6.0.tar.gz

	echo -e '\E[31;31m\n====== downloading nginx rtmp module and ngx_pagespeed module ======';tput sgr0
	cd nginx-1.6.0 && git clone https://git.oschina.net/xiangyu123/nginx-rtmp-module.git

	#installing nginx
	echo -e '\E[31;31m\n====== compiling nginx with rtmp module and ngx_pagespeed and install ======';tput sgr0
	./configure  --prefix=/usr/local/nginx --add-module=./nginx-rtmp-module/  --with-http_flv_module --with-http_mp4_module --with-http_realip_module --with-http_sub_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_stub_status_module --with-pcre  --with-http_addition_module --with-http_ssl_module --with-http_realip_module --with-pcre --with-http_addition_module --with-http_image_filter_module --with-debug && make && make install
	
	echo '<?php phpinfo(); ?>' > /usr/local/nginx/html/index.php
	chown -R nobody.nobody /usr/local/nginx/html/

        if [ ! -d "/usr/local/nginx/cache" ];then
                mkdir -p /usr/local/nginx/cache
        fi

	/bin/rm -rf /etc/sysconfig/nginx && cp $CURDIR/nginx.sysconfig /etc/sysconfig/nginx
	/bin/rm -rf /etc/init.d/nginx
	cp $CURDIR/nginx.service /etc/init.d/nginx
        chmod 755 /etc/init.d/nginx && chkconfig --add nginx && chkconfig nginx on 
}

function install_epel {
        #installing epel yum repo
        echo -e '\E[31;31m\n====== installing epel yum repo ======';tput sgr0
	set +e
        rpm -ivh http://mirrors.ustc.edu.cn/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
	yum clean all
	yum makecache
	set -e
}

function install_imagick_module {
        cp $CURDIR/ImageMagick.tar.gz $SOFTDIR/
        cp $CURDIR/jpegsrc.v9.tar.gz  $SOFTDIR/
        cp $CURDIR/imagick-3.1.0RC1.tgz $SOFTDIR/

        echo -e '\E[31;31m\n====== compiling jpeg9 and install ======';tput sgr0
        cd $SOFTDIR && tar xf jpegsrc.v9.tar.gz && cd jpeg-9
        ./configure && make libdir=/usr/lib64 && make libdir=/usr/lib64 install

        echo -e '\E[31;31m\n====== compiling imagick and install ======';tput sgr0
        cd $SOFTDIR && tar xf ImageMagick.tar.gz && cd ImageMagick-6.9.0-4
        ./configure && make && make install
        ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick

        echo -e '\E[31;31m\n====== compiling imagick module and install ======';tput sgr0
        cd $SOFTDIR && tar xf imagick-3.1.0RC1.tgz && cd imagick-3.1.0RC1
        /usr/local/php/bin/phpize
        ./configure --with-php-config=/usr/local/php/bin/php-config && make && make install
}

function install_sphinx_module {
        cp $CURDIR/coreseek-3.2.14.tar.gz $SOFTDIR/
        cp $CURDIR/sphinx-1.2.0.tgz  $SOFTDIR/

        echo -e '\E[31;31m\n====== compiling coreseek and install ======';tput sgr0
        cd $SOFTDIR && tar xf coreseek-3.2.14.tar.gz && cd coreseek-3.2.14/csft-3.2.14/api/libsphinxclient/
        ./configure --prefix=/usr/local/sphinxclient && make && make install

        echo -e '\E[31;31m\n====== compiling coreseek and install ======';tput sgr0
        cd $SOFTDIR && tar xf sphinx-1.2.0.tgz && cd sphinx-1.2.0
        /usr/local/php/bin/phpize
        ./configure --with-php-config=/usr/local/php/bin/php-config --with-sphinx=/usr/local/sphinxclient && make && make install
}

function install_php5 {
	#change to software dir
	cd $SOFTDIR

	#prepare for installing php5
	echo -e '\E[31;31m\n====== prepare for installing php5 ======';tput sgr0
	yum -y install libxml2* openssl* libjpeg* libpng*  zlib* libcurl*  freetype*

	#exec install_epel function
#	install_epel

	#installing libmcrypt 
	yum -y install libmcrypt-devel.x86_64 libmcrypt.x86_64
	
	#adding www user
	echo -e '\E[31;31m\n====== checking if user www exist and add ======';tput sgr0
	if [ $(id www | wc -l) == '0' ];then
		/usr/sbin/useradd -M www
	fi
	
	echo -e '\E[31;31m\n====== checking if php5 tar file exist and download ======';tput sgr0
	if [ ! -e "php-5.5.14.tar.gz" ];then
		wget -c http://cn2.php.net/distributions/php-5.5.14.tar.gz
	fi

	/bin/rm -rf php-5.5.14 && tar xf php-5.5.14.tar.gz && cd php-5.5.14

	#compiling php5 and install
	echo -e '\E[31;31m\n====== compiling php5 and install ======';tput sgr0
	./configure --prefix=/usr/local/php --with-config-file-path=/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath  --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl  --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt=/usr/local/libmcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets  --with-xmlrpc --enable-zip --enable-soap --without-pear --with-zlib --enable-pdo --with-pdo-mysql --with-mysql  --enable-opcache && make && make install

}

function config_php_start_nginx_php {
        #change to software dir
        cd $SOFTDIR

        #build conf and add chkconfig
        echo -e '\E[31;31m\n====== build conf and add chkconfig ======';tput sgr0
        cp $CURDIR/php.ini /etc/php.ini
        mkdir -p /usr/local/php/log
        touch /usr/local/php/log/www.log.slow
        chmod 777 /usr/local/php/log/www.log.slow
        cp $CURDIR/php-fpm.service /etc/init.d/php-fpm && chmod 755 /etc/init.d/php-fpm
        chmod 755 /etc/init.d/php-fpm && chkconfig --add php-fpm && chkconfig php-fpm on
        cp $CURDIR/php-fpm.conf /usr/local/php/etc/php-fpm.conf
        cp $CURDIR/fpm.d.tar.gz /usr/local/php/etc/ && cd /usr/local/php/etc/ && tar xf fpm.d.tar.gz && rm -rf fpm.d.tar.gz
        cp $CURDIR/nginx_php.conf /usr/local/nginx/conf/nginx.conf
        IP=$(ifconfig em1| grep 'inet addr' | awk -F '.' '{print $4}' | awk '{print $1}')
        sed -i -e s/Web30/Web$IP/g /usr/local/nginx/conf/nginx.conf
        cp $CURDIR/Configs.tar.gz /usr/local/nginx/conf/ && cd /usr/local/nginx/conf/ && tar xf Configs.tar.gz && rm -rf Configs.tar.gz
        cp $CURDIR/cut_nginx_log.sh /usr/local/bin/
        echo '00 00 * * * /usr/local/bin/cut_nginx_log.sh' >> /var/spool/cron/root
        service crond restart

        #starting php-fpm
        echo -e '\E[31;31m\n====== starting php-fpm ======';tput sgr0
        service php-fpm start || service php-fpm restart

        #starting nginx web server
        echo -e '\E[31;31m\n====== starting nginx web server ======';tput sgr0
        service nginx start || /usr/local/nginx/sbin/nginx
}

function install_mysqld {
	#change to software dir
	cd $SOFTDIR

	#prepare for installing nginx
	echo -e '\E[31;31m\n====== prepare for installing mysqld ======';tput sgr0
	yum -y install cmake.x86_64 ncurses.x86_64 ncurses-devel.x86_64

	#adding mysql user
	echo -e '\E[31;31m\n====== checking if user mysql exist and add user ======';tput sgr0
	if [ $(id mysql | wc -l) == '0' ];then
		/usr/sbin/useradd -M mysql
	fi
	
	#check if "data/mysql" exist
	echo -e '\E[31;31m\n====== checking if /data/mysql exist and create directory ======';tput sgr0
	if [ ! -d "/data/mysql" ];then
			mkdir -p /data/mysql
	fi

	chown -R mysql.mysql /data/mysql

	#check if mysqld tar file exist and download 
	echo -e '\E[31;31m\n====== checking if mysqld tar file exist and download ======';tput sgr0
	if [ ! -e "mysql-5.6.19.tar.gz" ];then
		wget -c http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.19.tar.gz
	fi

	/bin/rm -rf mysql-5.6.19 && tar xf mysql-5.6.19.tar.gz && cd mysql-5.6.19
	
	#compiling mysqld and install
	echo -e '\E[31;31m\n====== compiling mysqld and install ======';tput sgr0
	/usr/bin/cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql -DSYSCONFDIR=/etc && make && make install

	#build conf and add chkconfig
	echo -e '\E[31;31m\n====== build conf and add chkconfig ======';tput sgr0
	cp support-files/mysql.server /etc/init.d/mysqld
	chmod 755 /etc/init.d/mysqld && chkconfig --add mysqld && chkconfig mysqld on
	cp $CURDIR/my.cnf /etc/my.cnf
	
	#init mysql database
	echo -e '\E[31;31m\n====== init mysql to /data/mysql ======';tput sgr0
	/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/data/mysql --basedir=/usr/local/mysql/
	
	#check if /etc/ld.so.conf.d/mysql exist
	if [ ! -e '/etc/ld.so.conf.d/mysql.conf' ];then
		echo '/usr/local/mysql/lib' > /etc/ld.so.conf.d/mysql.conf && ldconfig
	fi

}

function install_phpredis {
	#change to software dir
	cd $SOFTDIR

	#check if phpredis exists and download
	echo -e '\E[31;31m\n====== check if phpredis exist and download ======';tput sgr0
	if [  -e "phpredis" ];then
		rm -rf phpredis
	fi
	
	echo -e '\E[31;31m\n====== downloading phpredis ======';tput sgr0
	git clone https://github.com/owlient/phpredis
	cd phpredis && /usr/local/php/bin/phpize
	
	#compiling phpredis extension
	echo -e '\E[31;31m\n====== compiling and install phpredis ======';tput sgr0
	./configure --with-php-config=/usr/local/php/bin/php-config --enable-redis && make && make install
}

function install_nodejs {
	#change to software dir
	cd $SOFTDIR

	#installing nodejs and npm
	echo -e '\E[31;31m\n====== installing nodejs and npm ======';tput sgr0
	yum -y install nodejs.x86_64 nodejs-devel.x86_64 npm.noarch

	#installing pomelo freamwork
	echo -e '\E[31;31m\n====== installing pomelo freamwork ======';tput sgr0
	npm install pomelo -g

	#installing pomelo freamwork
	echo -e '\E[31;31m\n====== installing nodejs forever ======';tput sgr0
	npm install forever -g
}

function install_redis_server {
	#change to software dir
	cd $SOFTDIR

	#check if redis_server packages exist and download 
	echo -e '\E[31;31m\n====== check if redis_server packages exist and download ======';tput sgr0
	if [ ! -e "redis-2.8.17.tar.gz" ];then
		wget -c http://download.redis.io/releases/redis-2.8.17.tar.gz
	fi
	
	/bin/rm -rf redis-2.8.17 && tar xf redis-2.8.17.tar.gz && cd redis-2.8.17
	
	#compiling redis server and install
	echo -e '\E[31;31m\n====== compiling redis server but not install ======';tput sgr0
	make && make install

	cd utils
	sed -i 's/read -p/#read -p/g' install_server.sh 
	sed -i 's/read  -p/#read -p/g' install_server.sh 
	sed -i 's/redis_${REDIS_PORT}/redis/g' install_server.sh
	sed -i 's/redis_$REDIS_PORT/redis/g' install_server.sh

	#installing redis server on production system
	echo -e '\E[31;31m\n====== installing redis default 6379 server ======';tput sgr0
	./install_server.sh
	sed -i 's/511/2048/g' /etc/redis/6379.conf
	#service redis restart

	cp $SCRIPTPATH/redis_6379  /etc/init.d/
	cp $SCRIPTPATH/redis_6380  /etc/init.d/
	chkconfig --add redis_6379
	chkconfig --add redis_6380
	chkconfig redis_6379 on
	chkconfig redis_6380 on
	service redis_6379 restart
	
	#configure 6380 server
	echo -e '\E[31;31m\n====== configure redis 6380 server ======';tput sgr0
	if [ ! -f "/etc/redis/6380.conf" ];then
		cp /etc/redis/6379.conf  /etc/redis/6380.conf
		echo 'requirepass haibian1qazxsw2' >> /etc/redis/6380.conf
		echo 'masterauth  haibian1qazxsw2' >> /etc/redis/6380.conf
	fi

	#check if dir /var/lib/redis/6380 and create
	echo -e '\E[31;31m\n====== make sure the dir /var/lib/redis/6380 exist ======';tput sgr0
	if [ ! -d "/var/lib/redis/6380" ];then
		mkdir -p /var/lib/redis/6380
	fi

	#configure the file /etc/redis/6380.conf
	echo -e '\E[31;31m\n====== configure the file /etc/redis/6380.conf ======';tput sgr0
	sed -i 's/redis.pid/redis_6380.pid/g' /etc/redis/6380.conf
	sed -i 's/port 6379/port 6380/g' /etc/redis/6380.conf
	sed -i 's/511/2048/g' /etc/redis/6380.conf 
	sed -i 's/redis.log/redis_6380.log/g' /etc/redis/6380.conf
	sed -i 's#redis/6379#redis/6380#g'  /etc/redis/6380.conf

	#start 6380 redis server
	echo -e '\E[31;31m\n====== starting redis 6380 server ======';tput sgr0
#	/usr/local/bin/redis-server /etc/redis/6380.conf

	service redis_6380 start

	#check the server port
	echo -e '\E[31;31m\n====== check the server port ======';tput sgr0
	netstat -antup | grep redis
}

install_nginx
install_mysqld
install_php5
install_imagick_module
install_sphinx_module
install_phpredis
install_redis_server
install_nodejs
config_php_start_nginx_php

echo -e '\E[31;31m\n====== Congratulations!! All have finished !! ======';tput sgr0
