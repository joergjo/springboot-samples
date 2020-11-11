FROM mcr.microsoft.com/java/jre-headless:11-zulu-alpine AS base
EXPOSE 8080

FROM mcr.microsoft.com/java/jdk:11-zulu-alpine AS build
WORKDIR /build

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw -B dependency:go-offline 

COPY src src
RUN ./mvnw -B package -DskipTests

FROM base AS final
WORKDIR /app
ARG appInsightsAgentURL="https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.0.0/applicationinsights-agent-3.0.0.jar"

RUN wget -q -O applicationinsights-agent-3.0.0.jar $appInsightsAgentURL
COPY applicationinsights.json .
COPY --from=build /build/target/spring-data-jpa-demo-*.jar spring-data-jpa-demo.jar
ENTRYPOINT ["java", "-javaagent:./applicationinsights-agent-3.0.0.jar", "-jar", "spring-data-jpa-demo.jar"]
