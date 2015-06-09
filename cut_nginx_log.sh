#!/bin/bash
logs_path="/usr/local/nginx/logs/"
pid_path="/usr/local/nginx/logs/nginx.pid"
logdata_dir="/usr/local/nginx/logs/logdata"

if [ ! -d "$logdata_dir" ];then
    mkdir -p $logdata
fi

cd ${logs_path}
for i in $(ls *.log);
do
	mv $i logdata/$i.$(date -d "yesterday" +"%Y%m%d")
	cd logdata
	gzip $i.$(date -d "yesterday" +"%Y%m%d")
	cd ..
done

kill -USR1 `cat ${pid_path}`
find $logs_path/logdata/ -mtime +7 -type f | xargs /bin/rm -f
