FROM maven:3.9.16-eclipse-temurin-21 AS builder

WORKDIR /app

COPY pom.xml .

# Download dependencies to cache them unless updated
# -B is non-interactive batch mode to avoid prompts during the build and excessive logging
RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package

FROM eclipse-temurin:21-jdk AS runner

WORKDIR /app

COPY --from=builder ./app/target/deploy-mate-0.0.1-SNAPSHOT.jar ./app.jar

EXPOSE 8087

ENTRYPOINT ["java", "-jar", "app.jar"]
