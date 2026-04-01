#!/bin/bash
# 工具下载和安装脚本

TOOLS_DIR="/root/deserialization-range/tools"
mkdir -p $TOOLS_DIR
cd $TOOLS_DIR

echo "=== 反序列化漏洞利用工具安装脚本 ==="
echo ""

# 安装Java环境
echo "步骤1: 检查Java环境..."
if ! command -v java &> /dev/null; then
    echo "正在安装Java..."
    apt-get update -qq
    apt-get install -y default-jdk -qq
    echo "✓ Java已安装"
else
    echo "✓ Java已存在"
fi

# 安装Python环境
echo "步骤2: 检查Python环境..."
if ! command -v python3 &> /dev/null; then
    echo "正在安装Python3..."
    apt-get install -y python3 python3-pip -qq
    echo "✓ Python3已安装"
else
    echo "✓ Python3已存在"
fi

# 下载ysoserial
echo "步骤3: 下载ysoserial..."
if [ ! -f "ysoserial-0.0.6-all.jar" ]; then
    wget -q https://github.com/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-0.0.6-all.jar
    if [ $? -eq 0 ]; then
        echo "✓ ysoserial已下载"
    else
        echo "✗ ysoserial下载失败，请手动下载"
    fi
else
    echo "✓ ysoserial已存在"
fi

# 下载PHPGGC
echo "步骤4: 克隆PHPGGC..."
if [ ! -d "phpggc" ]; then
    git clone -q https://github.com/ambionics/phpggc.git
    if [ -d "phpggc" ]; then
        cd phpggc
        composer install -q
        cd ..
        chmod +x phpggc/phpggc
        echo "✓ PHPGGC已安装"
    else
        echo "✗ PHPGGC克隆失败"
    fi
else
    echo "✓ PHPGGC已存在"
fi

# 下载JNDI-Injection-Exploit
echo "步骤5: 下载JNDI-Injection-Exploit..."
if [ ! -d "JNDI-Injection-Exploit" ]; then
    git clone -q https://github.com/welk1n/JNDI-Injection-Exploit.git
    if [ -d "JNDI-Injection-Exploit" ]; then
        cd JNDI-Injection-Exploit
        mvn clean package -q -DskipTests
        cd ..
        echo "✓ JNDI-Injection-Exploit已编译"
    else
        echo "✗ JNDI-Injection-Exploit克隆失败"
    fi
else
    echo "✓ JNDI-Injection-Exploit已存在"
fi

# 下载shiro_attack
echo "步骤6: 下载shiro_attack..."
if [ ! -d "Shiro_attack" ]; then
    git clone -q https://github.com/Jayl1n/Shiro_attack.git
    if [ -d "Shiro_attack" ]; then
        chmod +x Shiro_attack/shiro_exploit.py
        echo "✓ shiro_attack已下载"
    else
        echo "✗ shiro_attack克隆失败"
    fi
else
    echo "✓ shiro_attack已存在"
fi

# 设置脚本权限
chmod +x *.sh 2>/dev/null

echo ""
echo "=== 工具安装完成 ==="
echo ""
echo "已安装的工具:"
echo "  - ysoserial-0.0.6-all.jar (Java反序列化)"
echo "  - phpggc/ (PHP反序列化)"
echo "  - JNDI-Injection-Exploit/ (Fastjson利用)"
echo "  - Shiro_attack/ (Shiro利用)"
echo ""
echo "可用的脚本:"
echo "  - native_exploit.sh (Java原生反序列化)"
echo "  - fastjson_exploit.sh (Fastjson漏洞)"
echo "  - jackson_exploit.sh (Jackson漏洞)"
echo "  - php_exploit.sh (PHP反序列化)"
echo "  - phar_exploit.sh (Phar反序列化)"
echo ""
echo "使用示例:"
echo "  cd /root/deserialization-range/tools"
echo "  bash native_exploit.sh"
