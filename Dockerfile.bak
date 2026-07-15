FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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

EXPOSE 30000/udp
EXPOSE 30000/tcp

RUN echo '#!/bin/bash\n\
echo "正在启动 Luanti (Minetest) 服务器..."\n\
exec /usr/games/minetestserver --config /etc/minetest/minetest.conf "$@"' > /start.sh

RUN chmod +x /start.sh

# 设置启动命令
ENTRYPOINT ["/start.sh"]