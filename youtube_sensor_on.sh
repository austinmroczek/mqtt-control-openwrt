#!/bin/sh

mosquitto_pub -q 1 -d -t ha/internet/youtube -m ON 1>/dev/null 2>/dev/null
sleep 300
./youtube_sensor_off.sh
