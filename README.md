# pihole-dot-doh-updatelists
Official pihole docker with unbound (based from https://docs.pi-hole.net/guides/dns/unbound/) contacting the DNS root servers directly and jacklul/pihole-updatelists. 

Multi-arch image built for both Raspberry Pi (arm64, arm32/v7, arm32/v6) and amd64.

## Usage:
For docker parameters, refer to [official pihole docker readme](https://github.com/pi-hole/pi-hole). Below is an docker compose example.

```
version: '3.0'

services:
  pihole:
    container_name: pihole
    image: mwatz/pihole-unbound-updatelists:latest
    hostname: pihole
    domainname: pihole.localdomain
    ports:
      - "443:443/tcp"
      - "53:53/tcp"
      - "53:53/udp"
      #- "67:67/udp"
      - "80:80/tcp"
    environment:
      - FTLCONF_LOCAL_IPV4=<IP address of device running the docker>
      - TZ=America/Los_Angeles
      - WEBPASSWORD=<Password to access pihole>
      - WEBTHEME=lcars
      - REV_SERVER=true
      - REV_SERVER_TARGET=<ip address of your router>
      - REV_SERVER_DOMAIN=localdomain
      - REV_SERVER_CIDR=<may be 192.168.1.0/24 if your router is 192.168.1.1>
      - PIHOLE_DNS_=127.0.0.1#5335
      - DNSSEC="true"
    volumes:
      - './etc/pihole:/etc/pihole/:rw'
      - './etc/dnsmask:/etc/dnsmasq.d/:rw'
      - './etc/updatelists:/etc/pihole-updatelists/:rw'
    restart: unless-stopped
    
    
```
### Notes:
* Credits:
  * Pihole base image is the official [pihole/pihole:latest](https://hub.docker.com/r/pihole/pihole/tags?page=1&name=latest)
  * unbound method was based from https://github.com/chriscrowe/docker-pihole-unbound
  * pihole-update lists is from https://github.com/jacklul/pihole-updatelists
