FROM amazoncorretto:8-alpine3.17
WORKDIR /app
COPY target/vuln-java-1.0.0.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
