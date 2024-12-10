#!/bin/sh

#_trans_port="8118"
_trans_port="1080"
_int_if="wlan0"

#sudo iptables -t nat -A PREROUTING -i $_int_if -p udp --dport 53 -j REDIRECT --to-ports 53
#sudo iptables -t nat -A PREROUTING -i $_int_if -p tcp --syn -j REDIRECT --to-ports $_trans_port

#sudo  iptables -t nat -A OUTPUT -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353
#sudo  iptables -t nat -A OUTPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040

#route all TCP
sudo iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $_trans_port
#partially UDP
sudo iptables -t nat -A OUTPUT -p udp -m udp --dport 53 -j REDIRECT --to-ports 53
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#block other traffic
#sudo iptables -A OUTPUT -j REJECT
#sudo ip6tables -A OUTPUT -j REJECT


