# VPS工具箱

> 实用的 VPS 测速、优化、部署脚本集合，源自 [vpsvip.net](https://vpsvip.net)，由 [ClashHub](https://clashhub.net) 维护，每日自动更新。

本仓库汇集了运维 VPS 过程中最常用的几款一键脚本，覆盖**基准测试、网络加速、代理部署、容器化、环境配置、私有网络搭建**等核心场景。无论你是刚接触 VPS 的新手，还是需要高效批量管理多台服务器的老手，这套工具箱都能显著提升效率，省去逐条查询文档的麻烦。

---

## 目录

- [工具列表](#工具列表)
- [bench.sh 基准测试](#benchsh-基准测试)
- [bbr.sh 网络加速](#bbrsh-网络加速)
- [clash.sh 代理部署](#clashsh-代理部署)
- [docker.sh 容器环境](#dockersh-容器环境)
- [wireguard.sh 私有网络](#wireguardsh-私有网络)
- [适用系统](#适用系统)
- [常见问题](#常见问题)
- [推荐VPS](#推荐vps)

---

## 工具列表

| 脚本 | 功能简介 | 推荐场景 |
|------|---------|---------|
| `bench.sh` | 服务器综合基准测试 | 新购 VPS 验收、网络质量评估 |
| `bbr.sh` | TCP 拥塞控制加速 | 跨境带宽优化、游戏/视频加速 |
| `clash.sh` | 一键部署 Clash/mihomo | 科学上网、规则分流、广告屏蔽 |
| `docker.sh` | Docker + Compose 安装 | 快速容器化部署各类服务 |
| `wireguard.sh` | WireGuard VPN 搭建 | 私密组网、多节点互联 |

---

## bench.sh 基准测试

`bench.sh` 是服务器"体验报告生成器"，运行一次即可获得 VPS 的完整性能画像。

### 核心功能

**系统信息采集**
- CPU 型号、核心数、主频
- 内存总量 / 已用 / 可用（含 swap 大小）
- 磁盘总容量与可用空间

**磁盘 I/O 测试**
- 使用 `dd` 命令执行 1GB 顺序读写测试
- 分别输出读取速度和写入速度（MB/s）

**带宽测速**
- 选取全球多个优质测速节点，包括：
  - 🇯🇵 东京（亚洲代表节点）
  - 🇩🇪 法兰克福（欧洲代表节点）
  - 🇺🇸 迈阿密（美洲代表节点）
  - 🇨🇳 中国（国内出口延迟测试）
- 输出每个节点的延迟（ms）和带宽（Mbps）

**路由追踪（Traceroute）**
- 自动对上述测速节点执行路由追踪
- 直观展示数据包经过的 AS 路径，判断是否为最优路由

**流媒体解锁检测**
- **Netflix**：检测 IP 是否在 Netflix 可用区
- **Disney+**：检测 Disney+ 受限内容访问能力
- **YouTube**：验证 YouTube CDN 分配情况

### 使用方法

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/bench.sh | bash
```

或直接下载后执行：

```bash
curl -fsSL https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/bench.sh | bash
```

### 典型输出示例

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

> 💡 **建议**：在购买新 VPS 后第一时间运行 bench.sh，将结果截图保存，作为后续网络质量对比的基准线。

---

## bbr.sh 网络加速

BBR（Bottleneck Bandwidth and Rounding-trip time）是 Google 于 2016 年开源的 TCP 拥塞控制算法，在高延迟、高丢包网络中性能远超传统 CUBIC 算法。`bbr.sh` 脚本自动完成内核检测、模块加载与参数配置。

### 支持的加速方案

| 方案 | 简介 | 适用场景 |
|------|------|---------|
| **Google BBR** | 原生 BBR，需 Linux 4.9+ | 通用跨境加速 |
| **BBRplus** | 改进版 BBR，低丢包优化 | 抖动网络 |
| **LotServer** | 商业版加速，内核魔改 | 高带宽高延迟线路 |
| **锐速（ServerSpeeder）** | 经典单边加速工具 | 老牌 VPS 线路优化 |

### 工作原理简述

BBR 的核心思想是：不再仅依赖丢包来判断网络拥塞，而是通过实时估算**带宽上限（BWE）**和**最小延迟（RTT）**来动态调整发送窗口。即使在有一定丢包率的网络中（如跨境宽带），BBR 仍能维持较高的有效吞吐量。

### 使用方法

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/bbr.sh | bash
```

脚本执行后将自动：
1. 检测当前内核版本
2. 判断可用加速方案
3. 修改 sysctl 参数
4. 提示重启后生效

### 验证是否生效

```bash
# 查看当前拥塞控制算法
sysctl net.ipv4.tcp_congestion_control
# 输出应为: net.ipv4.tcp_congestion_control = bbr

# 查看 BBR 模块是否加载
sysctl net.ipv4.tcp_available_congestion_control
# 输出应包含: bbr cubic reno
```

> ⚠️ **注意**：部分商家提供的默认内核可能不支持 BBR，请使用脚本推荐的方案或自行更换内核。生产环境操作前建议快照备份。

---

## clash.sh 代理部署

`clash.sh` 提供一键安装与配置 [mihomo](https://github.com/MetaCubeX/mihomo)（Clash.Meta 内核），推荐作为主力代理客户端。相比原版 Clash，mihomo 支持更丰富的 GeoIP 规则和更大的规则集。

### 支持的内核

- **mihomo**（推荐）：功能最全面，支持 Snell / VLESS / Trojan-Go 等协议
- **Clash.Meta**：经典 Meta 分支，社区生态丰富

### 功能特性

- **自动订阅转换**：支持 Clash/SS/V2Ray 等常见订阅格式
- **规则分流**：按域名、IP、进程多维度匹配
- **广告屏蔽**：集成常用广告黑名单规则
- **自动故障转移**：节点失效时自动切换备用节点
- **Systemd 管理**：后台常驻，开机自启
- **API 控制**：本地 9090 端口提供 RESTful 管理界面

### 使用方法

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/clash.sh | bash
```

安装完成后，配置文件默认位于 `~/.config/clash/config.yaml`，可通过编辑该文件或订阅链接自动更新：

```bash
# 重启 Clash（修改配置后）
systemctl restart clash

# 查看 Clash 运行状态
systemctl status clash

# 查看实时连接日志
journalctl -u clash -f
```

### Clash Dashboard（可选）

推荐配合 [yacd](https://github.com/haishanh/yacd) 或 [Stash](https://github.com/StashBin-stash/stash) 使用：

```bash
# 在另一台机器上访问（需开启防火墙 9090 端口）
# 默认令牌（请在 config.yaml 中修改）：
# Secret: your-password-here
open http://your-vps-ip:9090/ui
```

> 💡 **安全建议**：生产环境务必修改 Dashboard 默认密码，并在防火墙中限制 9090 端口仅允许可信 IP 访问。

---

## docker.sh 容器环境

`docker.sh` 在目标 VPS 上快速部署 Docker Engine 和 Docker Compose，无需手动配置软件源和依赖。

### 为什么用 Docker？

- **环境隔离**：每个应用独立容器，不互相干扰系统依赖
- **秒级部署**：一条命令拉取镜像并启动完整服务
- **版本可控**：指定镜像版本，避免自动更新导致兼容性问题
- **迁移便捷**：整个环境打包为镜像，新机器一键还原

### 安装步骤

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/docker.sh | bash
```

脚本将自动：
1. 检测操作系统，配置对应 Docker CE 软件源
2. 安装 Docker Engine、containerd 和 Docker Compose 插件
3. 启用并启动 Docker 服务
4. 配置非 root 用户免 sudo 使用 docker 命令

### 验证安装

```bash
docker --version
# Docker version 26.x.x, build xxxxx

docker compose version
# Docker Compose version v2.x.x

# 运行测试容器
docker run --rm hello-world
```

### 快速上手示例

**部署一个 Nginx 网站：**

```bash
docker run -d   --name my-site   -p 80:80   -v /var/www/html:/usr/share/nginx/html   nginx:alpine
```

**使用 Docker Compose 部署 WordPress：**

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

## wireguard.sh 私有网络

WireGuard 是新一代轻量级 VPN 协议，代码量仅约 4000 行（vs OpenVPN 约 100 万行），性能极高，配置极简。

### WireGuard 优势

- **性能**：内核级实现，千兆网络下 CPU 占用接近零
- **安全**：现代加密原语（ChaCha20-Poly1305、Curve25519、BLAKE2s）
- **简洁**：密钥即身份，无需复杂 PKI 体系
- **低延迟**：无握手重传开销，Ping 通常 < 5ms（同城节点）

### 典型使用场景

- 个人多设备组网（手机+电脑+平板同时接入同一私有网络）
- 多台 VPS 之间安全互联
- 企业内网延伸（替代传统 OpenVPN / IPSec）

### 使用方法

```bash
wget -qO- https://raw.githubusercontent.com/CG-spring/vps-guide-nwa2nn/main/wireguard.sh | bash
```

脚本将自动：
1. 安装 WireGuard 相关软件包
2. 生成服务器公私钥对
3. 分配 VPN 网段地址（默认 `10.0.0.0/24`）
4. 生成客户端配置文件供下载
5. 配置 NAT 转发规则

### 客户端配置示例

脚本会在执行结束后输出客户端配置，内容类似：

```ini
[Interface]
PrivateKey = <客户端私钥>
Address = 10.0.0.2/24
DNS = 10.0.0.1

[Peer]
PublicKey = <服务器公钥>
Endpoint = your-vps-ip:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

将以上内容保存为 `.conf` 文件，导入各平台客户端：
- **macOS / iOS**：WireGuard 官方 App
- **Android**：WireGuard 官方 App 或 休眠熊
- **Windows**：WireGuard 官方客户端
- **Linux**：命令行 `wg-quick up wg0`

> ⚠️ **防火墙注意**：需开放 UDP 51820 端口，并确保 VPS 提供商安全组也放行该端口。

---

## 适用系统

| 操作系统 | 最低版本 | 推荐版本 |
|---------|---------|---------|
| Ubuntu | 18.04 LTS | 22.04 LTS |
| Debian | 10 (Buster) | 12 (Bookworm) |
| CentOS | 7 | Stream 9 |
| Rocky Linux | 8 | 9 |
| AlmaLinux | 8 | 9 |

> 📌 **为什么不用 CentOS 8+？** CentOS 8 已于 2021 年底停止更新，建议迁移至 Rocky Linux 或 AlmaLinux，它们与 RHEL 完全兼容。

---

## 常见问题

**Q: 运行 bench.sh 测速很低，是 VPS 被限速了吗？**
A: 可能是商家对带宽做了突发限制（Burstable BW），或测速节点网络波动。建议在不同时间段多次测试，取中位数。若持续远低于标称带宽，联系商家排查。

**Q: BBR 加速后 Speedtest 反而变慢了？**
A: BBR 适合高延迟高丢包场景（如跨境）。在本地到 VPS 延迟 < 30ms 的情况下，BBR 相对 CUBIC 优势不明显，有时反而略低。切换回原生 BBR 或关闭加速（`sysctl net.ipv4.tcp_congestion_control=cubic`）即可。

**Q: Docker 拉取镜像失败怎么办？**
A: 国内 VPS 访问 Docker Hub 通常较慢，建议配置镜像加速器。可在 `/etc/docker/daemon.json` 中添加：

```json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.nju.edu.cn"
  ]
}
```

然后 `systemctl restart docker` 生效。

**Q: WireGuard 连接不上，怎么排查？**
A: 检查清单：
1. VPS 防火墙是否放行 UDP 51820：`ufw allow 51820/udp`
2. 云服务商安全组是否放行 UDP 51820
3. 客户端时间是否准确（WireGuard 对时间敏感）
4. `wg show` 查看服务端是否有 `latest handshake` 时间

---

## 推荐VPS

| 提供商 | 特色 | 推荐场景 |
|-------|------|---------|
| [vpsvip.net](https://vpsvip.net) | 高性价比/优化线路 | 科学上网、流量消耗大的用户 |
| [搬瓦工](https://bandwagonhost.com) | 稳定老牌 | 长期建站、追求稳定性 |
| [Vultr](https://vultr.com) | 全球节点/按小时计费 | 临时测试、多地域部署 |
| [DigitalOcean](https://digitalocean.com) | SSD/开发者友好 | 开发环境、CI/CD |

---

## 免责声明

本工具箱中的脚本仅供学习与合法用途使用。BBR 加速脚本涉及内核参数修改，存在一定操作风险，请务必在修改前了解相关风险并做好备份。Clash 等代理工具的使用请遵守当地法律法规，本仓库不对任何滥用行为负责。

---

## 许可证

[MIT License](LICENSE) — 欢迎 fork、star 和贡献代码。

---

> 🛠 由 [ClashHub](https://clashhub.net) 维护 · 每日自动更新
