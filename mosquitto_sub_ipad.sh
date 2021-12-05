#!/bin/sh
host="$1"
device="$2"
mac="$3"
p="mqttPipe_$device"


([ ! -p "$p" ]) && mkfifo $p
(mosquitto_sub -h $host -q 1 -t ha/internet/$device >$p 2>/dev/null) &
PID=$!

trap 'kill $PID' HUP INT TERM QUIT KILL

while read line <$p
do
   echo $line > /tmp/$device
      TASK=`cat /tmp/$device`
      if [ "$TASK" == "OFF" ]; then
         /etc/iot/disable.sh $device $mac
      elif [ "$TASK" == "ON" ]; then
         /etc/iot/enable.sh $device $mac
      fi
done

