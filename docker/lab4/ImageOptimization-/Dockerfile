FROM maven:3.9.15-eclipse-temurin-17-alpine AS maven

WORKDIR /app

COPY pom.xml .
COPY src ./src
RUN mvn package


FROM  alpine/java:17
WORKDIR /app
RUN addgroup -S ivolve && adduser -S peter1 -G ivolve
RUN chown peter1:ivolve ./target/app2
COPY --from=maven /app/target/demo-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar"]
CMD ["app.jar"]
