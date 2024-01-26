ARG revision=1.0.0

FROM eclipse-temurin:17-jre-jammy AS base
EXPOSE 8080

FROM maven:3.9-eclipse-temurin-17 AS build
ARG revision
WORKDIR /build
COPY pom.xml .
COPY src src
RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests -Drevision=${revision} clean package

FROM base AS final
WORKDIR /app
ARG appInsightsAgentVersion="3.4.19"
ARG appInsightsAgentURL="https://github.com/microsoft/ApplicationInsights-Java/releases/download/${appInsightsAgentVersion}/applicationinsights-agent-${appInsightsAgentVersion}.jar"
RUN curl -s -L -o applicationinsights-agent.jar $appInsightsAgentURL
COPY applicationinsights.json .
COPY --from=build /build/target/spring-data-jpa-postgresql-*.jar spring-data-jpa-postgresql.jar
ENTRYPOINT ["java", "-javaagent:./applicationinsights-agent.jar", "-jar", "spring-data-jpa-postgresql.jar"]