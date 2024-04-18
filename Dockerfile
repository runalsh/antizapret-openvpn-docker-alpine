FROM alpine:3.19

COPY /etc/openvpn /etc/openvpn
COPY /root/easy-rsa-ipsec /root/easy-rsa-ipsec
COPY /root/dnsmap /root/dnsmap


RUN apk update && apk add openrc
RUN mkdir -p /run/openrc/exclusive && touch /run/openrc/softlevel
RUN apk add --no-cache ipcalc sipcalc gawk iptables ferm curl wget openssl nano git python3 knot-resolver iproute2 openvpn grep openssh-server openssh-sftp-server procps dbus easy-rsa gawk ebtables bash tzdata sed libidn

# debug tools
RUN apk add --no-cache tar ncdu socat mc strace

RUN git clone --depth 1 --single-branch https://github.com/runalsh/antizapret-pac-generator-light antizapret
# /root/antizapret will be external path or volume in docker-compose

RUN mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
RUN python -m ensurepip && pip3 install --upgrade dnspython 
RUN ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
RUN rc-update add sshd  && rc-update add kresd && rc-update add iptables 
# && rc-service iptables save
# && rc-update add openvpn
#RUN echo "nameserver 1.1.1.1" >> /etc/resolv.conf
RUN echo "root:$root_passwd" | chpasswd
RUN sed -i "s|^#PermitRootLogin .*|PermitRootLogin yes|g" /etc/ssh/sshd_config
RUN sed -i "s|^#AllowAgentForwarding .*|AllowAgentForwarding yes|g" /etc/ssh/sshd_config
RUN sed -i "s|^#AllowTcpForwarding .*|AllowTcpForwarding yes|g" /etc/ssh/sshd_config
RUN sed -i "s|^#GatewayPorts .*|GatewayPorts yes|g" /etc/ssh/sshd_config
RUN rm -rf /root/easy-rsa-ipsec/easyrsa3 && cp -r /usr/share/easy-rsa /root/easy-rsa-ipsec/easyrsa3 && bash /root/easy-rsa-ipsec/generate.sh
RUN sed -i 's/etc\/openvpn/etc\/openvpn\/server/' /etc/init.d/openvpn

# RUN mv /etc/init.d/openvpn /etc/init.d/openvpn-tcp
# RUN sed -i 's/\$instance_name.conf/antizapret.conf/' /etc/init.d/openvpn-tcp
# RUN cp /etc/init.d/openvpn-tcp /etc/init.d/openvpn-udp
# RUN sed -i 's/antizapret.conf/antizapret-tcp.conf/' /etc/init.d/openvpn-udp

RUN echo "0 */6 * * * /root/antizapret/doall.sh">> /etc/crontabs/root

RUN echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ipv4.conf

RUN echo "auto lo" > /etc/network/interfaces
RUN echo "iface lo inet loopback" > /etc/network/interfaces
RUN echo "auto eth0" > /etc/network/interfaces

EXPOSE 1194
EXPOSE 22

COPY init.sh /root/init.sh
USER root
ENTRYPOINT ["bash", "-c", "/root/init.sh"]