#!/bin/bash
# 项目验证脚本

echo "================================"
echo "反序列化漏洞靶场 - 项目验证"
echo "================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (缺失)"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ (缺失)"
        return 1
    fi
}

errors=0

echo "=== 核心配置文件 ==="
check_file "docker-compose.yml" || ((errors++))
check_file "start.sh" || ((errors++))
check_file "README.md" || ((errors++))
check_file "handbook.md" || ((errors++))
check_file "DELIVERY_CHECKLIST.md" || ((errors++))

echo ""
echo "=== 目录结构 ==="
check_dir "frontend" || ((errors++))
check_dir "vuln-java" || ((errors++))
check_dir "vuln-php" || ((errors++))
check_dir "tools" || ((errors++))

echo ""
echo "=== Java漏洞场景 ==="
check_file "vuln-java/Dockerfile" || ((errors++))
check_file "vuln-java/pom.xml" || ((errors++))
check_file "vuln-java/src/main/java/com/vuln/app/VulnApplication.java" || ((errors++))
check_file "vuln-java/src/main/java/com/vuln/app/controller/Vuln1NativeDeserializationController.java" || ((errors++))
check_file "vuln-java/src/main/java/com/vuln/app/controller/Vuln2FastjsonController.java" || ((errors++))
check_file "vuln-java/src/main/java/com/vuln/app/controller/Vuln3JacksonController.java" || ((errors++))
check_file "vuln-java/src/main/java/com/vuln/app/controller/Vuln4ShiroController.java" || ((errors++))
check_file "vuln-java/src/main/resources/application.yml" || ((errors++))
check_file "vuln-java/src/main/resources/templates/vuln1.html" || ((errors++))
check_file "vuln-java/src/main/resources/templates/vuln2.html" || ((errors++))
check_file "vuln-java/src/main/resources/templates/vuln3.html" || ((errors++))
check_file "vuln-java/src/main/resources/templates/vuln4.html" || ((errors++))

echo ""
echo "=== PHP漏洞场景 ==="
check_file "vuln-php/Dockerfile" || ((errors++))
check_file "vuln-php/vuln5.php" || ((errors++))
check_file "vuln-php/vuln6.php" || ((errors++))
check_file "vuln-php/sql/init.sql" || ((errors++))

echo ""
echo "=== 前端页面 ==="
check_file "frontend/index.html" || ((errors++))

echo ""
echo "=== 工具脚本 ==="
check_file "tools/setup_tools.sh" || ((errors++))
check_file "tools/native_exploit.sh" || ((errors++))
check_file "tools/fastjson_exploit.sh" || ((errors++))
check_file "tools/jackson_exploit.sh" || ((errors++))
check_file "tools/shiro_exploit.sh" || ((errors++))
check_file "tools/php_exploit.sh" || ((errors++))
check_file "tools/phar_exploit.sh" || ((errors++))

echo ""
echo "=== Docker配置检查 ==="
if grep -q "1008:80" docker-compose.yml; then
    echo -e "${GREEN}✓${NC} 端口配置正确 (1008)"
else
    echo -e "${RED}✗${NC} 端口配置不正确"
    ((errors++))
fi

echo ""
echo "=== 脚本执行权限检查 ==="
for script in start.sh tools/*.sh; do
    if [ -x "$script" ]; then
        echo -e "${GREEN}✓${NC} $script (可执行)"
    else
        echo -e "${RED}✗${NC} $script (不可执行)"
        ((errors++))
    fi
done

echo ""
echo "=== 文件统计 ==="
echo "总文件数: $(find . -type f | wc -l)"
echo "总目录数: $(find . -type d | wc -l)"
echo "代码行数: $(find . -name '*.java' -o -name '*.php' -name '*.html' | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')"
echo "文档页数: $(wc -l handbook.md | awk '{print $1}') 行"

echo ""
echo "================================"
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ 验证通过！所有文件都已正确创建${NC}"
    echo "================================"
    exit 0
else
    echo -e "${RED}✗ 验证失败！发现 $errors 个问题${NC}"
    echo "================================"
    exit 1
fi
