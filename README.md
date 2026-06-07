# Pi-hole + Unbound + pihole-updatelists

Official [pihole/pihole:latest](https://hub.docker.com/r/pihole/pihole) (Alpine / Pi-hole v6) with:

- **[Unbound](https://nlnetlabs.nl/projects/unbound/)** — fully recursive, validating DNS resolver (port 5335). Queries root servers directly — no third-party upstream required.
- **[jacklul/pihole-updatelists](https://github.com/jacklul/pihole-updatelists)** — automatically syncs blocklists, whitelists, and regex rules from URLs on a schedule.

Multi-arch: `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/arm/v6`, `linux/386`

> **Want lancache support too?** Use the sibling image [`mwatz/pihole-unbound-updatelists-lancache-cache-domains`](https://hub.docker.com/r/mwatz/pihole-unbound-updatelists-lancache-cache-domains) which adds automatic CDN hostname rewriting for Steam, Epic, Xbox, and ~20 more game platforms.

---

## Why unbound?

Unlike [DoT/DoH variants](https://hub.docker.com/r/mwatz/pihole-dot-doh-updatelists), unbound is a **recursive resolver** — it contacts the DNS root servers directly instead of forwarding to Cloudflare, Google, or another third-party. This means:

- Maximum privacy: no single upstream provider sees your full query history
- DNSSEC validation happens locally in unbound — no dependency on upstream provider support
- **Important:** Set `FTLCONF_dns_dnssec=false` — unbound validates DNSSEC itself. Enabling Pi-hole's DNSSEC *and* unbound's causes double-validation conflicts (SERVFAIL on valid domains).

---

## Quick Start

```yaml
services:
  pihole:
    container_name: pihole
    image: mwatz/pihole-unbound-updatelists:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "80:80/tcp"
      - "443:443/tcp"
    environment:
      - TZ=America/Los_Angeles
      - FTLCONF_webserver_api_password=<your-password-here>
      - FTLCONF_dns_upstreams=127.0.0.1#5335   # Route queries through local unbound
      - FTLCONF_dns_listeningMode=all
      - FTLCONF_dns_dnssec=false               # Unbound validates DNSSEC - do not enable both
      - FTLCONF_LOCAL_IPV4=192.168.1.10        # Your Pi-hole server's LAN IP
      - BLOCKLISTS_URL=https://v.firebog.net/hosts/lists.php?type=tick
    volumes:
      - './etc-pihole:/etc/pihole'
    cap_add:
      - NET_ADMIN
      - NET_BIND_SERVICE
    restart: unless-stopped
```

See [examples/](examples/) for full compose files with all options documented.

---

## Environment Variables

### Required
| Variable | Example | Description |
|----------|---------|-------------|
| `TZ` | `America/Los_Angeles` | Your timezone |
| `FTLCONF_webserver_api_password` | `mysecretpassword` | Pi-hole admin UI password |
| `FTLCONF_dns_upstreams` | `127.0.0.1#5335` | Must point to local unbound |
| `FTLCONF_dns_listeningMode` | `all` | Required for Docker |
| `FTLCONF_dns_dnssec` | `false` | Disable Pi-hole DNSSEC -- unbound handles it |

### Optional Pi-hole
| Variable | Example | Description |
|----------|---------|-------------|
| `FTLCONF_LOCAL_IPV4` | `192.168.1.10` | Pi-hole server's LAN IP (reverse DNS lookup) |
| `FTLCONF_dns_revServers` | `true,192.168.1.0/24,192.168.1.1,localdomain` | Local hostname resolution via your router |

### pihole-updatelists
| Variable | Description |
|----------|-------------|
| `BLOCKLISTS_URL` | Space-separated list collection URLs (not direct file URLs) |
| `WHITELIST_URL` | Space-separated exact-match domain whitelist URLs |
| `REGEX_BLACKLIST_URL` | Space-separated regex rule URLs |
| `ALLOWLISTS_URL` | Allowlist collection URLs |
| `BLACKLIST_URL` | Exact domain blocklist URLs |
| `REGEX_WHITELIST_URL` | Regex whitelist URLs |
| `CRONTAB_STRING` | Override pihole-updatelists cron (default: random 3-4 AM Sunday) |

---

## Volumes

| Volume | Required | Description |
|--------|----------|-------------|
| `/etc/pihole` | Yes | Pi-hole config, gravity DB, FTL state |
| `/etc/pihole-updatelists` | Optional | File-based pihole-updatelists config (alternative to env vars) |

---

## Credits

- Base image: [pihole/pihole:latest](https://hub.docker.com/r/pihole/pihole)
- Recursive DNS: [NLnet Labs Unbound](https://github.com/NLnetLabs/unbound) -- following the [Pi-hole unbound guide](https://docs.pi-hole.net/guides/dns/unbound/)
- List management: [jacklul/pihole-updatelists](https://github.com/jacklul/pihole-updatelists)

If you find this useful, [a donation to my hot tamales fund](https://paypal.me/mwatz1234) is much appreciated!

[![Donate](https://github.com/mwatz1234/pihole-dot-doh-updatelists/blob/master/donate-button-small.png)](https://paypal.me/mwatz1234)
