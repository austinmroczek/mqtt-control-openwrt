#!/bin/sh /etc/rc.common
# Example script
# Copyright (C) 2007 OpenWrt.org

# from https://medium.com/@arturlr/using-iot-button-to-control-my-kids-internet-usage-5bd825c1da76

START=82
host=rpi4

start() {
        sleep 30
        echo "Start HA MQTT controller service"

	echo "...show the MQTT switches as as available in Home Assistant"
	/usr/bin/mosquitto_pub -r -h $host -t ha/internet/kid_computer/available -m online
	/usr/bin/mosquitto_pub -r -h $host -t ha/internet/ipad/available -m online
	/usr/bin/mosquitto_pub -r -h $host -t ha/internet/roku/available -m online
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/youtube/available -m online

	echo "...start the MQTT subscriptions to watch for updates"
        /etc/iot/mosquitto_sub.sh $host ipad 4C:AB:4F:31:52:0C &
        /etc/iot/mosquitto_sub.sh $host kid_computer CC:3D:82:B1:1A:70 &
        /etc/iot/mosquitto_sub.sh $host roku B8:3E:59:22:A3:61 &
	/etc/iot/mosquitto_sub_youtube.sh $host &

        echo "Start HA MQTT controller service -- COMPLETE"
}

stop() {
        echo "Stop HA MQTT controller service"

        echo "...show the MQTT switches as unavailable to Home Assistant"
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/kid_computer/available -m offline
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/ipad/available -m offline
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/roku/available -m offline
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/youtube/available -m offline

	echo "...stop the MQTT subscriptions"
	PIDS=$(ps | grep mosquitto_sub | grep -v grep | awk '{print $1}')
	export PIDS
	for i in ${PIDS}
 	do
	   echo $1
	   kill -9 $i
	done

	echo "...stop the youtube tcpdump task"
        PIDS=$(ps | grep tcpdump | grep -v grep | awk '{print $1}')
        export PIDS
        for i in ${PIDS}
        do
           echo $1
           kill -9 $i
        done

        echo "Stop HA MQTT controller service -- COMPLETE"

}
