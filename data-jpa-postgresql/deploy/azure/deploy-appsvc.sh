#!/bin/bash

# Set script variables
image=$1
webapp=$2
acr=$3
location=${4:-northeurope}
rg=${5:-${webapp}-rg}
plan=${6:-${webapp}-plan}
appsvc_sku=${7:-P1V2}

echo -n "Creating resource group \"$rg\" in \"$location\"..."
az group create \
  -g $rg \
  -l $location \
  -o none
echo "done."

echo -n "Creating App Service plan \"$plan\" of size \"$appsvc_sku\"..."
az appservice plan create \
  -g $rg \
  -n $plan \
  -l $location \
  --is-linux \
  --sku $appsvc_sku \
  -o none
echo "done."

echo -n "Creating Web App \"$webapp\"..."
# Deploy a dummy container (e.g. nginx) because we're not authorized yet
az webapp create \
  -g $rg \
  -n $webapp \
  -p $plan \
  -i nginx \
  -o none
az webapp update \
  -g $rg \
  -n $webapp \
 --https-only true \
 -o none
echo "done."

echo -n "Updating Web App configuration..."
az webapp config appsettings set \
  -g $rg \
  -n $webapp \
  --settings POSTGRESQL_HOST="$POSTGRESQL_HOST" POSTGRESQL_USERNAME="$POSTGRESQL_USERNAME" POSTGRESQL_PASSWORD="$POSTGRESQL_PASSWORD"\
    APPLICATIONINSIGHTS_CONNECTION_STRING="$APPLICATIONINSIGHTS_CONNECTION_STRING" APPLICATIONINSIGHTS_ROLE_NAME="springboot-todo-api" \
  -o none
az webapp config set \
  -g $rg \
  -n $webapp \
  --always-on true \
  -o none
echo "done."

echo -n "Setting Managed Identity..."
principal_id=$(az webapp identity assign \
  -g $rg \
  -n $webapp \
  --query principalId \
  -o tsv)
echo "done. Waiting for identity to propagate..."

sleep 60

echo -n "Granting access to ACR \"$acr\"..."
scope=$(az acr show \
  -n $acr \
  --query id \
  -o tsv)
az role assignment create \
  --assignee $principal_id \
  --scope $scope \
  --role AcrPull \
  -o none
echo "done."

echo -n "Deploying \"$image\"..."
az webapp config container set \
  -g $rg \
  -n $webapp \
  -i $image \
  -r https://$acr.azurecr.io \
  -t false \
  -o none
echo "done."

echo "Deployment completed! Browse to https://$webapp.azurewebsites.net..."