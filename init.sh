echo "nameserver 1.1.1.1" >> /etc/resolv.conf
/root/easy-rsa-ipsec/generate.sh
openvpn /etc/openvpn/server/antizapret-tcp.conf