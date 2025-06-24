FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
COPY migrations/changelog /app/db/init
RUN mvn clean package -DskipTests

FROM openjdk:21

WORKDIR /app

COPY --from=build /app/target/FishMasters-0.0.1-SNAPSHOT.jar app.jar

COPY --from=build /app/db/init /app/db/init

ENTRYPOINT ["java", "-jar", "app.jar"]