FROM mcr.microsoft.com/java/jre-headless:11-zulu-alpine AS base
EXPOSE 8080

FROM mcr.microsoft.com/java/maven:11-zulu-debian10 AS build
WORKDIR /build

COPY pom.xml .
RUN mvn -B dependency:go-offline 

COPY src src
RUN mvn -B clean package -DskipTests

FROM base AS final
WORKDIR /app
ARG appInsightsAgentURL="https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.0.3/applicationinsights-agent-3.0.3.jar"

RUN wget -q -O applicationinsights-agent-3.0.3.jar $appInsightsAgentURL
COPY applicationinsights.json .
COPY --from=build /build/target/spring-data-jpa-postgresql-*.jar spring-data-jpa-postgresql.jar
ENTRYPOINT ["java", "-javaagent:./applicationinsights-agent-3.0.3.jar", "-jar", "spring-data-jpa-postgresql.jar"]
