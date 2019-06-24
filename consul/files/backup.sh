#!/bin/sh
echo "This is a test file"
DATE=`date '+%Y-%m-%d_%H_%M_%S'`
mkdir -p /root/backup
IP=`/bin/hostname -I`
LEADER=`curl http://127.0.0.1:8500/v1/status/leader | awk -F'[":]' '{print $2}'`
if [ "$LEADER" == "$IP" ] ; then
    /usr/local/bin/consul snapshot save /root/backup/backup_$DATE.snap
    /usr/bin/aws s3 cp /root/backup/backup_$DATE.snap s3://clark-consul-${env}-backup-987/
fi
find /root/backup/ -name "backup_*.snap" -mtime +15 -exec rm -rf {} \;