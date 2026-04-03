# 反序列化漏洞靶场 - 优化版

> ⚠️ **安全警告：本靶场仅供安全研究和教育培训使用，严禁用于非法用途！**

## 📋 项目简介

这是一个完整的教育型反序列化漏洞靶场，包含6个经典反序列化漏洞场景，配套详细的通关手册和自动化利用工具。旨在帮助安全研究人员和学习者深入理解反序列化漏洞的原理、利用和防御。

**最新更新**：
- ✅ 优化vuln3页面，添加集成ysoserial payload生成器
- ✅ 改进响应式设计，支持移动端访问
- ✅ 添加多种gadget链选择和payload模板
- ✅ 实现payload历史记录和导出功能

## 🎯 漏洞场景清单

| 序号 | 漏洞类型 | 技术栈 | 危险等级 | 利用工具 | 状态 |
|:---|:---|:---|:---|:---|
| 1 | Java原生反序列化 | Java + Commons Collections | 🔴 高危 | ysoserial | ✅ 正常 |
| 2 | Fastjson反序列化 | Java + Fastjson 1.2.24 | 🔴 高危 | JNDI-Injection-Exploit | ✅ 正常 |
| 3 | Jackson反序列化 | Java + Jackson 2.9.8 | 🟡 中高危 | 手工/XML | ✅ 优化完成 |
| 4 | Shiro反序列化 | Java + Shiro 1.2.4 | 🔴 高危 | shiro_attack | ✅ 正常 |
| 5 | PHP反序列化POP链 | PHP 7.4 | 🟡 中高危 | PHPGGC | ✅ 正常 |
| 6 | PHP Phar反序列化 | PHP 7.4 | 🟡 中高危 | PHPGGC | ✅ 正常 |

## 🚀 快速开始

### 前置要求

- Docker 和 Docker Compose
- Java 8+ (用于运行工具)
- Python 3 (用于运行工具)
- Bash shell

### 一键部署

\`\`\`bash
# 克隆仓库
git clone https://github.com/hujiaozhuzhu/fanxulieh-bachang.git
cd fanxulieh-bachang

# 启动所有漏洞靶场
bash start.sh

# 启动特定靶场
docker-compose up -d vuln-java  # Java原生反序列化
docker-compose up -d vuln-fastjson  # Fastjson反序列化
docker-compose up -d vuln-jackson   # Jackson反序列化
docker-compose up -d vuln-shiro     # Shiro反序列化
docker-compose up -d vuln-php        # PHP POP链
docker-compose up -d vuln-phar       # Phar反序列化
\`\`\`

## 🎯 漏洞场景详情

### 漏洞场景1：Java原生反序列化

**路径**: http://localhost:18080/vuln1

**描述**: Java原生反序列化漏洞，使用CommonsCollections的ChainedTransformer链

**利用工具**: ysoserial-all.jar

**推荐Gadget链**：
- Jdk7u21（最适合Java 7/8）
- CommonsCollections2
- CommonsCollections3

**测试步骤**：
1. 访问 http://localhost:18080/vuln1
2. 选择适合的gadget链
3. 输入测试命令：touch /tmp/pwned
4. 生成并发送payload
5. 查看是否成功创建文件

### 漏洞场景2：Fastjson反序列化

**路径**: http://localhost:18080/vuln2

**描述**: Fastjson 1.2.24版本的JNDI注入漏洞

**利用工具**: JNDI-Injection-Exploit

**注意事项**: 需要启动恶意的JNDI服务器

### 漏洞场景3：Jackson反序列化（优化版本）⭐

**路径**: http://localhost:18080/vuln3

**描述**: Jackson反序列化漏洞，现已优化

**最新优化内容**：
- ✅ **集成ysoserial payload生成器**：无需本地生成payload，直接在网页中生成
- ✅ **多种gadget链选择**：支持Jdk7u21、CommonsCollections、BeanShell等10+种链
- ✅ **payload模板快速生成**：提供id、whoami、pwd、ls等常用命令模板
- ✅ **payload历史记录**：保存测试历史，支持导出JSON
- ✅ **响应式设计**：完美支持手机和平板访问
- ✅ **改进用户体验**：现代化UI设计，更直观的操作流程

**使用方法**：
1. 访问 http://localhost:18080/vuln3
2. 选择"Payload模板"标签页
3. 点击gadget链按钮选择适合的链（推荐Jdk7u21）
4. 输入测试命令（如：touch /tmp/pwned）
5. 点击"生成Payload"按钮
6. 点击"生成并提交"按钮直接测试

**高级功能**：
- 自动重试失败的请求
- 详细错误信息显示
- 实时payload预览
- 历史记录重用
- payload格式验证

### 漏洞场景4：Shiro反序列化

**路径**: http://localhost:18080/vuln4

**描述**: Apache Shiro 1.2.4 RememberMe反序列化漏洞

**利用工具**: shiro_attack

### 漏洞场景5：PHP反序列化POP链

**路径**: http://localhost:18080/vuln5

**描述**: PHP 7.4的POP链反序列化漏洞

**利用工具**: PHPGGC

### 漏洞场景6：PHP Phar反序列化

**路径**: http://localhost:18080/vuln6

**描述**: PHP Phar反序列化漏洞

**利用工具**: PHPGGC

## 🛠️ 工具清单

### ysoserial-all.jar
- **功能**: Java反序列化payload生成
- **支持链**: 20+种gadget链
- **推荐链**: Jdk7u21、CommonsCollections1-7

### JNDI-Injection-Exploit
- **功能**: JNDI注入攻击工具
- **支持协议**: RMI、LDAP、DNS

### shiro_attack
- **功能**: Shiro利用工具
- **支持版本**: 1.2.4、1.2.6

### PHPGGC
- **功能**: PHP反序列化工具
- **支持**: POP链、Phar生成

## 📚 学习资源

- [反序列化漏洞详解](./docs/TECHNICAL_GUIDE.md)
- [项目源码分析](./docs/SOURCE_CODE_SUMMARY.md)
- [安全最佳实践](./docs/handbook.md)

## 🚨 安全注意事项

> **⚠️ 重要提示**：
> 1. 此靶场仅供授权的安全研究和教育培训使用
> 2. 严禁用于非法用途或未授权测试
> 3. 请在隔离的网络环境中使用
> 4. 使用完毕后请立即停止所有服务

## 📞 技术支持

- 提交Issue: https://github.com/hujiaozhuzhuzhu/fanxulieh-bachang/issues
- 查看文档: [项目文档](./README.md)

---

**更新日期**: 2025-04-03  
**版本**: 优化版 v1.1  
**维护者**: hujiaozhuzhu
