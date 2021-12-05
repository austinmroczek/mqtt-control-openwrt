#!/bin/sh

### set up a pipe from tcpdump this script can read

p="youtube"
host="$1"
([ ! -p "$p" ]) && mkfifo $p

### set up background tcpdump task
### it listens for DNS requests from a specific computer

(tcpdump -l udp port 53 and ether src host CC:3D:82:B1:1A:70 >$p) &
PID=$!
trap 'kill $PID' HUP INT TERM QUIT KILL

# start with sensor in OFF state
/etc/iot/youtube_sensor_off.sh $host

### read from the pipe when tcpdump provides output

while read line <$p
do

  ### look only for DNS requests that contain youtube
  echo $line > temp.txt
  result=$( grep -q youtube temp.txt )

  if [ -n $result ]; then
    # youtube DNS lookup detected

    # but only turn on the sensor if it's not already on
    if [ ! -f sensor.lock ]; then
      #echo create lock file
      touch sensor.lock
      /etc/iot/youtube_sensor_on.sh $host &
    fi

  else
    #echo youtube not detected, ensure sensor is OFF
    /etc/iot/youtube_sensor_off.sh $host &
  fi

done

echo youtube script quit for unknown reason
