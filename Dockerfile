FROM --platform=linux/amd64 ubuntu:22.04

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 更新并安装必要组件
# 在 Ubuntu 22.04 中，包名仍为 minetest-server
RUN apt update -y && apt install -y \
    minetest-server \
    openssh-server \
    sudo \
    curl \
    vim \
    git \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 配置 SSH
RUN mkdir /var/run/sshd
# 设置 root 密码为 'root123'
RUN echo 'root:root123' | chpasswd
# 允许 root 登录 SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# 创建 Luanti (Minetest) 数据目录并设置权限
RUN mkdir -p /var/lib/minetest/.minetest/worlds
RUN chown -R minetest:minetest /var/lib/minetest

# 开放端口：30000 (Luanti), 22 (SSH)
EXPOSE 30000/udp
EXPOSE 30000/tcp
EXPOSE 22

# 编写启动脚本
# 注意：Ubuntu 22.04 中二进制路径为 /usr/games/minetestserver
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH 服务已启动..."\n\
echo "正在启动 Luanti (Minetest) 服务器..."\n\
# 切换到 minetest 用户运行服务器以保证安全，或者直接 root 运行\n\
/usr/games/minetestserver --config /etc/minetest/minetest.conf "$@"' > /start.sh

RUN chmod +x /start.sh

# 设置启动命令
ENTRYPOINT ["/start.sh"]