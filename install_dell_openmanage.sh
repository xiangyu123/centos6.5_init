#!/bin/bash
#author: xuzhigui
#email: xuzhigui1991@163.com
#os: centos6.5_x86_64
#server: dell R720

set -e

#check if the user is root
echo -e '\E[31;31m\n====== check if the user is root ======';tput sgr0
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

function install_dell_repo {
	echo -e '\E[31;31m\n====== install_dell_repo ======';tput sgr0
	wget -q -O - http://linux.dell.com/repo/hardware/Linux_Repository_14.12.00/bootstrap.cgi | bash
}

function install_dell_openmanager {
	echo -e '\E[31;31m\n====== install_dell_openmanager ======';tput sgr0
	yum install srvadmin-all -y
}

function copy_mibs {
	echo -e '\E[31;31m\n====== copy_mibs ======';tput sgr0
	for i in $(find /opt/dell/ -name \*.mib);do cp $i /usr/share/snmp/mibs/;done
}

function install_net_snmp {
	echo -e '\E[31;31m\n====== install_net_snmp ======';tput sgr0
	yum -y install net-snmp
}


function start_dell_openmanager {
	echo -e '\E[31;31m\n====== start_dell_openmanager ======';tput sgr0
	/opt/dell/srvadmin/sbin/srvadmin-services.sh start
	echo '/opt/dell/srvadmin/sbin/srvadmin-services.sh start' >> /etc/rc.d/rc.local
}

function config_snmp {
echo -e '\E[31;31m\n====== config_snmp ======';tput sgr0
cat > /etc/snmp/snmpd.conf <<EOF
com2sec notConfigUser 210.14.132.232    xeshaibian123
com2sec notConfigUser 192.168.12.0/24   xeshaibian123
com2sec notConfigUser 127.0.0.1         xeshaibian123
group   notConfigGroup v2c              notConfigUser
view    all           included   .1
view    systemview    included   .1.3.6.1.2.1.1
view    systemview    included   .1.3.6.1.2.1.25.1.1
access  notConfigGroup ""      any       noauth    exact  all    none   none
dontLogTCPWrappersConnects yes
smuxpeer .1.3.6.1.4.1.674.10892.1
mibs +MIB-Dell-10892:StorageManagement-MIB
EOF
	chkconfig snmpd on
	service snmpd restart
}

#install_dell_repo
install_dell_openmanager
install_net_snmp
copy_mibs
start_dell_openmanager
config_snmp
