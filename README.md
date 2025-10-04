Various notes on setting up servers and boxes

Box setup:
* Visual Studio Code installation manual: [www](https://learningorbis.com/gcc-gdb-installation-on-windows/)
* Ubuntu - free port 53: [www](https://andreyex.ru/ubuntu/kak-osvobodit-port-53-ispolzuemyj-systemd-resolved-v-ubuntu/)


WIREGUARD

Server side:
*install:*
```bash
sudo apt update
sudo apt install wireguard
```
*Forward* packages at kernel - edit /etc/sysctl.conf - add to the end of the file:
```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.proxy_arp = 0
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.all.send_redirects = 0
```
