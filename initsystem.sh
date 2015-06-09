#!/bin/bash
#author: xuzhigui
#version: v1.0
#for Centos6.5

set -e
#check if the user is root
echo -e '\E[31;31m\n====== check if the user is root ======';tput sgr0
if [ $(id -u) != '0' ]; then
    echo 'Error: You must be root to run this script, please use root to install lnmp'
    exit 1
fi

#install ntpdate
echo -e '\E[31;31m\n====== installing ntpdate package ======';tput sgr0
yum install ntpdate.x86_64 -y

#sync datetime from server and write to bios
echo -e '\E[31;31m\n====== sync datetime from server ======';tput sgr0
if [ $(date +%z) == '+0800' ];then
	ntpdate 202.65.114.202 && hwclock -w && hwclock --systohc
else
	/bin/rm -rf /etc/localtime
	/bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	/usr/sbin/ntpdate 202.65.114.202 && hwclock -w && hwclock --systohc
fi

#add root cron job to sync datetime from server every 5m
echo -e '\E[31;31m\n====== adding cron job for root to sync datetime ======';tput sgr0
echo '*/5 * * * * /usr/sbin/ntpdate 202.65.114.202 >/dev/null 2 >&1' >>  /var/spool/cron/root

#restart crond
echo -e '\E[31;31m\n====== restart crond ======';tput sgr0
service crond restart

#list cron
echo -e '\E[31;31m\n====== list cron job for root =======';tput sgr0
/usr/bin/crontab -l | grep ntpdate 

#disable selinux
echo -e '\E[31;31m\n====== disable selinux ======';tput sgr0
/usr/sbin/setenforce 0
/bin/sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#flush iptables
echo -e '\E[31;31m\n====== flush and disable iptables ======';tput sgr0
/sbin/iptables -F
/sbin/iptables -t nat -F
service iptables save

#adding user U:xuzhigui P:xiangyu2014xes and add sudo with no password
echo -e '\E[31;31m\n====== adding user xuzhigui ======';tput sgr0
/usr/sbin/useradd xuzhigui
echo 'xiangyu2014xes' | passwd xuzhigui --stdin
/bin/sed -i '/xuzhigui/d' /etc/sudoers
echo 'xuzhigui ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

#adding user U:xiaoming P:xiaoming123 and add sudo with no password
echo -e '\E[31;31m\n====== adding user xiaoming ======';tput sgr0
/usr/sbin/useradd xiaoming
echo 'xiaoming0049' | passwd xiaoming --stdin
/bin/sed -i '/xiaoming/d' /etc/sudoers
echo 'xiaoming ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

#change root password
echo -e '\E[31;31m\n====== changing root password ======';tput sgr0
echo 'xiangyu1991' | passwd root --stdin

#tunning sshd port and disable DNS and not permit root login
echo -e '\E[31;31m\n====== tunning sshd ======';tput sgr0
/bin/sed -i 's/#Port 22/Port 12315/g' /etc/ssh/sshd_config
/bin/sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
/bin/sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
/bin/sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g'  /etc/ssh/sshd_config

#restart sshd
echo -e '\E[31;31m\n====== restarting sshd ======';tput sgr0
service sshd restart

#tunning service 
echo -e '\E[31;31m\n====== tunning service ======';tput sgr0
for sun in `chkconfig --list|grep on|awk '{print $1}'`;do chkconfig  $sun off;done
for sun in lvm2-monitor cpuspeed crond rsyslog sshd network;do chkconfig $sun on;done

#tunning limits.conf
echo -e '\E[31;31m\n====== tunning limits.conf ======';tput sgr0
cat >> /etc/security/limits.conf << EOF
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF

#tunning sysctl.conf
echo -e '\E[31;31m\n====== tunning sysctl.conf ======';tput sgr0
mv /etc/sysctl.conf /etc/sysctl.conf.bak
cat >> /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 2
vm.swappiness = 30
net.ipv4.conf.lo.arp_announce=2
net.core.somaxconn = 65536
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.core.rmem_max = 167772160
net.core.wmem_max = 167772160
net.ipv4.tcp_rmem = 16777216 16777216 16777216
net.ipv4.tcp_wmem = 16777216 16777216 16777216
net.ipv4.tcp_sack = 0
net.ipv4.tcp_fin_timeout = 15
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.ip_local_port_range = 1024 65535

net.ipv4.tcp_keepalive_time = 120

##for iptables
#net.nf_conntrack_max = 25000000
#net.netfilter.nf_conntrack_max = 25000000
#net.netfilter.nf_conntrack_tcp_timeout_established = 180
#net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
#net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
#net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF

#delete invalid user
echo -e '\E[31;31m\n====== deleting invalid user ======';tput sgr0
userdel adm
userdel lp
userdel shutdown
userdel halt
userdel uucp
userdel operator
userdel games
userdel gopher
groupdel adm
groupdel lp
groupdel dip

#disable ctrl+alt+del reboot
echo -e '\E[31;31m\n====== disable ctrl+alt+del reboot ======';tput sgr0
sed -i 's/exec/#exec/g' /etc/init/control-alt-delete.conf

#install dell openmanger repo
echo -e '\E[31;31m\n====== installing dell openmanger yum repo ======';tput sgr0
cat > /etc/yum.repos.d/dell.repo << EOF
[openmange]
name=dell
#baseurl=http://mirror.symnds.com/software/linux.dell.com/
baseurl=http://yum2.xiaokao.cn:8888/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
EOF

#installing epel yum repo
echo -e '\E[31;31m\n====== installing epel yum repo ======';tput sgr0
EpelCount=$(rpm -qa | grep epel |wc -l)
if [ $EpelCount -eq 0 ];then
    rpm -ivh http://mirrors.ustc.edu.cn/fedora/epel/6/i386/epel-release-6-8.noarch.rpm && yum clean all
fi

echo -e '\E[31;31m\n====== Congratulations!! All have finished !! ======';tput sgr0
