ARG FRM='pihole/pihole:latest'
ARG TAG='latest'

FROM ${FRM}
ARG FRM
ARG TAG
ARG TARGETPLATFORM

RUN apt-get update && \
    apt-get install -Vy sudo bash wget nano php-cli php-sqlite3 php-intl php-curl curl unbound && \
    apt-get clean && \
    rm -fr /var/cache/apt/* /var/lib/apt/lists/*.lz4

RUN mkdir -p /etc/services.d/unbound

COPY /stuff/lighttpd-external.conf /etc/lighttpd/external.conf 
COPY /stuff/unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY /stuff/99-edns.conf /etc/dnsmasq.d/99-edns.conf
COPY /stuff/unbound-run /etc/services.d/unbound/run
# Make bash script executable
RUN chmod -v +x /etc/services.d/unbound/run

#ENTRYPOINT ./s6-init

RUN wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | bash /dev/stdin docker

RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM} with tag ${TAG}" >> /build_date.info

