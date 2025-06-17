# Ubuntu SSH Docker 容器

这个项目创建了一个可以通过SSH密钥无密码连接的Ubuntu Docker容器，使用标准的`ssh-copy-id`方式配置密钥认证。

## 快速开始

### 一键设置和启动
```bash
# 需要先安装sshpass（如果没有的话）
# macOS: brew install sshpass
# Ubuntu/Debian: sudo apt-get install sshpass

chmod +x setup.sh
./setup.sh
```

这个脚本会：
- 检查并使用现有SSH密钥（~/.ssh/id_rsa）或生成新的项目密钥
- 启动Docker容器（初始支持密码登录）
- 使用`ssh-copy-id`复制公钥到容器
- 自动禁用密码认证，仅保留密钥认证
- 显示连接信息

## 手动使用方法

### 1. 启动容器
```bash
docker-compose up -d
```

### 2. 使用ssh-copy-id配置密钥认证
```bash
# 使用现有密钥
ssh-copy-id -p 2025 root@localhost
# 密码: temp123456

# 或使用指定密钥
ssh-copy-id -i ~/.ssh/id_rsa -p 2025 root@localhost
```

### 3. 禁用密码认证（可选，提高安全性）
```bash
docker exec ubuntu-ssh-container bash -c "
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config &&
    sed -i 's/PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config &&
    service ssh restart
"
```

### 4. SSH连接到容器（无密码）
```bash
ssh root@localhost -p 2025
```

### 5. 可选：添加到SSH配置文件
在 `~/.ssh/config` 中添加：
```
Host ubuntu-docker
    HostName localhost
    Port 2025
    User root
```

然后直接使用：
```bash
ssh ubuntu-docker
```

### 6. 停止容器
```bash
docker-compose down
```

## 配置说明

- **端口映射**: 主机端口2025映射到容器端口22
- **初始认证**: 临时密码认证（temp123456）
- **最终认证**: SSH密钥认证（无密码）
- **安全性**: 自动禁用密码认证，仅保留密钥认证

## 依赖要求

- Docker & Docker Compose
- sshpass（用于自动化ssh-copy-id）
  - macOS: `brew install sshpass`
  - Ubuntu/Debian: `sudo apt-get install sshpass`
  - CentOS/RHEL: `sudo yum install sshpass`

## 文件结构
```
.
├── docker-compose.yaml    # Docker Compose配置
├── setup.sh              # 一键设置脚本（使用ssh-copy-id）
├── ssh_keys/             # SSH密钥目录（如果生成新密钥）
│   ├── id_rsa            # 私钥
│   └── id_rsa.pub        # 公钥
└── README.md             # 说明文档
``` 