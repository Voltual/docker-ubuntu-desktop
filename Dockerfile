FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install -y \
    minetest-server \
    sudo \
    curl \
    vim \
    git \
    tzdata \
    socat \          # ← 新增
    && rm -rf /var/lib/apt/lists/*

# 创建数据目录
RUN mkdir -p /var/lib/minetest/.minetest/worlds/world

# 暴露端口
EXPOSE 6080/tcp      # 给 Railway TCP Proxy 用
EXPOSE 30000/udp     # Luanti 实际监听

# 启动脚本（关键部分）
RUN echo '#!/bin/bash
echo "启动 Luanti 服务器 + socat 转发..."

# 后台启动 socat：把外部 TCP 6080 转成内部 UDP 30000
socat TCP-LISTEN:6080,reuseaddr,fork UDP:127.0.0.1:30000 &

# 启动 Luanti（监听 UDP 30000）
exec /usr/games/minetestserver \
    --config /etc/minetest/minetest.conf \
    --worldpath /var/lib/minetest/.minetest/worlds/world \
    --port 30000 \
    "$@"
' > /start.sh

RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
