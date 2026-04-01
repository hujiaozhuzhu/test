FROM amazoncorretto:8-alpine3.17

WORKDIR /app

# 复制简单的HTTP服务器
COPY SimpleServer.java .

# 编译并运行
RUN javac SimpleServer.java

EXPOSE 8080

CMD ["java", "SimpleServer"]
