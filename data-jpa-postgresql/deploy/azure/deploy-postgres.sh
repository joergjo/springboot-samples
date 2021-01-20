#!/bin/bash
export $(grep -v '^#' ../../.env | xargs)

local_ip=$(curl -s 'https://api.ipify.org?format=json' | jq -r .ip)

az group create \
	--name $AZ_RESOURCE_GROUP \
	--location $AZ_LOCATION \
	| jq

az postgres server create \
	--resource-group $AZ_RESOURCE_GROUP \
	--name $POSTGRESQL_HOST \
	--location $AZ_LOCATION \
	--sku-name GP_Gen5_2 \
	--version 11 \
	--storage-size 20480 \
	--admin-user $POSTGRESQL_USERNAME \
	--admin-password $POSTGRESQL_PASSWORD \
	--assign-identity \
	| jq

az postgres server firewall-rule create \
	--resource-group $AZ_RESOURCE_GROUP \
	--name $POSTGRESQL_HOST-database-allow-local-ip \
	--server $POSTGRESQL_HOST \
	--start-ip-address $local_ip \
	--end-ip-address $local_ip \
        | jq

az postgres db create \
	--resource-group $AZ_RESOURCE_GROUP \
	--name demo \
	--server-name $POSTGRESQL_HOST \
	| jq

