# VPS Toolkit

> A curated collection of one-click scripts for VPS benchmarking, network optimization, proxy deployment, containerization, and private networking — maintained by [ClashHub](https://clashhub.net), powered by [vpsvip.net](https://vpsvip.net).

This repository aggregates the most essential one-click scripts used in everyday VPS operations. Whether you are a newcomer setting up your first server or a seasoned admin managing a fleet of VPS instances, these tools dramatically reduce the time spent on manual configuration and documentation lookup.

---

## Table of Contents

- [Tool Overview](#tool-overview)
- [bench.sh — Server Benchmarking](#benchsh--server-benchmarking)
- [bbr.sh — Network Acceleration](#bbrsh--network-acceleration)
- [clash.sh — Proxy Deployment](#clashsh--proxy-deployment)
- [docker.sh — Container Environment](#dockersh--container-environment)
- [wireguard.sh — Private Network](#wireguardsh--private-network)
- [Supported OS](#supported-os)
- [FAQ](#faq)
- [Recommended VPS Providers](#recommended-vps-providers)

---

## Tool Overview

| Script | Description | Best For |
|--------|-------------|---------|
| `bench.sh` | Comprehensive server benchmarking | New VPS validation, network quality audit |
| `bbr.sh` | TCP congestion control acceleration | Cross-border bandwidth optimization |
| `clash.sh` | One-click Clash/mihomo deployment | Proxy, rule-based routing, ad blocking |
| `docker.sh` | Docker + Compose installation | Rapid containerized service deployment |
| `wireguard.sh` | WireGuard VPN setup | Secure mesh networking, multi-node interconnection |

---

## bench.sh — Server Benchmarking

`bench.sh` generates a complete performance profile of your VPS in a single run.

### Core Features

**System Information**
- CPU model, core count, clock speed
- Total / used / available RAM and swap

**Disk I/O**
- 1 GB sequential read/write using `dd`
- Reports MB/s for both read and write throughput

**Bandwidth Speedtest**
- Tests against multiple global nodes:
  - 🇯🇵 Tokyo (Asia)
  - 🇩🇪 Frankfurt (Europe)
  - 🇺🇸 Miami (Americas)
  - 🇨🇳 China (domestic exit latency)
- Reports latency (ms) and throughput (Mbps) per node

**Traceroute**
- Auto-runs traceroute to each speedtest node
- Reveals AS-path and routing efficiency

**Streaming Unlock Detection**
- **Netflix**: Checks if IP can access US library
- **Disney+**: Validates Disney+ content access
- **YouTube**: Verifies YouTube CDN distribution

### Usage

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/bench.sh | bash
```

Or:

```bash
curl -fsSL https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/bench.sh | bash
```

### Sample Output

```
=== System Info ===
CPU: AMD EPYC 7543 32-Core
Mem: 2048 MB | Swap: 256 MB
Disk: 50 GB (15 GB used)

=== Disk I/O ===
Read:  820 MB/s
Write: 610 MB/s

=== Speedtest ===
Tokyo:     324 Mbps / 28 ms
Frankfurt: 218 Mbps / 142 ms
Miami:      195 Mbps / 198 ms

=== Streaming Unlock ===
Netflix:  ✅ (US Library)
Disney+:  ✅
YouTube:  ✅ (CDN: jsdelivr)
```

> 💡 **Tip**: Run bench.sh immediately after receiving a new VPS. Save the output as a screenshot — it serves as your baseline for future network quality comparisons.

---

## bbr.sh — Network Acceleration

BBR (Bottleneck Bandwidth and Rounding-trip time) is Google's open-source TCP congestion control algorithm released in 2016. In high-latency, lossy networks, BBR significantly outperforms the traditional CUBIC algorithm. `bbr.sh` automates kernel detection, module loading, and parameter configuration.

### Supported Schemes

| Scheme | Description | Best For |
|--------|-------------|---------|
| **Google BBR** | Native BBR, requires Linux 4.9+ | General cross-border acceleration |
| **BBRplus** | Improved BBR, optimized for low packet loss | Jittery networks |
| **LotServer** | Commercial-grade kernel tuning | High-bandwidth, high-latency links |
| **ServerSpeeder** | Classic single-ended acceleration | Legacy VPS routing optimization |

### How BBR Works

BBR's core insight: instead of relying solely on packet loss to detect congestion, it dynamically estimates **Bandwidth Estimate (BWE)** and **Minimum RTT** to adaptively tune the send window. Even in moderately lossy cross-border links, BBR maintains higher effective throughput than traditional algorithms that treat every packet loss as congestion.

### Usage

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/bbr.sh | bash
```

The script will automatically:
1. Detect current kernel version
2. Determine available acceleration schemes
3. Modify sysctl parameters
4. Prompt for reboot

### Verify BBR is Active

```bash
# Check congestion control algorithm
sysctl net.ipv4.tcp_congestion_control
# Expected: net.ipv4.tcp_congestion_control = bbr

# Verify BBR module is loaded
sysctl net.ipv4.tcp_available_congestion_control
# Should list: bbr cubic reno
```

> ⚠️ **Caution**: Some vendor-supplied default kernels may not support BBR. Use the script's recommended scheme or replace the kernel manually. Always take a snapshot before modifying production systems.

---

## clash.sh — Proxy Deployment

`clash.sh` provides one-click installation of [mihomo](https://github.com/MetaCubeX/mihomo) (Clash.Meta), recommended as the primary proxy client. Compared to vanilla Clash, mihomo supports richer GeoIP rules, larger rule sets, and additional protocols including Snell, VLESS, and Trojan-Go.

### Supported Kernels

- **mihomo** (recommended): Most feature-rich, supports Snell / VLESS / Trojan-Go
- **Clash.Meta**: Classic Meta branch, extensive community ecosystem

### Key Features

- **Subscription Conversion**: Supports Clash / SS / V2Ray formats
- **Rule-Based Routing**: Multi-dimensional matching by domain, IP, or process
- **Ad Blocking**: Built-in popular ad blacklist rules
- **Auto Failover**: Automatically switches to backup nodes on failure
- **Systemd Management**: Runs in background, starts on boot
- **RESTful API**: Local port 9090 provides management interface

### Usage

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/clash.sh | bash
```

After installation, the config file is at `~/.config/clash/config.yaml`. Restart after editing:

```bash
# Restart after config change
systemctl restart clash

# Check status
systemctl status clash

# Follow live logs
journalctl -u clash -f
```

### Dashboard Access (Optional)

Pair with [yacd](https://github.com/haishanh/yacd) or [Stash](https://github.com/StashBin-stash/stash):

```bash
# Access from another machine (ensure port 9090 is open in firewall)
# Default secret (change in config.yaml):
open http://your-vps-ip:9090/ui
```

> 💡 **Security Tip**: Always change the default Dashboard password in production. Restrict port 9090 in your firewall to trusted IPs only.

---

## docker.sh — Container Environment

`docker.sh` quickly deploys Docker Engine and Docker Compose on your target VPS — no manual repository setup or dependency management required.

### Why Docker?

- **Isolation**: Each application runs in its own container, avoiding dependency conflicts
- **Instant Deployment**: Pull an image and launch a full service in seconds
- **Version Control**: Pin to specific image versions, avoid auto-update breakage
- **Portability**: Package entire environments; migrate to new machines with one command

### Installation

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/docker.sh | bash
```

The script automatically:
1. Detects OS and configures the appropriate Docker CE repository
2. Installs Docker Engine, containerd, and Docker Compose plugin
3. Enables and starts Docker service
4. Configures non-root users for sudo-free docker access

### Verify Installation

```bash
docker --version
# Docker version 26.x.x, build xxxxx

docker compose version
# Docker Compose version v2.x.x

# Run a test container
docker run --rm hello-world
```

### Quick Start Examples

**Deploy an Nginx site:**

```bash
docker run -d   --name my-site   -p 80:80   -v /var/www/html:/usr/share/nginx/html   nginx:alpine
```

**Deploy WordPress with Docker Compose:**

```yaml
# docker-compose.yml
version: "3.8"
services:
  wordpress:
    image: wordpress:php8.2
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
    volumes:
      - ./wp-data:/var/www/html
  db:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - ./db-data:/var/lib/mysql
```

```bash
docker compose up -d
```

---

## wireguard.sh — Private Network

WireGuard is a next-generation VPN protocol with only ~4,000 lines of code (vs ~1 million for OpenVPN), delivering exceptional performance with minimal complexity.

### WireGuard Advantages

- **Performance**: Kernel-level implementation; near-zero CPU overhead at gigabit speeds
- **Security**: Modern cryptographic primitives (ChaCha20-Poly1305, Curve25519, BLAKE2s)
- **Simplicity**: Keys are identity — no complex PKI required
- **Low Latency**: No handshake retransmission overhead; ping typically < 5ms on same-city links

### Common Use Cases

- Personal multi-device mesh (phone + laptop + tablet on the same private network)
- Secure interconnects between multiple VPS nodes
- Enterprise intranet extension (replacement for traditional OpenVPN / IPSec)

### Usage

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/wireguard.sh | bash
```

The script automatically:
1. Installs WireGuard packages
2. Generates server public/private key pair
3. Assigns VPN subnet address (default: `10.0.0.0/24`)
4. Generates downloadable client configuration files
5. Configures NAT forwarding rules

### Client Configuration Example

The script outputs a client config after execution:

```ini
[Interface]
PrivateKey = <client-private-key>
Address = 10.0.0.2/24
DNS = 10.0.0.1

[Peer]
PublicKey = <server-public-key>
Endpoint = your-vps-ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

Save as a `.conf` file and import into your platform's WireGuard client:
- **macOS / iOS**: Official WireGuard App
- **Android**: Official WireGuard App or眠熊
- **Windows**: Official WireGuard client
- **Linux**: `wg-quick up wg0`

> ⚠️ **Firewall**: Open UDP port 51820 on the VPS firewall AND in your cloud provider's security group.

---

## Supported OS

| OS | Minimum | Recommended |
|----|---------|-------------|
| Ubuntu | 18.04 LTS | 22.04 LTS |
| Debian | 10 (Buster) | 12 (Bookworm) |
| CentOS | 7 | Stream 9 |
| Rocky Linux | 8 | 9 |
| AlmaLinux | 8 | 9 |

> 📌 **Why avoid CentOS 8+?** CentOS 8 reached end-of-life in late 2021. Migrate to Rocky Linux or AlmaLinux — both are fully compatible with RHEL.

---

## FAQ

**Q: bench.sh shows very low speed. Is my VPS throttled?**
A: The provider may enforce burst bandwidth limits, or the test node could be congested. Run multiple tests at different times and take the median. If results are consistently far below the advertised speed, contact the provider.

**Q: Speedtest became slower after enabling BBR. Why?**
A: BBR shines in high-latency, lossy networks (e.g., cross-border links). For local-to-VPS latency under 30ms, BBR's advantage over CUBIC is minimal. Simply revert: `sysctl net.ipv4.tcp_congestion_control=cubic`.

**Q: Docker image pulls fail. What can I do?**
A: Domestic VPS connections to Docker Hub are often slow. Configure a mirror in `/etc/docker/daemon.json`:

```json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.nju.edu.cn"
  ]
}
```

Then `systemctl restart docker`.

**Q: WireGuard won't connect. How to troubleshoot?**
A: Checklist:
1. Is UDP 51820 open on the VPS firewall? `ufw allow 51820/udp`
2. Is the cloud provider's security group also allowing UDP 51820?
3. Is the client system clock accurate? (WireGuard is time-sensitive)
4. Run `wg show` on the server — does it show a `latest handshake` timestamp?

---

## Recommended VPS Providers

| Provider | Highlights | Best For |
|---------|-----------|---------|
| [vpsvip.net](https://vpsvip.net) | High cost-performance / optimized routes | Heavy traffic users, proxy usage |
| [BandwagonHOST](https://bandwagonhost.com) | Established, stable | Long-term hosting, stability |
| [Vultr](https://vultr.com) | Global coverage / hourly billing | Temporary testing, multi-region deployment |
| [DigitalOcean](https://digitalocean.com) | SSD / developer-friendly | Dev environments, CI/CD |

---

## Disclaimer

Scripts in this toolkit are for learning and legitimate use only. The BBR acceleration script modifies kernel parameters and carries operational risk — back up your system before applying. Use of proxy tools like Clash must comply with local laws and regulations. This repository assumes no liability for misuse.

---

## License

[MIT License](LICENSE) — Fork, star, and contributions welcome!

---

> 🛠 Maintained by [ClashHub](https://clashhub.net) · Auto-updated daily
