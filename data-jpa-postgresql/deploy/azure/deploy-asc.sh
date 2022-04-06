#!/bin/bash
az spring-cloud app create \
    -n "$SC_APP_NAME" \
    -s "$SC_SERVICE_NAME" \
    -g "$SC_RESOURCE_GROUP_NAME" \
    --runtime-version Java_11 \
    --jvm-options='-Xms1024m -Xmx1024m' \
    --assign-endpoint true

az spring-cloud app deploy \
    -n "$SC_APP_NAME" \
    -s "$SC_SERVICE_NAME" \
    -g "$SC_RESOURCE_GROUP_NAME" \
    --artifact-path target/spring-data-jpa-postgresql-0.0.1-SNAPSHOT.jar \
    --env POSTGRESQL_HOST="$POSTGRESQL_HOST" POSTGRESQL_USERNAME="$POSTGRESQL_USERNAME" POSTGRESQL_PASSWORD="$POSTGRESQL_PASSWORD"