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

# 创建 Luanti 数据根目录（确保它存在）
RUN mkdir -p /var/lib/minetest/.minetest

# 暴露端口
EXPOSE 30000/udp
EXPOSE 30000/tcp

# 启动脚本：显式指定世界数据和配置文件的路径
RUN echo '#!/bin/bash\n\
echo "正在启动 Luanti (Minetest) 服务器..."\n\
# --worldpath 指定世界存档存在我们挂载的 Volume 里\n\
exec /usr/games/minetestserver --config /etc/minetest/minetest.conf --worldpath /var/lib/minetest/.minetest/worlds/world "$@"' > /start.sh

RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]