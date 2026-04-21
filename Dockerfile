# ========== BUILD ==========
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# ========== RUN ==========
FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

# Render sẽ inject PORT -> phải dùng biến môi trường
ENV PORT=8080

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java -Xms128m -Xmx384m -XX:MaxMetaspaceSize=128m -XX:+UseG1GC -jar app.jar --server.port=$PORT"]