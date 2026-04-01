# 反序列化漏洞靶场

> ⚠️ **安全警告：本靶场仅供安全研究和教育培训使用，严禁用于非法用途！**

## 📋 项目简介

这是一个完整的教育型反序列化漏洞靶场，包含6个经典反序列化漏洞场景，配套详细的通关手册和自动化利用工具。旨在帮助安全研究人员和学习者深入理解反序列化漏洞的原理、利用和防御。

## 🎯 漏洞场景清单

| 序号 | 漏洞类型 | 技术栈 | 危险等级 | 利用工具 |
|:---|:---|:---|:---:|:---|
| 1 | Java原生反序列化 | Java + Commons Collections | 🔴 高危 | ysoserial |
| 2 | Fastjson反序列化 | Java + Fastjson 1.2.24 | 🔴 高危 | JNDI-Injection-Exploit |
| 3 | Jackson反序列化 | Java + Jackson 2.9.8 | 🟡 中高危 | 手工/XML |
| 4 | Shiro反序列化 | Java + Shiro 1.2.4 | 🔴 高危 | shiro_attack |
| 5 | PHP反序列化POP链 | PHP 7.4 | 🟡 中危 | PHPGGC |
| 6 | PHP Phar反序列化 | PHP 7.4 | 🟡 中高危 | PHPGGC |

## 🚀 快速开始

### 前置要求

- Docker 和 Docker Compose
- Java 8+ (用于运行工具)
- Python 3 (用于运行工具)
- Bash shell

### 一键部署

```bash
# 克隆项目（如果是从Git获取）
git clone <repository_url>
cd deserialization-range

# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

### 访问靶场

部署成功后，访问以下地址：

- **前端首页**: http://localhost:1008
- **Java漏洞场景**: http://localhost:18080/vuln[1-4]
- **PHP漏洞场景**: http://localhost:18081/vuln5.php
- **PHP漏洞场景**: http://localhost:18081/vuln6.php

### 开机自启设置

靶场已配置为开机自动启动，可以使用以下命令管理：

**设置开机自启：**
```bash
vuln-range enable
```

**取消开机自启：**
```bash
vuln-range disable
```

**手动启动靶场：**
```bash
vuln-range start
```

**手动停止靶场：**
```bash
vuln-range stop
```

**重启靶场：**
```bash
vuln-range restart
```

**查看靶场状态：**
```bash
vuln-range status
```

**查看靶场日志：**
```bash
vuln-range logs
```

## 🛠️ 工具安装

靶场提供了自动化工具安装脚本：

```bash
cd tools
bash setup_tools.sh
```

该脚本会自动下载和编译以下工具：

- **ysoserial**: Java反序列化工具
- **PHPGGC**: PHP反序列化工具
- **JNDI-Injection-Exploit**: Fastjson利用工具
- **Shiro_attack**: Shiro利用工具

## 📖 使用指南

### 方式一：手工测试（推荐新手）

1. 访问 [handbook.md](handbook.md) 查看详细通关手册
2. 每个漏洞章节包含：
   - 前置知识（10%）
   - 环境准备（10%）
   - 手工测试方法（40%）
   - 工具利用方法（30%）
   - 修复方案（10%）

3. 按手册步骤逐步学习，每个场景2-3页A4纸内容

### 方式二：自动脚本（快速验证）

```bash
cd tools

# Java原生反序列化
bash native_exploit.sh

# Fastjson反序列化
bash fastjson_exploit.sh

# Jackson反序列化
bash jackson_exploit.sh

# Shiro反序列化
bash shiro_exploit.sh

# PHP反序列化
bash php_exploit.sh

# Phar反序列化
bash phar_exploit.sh
```

### 方式三：手动使用工具

```bash
# Java原生反序列化
java -jar ysoserial.jar CommonsCollections1 "touch /tmp/pwned" | base64 -w 0

# Fastjson (需先启动LDAP服务器)
java -jar JNDI-Injection-Exploit.jar -A 127.0.0.1 -C "touch /tmp/pwned"

# PHP反序列化
./phpggc/phpggc monolog/RCE1 system "touch /tmp/pwned" | base64 -w 0

# Phar反序列化
./phpggc/phpggc -p phar monolog/RCE1 system "touch /tmp/pwned"
```

## 📁 项目结构

```
deserialization-range/
├── docker-compose.yml          # Docker编排配置
├── README.md                   # 本文件
├── handbook.md                 # 完整通关手册
├── vuln-java/                  # Java漏洞场景
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/java/com/vuln/app/
│       ├── controller/         # 4个Java漏洞控制器
│       └── resources/          # HTML模板
├── vuln-php/                   # PHP漏洞场景
│   ├── Dockerfile
│   ├── sql/                    # 数据库初始化
│   ├── vuln5.php               # PHP反序列化POP链
│   └── vuln6.php               # PHP Phar反序列化
├── frontend/                   # 前端页面
│   └── index.html             # 靶场首页
└── tools/                      # 利用工具和脚本
    ├── setup_tools.sh         # 工具安装脚本
    ├── native_exploit.sh      # Java原生反序列化脚本
    ├── fastjson_exploit.sh    # Fastjson利用脚本
    ├── jackson_exploit.sh     # Jackson利用脚本
    ├── shiro_exploit.sh       # Shiro利用脚本
    ├── php_exploit.sh         # PHP反序列化脚本
    ├── phar_exploit.sh        # Phar反序列化脚本
    ├── ysoserial-0.0.6-all.jar
    ├── phpggc/
    ├── JNDI-Injection-Exploit/
    └── Shiro_attack/
```

## 🔍 验证利用结果

### Java容器验证

```bash
# 进入Java容器
docker exec -it vuln-java bash

# 查看创建的文件
ls -la /tmp/*pwned

# 执行命令
cat /tmp/*pwned
```

### PHP容器验证

```bash
# 进入PHP容器
docker exec -it vuln-php bash

# 查看创建的文件
ls -la /tmp/*pwned

# 执行命令
cat /tmp/*pwned
```

## 🛡️ 防御建议

本靶场演示的各种反序列化漏洞，对应的防御方案如下：

### 1. Java原生反序列化
- 升级依赖库版本
- 使用`ValidatingObjectInputStream`或`SerialKiller`
- 设置白名单机制

### 2. Fastjson反序列化
- 升级到Fastjson 1.2.68+
- 启用SafeMode
- 严格限制AutoType白名单

### 3. Jackson反序列化
- 禁用`enableDefaultTyping()`
- 升级到Jackson 2.10.0+
- 使用`PolymorphicTypeValidator`限制类型

### 4. Shiro反序列化
- 升级到Shiro 1.2.5+
- 使用强随机密钥
- 定期更换RememberMe密钥

### 5. PHP反序列化
- 避免使用`unserialize()`处理用户数据
- 使用安全的序列化格式（JSON）
- 设置`allowed_classes`参数

### 6. PHP Phar反序列化
- 禁用`phar`扩展
- 严格验证文件内容
- 重命名上传文件，修改扩展名

## 📊 学习路径建议

### 初学者路径

1. 从**第一章：Java原生反序列化**开始
2. 理解反序列化基本概念
3. 学习手工构造Payload
4. 掌握ysoserial工具使用

### 进阶路径

1. 学习**Fastjson**和**Jackson**漏洞
2. 理解JNDI注入原理
3. 研究不同框架的利用链
4. 掌握自动化工具

### 高级路径

1. 深入研究**PHP反序列化**
2. 学习POP链构造技巧
3. 掌握Phar反序列化
4. 研究绕过技巧

## 🐛 故障排查

### 常见问题

**Q: Docker启动失败？**
```bash
# 检查Docker状态
systemctl status docker
docker --version

# 重启Docker
systemctl restart docker
```

**Q: 端口被占用？**
```bash
# 检查端口占用
lsof -i :1008
lsof -i :8080
lsof -i :8081

# 修改docker-compose.yml中的端口映射
```

**Q: 工具下载失败？**
```bash
# 检查网络连接
ping github.com

# 手动下载工具
cd tools
wget https://github.com/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-0.0.6-all.jar
```

**Q: 利用失败无反应？**
```bash
# 查看容器日志
docker logs vuln-java
docker logs vuln-php
docker logs vuln-frontend

# 进入容器调试
docker exec -it vuln-java bash
```

### 日志查看

```bash
# 查看所有容器日志
docker-compose logs -f

# 查看特定服务日志
docker logs -f vuln-java
docker logs -f vuln-php
docker logs -f vuln-frontend
```

## 🔄 重置环境

如需重置靶场环境：

```bash
cd /root/deserialization-range

# 停止所有服务
docker-compose down

# 删除所有数据（包括MySQL）
docker-compose down -v

# 重新启动
docker-compose up -d
```

## 📝 更新日志

### v1.0.0 (2026-04-01)

- ✅ 完成6个漏洞场景实现
- ✅ 配套完整通关手册
- ✅ 提供自动化利用脚本
- ✅ Docker化一键部署
- ✅ 新手友好的提示系统

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 提交Bug

1. 在Issues中描述问题
2. 提供复现步骤
3. 附上错误日志

### 新增功能

1. Fork项目
2. 创建特性分支
3. 提交代码
4. 发起Pull Request

## 📄 许可证

本项目仅供学习和研究使用。请勿用于任何非法用途。

## 📞 联系方式

- 项目地址: [GitHub Repository]
- 问题反馈: [Issues]
- 学习交流: [Discussion]

## 🎓 致谢

感谢以下开源项目和工具：

- [ysoserial](https://github.com/frohoff/ysoserial) - Java反序列化工具
- [PHPGGC](https://github.com/ambionics/phpggc) - PHP反序列化工具
- [JNDI-Injection-Exploit](https://github.com/welk1n/JNDI-Injection-Exploit) - Fastjson利用工具
- [Shiro_attack](https://github.com/Jayl1n/Shiro_attack) - Shiro利用工具

---

**祝你学习愉快！🎉**

> ⚠️ 再次提醒：本靶场仅供安全研究和教育培训使用，严禁用于非法用途！
