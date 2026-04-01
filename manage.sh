#!/bin/bash
# 反序列化漏洞靶场 - 管理脚本

case "$1" in
    start)
        echo "启动靶场..."
        systemctl start deserialization-range.service
        echo "✓ 靶场已启动"
        echo ""
        echo "访问地址:"
        echo "  前端: http://localhost:1008"
        echo "  Java: http://localhost:18080/vuln[1-4]"
        echo "  PHP:  http://localhost:18081/vuln[5-6].php"
        ;;
    stop)
        echo "停止靶场..."
        systemctl stop deserialization-range.service
        echo "✓ 靶场已停止"
        ;;
    restart)
        echo "重启靶场..."
        systemctl restart deserialization-range.service
        echo "✓ 靶场已重启"
        ;;
    status)
        echo "靶场状态:"
        systemctl status deserialization-range.service
        echo ""
        echo "容器状态:"
        docker ps --filter "name=vuln" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    logs)
        echo "查看靶场日志..."
        cd /root/deserialization-range
        docker-compose logs -f
        ;;
    enable)
        echo "设置开机自启..."
        systemctl enable deserialization-range.service
        echo "✓ 已设置开机自启"
        ;;
    disable)
        echo "取消开机自启..."
        systemctl disable deserialization-range.service
        echo "✓ 已取消开机自启"
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|logs|enable|disable}"
        echo ""
        echo "命令说明:"
        echo "  start   - 启动靶场"
        echo "  stop    - 停止靶场"
        echo "  restart - 重启靶场"
        echo "  status  - 查看状态"
        echo "  logs    - 查看日志"
        echo "  enable  - 设置开机自启"
        echo "  disable - 取消开机自启"
        exit 1
        ;;
esac
