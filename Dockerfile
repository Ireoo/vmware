FROM ubuntu:latest

# 设置环境变量避免交互式安装
ENV DEBIAN_FRONTEND=noninteractive
ENV ROOT_PASSWORD=123456

# 更新系统并安装SSH服务器
RUN apt-get update && \
    apt-get install -y openssh-server git curl wget zsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 nvm, Node.js 和全局包
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 22

RUN apt-get update && apt-get install -y --no-install-recommends build-essential libssl-dev && \
    # 安装 nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    # 加载 nvm
    . "$NVM_DIR/nvm.sh" && \
    # 安装指定版本的 Node.js
    nvm install "$NODE_VERSION" && \
    # 设置默认版本
    nvm alias default "$NODE_VERSION" && \
    # 使用默认版本
    nvm use default && \
    # 安装全局 npm 包
    npm install -g yarn pnpm npm@latest && \
    # 创建一个指向默认 Node.js 版本的符号链接
    ln -s "$(nvm_version_path default)" "$NVM_DIR/default" && \
    # 清理工作，减小镜像体积
    apt-get purge -y build-essential libssl-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 将 nvm 安装的 node 添加到 PATH
ENV PATH "$NVM_DIR/default/bin:$PATH"

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 设置 zsh 为默认 shell
RUN chsh -s $(which zsh)
RUN echo "export NVM_DIR=\"$NVM_DIR\"" >> /etc/zsh/zshenv && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /etc/zsh/zshenv && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && . \"$NVM_DIR/bash_completion\"" >> /etc/zsh/zshenv
    
RUN echo "export NVM_DIR=\"$NVM_DIR\"" >> /etc/profile && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /etc/profile && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && . \"$NVM_DIR/bash_completion\"" >> /etc/profile

RUN echo "export NVM_DIR=\"$NVM_DIR\"" >> /root/.bashrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /root/.bashrc && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && . \"$NVM_DIR/bash_completion\"" >> /root/.bashrc

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
EXPOSE 22 5173 3001

# 启动脚本
CMD ["/start.sh"]
