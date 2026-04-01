# 反序列化漏洞靶场 - 开机自启设置指南

## ✅ 已完成配置

靶场已成功配置为开机自动启动！

---

## 🚀 快速命令

### 启动/停止靶场

```bash
# 启动靶场
vuln-range start

# 停止靶场
vuln-range stop

# 重启靶场
vuln-range restart
```

### 查看状态

```bash
# 查看靶场状态
vuln-range status

# 查看靶场日志
vuln-range logs
```

### 开机自启管理

```bash
# 设置开机自启（已默认开启）
vuln-range enable

# 取消开机自启
vuln-range disable
```

---

## 📊 服务状态

查看开机自启服务状态：

```bash
systemctl status deserialization-range.service
```

预期输出：
```
● deserialization-range.service - Deserialization Vulnerability Range
     Loaded: loaded (/etc/systemd/system/deserialization-range.service; enabled)
     Active: active (exited)
```

**关键字说明：**
- `enabled` - 开机自启已启用
- `active` - 服务正在运行
- `inactive` - 服务未运行

---

## 🔍 验证开机自启

### 方法1：查看服务状态

```bash
systemctl is-enabled deserialization-range.service
```

如果输出 `enabled`，说明开机自启已设置。

### 方法2：重启系统测试

```bash
# 重启系统（谨慎操作！）
reboot
```

重启后，检查容器是否自动启动：

```bash
docker ps --filter "name=vuln"
```

如果看到4个容器，说明开机自启正常工作。

---

## 🛠️ 服务管理

### 手动启动服务

```bash
systemctl start deserialization-range.service
```

### 手动停止服务

```bash
systemctl stop deserialization-range.service
```

### 重启服务

```bash
systemctl restart deserialization-range.service
```

### 查看服务日志

```bash
# 查看系统日志
journalctl -u deserialization-range.service -f

# 查看Docker日志
docker logs -f vuln-frontend
docker logs -f vuln-java
docker logs -f vuln-php
```

---

## 📁 配置文件

### systemd服务文件

位置：`/etc/systemd/system/deserialization-range.service`

```ini
[Unit]
Description=Deserialization Vulnerability Range
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/root/deserialization-range
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

### 管理脚本

位置：`/usr/local/bin/vuln-range`

这是指向 `/root/deserialization-range/manage.sh` 的符号链接，提供友好的命令接口。

---

## 🔧 故障排查

### 问题1：服务启动失败

**症状：**
```bash
vuln-range start
Job for deserialization-range.service failed.
```

**解决方法：**

```bash
# 查看详细错误
systemctl status deserialization-range.service

# 查看系统日志
journalctl -xe

# 手动启动查看错误
cd /root/deserialization-range
docker-compose up -d
```

### 问题2：容器未启动

**症状：**
```bash
docker ps --filter "name=vuln"
# 没有输出
```

**解决方法：**

```bash
# 查看容器日志
cd /root/deserialization-range
docker-compose logs

# 手动启动容器
docker-compose up -d

# 检查Docker状态
systemctl status docker
```

### 问题3：开机未自动启动

**症状：**
```bash
systemctl is-enabled deserialization-range.service
disabled
```

**解决方法：**

```bash
# 重新启用服务
systemctl enable deserialization-range.service

# 验证
systemctl is-enabled deserialization-range.service
# 应该输出 enabled
```

### 问题4：端口被占用

**症状：**
```bash
vuln-range start
Bind for 0.0.0.0:1008 failed: port is already allocated
```

**解决方法：**

```bash
# 查看端口占用
lsof -i :1008 -i :18080 -i :18081

# 停止占用端口的进程
kill <PID>

# 或者修改docker-compose.yml中的端口映射
```

---

## 📊 常用命令速查

| 命令 | 说明 |
|:---|:---|
| `vuln-range start` | 启动靶场 |
| `vuln-range stop` | 停止靶场 |
| `vuln-range restart` | 重启靶场 |
| `vuln-range status` | 查看状态 |
| `vuln-range logs` | 查看日志 |
| `vuln-range enable` | 设置开机自启 |
| `vuln-range disable` | 取消开机自启 |
| `systemctl start deserialization-range.service` | 启动服务 |
| `systemctl stop deserialization-range.service` | 停止服务 |
| `systemctl restart deserialization-range.service` | 重启服务 |
| `systemctl status deserialization-range.service` | 查看服务状态 |
| `journalctl -u deserialization-range.service` | 查看服务日志 |

---

## 🎉 总结

### ✅ 已完成配置

1. ✅ 创建systemd服务文件
2. ✅ 启用开机自启
3. ✅ 创建管理脚本
4. ✅ 创建命令别名

### 🚀 使用方法

```bash
# 启动靶场
vuln-range start

# 查看状态
vuln-range status

# 查看日志
vuln-range logs
```

### 🌐 访问地址

- **前端**: http://localhost:1008
- **Java**: http://localhost:18080/vuln[1-4]
- **PHP**: http://localhost:18081/vuln[5-6].php

### 📞 需要帮助？

- 查看详细文档: `README.md`
- 查看技术手册: `TECHNICAL_GUIDE.md`
- 查看通关手册: `handbook.md`

---

**靶场已配置开机自启，重启系统后自动运行！** 🎊
