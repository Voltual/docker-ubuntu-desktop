FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install -y \
    minetest-server \
    sudo \
    curl \
    vim \
    git \
    tzdata \
    socat \
    net-tools \
    lsof \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/minetest/.minetest/worlds/world

EXPOSE 6080/tcp
EXPOSE 30000/udp

COPY <<'EOF' /start.sh
#!/bin/bash
echo "启动 Luanti 服务器 + socat 转发..."

socat TCP-LISTEN:6080,reuseaddr,fork,keepalive,sndbuf=65536,rcvbuf=65536 UDP:127.0.0.1:30000 &

exec /usr/games/minetestserver \
    --config /etc/minetest/minetest.conf \
    --world /var/lib/minetest/.minetest/worlds/world \
    --port 30000 \
    "$@"
EOF

RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
