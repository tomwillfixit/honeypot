#!/bin/bash

echo "Starting rsyslog"
/etc/init.d/rsyslog start

echo "Starting sshd"
/opt/openssh2/dist/sbin/sshd -f /opt/openssh2/dist/etc/sshd_config

echo "Checking ps"
ps -ef

echo "Tailing auth.log for failing connections"
tail -f /var/log/auth.log |grep Honey
