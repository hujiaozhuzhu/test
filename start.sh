#!/bin/bash
# 反序列化漏洞靶场快速启动脚本

echo "================================"
echo "反序列化漏洞靶场 - 快速启动"
echo "================================"
echo ""

# 检查Docker
echo "步骤1: 检查Docker环境..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

echo "✓ Docker环境正常"
echo ""

# 进入项目目录
cd /root/deserialization-range

# 停止旧容器
echo "步骤2: 停止旧容器..."
docker-compose down 2>/dev/null

# 构建并启动容器
echo "步骤3: 构建并启动容器..."
docker-compose up -d --build

if [ $? -ne 0 ]; then
    echo "❌ 容器启动失败"
    exit 1
fi

echo "✓ 容器启动成功"
echo ""

# 等待服务启动
echo "步骤4: 等待服务启动..."
sleep 10

# 检查服务状态
echo "步骤5: 检查服务状态..."
docker-compose ps

echo ""
echo "================================"
echo "✓ 靶场部署完成！"
echo "================================"
echo ""
echo "访问地址:"
echo "  前端首页:    http://localhost:1008"
echo "  Java场景:    http://localhost:1008/vuln[1-4]"
echo "  PHP场景:     http://localhost:1008/vuln5.php"
echo "               http://localhost:1008/vuln6.php"
echo ""
echo "工具安装:"
echo "  cd tools && bash setup_tools.sh"
echo ""
echo "查看日志:"
echo "  docker-compose logs -f"
echo ""
echo "停止服务:"
echo "  docker-compose down"
echo ""
echo "================================"
