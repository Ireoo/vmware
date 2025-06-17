#!/bin/bash

echo "=== Ubuntu SSH Docker 容器设置 ==="

# 检查是否已有SSH密钥
if [ -f ~/.ssh/id_rsa ]; then
    echo "✓ 使用现有的SSH密钥 ~/.ssh/id_rsa"
    SSH_KEY_PATH="$HOME/.ssh/id_rsa"
else
    # 创建项目专用的SSH密钥
    mkdir -p ssh_keys
    if [ -f ssh_keys/id_rsa ]; then
        echo "✓ 使用项目SSH密钥"
    else
        echo "生成新的SSH密钥..."
        ssh-keygen -t rsa -b 4096 -f ssh_keys/id_rsa -N "" -C "docker-ubuntu-ssh"
        echo "✓ SSH密钥已生成"
    fi
    SSH_KEY_PATH="$(pwd)/ssh_keys/id_rsa"
    chmod 600 ssh_keys/id_rsa
    chmod 644 ssh_keys/id_rsa.pub
fi

echo ""
echo "=== 构建并启动容器 ==="
docker-compose up --build -d

echo ""
echo "等待容器启动..."
sleep 10

echo ""
echo "=== 配置SSH密钥认证 ==="
echo "临时密码: 123456"
echo "正在复制SSH公钥到容器..."

# 使用ssh-copy-id复制公钥
SSHPASS=123456 sshpass -e ssh-copy-id -i "$SSH_KEY_PATH" -p 2025 -o StrictHostKeyChecking=no root@localhost

if [ $? -eq 0 ]; then
    echo "✓ SSH公钥复制成功"
    
    echo ""
    echo "=== 禁用密码认证 ==="
    # 禁用密码认证，只保留密钥认证
    docker exec ubuntu-ssh-container bash -c "
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config &&
        sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config &&
        service ssh restart
    "
    echo "✓ 已禁用密码认证，仅保留密钥认证"
    
    echo ""
    echo "=== 设置完成 ==="
    echo "SSH连接命令（无密码）："
    echo "ssh -i $SSH_KEY_PATH root@localhost -p 2025"
    echo ""
    echo "或者添加到SSH配置 (~/.ssh/config)："
    echo "Host ubuntu-docker"
    echo "    HostName localhost"
    echo "    Port 2025"
    echo "    User root"
    echo "    IdentityFile $SSH_KEY_PATH"
    echo ""
    echo "然后可以直接使用: ssh ubuntu-docker"
else
    echo "❌ SSH公钥复制失败，请检查容器是否正常启动"
    echo "可以手动尝试: ssh root@localhost -p 2025 (密码: 123456)"
fi 