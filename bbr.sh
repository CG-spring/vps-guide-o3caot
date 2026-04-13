#!/usr/bin/env bash
# BBR/LotServer 加速脚本
# 用法: wget -qO- https://raw.githubusercontent.com/clashhub-net/vps-guide-xxx/main/bbr.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[*] BBR/LotServer 加速安装脚本${NC}"
echo ""

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[!] 请使用 root 权限运行${NC}"
        exit 1
    fi
}

enable_bbr() {
    echo -e "${YELLOW}[*] 开启 BBR${NC}"
    cat >> /etc/sysctl.conf << EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
    sysctl -p
    if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
        echo -e "${GREEN}[+] BBR 已启用${NC}"
    else
        echo -e "${RED}[-] BBR 启用失败${NC}"
    fi
}

enable_bbrplus() {
    echo -e "${YELLOW}[*] 安装 BBRplus${NC}"
    wget -qO /tmp/bbrplus.sh https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/bbrplus.sh
    chmod +x /tmp/bbrplus.sh
    /tmp/bbrplus.sh
}

enable_lotserver() {
    echo -e "${YELLOW}[*] 安装 LotServer${NC}"
    wget -qO appex.sh https://raw.githubusercontent.com/0oVicero0/serverSpeeder_Install/master/appex.sh
    chmod +x appex.sh
    bash appex.sh install
}

echo "请选择:"
echo "1) 启用原生 BBR (推荐)"
echo "2) 安装 BBRplus"
echo "3) 安装 LotServer (锐速)"
read -p "请输入选项 [1-3]: " choice

case $choice in
    1) check_root; enable_bbr ;;
    2) check_root; enable_bbrplus ;;
    3) check_root; enable_lotserver ;;
    *) echo "无效选项"; exit 1 ;;
esac

echo -e "${GREEN}[*] 安装完成${NC}"
