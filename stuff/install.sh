#!/bin/bash
set -ex

########################################
# Unbound setup
# Pi-hole v6 / Alpine — unbound installed via apk add unbound
########################################
mkdir -p /etc/services.d/unbound
mkdir -p /etc/unbound/unbound.conf.d

# Install unbound config
if [ -f /temp/unbound-pihole.conf ]; then
    cp /temp/unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
    echo "Installed /etc/unbound/unbound.conf.d/pi-hole.conf"
else
    echo "ERROR: /temp/unbound-pihole.conf not found"
    exit 1
fi

# Install unbound EDNS config for dnsmasq/FTL (reduces fragmentation issues)
if [ -f /temp/99-edns.conf ]; then
    mkdir -p /etc/dnsmasq.d
    cp /temp/99-edns.conf /etc/dnsmasq.d/99-edns.conf
    echo "Installed /etc/dnsmasq.d/99-edns.conf"
fi

# Install s6-overlay service runner for unbound (legacy; not invoked in Pi-hole v6 — kept for reference)
if [ -f /temp/unbound-run ]; then
    cp /temp/unbound-run /etc/services.d/unbound/run
    chmod +x /etc/services.d/unbound/run
    echo "Installed /etc/services.d/unbound/run"
else
    echo "ERROR: /temp/unbound-run not found"
    exit 1
fi

# Store default unbound config for volume-init on first start
mkdir -p /usr/local/share/unbound-defaults
cp /temp/unbound-pihole.conf /usr/local/share/unbound-defaults/unbound-pihole.conf

echo "Unbound setup complete"

########################################
# _start-unbound.sh
# Called by start.sh before pihole-FTL starts.
# Pi-hole v6 uses plain start.sh (not s6-overlay) so /etc/services.d/unbound/run
# is never automatically invoked -- we must start unbound explicitly here.
########################################
cat << 'EOF' > /usr/local/bin/_start-unbound.sh
#!/bin/bash
echo "  [i] Starting unbound recursive DNS resolver..."
mkdir -p /var/log/unbound /run/unbound
/usr/sbin/unbound -d &
for i in $(seq 1 30); do
    if ss -tuln 2>/dev/null | grep -q 5335; then
        echo "  [i] Unbound is ready on port 5335"
        break
    fi
    sleep 1
done
EOF
chmod +x /usr/local/bin/_start-unbound.sh

########################################
# Inject _start-unbound.sh into Pi-hole's start.sh
# Injection point: before pihole-FTL-prestart.sh (ensures unbound is up before FTL starts)
########################################
if grep -q '_start-unbound.sh' /usr/bin/start.sh; then
    echo "_start-unbound.sh already injected into start.sh"
else
    sed '/sh \/opt\/pihole\/pihole-FTL-prestart.sh/i\\    bash /usr/local/bin/_start-unbound.sh' -i /usr/bin/start.sh
    echo "Injected _start-unbound.sh into start.sh"
fi

echo "install.sh complete"
