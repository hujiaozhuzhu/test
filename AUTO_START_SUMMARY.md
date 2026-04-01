# 反序列化漏洞靶场 - 开机自启配置完成

## ✅ 配置完成

靶场已成功配置为开机自动启动！

---

## 📦 已创建的文件

### 1. systemd服务文件

**位置**: `/etc/systemd/system/deserialization-range.service`

**功能**: 管理靶场的启动和停止

**状态**: ✅ 已启用

### 2. 管理脚本

**位置**: `/root/deserialization-range/manage.sh`

**功能**: 提供友好的命令接口

**权限**: ✅ 可执行

### 3. 命令别名

**位置**: `/usr/local/bin/vuln-range`

**功能**: 全局命令，可在任何目录使用

---

## 🚀 使用方法

### 快速命令

```bash
# 启动靶场
vuln-range start

# 停止靶场
vuln-range stop

# 重启靶场
vuln-range restart

# 查看状态
vuln-range status

# 查看日志
vuln-range logs

# 设置开机自启
vuln-range enable

# 取消开机自启
vuln-range disable
```

### systemctl命令

```bash
# 启动服务
systemctl start deserialization-range.service

# 停止服务
systemctl stop deserialization-range.service

# 重启服务
systemctl restart deserialization-range.service

# 查看状态
systemctl status deserialization-range.service

# 查看日志
journalctl -u deserialization-range.service
```

---

## 📊 当前状态

### 服务状态

```bash
systemctl status deserialization-range.service
```

**输出**: `active (exited)` ✅

**开机自启**: `enabled` ✅

### 容器状态

```bash
docker ps --filter "name=vuln"
```

**运行中的容器**:
- vuln-frontend (1008:80)
- vuln-java (18080:8080)
- vuln-php (18081:80)
- vuln-mysql (13306:3306)

---

## 🌐 访问地址

- **前端首页**: http://localhost:1008
- **Java漏洞**:
  - vuln1: http://localhost:18080/vuln1
  - vuln2: http://localhost:18080/vuln2
  - vuln3: http://localhost:18080/vuln3
  - vuln4: http://localhost:18080/vuln4
- **PHP漏洞**:
  - vuln5: http://localhost:18081/vuln5.php
  - vuln6: http://localhost:18081/vuln6.php

---

## 🔍 验证开机自启

### 方法1：检查服务状态

```bash
systemctl is-enabled deserialization-range.service
```

**预期输出**: `enabled`

### 方法2：重启系统测试（谨慎！）

```bash
# 备份重要数据后
reboot

# 重启后检查
docker ps --filter "name=vuln"
```

如果所有容器都在运行，说明开机自启配置成功！

---

## 📝 文档清单

| 文档 | 用途 | 位置 |
|:---|:---|:---|
| README.md | 项目说明 | /root/deserialization-range/ |
| handbook.md | 完整通关手册 | /root/deserialization-range/ |
| TECHNICAL_GUIDE.md | 自动化+手工测试 | /root/deserialization-range/ |
| AUTO_START_GUIDE.md | 开机自启指南 | /root/deserialization-range/ |

---

## 🛠️ 故障排查

### 问题：靶场未自动启动

**检查步骤**:

1. 查看服务状态
```bash
systemctl status deserialization-range.service
```

2. 查看系统日志
```bash
journalctl -u deserialization-range.service
```

3. 检查Docker服务
```bash
systemctl status docker
```

4. 手动启动
```bash
vuln-range start
```

### 问题：端口被占用

**解决方法**:

```bash
# 查看端口占用
lsof -i :1008 -i :18080 -i :18081

# 停止占用端口的进程
kill <PID>

# 或修改端口映射
vim /root/deserialization-range/docker-compose.yml
```

---

## 🎉 总结

### ✅ 完成的配置

1. ✅ 创建systemd服务
2. ✅ 启用开机自启
3. ✅ 创建管理脚本
4. ✅ 创建全局命令
5. ✅ 创建完整文档

### 🚀 使用场景

**日常使用**:
```bash
vuln-range status  # 查看状态
curl http://localhost:1008  # 访问靶场
```

**学习测试**:
```bash
cd /root/deserialization-range/tools
bash native_exploit.sh  # 使用工具测试
```

**系统重启后**:
```bash
# 靶场自动启动
docker ps  # 验证容器运行
```

---

**靶场已配置开机自启，随时可用！** 🎊
