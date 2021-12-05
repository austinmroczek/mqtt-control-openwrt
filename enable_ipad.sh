#!/bin/sh

device="iPad"
mac="4C:AB:4F:31:52:0C"
chain="forwarding_rule"

echo "enable $device $mac"

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



