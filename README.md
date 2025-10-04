Various notes on setting up servers and boxes

Box setup:
* Visual Studio Code installation manual: [www](https://learningorbis.com/gcc-gdb-installation-on-windows/)
* Ubuntu - free port 53: [www](https://andreyex.ru/ubuntu/kak-osvobodit-port-53-ispolzuemyj-systemd-resolved-v-ubuntu/)


WIREGUARD 
manual: https://telegra.ph/Prostaya-nastrojka-WireGuard-Linux-04-28

Server side:
**install:**
```bash
sudo apt update
sudo apt install wireguard
```
**Forward** packages at kernel 
```bash
# edit /etc/sysctl.conf
nano /etc/sysctl.conf

# add to the end of the file:
net.ipv4.ip_forward = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.proxy_arp = 0
net.ipv4.conf.default.send_redirects = 1
net.ipv4.conf.all.send_redirects = 0

#update setting
sysctl -p
```

**create keys**
```bash
wg genkey | sudo tee server_private.key | wg pubkey | sudo tee server_public.key
wg genkey | sudo tee client_private.key | wg pubkey | sudo tee client_public.key
```

**edit wireguard server config** /etc/wireguard/wg0.conf
- Address - set IP for VPN
- ListenPort  - set server port
- PrivateKey  - set private server key, generated above
- PostUp, PostDown - edit network interface instead of enp0s8
```bash
[Interface]
Address = 10.66.66.1/24,fd42:42:42::1/64
ListenPort = 63665
PrivateKey = <server_private.key>
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A
POSTROUTING -o enp0s8 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j
ACCEPT; ip6tables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D
POSTROUTING -o enp0s8 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j
ACCEPT; ip6tables -t nat -D POSTROUTING -o enp0s8 -j MASQUERADE
[Peer]
PublicKey = <client_public.key>
AllowedIPs = 10.66.66.2/32,fd42:42:42::2/128 
```
**edit client config** and copy to /etc/wireguard/wg0.conf on client
```bash
[Interface]
PrivateKey = <client_private.key>
Address = 10.66.66.2/24,fd42:42:42::2/64
DNS = 8.8.8.8,8.8.4.4
[Peer]
PublicKey = <server_public.key>
Endpoint = 192.168.56.101:63665
AllowedIPs = 0.0.0.0/0,::/0
```
**start the server\client**
```bash
# just start
sudo wg-quick up wg0

#autostart
sudo systemctl enable wg-quick@wg0

```
