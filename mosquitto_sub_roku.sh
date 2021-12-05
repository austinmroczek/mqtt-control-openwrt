#!/bin/sh
p="mqttPipeRoku"
([ ! -p "$p" ]) && mkfifo $p
host="$1"
(mosquitto_sub -h $host -q 1 -d -t ha/internet/roku >$p 2>/dev/null) &
PID=$!

trap 'kill $PID' HUP INT TERM QUIT KILL

while read line <$p
do
   echo $line > /tmp/roku
      TASK=`cat /tmp/roku`
      #echo $TASK
      if [ "$TASK" == "OFF" ]; then
         /etc/iot/disable_roku.sh
      elif [ "$TASK" == "ON" ]; then
         /etc/iot/enable_roku.sh
      fi
      #echo "Event: " $line
done

