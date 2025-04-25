#!/bin/bash

# Script to generate limited kubeconfig for a service account with namespace-scoped permissions

# Set variables
SERVICE_ACCOUNT_NAME="user-sa"        # Change this to your desired service account name
NAMESPACE="your-namespace"            # Change this to your target namespace
KUBECONFIG_FILE="kubeconfig.yaml"     # Output kubeconfig file name
CONTEXT_NAME="${SERVICE_ACCOUNT_NAME}-${NAMESPACE}-context"
SECRET_NAME="${SERVICE_ACCOUNT_NAME}-token"
SERVER_URL="https://your-kubernetes-api-server:port"  # Change this to your K8s API server

# Apply service account, role, and role binding
echo "Creating service account, role, and role binding..."
kubectl apply -f ${SERVICE_ACCOUNT_NAME}-service-account.yaml
kubectl apply -f ${SERVICE_ACCOUNT_NAME}-role.yaml
kubectl apply -f ${SERVICE_ACCOUNT_NAME}-role-binding.yaml

# Create service account token secret manually (for Kubernetes v1.24+)
echo "Creating service account token secret..."
kubectl apply -f ${SERVICE_ACCOUNT_NAME}-token-secret.yaml

# Wait a moment for the token controller to populate the secret
echo "Waiting for token controller to populate the secret..."
sleep 5

# Extract CA certificate and user token
echo "Getting service account token..."
CA_CRT=$(kubectl get secret ${SECRET_NAME} -n ${NAMESPACE} -o jsonpath='{.data.ca\.crt}')
USER_TOKEN=$(kubectl get secret ${SECRET_NAME} -n ${NAMESPACE} -o jsonpath='{.data.token}' | base64 --decode)

# Create kubeconfig
echo "Generating kubeconfig file: ${KUBECONFIG_FILE}..."
cat > ${KUBECONFIG_FILE} << EOF
apiVersion: v1
kind: Config
preferences: {}
clusters:
- cluster:
    certificate-authority-data: ${CA_CRT}
    server: ${SERVER_URL}
  name: ${CONTEXT_NAME}-cluster
contexts:
- context:
    cluster: ${CONTEXT_NAME}-cluster
    namespace: ${NAMESPACE}
    user: ${SERVICE_ACCOUNT_NAME}
  name: ${CONTEXT_NAME}
current-context: ${CONTEXT_NAME}
users:
- name: ${SERVICE_ACCOUNT_NAME}
  user:
    token: ${USER_TOKEN}
EOF

echo "Kubeconfig file generated: ${KUBECONFIG_FILE}"
echo "You can use this file with: kubectl --kubeconfig=${KUBECONFIG_FILE} get pods -n ${NAMESPACE}"