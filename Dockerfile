#---------------------------------------
# Base image
#---------------------------------------
ARG FRM='pihole/pihole:latest'
ARG TAG='latest'
ARG TARGETPLATFORM
FROM ${FRM}

# Re-declare ARGs for use in RUN commands (BuildKit requirement)
ARG FRM
ARG TAG
ARG TARGETPLATFORM

USER root

#---------------------------------------
# Install dependencies
# Pi-hole v6 is Alpine-based — use apk, not apt-get
#---------------------------------------
RUN apk add --no-cache \
        bash \
        curl \
        wget \
        git \
        sudo \
        nano \
        php \
        php-curl \
        php-intl \
        php-openssl \
        php-pcntl \
        php-posix \
        php-pdo_sqlite \
        unbound \
        unbound-libs

#---------------------------------------
# Install unbound service + pihole-updatelists
#---------------------------------------
COPY stuff /temp
RUN chmod +x /temp/install.sh \
    && /bin/bash /temp/install.sh \
    && wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | bash -s docker \
    && rm -rf /temp

#---------------------------------------
# Record build date
#---------------------------------------
RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM} with tag ${TAG}" >> /build_date.info

#---------------------------------------
# Inherit Pi-hole's default entrypoint from base image
#---------------------------------------

