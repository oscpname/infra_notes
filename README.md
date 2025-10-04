Various notes on setting up servers and boxes

Box setup:
* Visual Studio Code installation manual: [www](https://learningorbis.com/gcc-gdb-installation-on-windows/)
* Ubuntu - free port 53: [www](https://andreyex.ru/ubuntu/kak-osvobodit-port-53-ispolzuemyj-systemd-resolved-v-ubuntu/)


WIREGUARD \
manuals: \
server side  
- https://telegra.ph/Prostaya-nastrojka-WireGuard-Linux-04-28 \

Mikrotik side 
video1 
- https://write.as/5mgc9gbud1kse.md 
- https://youtu.be/v48LghhEGOo?si=tiqjCTm-ES87BIHD 

video2 
- https://youtu.be/bVKNSf1p1d0?si=bkXFlyNt9VPHsYjv 
- https://github.com/ChristianLempa/videos/tree/main/wireguard-on-linux 

Server side (Linux Server running Ubuntu 20.04 LTS or newer): \
**install:**
```bash
sudo apt update
sudo apt install wireguard iptables nano
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
wg genkey | tee server_private.key | wg pubkey > server_public.key
wg genkey | tee client_private.key | wg pubkey > client_public.key
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
SaveConfig = true
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

**Mikrotik** side
```bash
1- Create a Wireguard Interface.
Winbox > Wireguard > Wireguard Section > Plus button > Leave the default “wireguard1” name > Enter your Client Private Key from the configuration file > Click OK.

2- Create an IP Address for your “wireguard1” interface. Replace “x” with the values from your “Address” field in the config file.

/ip address
add address=10.0.2.2/30 interface=wireguard1 network=10.0.2.0

3- Create a peer for your “wireguard1” interface. Replace “endpoint-address”, “endpoint-port” and “public-key” values with the values from your config file.

/interface wireguard peers
add allowed-address=0.0.0.0/0 endpoint-address=185.231.180.217 endpoint-port=38032 interface=wireguard1 persistent-keepalive=25s public-key=“Server Public Key”

4- Allow your “wireguard1” interface through your mikrotik Firewall. If you are not using the default Mikrotik network IP range, replace the “src-address” value with your network range of choice.

/ip firewall nat
add action=masquerade chain=srcnat out-interface=wireguard1 src-address=192.168.88.0/24

5- Route all of your mikrotik internet traffic through the Wireguard Interface. Replace “x” with the values from your “Address” field in the config file.

/ip route
add disabled=no distance=1 dst-address=0.0.0.0/1 gateway=10.0.2.1 pref-src=“” routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=1 dst-address=128.0.0.0/1 gateway=10.0.2.1 pref-src=“” routing-table=main scope=30 suppress-hw-offload=no target-scope=10

6- Configure a DNS server for your router.

/ip dns
set servers=1.1.1.1
/ip dhcp-client
set 0 use-peer-dns=no

7- Redirect Wireguard traffic through your Internet gateway. Replace the “x.x.x.x” with your Endpoint Address from your config file.

/ip route
add disabled=no dst-address=185.231.180.217/32 gateway=[/ip dhcp-client get [find interface=ether1] gateway] routing-table=main suppress-hw-offload=no

8- Reboot your router.
```
