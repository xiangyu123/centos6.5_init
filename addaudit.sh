#!/bin/bash
mv /etc/profile /etc/profile.bak
cp ./profile  /etc/profile

touch /var/log/audit.log
chown nobody.nobody /var/log/audit.log
chmod 002 /var/log/audit.log
chattr +i /etc/profile
chattr +a /var/log/audit.log
source /etc/profile
