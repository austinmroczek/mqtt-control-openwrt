#!/bin/sh /etc/rc.common
# Example script
# Copyright (C) 2007 OpenWrt.org

# from https://medium.com/@arturlr/using-iot-button-to-control-my-kids-internet-usage-5bd825c1da76

START=82
host=rpi4

start() {
        echo start

	# show the MQTT switches as as available in Home Assistant
	/usr/bin/mosquitto_pub -r -h $host -t ha/internet/kid_computer/available -m online
	/usr/bin/mosquitto_pub -r -h $host -t ha/internet/ipad/available -m online
	/usr/bin/mosquitto_pub -r -h $host -t ha/internet/roku/available -m online
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/youtube/available -m online

        /etc/iot/mosquitto_sub_ipad.sh $host &
        /etc/iot/mosquitto_sub_kid_computer.sh $host &
        /etc/iot/mosquitto_sub_roku.sh $host &
	/etc/iot/youtube.sh $host &
}

stop() {
        echo stop

        #show the MQTT switches as unavailable to Home Assistant
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/kid_computer/available -m offline
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/ipad/available -m offline
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/roku/available -m offline
        /usr/bin/mosquitto_pub -r -h $host -t ha/internet/youtube/available -m offline

	# stop the mosquitto subscriptions
	PIDS=$(ps | grep mosquitto_sub | grep -v grep | awk '{print $1}')
	export PIDS
	for i in ${PIDS}
 	do
	   echo $1
	   kill -9 $i
	done

	# stop the youtube task
        PIDS=$(ps | grep youtube | grep -v grep | awk '{print $1}')
        export PIDS
        for i in ${PIDS}
        do
           echo $1
           kill -9 $i
        done

}
