# 反序列化漏洞靶场 - 源码整理完成

## ✅ 整理完成

源码已整理并打包完成！

---

## 📦 压缩包信息

**文件名**: `/root/deserialization-range.zip`  
**大小**: 68KB  
**文件数**: 50个  
**创建日期**: 2026-04-02  

---

## 🧹 清理内容

### 已删除的文件
- ❌ `vuln-java/SimpleServer.java` - 临时测试文件
- ❌ `vuln-php/public/` - 空目录

### 保留的内容
- ✅ 所有核心源代码
- ✅ Docker配置文件
- ✅ 所有文档文件
- ✅ 所有脚本文件
- ✅ 工具脚本

---

## 📁 项目结构（50个文件）

```
deserialization-range/                     # 项目根目录
├── README.md (8.9K)                   # 项目说明
├── handbook.md (27K)                   # 完整通关手册
├── TECHNICAL_GUIDE.md (32K)           # 技术手册
├── AUTO_START_GUIDE.md (5.1K)          # 开机自启指南
├── AUTO_START_SUMMARY.md (3.8K)        # 开机自启总结
├── PACKAGE_INFO.md (2.8K)              # 压缩包信息 ⭐ 新增
│
├── docker-compose.yml (1.5K)             # Docker编排
├── deserialization-range.service (323B)   # systemd服务
├── start.sh (1.6K)                     # 启动脚本
├── manage.sh (1.8K)                    # 管理脚本
├── verify.sh (4.0K)                    # 验证脚本
│
├── vuln-java/                          # Java漏洞场景
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/vuln/app/
│       │   ├── VulnApplication.java
│       │   └── controller/
│       │       ├── Vuln1NativeDeserializationController.java
│       │       ├── Vuln2FastjsonController.java
│       │       ├── Vuln3JacksonController.java
│       │       └── Vuln4ShiroController.java
│       └── resources/
│           ├── application.yml
│           └── templates/
│               ├── vuln1.html
│               ├── vuln2.html
│               ├── vuln3.html
│               └── vuln4.html
│
├── vuln-php/                           # PHP漏洞场景
│   ├── Dockerfile
│   ├── vuln5.php                        # PHP反序列化POP链
│   ├── vuln6.php                        # PHP Phar反序列化
│   └── sql/
│       └── init.sql                     # 数据库初始化
│
├── frontend/                            # 前端页面
│   └── index.html (5.4K)
│
└── tools/                               # 工具脚本
    ├── setup_tools.sh (3.0K)            # 工具安装
    ├── native_exploit.sh (1.2K)         # Java原生
    ├── fastjson_exploit.sh (1.3K)       # Fastjson
    ├── jackson_exploit.sh (1.6K)        # Jackson
    ├── shiro_exploit.sh (1.3K)          # Shiro
    ├── php_exploit.sh (0.9K)            # PHP反序列化
    └── phar_exploit.sh (1.1K)           # Phar反序列化
```

---

## 📊 文件统计

| 类别 | 文件数 | 总大小 |
|:---|:---:|:---|
| Java源码 | 10 | ~15KB |
| Java资源 | 5 | ~15KB |
| PHP源码 | 3 | ~17KB |
| 前端文件 | 1 | ~5KB |
| 工具脚本 | 7 | ~11KB |
| 配置文件 | 3 | ~2KB |
| 管理脚本 | 3 | ~7KB |
| 文档文件 | 6 | ~81KB |
| **总计** | **50** | **~153KB** (压缩后68KB)

---

## 📝 文档列表

| 文档 | 大小 | 行数 | 说明 |
|:---|:---|:---:|:---|
| README.md | 8.9K | - | 项目说明和使用指南 |
| handbook.md | 27K | 1063 | 完整通关手册（6个漏洞） |
| TECHNICAL_GUIDE.md | 32K | 1379 | 自动化与手工测试技术手册 |
| AUTO_START_GUIDE.md | 5.1K | - | 开机自启使用指南 |
| AUTO_START_SUMMARY.md | 3.8K | - | 开机自启配置总结 |
| PACKAGE_INFO.md | 2.8K | - | 压缩包信息说明 ⭐ 新增 |
| **总计** | **~79K** | **~2442** | 完整文档体系 |

---

## 🎯 漏洞场景清单

### Java漏洞（4个）

| 序号 | 漏洞类型 | 控制器 | 危险等级 |
|:---|:---|:---|:---|
| 1 | Java原生反序列化 | Vuln1NativeDeserializationController | 🔴 高危 |
| 2 | Fastjson反序列化 | Vuln2FastjsonController | 🔴 高危 |
| 3 | Jackson反序列化 | Vuln3JacksonController | 🟡 中高危 |
| 4 | Shiro反序列化 | Vuln4ShiroController | 🔴 高危 |

### PHP漏洞（2个）

| 序号 | 漏洞类型 | 文件 | 危险等级 |
|:---|:---|:---|:---|
| 5 | PHP反序列化POP链 | vuln5.php | 🟡 中危 |
| 6 | PHP Phar反序列化 | vuln6.php | 🟡 中高危 |

---

## 🚀 快速使用

### 解压压缩包

```bash
# 解压到当前目录
unzip deserialization-range.zip

# 或解压到指定目录
unzip deserialization-range.zip -d /opt/
```

### 启动靶场

```bash
cd deserialization-range

# 方法1：使用启动脚本
bash start.sh

# 方法2：使用管理命令（全局）
vuln-range start
```

### 访问靶场

```
前端首页: http://localhost:1008
Java漏洞: http://localhost:18080/vuln[1-4]
PHP漏洞: http://localhost:18081/vuln[5-6].php
```

---

## ✨ 完整功能清单

### ✅ 代码实现
- ✅ 6个漏洞场景（4个Java + 2个PHP）
- ✅ 完整的前端界面
- ✅ Docker一键部署
- ✅ MySQL数据库配置
- ✅ 开机自启配置

### ✅ 文档体系
- ✅ 项目说明文档（README.md）
- ✅ 完整通关手册（handbook.md）
- ✅ 技术测试手册（TECHNICAL_GUIDE.md）
- ✅ 开机自启指南（AUTO_START_GUIDE.md）
- ✅ 配置总结（AUTO_START_SUMMARY.md）
- ✅ 压缩包说明（PACKAGE_INFO.md）

### ✅ 脚本工具
- ✅ 启动脚本（start.sh）
- ✅ 管理脚本（manage.sh）
- ✅ 验证脚本（verify.sh）
- ✅ 工具安装脚本（setup_tools.sh）
- ✅ 6个漏洞利用脚本

### ✅ 管理功能
- ✅ systemd服务配置
- ✅ 全局命令（vuln-range）
- ✅ 开机自启
- ✅ 日志查看
- ✅ 状态监控

---

## 📞 技术支持

### 文档查阅

```bash
cd deserialization-range

# 查看项目说明
cat README.md

# 查看完整手册
cat handbook.md

# 查看技术手册
cat TECHNICAL_GUIDE.md

# 查看开机自启指南
cat AUTO_START_GUIDE.md

# 查看压缩包信息
cat PACKAGE_INFO.md
```

### 快速命令

```bash
# 启动靶场
vuln-range start

# 查看状态
vuln-range status

# 查看日志
vuln-range logs

# 验证项目
cd deserialization-range && bash verify.sh
```

---

## 🎊 总结

### ✅ 完成的工作

1. ✅ 源码整理 - 删除不需要的文件
2. ✅ 项目结构 - 完整的50个文件
3. ✅ 文档体系 - 6个完整文档
4. ✅ 脚本工具 - 10个自动化脚本
5. ✅ 压缩打包 - 68KB完整压缩包

### 📦 压缩包特点

- **体积小**: 仅68KB
- **文件全**: 50个文件
- **文档全**: 6个文档
- **功能全**: 6个漏洞场景
- **即开即用**: 解压后直接使用

### 🚀 使用场景

- ✅ 安全教育培训
- ✅ CTF竞赛训练
- ✅ 渗透测试练习
- ✅ 漏洞研究分析
- ✅ 演示展示

---

## 📍 文件位置

**压缩包**: `/root/deserialization-range.zip`  
**项目目录**: `/root/deserialization-range/`  
**文档**: 见压缩包内的6个文档

---

**源码整理完成，压缩包已创建！** 🎉

> ⚠️ **重要提醒**：本靶场仅供安全研究和教育培训使用，严禁用于非法用途！
