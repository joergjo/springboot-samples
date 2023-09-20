#!/bin/bash
service_account_name="springboot-todo-api-sa"
oidc_issuer="$(az aks show -n "${CLUSTER_NAME}" -g "${CLUSTER_RESOURCE_GROUP}" --query "oidcIssuerProfile.issuerUrl" -o tsv)"

user_assigned_client_id="$(az identity show --resource-group "${USER_ASSIGNED_IDENTITY_RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'clientId' -o tsv)"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${user_assigned_client_id}"
  name: "${service_account_name}"
  namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
EOF

az identity federated-credential create \
    --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
    --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${USER_ASSIGNED_IDENTITY_RESOURCE_GROUP}" \
    --issuer "${oidc_issuer}" \
    --subject system:serviceaccount:"${SERVICE_ACCOUNT_NAMESPACE}":"${service_account_name}" \
    --audience api://AzureADTokenExchange