FROM eclipse-temurin:11-jre-focal AS base
EXPOSE 9001

FROM eclipse-temurin:11-jdk-focal AS build
WORKDIR /build

COPY mvnw  .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B clean package -DskipTests

FROM base AS final
WORKDIR /app
ARG appInsightsAgentVersion="3.2.10"
ARG appInsightsAgentURL="https://github.com/microsoft/ApplicationInsights-Java/releases/download/${appInsightsAgentVersion}/applicationinsights-agent-${appInsightsAgentVersion}.jar"

RUN curl -s -L -o applicationinsights-agent.jar $appInsightsAgentURL
COPY applicationinsights.json .
COPY --from=build /build/target/usage-detail-sender-*.jar ./usage-detail-sender.jar
ENTRYPOINT ["java", "-javaagent:./applicationinsights-agent.jar", "-jar", "usage-detail-sender.jar"]
