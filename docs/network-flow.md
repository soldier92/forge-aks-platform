# Network Flow

1. A developer opens the portal hosted on Azure App Service.
2. The portal stores the request and presents an AI-assisted recommendation.
3. An admin reviews the request in the portal and approves or rejects it.
4. On approval, the portal renders Kubernetes manifests and calls `kubectl apply`.
5. AKS schedules the default application inside the team namespace.
6. Internal consumers reach the workload through the ClusterIP service and any higher-level ingress or API gateway added later.

The control plane stays outside the cluster, which reduces blast radius and keeps governance separate from workloads.
