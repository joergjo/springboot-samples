#!/bin/bash
repo=springboot-samples/data-jpa-postgresql
az acr login
az acr build -t ${repo}:latest -t ${repo}:{{.Run.ID}} -f ../Dockerfile ..