#!/bin/sh

device="Guest Roku WiFi"
mac="B8:3E:59:22:A3:61"
chain="forwarding_rule"

# ipv4

for proto in "tcp" "udp"
do
  rule=$(iptables -L --line-numbers | grep -i "$mac" | grep "$proto" | awk '{print $1}')
  if [ "$rule" -gt 0 ] 2>/dev/null; then
    echo "Rule already exists"
    continue
  fi
  echo "blocking $proto for $device - $mac"
  iptables -A "$chain" -m comment --comment "blocking $proto for $device" -p "$proto" -m mac --mac-source "$mac" -j REJECT
done
echo "---------------------------------------------"

# ipv6

for proto in "tcp" "udp"
do
  rule=$(ip6tables -L --line-numbers | grep -i "$mac" | grep "$proto" | awk '{print $1}')
  if [ "$rule" -gt 0 ] 2>/dev/null; then
    echo "Rule already exists"
    continue
  fi
  echo "blocking $proto for $device - $mac"
  ip6tables -A "$chain" -m comment --comment "blocking $proto for $device" -p "$proto" -m mac --mac-source "$mac" -j REJECT
done
echo "---------------------------------------------"



