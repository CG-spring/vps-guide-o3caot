#!/usr/bin/env bash
# mihomo/Clash.Meta 一键安装脚本
# 用法: wget -qO- https://raw.githubusercontent.com/clashhub-net/vps-guide-xxx/main/clash.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="/etc/mihomo"
CONFIG_FILE="$INSTALL_DIR/config.yaml"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  mihomo 一键安装脚本${NC}"
echo -e "${BLUE}========================================${NC}"

install_deps() {
    echo -e "${GREEN}[*] 安装依赖${NC}"
    if command -v apt &>/dev/null; then
        apt update && apt install -y curl wget jq
    elif command -v yum &>/dev/null; then
        yum install -y curl wget jq
    fi
}

download_mihomo() {
    echo -e "${GREEN}[*] 下载 mihomo${NC}"
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) META_ARCH="linux-amd64-" ;;
        aarch64) META_ARCH="linux-arm64-" ;;
        *) echo "不支持的架构: $ARCH"; exit 1 ;;
    esac
    
    LATEST=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | jq -r '.tag_name')
    URL="https://github.com/MetaCubeX/mihomo/releases/download/${LATEST}/mihomo-${META_ARCH}compatible-v${LATEST}.gz"
    
    mkdir -p $INSTALL_DIR
    wget -qO- "$URL" | gzip -d > $INSTALL_DIR/mihomo
    chmod +x $INSTALL_DIR/mihomo
    echo -e "${GREEN}[+] mihomo 下载完成${NC}"
}

create_service() {
    echo -e "${GREEN}[*] 创建 Systemd 服务${NC}"
    cat > /etc/systemd/system/mihomo.service << 'EOF'
[Unit]
Description=mihomo Daemon
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/etc/mihomo/mihomo -d /etc/mihomo
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable mihomo
    echo -e "${GREEN}[+] 服务已启用${NC}"
}

echo ""
echo "请提供订阅地址（留空则创建示例配置）:"
read -p "订阅URL: " sub_url

if [ -n "$sub_url" ]; then
    echo -e "${GREEN}[*] 下载配置${NC}"
    curl -sL "$sub_url" -o $CONFIG_FILE
else
    cat > $CONFIG_FILE << 'EOF'
# mihomo 配置示例
# 请替换为你的订阅地址或节点信息
port: 7890
socks-port: 7891
allow-lan: false
mode: rule
log-level: info
external-controller: 0.0.0.0:9090

proxies:
  - name: "示例节点"
    type: ss
    server: 127.0.0.1
    port: 8388
    cipher: aes-256-gcm
    password: "password"

proxy-groups:
  - name: "PROXY"
    type: select
    proxies:
      - 示例节点

rules:
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
EOF
    echo -e "${YELLOW}[!] 已创建示例配置，请编辑 $CONFIG_FILE${NC}"
fi

install_deps
download_mihomo
create_service
systemctl start mihomo

echo ""
echo -e "${GREEN}[+] 安装完成！${NC}"
echo "  管理面板: http://localhost:9090"
echo "  HTTP代理: http://localhost:7890"
echo "  SOCKS5:   socks5://localhost:7891"
echo ""
echo "常用命令:"
echo "  systemctl start mihomo   # 启动"
echo "  systemctl stop mihomo    # 停止"
echo "  systemctl restart mihomo # 重启"
echo "  journalctl -u mihomo -f   # 查看日志"
