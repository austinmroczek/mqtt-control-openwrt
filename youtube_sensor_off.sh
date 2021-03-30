#!/bin/sh

mosquitto_pub -q 1 -d -t ha/internet/youtube -m OFF 1>/dev/null 2>/dev/null
rm sensor.lock

