FROM eclipse-temurin:11-jre-focal AS base
EXPOSE 8080

FROM eclipse-temurin:11-jdk-focal AS build
WORKDIR /build

COPY mvnw  .
COPY .mvn .mvn

COPY pom.xml .
RUN ./mvnw -B dependency:go-offline 

COPY src src
RUN ./mvnw -B clean package -DskipTests

FROM base AS final
WORKDIR /app
ARG appInsightsAgentVersion="3.2.10"
ARG appInsightsAgentURL="https://github.com/microsoft/ApplicationInsights-Java/releases/download/${appInsightsAgentVersion}/applicationinsights-agent-${appInsightsAgentVersion}.jar"

RUN curl -s -L -o applicationinsights-agent.jar $appInsightsAgentURL
COPY applicationinsights.json .
COPY --from=build /build/target/spring-data-jpa-postgresql-*.jar spring-data-jpa-postgresql.jar
ENTRYPOINT ["java", "-javaagent:./applicationinsights-agent.jar", "-jar", "spring-data-jpa-postgresql.jar"]
