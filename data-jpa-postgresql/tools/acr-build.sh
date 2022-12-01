#!/bin/bash
version=${1:-2.7.6}
platform=${2:-"linux/arm64"}
repo=springboot-samples/data-jpa-postgresql
az acr login
az acr build -t "${repo}:${version}-{{.Run.ID}}" --platform "${platform}"  -f ./Dockerfile .