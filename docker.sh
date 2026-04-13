#!/usr/bin/env bash
# Docker + Docker Compose 一键安装
# 用法: wget -qO- https://raw.githubusercontent.com/clashhub-net/vps-guide-xxx/main/docker.sh | bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[*] Docker + Docker Compose 安装脚本${NC}"

# 安装 Docker
echo -e "${YELLOW}[*] 安装 Docker${NC}"
if command -v docker &>/dev/null; then
    echo -e "${GREEN}[+] Docker 已安装: $(docker --version)${NC}"
else
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    echo -e "${GREEN}[+] Docker 安装完成: $(docker --version)${NC}"
fi

# 安装 Docker Compose
echo -e "${YELLOW}[*] 安装 Docker Compose v2${NC}"
if docker compose version &>/dev/null; then
    echo -e "${GREEN}[+] Docker Compose 已安装: $(docker compose version --short)${NC}"
else
    COMPOSE_V=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -SL "https://github.com/docker/compose/releases/download/$COMPOSE_V/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo -e "${GREEN}[+] Docker Compose 安装完成: $(docker-compose --version)${NC}"
fi

# 安装 Portainer (可选Web管理面板)
echo ""
echo "是否安装 Portainer Web管理面板? (y/n)"
read -p "选择: " install_portainer
if [ "$install_portainer" = "y" ]; then
    echo -e "${YELLOW}[*] 安装 Portainer${NC}"
    docker volume create portainer_data
    docker run -d \
        --name portainer \
        --restart unless-stopped \
        -p 9000:9000 \
        -p 8000:8000 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    echo -e "${GREEN}[+] Portainer 已安装: http://localhost:9000${NC}"
fi

echo ""
echo -e "${GREEN}[+] 安装完成！${NC}"
echo "  Docker:      $(docker --version 2>/dev/null || echo 'N/A')"
echo "  Compose:     $(docker-compose --version 2>/dev/null || echo 'N/A')"
echo "  Portainer:   http://localhost:9000 (如已安装)"
