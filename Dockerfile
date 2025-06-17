FROM ubuntu:22.04

# 设置环境变量避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV ROOT_PASSWORD=123456

# 更新系统并安装SSH服务器
RUN apt-get update && \
    apt-get install -y openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# 创建启动脚本
RUN echo '#!/bin/bash\n\
echo "root:${ROOT_PASSWORD}" | chpasswd\n\
service ssh start\n\
tail -f /dev/null' > /start.sh && \
    chmod +x /start.sh

# 暴露SSH端口
EXPOSE 22

# 启动脚本
CMD ["/start.sh"] 