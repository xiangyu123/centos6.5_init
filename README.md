# Centos_6.5_x86_64_init


### Overview
# 
&#8195;&#8195; **Centos_6.5_x86_64_init** , This script is written by xuzhigui and is to tunning for centos_6.5_x86_64 operation system after finish installing centos 6.5 on some server! If you have any good idea with this script, please contace me with email:com <xuzhigui1991@163.com> , This script which is used by __*System Administrator*__.

> <b>**Warning:**</b>
# 
&#8195;&#8195;You have to be noticed that this scripts is only tested on centos6.5_x86_64 ! And you must remember that exec all scripts you must use the root user !!

&#8195;&#8195;when after finish installing **centos 6.5**, the first step is to exec `initsystem.sh`, this script change some kernel parameters and change open-file descriptors for all user, flush iptables , disable <kbd> Ctrl+Alt+Delete </kbd> and etc.

&#8195;&#8195;when you want to install **nginx+mysql+php+redis+phpredis** system, just exec the second script `softinstall.sh` with root.

# 
### configure file  location

Let's see the location of the main applications:

> ### **nginx**
* <b>basedir:</b>
 + /usr/local/nginx_conf:x/
* <b>nginx_conf:</b>
 + /usr/local/nginx/conf/nginx.conf
 + /usr/local/nginx/conf/Configs/*.conf
* <b>logs:</b>
 + /usr/local/nginx/logs/
 + /usr/local/nginx/logs/logdata/
* <b>default_webdir:</b>
 + /usr/local/nginx/html
* <b>default_pages:</b>
 + index.php
* <b>start_nginx:</b>
 + service nginx start

> ### **php**
* <b>basedir:</b>
 + /usr/local/php
* <b>php.ini:</b>
 + /etc/php.ini
* <b>php-fpm.conf:</b>
 + /usr/local/php/etc/php-fpm.conf
* <b>start php-fpm:</b>
 + service php-fpm start

> ### **mysql**
* <b>basedir:</b>
 + /usr/local/mysql/
* <b>datadir:</b>
 + /data/mysql/
* <b>dafeult_engine:</b>
 + innodb
* <b>my.cnf:</b>
 + /etc/my.cnf
* <b>start_mysql:</b>
 + service mysqld start
