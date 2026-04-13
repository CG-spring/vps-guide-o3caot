#!/usr/bin/env bash
# VPS Benchmark Script
# 用法: wget -qO- https://raw.githubusercontent.com/clashhub-net/vps-guide-xxx/main/bench.sh | bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  VPS Benchmark Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 系统信息
echo -e "${YELLOW}[测试] 系统信息${NC}"
if command -v neofetch &>/dev/null; then
    neofetch --off 2>/dev/null || echo "$(uname -a)"
else
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Kernel: $(uname -r)"
    echo "Arch: $(uname -m)"
fi

# CPU信息
echo ""
echo -e "${YELLOW}[测试] CPU${NC}"
if [ -f /proc/cpuinfo ]; then
    echo "型号: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//')"
    echo "核心数: $(nproc)"
fi

# 内存
echo ""
echo -e "${YELLOW}[测试] 内存${NC}"
free -h | grep -E "Mem|Swap"

# 磁盘IO
echo ""
echo -e "${YELLOW}[测试] 磁盘IO (dd 1GB)${NC}"
io1=$(dd if=/dev/zero of=test_io bs=64k count=16000 conv=fdatasync 2>&1 | grep copied)
io2=$(dd if=test_io of=/dev/null bs=64k count=16000 2>&1 | grep copied)
rm -f test_io
echo "写: $io1"
echo "读: $io2"

# 带宽测速节点
echo ""
echo -e "${YELLOW}[测试] 带宽测速${NC}"

speedtest_node() {
    name=$1
    url=$2
    echo -n "  $name ... "
    speed=$(curl -s -m 10 -o /dev/null -w "%{speed_download}" "$url" 2>/dev/null)
    if [ -n "$speed" ] && [ "$speed" != "0" ]; then
        echo -e "${GREEN}$(echo "scale=2; $speed/1024/1024" | bc) MB/s${NC}"
    else
        echo -e "${RED}失败${NC}"
    fi
}

speedtest_node "东京" "http://speedtest.tokyo2.linode.com/100MB-tokyo.bin"
speedtest_node "新加坡" "http://speedtest.singapore.linode.com/100MB-singapore.bin"
speedtest_node "法兰克福" "http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin"
speedtest_node "伦敦" "http://speedtest.london.linode.com/100MB-london.bin"
speedtest_node "纽瓦克" "http://speedtest.newark.linode.com/100MB-newark.bin"

# 流媒体解锁
echo ""
echo -e "${YELLOW}[测试] 流媒体解锁${NC}"

check_streaming() {
    svc=$1
    url=$2
    code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 8 "$url" 2>/dev/null)
    if [ "$code" = "200" ]; then
        echo -e "  $svc: ${GREEN}支持 ✓${NC}"
    else
        echo -e "  $svc: ${RED}不支持 ✗${NC}"
    fi
}

check_streaming "Netflix" "https://www.netflix.com/"
check_streaming "YouTube" "https://www.youtube.com/"
check_streaming "Disney+" "https://www.disneyplus.com/"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "测试完成: $(date '+%Y-%m-%d %H:%M:%S')"
