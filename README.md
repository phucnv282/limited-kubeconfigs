# Limited Kubeconfigs for Kubernetes Namespaces

This repository contains templates and scripts to create limited-scope kubeconfig files for service accounts with namespace-scoped permissions in Kubernetes clusters.

## Purpose

These templates demonstrate how to create service accounts with limited permissions and generate kubeconfig files that can be distributed to users who need access to specific namespaces only.

## Files

- `user-sa-service-account.yaml`: Template for creating a service account
- `user-sa-role.yaml`: Template for a role with customizable permissions in a namespace
- `user-sa-role-binding.yaml`: Template for binding the service account to the role
- `user-sa-token-secret.yaml`: Template for creating a token secret for the service account
- `generate-kubeconfig.sh`: Script template to generate a kubeconfig file

## Usage

1. Edit the templates to customize service account name, namespace, and permissions
2. Make sure you're connected to your Kubernetes cluster with admin privileges
3. Run the script:
   ```bash
   ./generate-kubeconfig.sh
   ```
4. This will create a kubeconfig file in the current directory
5. You can use this file with kubectl:
   ```bash
   kubectl --kubeconfig=kubeconfig.yaml get pods -n your-namespace
   ```

## What This Does

This setup creates:
1. A service account in your specified namespace
2. A role with configurable permissions in that namespace
3. A role binding that connects the service account to the role
4. A token secret for the service account
5. A kubeconfig file that uses the token for authentication

## Security Notes

- **IMPORTANT**: Before making this repo public, ensure you have removed all sensitive information:
  - Replace all specific URLs, IP addresses, and server details with placeholder values
  - Remove any actual tokens, certificates, or credentials
  - Replace all personal or organization identifiers with generic names
  
- The generated kubeconfig grants permissions only within the specified namespace. The service account won't have access to other namespaces.

- **DO NOT commit actual kubeconfig files with tokens to this repository!** Always add generated kubeconfig files to your `.gitignore`.

## Customization

Edit the template files and replace the placeholder values:
- `your-namespace`: The namespace you want to grant access to
- `user-sa`: The name of the service account
- `https://your-kubernetes-api-server:port`: Your actual Kubernetes API server URL