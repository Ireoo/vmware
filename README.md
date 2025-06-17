# Ubuntu SSH Docker 容器

这个项目创建了一个可以通过SSH连接的Ubuntu Docker容器。

## 使用方法

### 1. 启动容器
```bash
docker-compose up -d
```

### 2. 查看容器状态
```bash
docker-compose ps
```

### 3. SSH连接到容器
```bash
ssh root@localhost -p 2025
```

默认密码是：`123456`

### 4. 停止容器
```bash
docker-compose down
```

## 配置说明

- **端口映射**: 主机端口2025映射到容器端口22
- **root密码**: 默认为123456（可在docker-compose.yaml中修改ROOT_PASSWORD环境变量）
- **SSH访问**: 已启用root登录和密码认证

## 安全提醒

⚠️ 这个配置仅适用于开发和测试环境。在生产环境中，请：
- 修改默认密码
- 使用SSH密钥认证而非密码认证
- 限制网络访问
- 创建非root用户进行日常操作 