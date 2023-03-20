#!/bin/bash
az spring app create \
    -n "$SPRING_APP" \
    -s "$SPRING_APP_SERVICE" \
    -g "$SPRING_APP_RESOURCE_GROUP" \
    --runtime-version Java_17 \
    --jvm-options='-Xms1024m -Xmx1024m' \
    --assign-endpoint true

az spring app deploy \
    -n "$SPRING_APP" \
    -s "$SPRING_APP_SERVICE" \
    -g "$SPRING_APP_RESOURCE_GROUP" \
    --artifact-path "$SPRING_APP_ARTIFACT_PATH" \
    --env POSTGRESQL_HOST="$POSTGRESQL_HOST" POSTGRESQL_USERNAME="$POSTGRESQL_USERNAME" POSTGRESQL_PASSWORD="$POSTGRESQL_PASSWORD"
