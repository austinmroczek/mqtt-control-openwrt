#!/bin/sh

device="Guest Roku WiFi"
mac="B8:3E:59:22:A3:61"
chain="forwarding_rule"

# ipv4

for proto in "tcp" "udp"
do
  iptables -D "$chain" -m comment --comment "blocking $proto for $device" -p "$proto" -m mac --mac-source "$mac" -j REJECT
done
echo "---------------------------------------------"

# ipv6

for proto in "tcp" "udp"
do
  ip6tables -D "$chain" -m comment --comment "blocking $proto for $device" -p "$proto" -m mac --mac-source "$mac" -j REJECT
done
echo "---------------------------------------------"



