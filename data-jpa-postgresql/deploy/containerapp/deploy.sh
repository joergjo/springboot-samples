#!/bin/bash
if [ -z "$CONTAINERAPP_RESOURCE_GROUP" ]; then
  echo "CONTAINERAPP_RESOURCE_GROUP is not set. Please set it to the name of the resource group to deploy to."
  exit 1
fi

if [ -z "$CONTAINERAPP_POSTGRES_LOGIN" ]; then
  echo "CONTAINERAPP_POSTGRES_LOGIN is not set. Please set it to a valid login name for the Container App's database server."
  exit 1
fi

if [ -z "$CONTAINERAPP_POSTGRES_LOGIN_PWD" ]; then
  echo "CONTAINERAPP_POSTGRES_LOGIN_PWD is not set. Please set it to a secure password for the Container App's database server."
  exit 1
fi

resource_group="$CONTAINERAPP_RESOURCE_GROUP"
image=${CONTAINERAPP_IMAGE:-"joergjo/springboot-todo-api:latest"}
name=${CONTAINERAPP_NAME:-"todoapi"}
location=${CONTAINERAPP_LOCATION:-"westeurope"}
postgres_login="$CONTAINERAPP_POSTGRES_LOGIN"
postgres_login_pwd="$CONTAINERAPP_POSTGRES_LOGIN_PWD"
database=${CONTAINERAPP_POSTGRES_DB-"demo"}
timestamp=$(date +%s)
client_ip=$(curl -s 'https://api.ipify.org?format=text')

az group create \
  --resource-group "$resource_group" \
  --location "$location"

fqdn=$(az deployment group create \
  --resource-group "$resource_group" \
  --name "env-$timestamp" \
  --template-file main.bicep \
  --parameters image="$image" name="$name" \
    postgresLogin="$postgres_login" postgresLoginPassword="$postgres_login_pwd" \
    database="$database" clientIP="$client_ip" \
  --query properties.outputs.fqdn.value \
  --output tsv)

if [ $? -ne 0 ]; then
  echo "Bicep deployment failed. Please check the error message above."
  exit 1
fi

echo "Application has been deployed successfully. You can access it at https://$fqdn"
