#!/bin/sh
p="mqttPipeiPad"
host="$1"
([ ! -p "$p" ]) && mkfifo $p
(mosquitto_sub -h $host -q 1 -t ha/internet/ipad >$p 2>/dev/null) &
PID=$!

trap 'kill $PID' HUP INT TERM QUIT KILL

while read line <$p
do
   echo $line > /tmp/ipad
      TASK=`cat /tmp/ipad`
      #echo $TASK
      if [ "$TASK" == "OFF" ]; then
         /etc/iot/disable_ipad.sh
      elif [ "$TASK" == "ON" ]; then
         /etc/iot/enable_ipad.sh
      fi
      #echo "Event: " $line
done

