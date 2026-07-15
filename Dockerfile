FROM --platform=linux/amd64 ubuntu:22.04

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 更新并安装必要组件（已移除 openssh-server）
RUN apt update -y && apt install -y \
    minetest-server \
    sudo \
    curl \
    vim \
    git \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 创建 Luanti (Minetest) 数据目录
RUN mkdir -p /var/lib/minetest/.minetest/worlds

# 开放端口：30000 (Luanti)（已移除 22 端口）
EXPOSE 30000/udp
EXPOSE 30000/tcp

# 编写启动脚本（已移除 SSH 启动命令，并使用 exec 优化进程管理）
RUN echo '#!/bin/bash\n\
echo "正在启动 Luanti (Minetest) 服务器..."\n\
exec /usr/games/minetestserver --config /etc/minetest/minetest.conf "$@"' > /start.sh

RUN chmod +x /start.sh

# 设置启动命令
ENTRYPOINT ["/start.sh"]