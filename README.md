# OpenVPN for Docker - based on Alpine

Based on the `jpetazzo/dockvpn` image, this container starts an OpenVPN server and serves the config via a mounted directory.

## Quick Start

```bash
$ docker run -d --cap-add -p 1194:1194/udp -p 443:443/tcp -v /tmp:/tmp clma/dockvpn
...
$ ls /tmp/client.ovpn
```

## Not so Quick Start

Just like the `jpetazzo/dockvpn` image, the following stuff is generated:

- Diffie-Hellman parameters,
- a private key,
- a self-certificate matching the private key,
- two OpenVPN server configurations (for UDP and TCP),
- an OpenVPN client profile.

Two OpenVPN server processes serve UDP (port 1194) and TCP (port 443); the configuration is generated in `/etc/openvpn`. The client certificate is copied to `/tmp`.

### OpenVPN details

We use `tun` mode, because it works on the widest range of devices. `tap` mode, for instance, does not work on Android, except if the device
is rooted.

The topology used is `net30`, because it works on the widest range of OS. `p2p`, for instance, does not work on Windows.

The TCP server uses `192.168.255.0/25` and the UDP server uses
`192.168.255.128/25`.

The client profile specifies `redirect-gateway def1`, meaning that after establishing the VPN connection, all traffic will go through the VPN. This might cause problems if you use local DNS recursors which are not directly reachable, since you will try to reach them through the VPN and they might not answer to you. If that happens, use public DNS resolvers like those of Google (8.8.4.4 and 8.8.8.8) or OpenDNS (208.67.222.222 and 208.67.220.220).


### Security discussion

For simplicity, the client and the server use the same private key and
certificate. This is certainly a terrible idea. If someone can get their
hands on the configuration on one of your clients, they will be able to
connect to your VPN, and you will have to generate new keys. Which is,
by the way, extremely easy, since each time you `docker run` the OpenVPN
image, a new key is created. If someone steals your configuration file
(and key), they will also be able to impersonate the VPN server (if they
can also somehow hijack your connection).

It would probably be a good idea to generate two sets of keys.

It would probably be even better to generate the server key when
running the container for the first time (as it is done now), but
generate a new client key each time the `serveconfig` command is
called. The command could even take the client CN as argument, and
another `revoke` command could be used to revoke previously issued
keys.
