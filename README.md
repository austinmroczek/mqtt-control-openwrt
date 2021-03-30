# mqtt-control-openwrt
This project enables control of the OpenWRT iptables firewall via an MQTT broker.  

This is based on Artur Rodrigues' [Medium post](https://medium.com/@arturlr/using-iot-button-to-control-my-kids-internet-usage-5bd825c1da76) about enabling parental control of internet access with an Amazon button using OpenWRT and MQTT. I adapted it to work with Home Assistant sending commands to the MQTT broker instead of an Amazon button. This adds the ability to control internet access via multiple devices and automatically schedule on/off time.  It also keeps everything on my local area network.

At a basic level, flipping a switch in Home Assistant sends a command to the MQTT broker.  The router sees a change on the MQTT broker and changes the firewall rules to block or allow internet access.

## Requirements

- router with [OpenWRT](https://openwrt.org/)
- MQTT broker
- [Home Assistant](https://www.home-assistant.io/)

## Setup

While possible to install MQTT on the device router running OpenWRT, I chose to run it from my device that runs Home Assistant.  This minimized the load on the router, and moves most of the potential vulnerabilities to a less critical device.  

OpenWRT and Home Assistant setup are not covered here.

### Mosquitto MQTT broker

Any MQTT broker should work. I chose [mosquitto](https://mosquitto.org/). 

I already had Docker setup, so I set up the [mosquitto container](https://hub.docker.com/_/eclipse-mosquitto/) per the instructions.

### Home Assistant configuration

First add the broker address to the `secrets.yaml` file.

```yaml
mqtt_broker_address: 10.10.10.10
# put in your real address
```

Add the [MQTT broker](https://www.home-assistant.io/integrations/mqtt/) and an [MQTT switch](https://www.home-assistant.io/integrations/switch.mqtt/) to `configuration.yaml`

```yaml
mqtt:
  broker: !secret mqtt_broker_address

switch:
  - platform: mqtt
    unique_id: kid_internet
    name: Kid Internet
    state_topic: "ha/internet/kid_computer"
    command_topic: "ha/internet/kid_computer"
    retain: true
    availability:
      - topic: "ha/internet/kid_computer/available"
```

In this setup, the router will set `available` as `online` when it starts, and `offline` if the system is not available.  Home Assistant will send state and commands, but only when `online`.

Reload the configuration, or restart Home Assistant so the new configuration is active.  Use mosquitto_sub to see that the new switch is sending updates to the MQTT broker.  Until we set up the router, the switch will show as "unavailable" in Home Assistant.

```console
pi@rpi4:~ $ mosquitto_sub -t ha/internet/kid_computer
OFF
```

### OpenWRT configuration

Get the files.  

```console
root@OpenWRT:~# opkg install git-http 
root@OpenWRT:~# cd /tmp
root@OpenWRT:~# git clone https://github.com/austinmroczek/mqtt-control-openwrt.git 
root@OpenWRT:~# cd mqtt-control-openwrt
```

Modify the `host` variable near the top of file `ha` to match your MQTT server host name or IP address.

Copy the files to a long term destination.

```console
root@OpenWRT:~# mkdir /etc/iot
root@OpenWRT:~# cp * /etc/iot
root@OpenWRT:~# cp ha /etc/init.d/ha
root@OpenWRT:~# ln -s /etc/init.d/ha /etc/rc.d/S90ha
```

Start up the service
```console
root@OpenWRT:~# service ha start
```

### Security Note

This setup uses an anonymous MQTT setup with no authentication. Someone with access to my network could send MQTT commands pretending to be Home Assistant, which the router would happily accept.  I'm willing to accept the possibility of someone turning off my kid's devices for a while.  Think about it before you modify this for other purposes.

Upgrading this setup to certificate based authentication is on the todo list.