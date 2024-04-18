FROM alpine:3.19

COPY root/antizapret /root/antizapret
COPY /etc/openvpn /etc/openvpn

RUN apk update && apk add openrc
RUN mkdir -p /run/openrc/exclusive && touch /run/openrc/softlevel
RUN apk add --no-cache tar ipcalc sipcalc gawk iptables ferm curl wget openssl nano git python3 knot-resolver iproute2 openvpn grep mc ncdu openssh-server openssh-sftp-server procps dbus easy-rsa gawk ebtables bash tzdata dnsmap socat sed
RUN mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
RUN python -m ensurepip && pip3 install --upgrade dnspython 
RUN ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime
RUN rc-update add sshd && rc-update add openvpn && rc-update add kresd && rc-update add iptables
RUN cd /root/antizapret && git reset --hard && git pull
RUN echo "nameserver 1.1.1.1" >> /etc/resolv.conf
RUN sed -i "s|^#PermitRootLogin .*|PermitRootLogin yes|g" /etc/ssh/sshd_config
RUN sed -i "s|^#AllowAgentForwarding .*|AllowAgentForwarding yes|g" /etc/ssh/sshd_config
RUN sed -i "s|^#AllowTcpForwarding .*|AllowTcpForwarding yes|g" /etc/ssh/sshd_config
RUN sed -i "s|^#GatewayPorts .*|GatewayPorts yes|g" /etc/ssh/sshd_config
RUN rm -rf /root/easy-rsa-ipsec/easyrsa3 && cp -r /usr/share/easy-rsa /root/easy-rsa-ipsec/easyrsa3 && bash /root/easy-rsa-ipsec/generate.sh
RUN sed -i 's/etc\/openvpn/etc\/openvpn\/server/' > /etc/init.d/openvpn

RUN echo "0 */6 * * * /root/antizapret/doall.sh">> /etc/crontabs/root


RUN chmod +x 