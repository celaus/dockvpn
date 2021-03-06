FROM alpine:3.3
RUN apk add --no-cache openvpn openssl curl iptables
ADD ./bin /usr/local/sbin
VOLUME /etc/openvpn
VOLUME /tmp
EXPOSE 443/tcp 1194/udp 8080/tcp
CMD run
