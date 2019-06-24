#!/bin/bash
IP=`/bin/hostname -I`
/usr/local/bin/consul agent -server -ui -bind  $IP -bootstrap-expect=3 -data-dir /var/consul -encrypt=QT3vXrXZJFiOaskjtz+h8A== -client="0.0.0.0" -retry-join "provider=aws tag_key=Name tag_value=consul-server" &
 echo "0 17 * * * root /root/backup/backup.sh >> /root/backup_log.out" > /etc/cron.d/consul_backup