# VPS工具箱 0413

> 实用的VPS测速、优化、部署脚本集合

## 工具列表

| 脚本 | 功能 | 使用 |
|------|------|------|
| `bench.sh` | 服务器基准测试 | `wget -qO- https://raw.githubusercontent.com/.../bench.sh \| bash` |
| `bbr.sh` | BBR/LotServer加速 | `wget -qO- https://raw.githubusercontent.com/.../bbr.sh \| bash` |
| `clash.sh` | 一键安装Clash | `wget -qO- https://raw.githubusercontent.com/.../clash.sh \| bash` |
| `docker.sh` | Docker+Compose | `wget -qO- https://raw.githubusercontent.com/.../docker.sh \| bash` |
| `wireguard.sh` | WireGuard搭建 | `wget -qO- https://raw.githubusercontent.com/.../wireguard.sh \| bash` |

## bench.sh 功能

- 系统信息（CPU/内存/_swap）
- 磁盘IO测试（dd 1GB读写）
- 带宽测速（东京/法兰克福/迈阿密/中国节点）
- 路由追踪
- 流媒体解锁检测（Netflix/Disney+/YouTube）

## bbr.sh 支持

- Google BBR
- BBRplus
- LotServer
- 锐速

## clash.sh 支持

- mihomo (推荐)
- Clash.Meta
- 支持 Systemd 管理
- 自动配置开机启动

## 适用系统

Ubuntu 18.04+ / Debian 10+ / CentOS 7+

## 推荐VPS

[![vpsvip.net](https://img.shields.io/badge/VPS-vpsvip.net-blue)](https://vpsvip.net)

---

> 由 [ClashHub](https://clashhub.net) 维护 · 每日自动更新
