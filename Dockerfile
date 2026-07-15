FROM --platform=linux/amd64 ubuntu:22.04

# 设置环境变量，避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive

# 更新并安装必要组件：Luanti服务器、SSH服务、sudo、以及基础工具
RUN apt update -y && apt install -y \
    luanti-server \
    openssh-server \
    sudo \
    curl \
    vim \
    git \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 配置 SSH
RUN mkdir /var/run/sshd
# 设置 root 密码为 'root123' (建议部署后立即通过 SSH 修改)
RUN echo 'root:root123' | chpasswd
# 允许 root 登录 SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# 创建 Luanti 数据目录
RUN mkdir -p /var/lib/minetest/.minetest/worlds

# 开放端口：30000 (Luanti), 22 (SSH)
EXPOSE 30000/udp
EXPOSE 30000/tcp
EXPOSE 22

# 编写启动脚本
RUN echo '#!/bin/bash\n\
service ssh start\n\
echo "SSH 服务已启动..."\n\
echo "正在启动 Luanti 服务器..."\n\
/usr/bin/luantiserver --config /etc/minetest/minetest.conf "$@"' > /start.sh

RUN chmod +x /start.sh

# 设置启动命令
ENTRYPOINT ["/start.sh"]