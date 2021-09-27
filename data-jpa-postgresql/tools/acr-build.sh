#!/bin/bash
version=${1:-2.4.11}
repo=springboot-samples/data-jpa-postgresql
az acr login
az acr build -t ${repo}:latest -t ${repo}:${version}-{{.Run.ID}} -f ./Dockerfile .