# 反序列化漏洞靶场 - 源码压缩包

## 📦 压缩包信息

**文件名**: deserialization-range.zip  
**大小**: 66KB  
**文件数**: 49个  
**创建日期**: 2026-04-02  

## 📁 项目结构

```
deserialization-range/
├── README.md                              # 项目说明文档
├── handbook.md                           # 完整通关手册
├── TECHNICAL_GUIDE.md                   # 自动化与手工测试技术手册
├── AUTO_START_GUIDE.md                  # 开机自启使用指南
├── AUTO_START_SUMMARY.md                 # 开机自启配置总结
├── docker-compose.yml                    # Docker编排配置
├── start.sh                             # 快速启动脚本
├── manage.sh                            # 靶场管理脚本
├── verify.sh                            # 项目验证脚本
├── deserialization-range.service          # systemd服务文件
│
├── vuln-java/                          # Java漏洞场景
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/java/com/vuln/app/
│       ├── VulnApplication.java
│       └── controller/
│           ├── Vuln1NativeDeserializationController.java
│           ├── Vuln2FastjsonController.java
│           ├── Vuln3JacksonController.java
│           └── Vuln4ShiroController.java
│   └── src/main/resources/
│       ├── application.yml
│       └── templates/
│           ├── vuln1.html
│           ├── vuln2.html
│           ├── vuln3.html
│           └── vuln4.html
│
├── vuln-php/                           # PHP漏洞场景
│   ├── Dockerfile
│   ├── vuln5.php                        # PHP反序列化POP链
│   ├── vuln6.php                        # PHP Phar反序列化
│   └── sql/
│       └── init.sql                     # 数据库初始化
│
├── frontend/                            # 前端页面
│   └── index.html
│
└── tools/                               # 利用工具脚本
    ├── setup_tools.sh                    # 工具安装脚本
    ├── native_exploit.sh                 # Java原生反序列化
    ├── fastjson_exploit.sh               # Fastjson利用
    ├── jackson_exploit.sh                # Jackson利用
    ├── shiro_exploit.sh                  # Shiro利用
    ├── php_exploit.sh                    # PHP反序列化
    └── phar_exploit.sh                   # Phar反序列化
```

## 📊 文件统计

| 类型 | 文件数 | 说明 |
|:---|:---:|:---|
| Java源码 | 10 | Application + 4个Controller |
| Java资源 | 5 | application.yml + 4个HTML模板 |
| PHP源码 | 3 | 2个漏洞页面 + SQL初始化 |
| 前端文件 | 1 | 首页HTML |
| 工具脚本 | 7 | 6个利用脚本 + 1个安装脚本 |
| 配置文件 | 2 | docker-compose.yml + Dockerfile ×2 |
| 管理脚本 | 4 | start.sh + manage.sh + verify.sh + systemd |
| 文档文件 | 5 | README + handbook + 技术手册 + 开机自启 ×2 |
| **总计** | **49** | - |

## 📝 文档说明

| 文档 | 大小 | 用途 | 行数 |
|:---|:---|:---|:---|
| README.md | 8.9K | 项目说明和使用指南 | - |
| handbook.md | 27K | 完整通关手册（6个漏洞） | 1063 |
| TECHNICAL_GUIDE.md | 32K | 自动化与手工测试技术 | 1379 |
| AUTO_START_GUIDE.md | 5.1K | 开机自启使用指南 | - |
| AUTO_START_SUMMARY.md | 3.8K | 开机自启配置总结 | - |

## 🎯 漏洞场景

### Java漏洞（4个）

| 序号 | 漏洞类型 | 技术栈 | 文件 |
|:---|:---|:---|:---|
| 1 | Java原生反序列化 | Commons Collections 3.1 | Vuln1NativeDeserializationController.java |
| 2 | Fastjson反序列化 | Fastjson 1.2.24 | Vuln2FastjsonController.java |
| 3 | Jackson反序列化 | Jackson 2.9.8 | Vuln3JacksonController.java |
| 4 | Shiro反序列化 | Shiro 1.2.4 | Vuln4ShiroController.java |

### PHP漏洞（2个）

| 序号 | 漏洞类型 | 技术栈 | 文件 |
|:---|:---|:---|:---|
| 5 | PHP反序列化POP链 | PHP 7.4 | vuln5.php |
| 6 | PHP Phar反序列化 | PHP 7.4 | vuln6.php |

## 🚀 快速开始

### 1. 解压文件

```bash
unzip deserialization-range.zip
cd deserialization-range
```

### 2. 启动靶场

```bash
# 方法1：使用启动脚本
bash start.sh

# 方法2：使用管理命令
vuln-range start
```

### 3. 访问靶场

```
前端首页: http://localhost:1008
Java漏洞: http://localhost:18080/vuln[1-4]
PHP漏洞: http://localhost:18081/vuln[5-6].php
```

### 4. 安装工具（可选）

```bash
cd tools
bash setup_tools.sh
```

## 🔧 系统要求

### 基础要求
- Linux系统（推荐Ubuntu 20.04+）
- Docker 20.10+
- Docker Compose 1.25+
- 至少2GB可用内存
- 至少10GB可用磁盘空间

### 工具要求（可选）
- Java 8+ (运行ysoserial)
- Python 3.6+ (运行PHPGGC)
- Python 2.7+ (运行Shiro_attack)
- Git (下载工具)

## ⚠️ 注意事项

1. **端口占用**
   - 默认端口：1008, 18080, 18081, 13306
   - 如端口冲突，修改docker-compose.yml

2. **Docker权限**
   - 确保用户有Docker访问权限
   - 或使用sudo运行

3. **网络连接**
   - 初次构建需要下载Docker镜像
   - 工具安装需要访问GitHub

4. **安全警告**
   - 本靶场仅供学习和研究
   - 严禁用于非法用途
   - 所有服务绑定本地回环地址

## 📞 问题排查

### 启动失败

```bash
# 查看Docker状态
docker ps

# 查看容器日志
docker-compose logs

# 检查端口占用
lsof -i :1008 -i :18080 -i :18081
```

### 工具安装失败

```bash
# 检查网络连接
ping github.com

# 手动下载工具
cd tools
wget https://github.com/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-0.0.6-all.jar
```

### 访问失败

```bash
# 检查容器运行状态
docker ps | grep vuln

# 检查防火墙
sudo ufw status

# 测试服务响应
curl http://localhost:1008
curl http://localhost:18080
curl http://localhost:18081
```

## 📖 学习路径

### 初学者
1. 阅读 README.md 了解项目
2. 阅读 TECHNICAL_GUIDE.md 学习工具使用
3. 从简单漏洞开始（如Java原生反序列化）
4. 按handbook.md逐步学习

### 进阶者
1. 研究不同gadget链
2. 尝试绕过技巧
3. 开发自定义利用脚本

### 高级者
1. 挖掘新的gadget链
2. 开发自动化框架
3. 贡献开源项目

## 🎊 总结

### ✅ 压缩包包含

- ✅ 完整源代码（Java + PHP）
- ✅ Docker配置文件
- ✅ 完整文档（5个文档）
- ✅ 自动化脚本（8个脚本）
- ✅ 工具脚本（7个利用脚本）
- ✅ 开机自启配置
- ✅ 项目验证脚本

### 📊 文件统计

- **总文件数**: 49个
- **压缩大小**: 66KB
- **文档行数**: 3000+行
- **代码行数**: 335行

### 🚀 使用场景

- ✅ 安全教育培训
- ✅ CTF竞赛训练
- ✅ 渗透测试练习
- ✅ 漏洞研究分析

---

**压缩包已创建，解压后即可使用！** 🎉

> ⚠️ **重要提醒**：本靶场仅供安全研究和教育培训使用，严禁用于非法用途！
