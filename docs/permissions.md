# Permissions Model

## Demo Roles

- `developer`: can submit and view requests.
- `admin`: can review, approve, reject, and request changes.

## Production Recommendation

- Use Azure Entra ID for sign-in.
- Map developers and platform admins to separate Entra groups.
- Use App Service managed identity for Azure operations.
- Limit AKS access with Kubernetes RBAC and least-privilege Azure RBAC roles.
- Grant the provisioning identity permission only to the target namespaces and required cluster operations.
- Run Terraform and deployment workflows through the `serviceprincipal` identity from a controlled self-hosted GitHub runner.
