Create a complete phased project called "AI-Assisted Azure AKS Platform Control Plane".

Business goal:
Build an enterprise-style internal developer platform prototype. The platform portal runs outside AKS on Azure App Service and lets developers request team-specific AKS environments. Supervisors review, approve, reject, or request changes. Approved requests trigger Python automation that provisions Kubernetes resources and deploys a default FastAPI starter app into AKS.

Important architecture requirement:
The platform portal/control plane must not run inside the AKS workload cluster. It should run as a Python FastAPI app that can later be deployed to Azure App Service. AKS is only for team workloads.

Create this repository structure:

portal/
  app/
    main.py
    database.py
    models.py
    schemas.py
    provisioner.py
    ai_reviewer.py
    diagnostics.py
    templates/
      index.html
      request.html
      admin.html
      request_detail.html
      deployment_result.html
  requirements.txt
  startup.sh

default-app/
  app/
    main.py
  requirements.txt
  Dockerfile

k8s-templates/
  namespace.yaml.j2
  resourcequota.yaml.j2
  limitrange.yaml.j2
  serviceaccount.yaml.j2
  role.yaml.j2
  rolebinding.yaml.j2
  configmap.yaml.j2
  deployment.yaml.j2
  service.yaml.j2
  networkpolicy.yaml.j2

infra/
  create-azure.sh
  deploy-portal.sh
  build-push-default-app.sh
  get-kubeconfig.sh
  destroy-azure.sh

docs/
  architecture.md
  network-flow.md
  permissions.md
  cost-control.md

README.md

Portal requirements:
- Use Python FastAPI.
- Use Jinja2 templates for simple UI.
- Use SQLite for local/demo database.
- Home page explains project.
- Developer page lets user submit environment request.
- Admin page lists pending requests.
- Admin can approve, reject, or mark needs changes.
- Admin can add comments.
- Request statuses:
  - PENDING_APPROVAL
  - NEEDS_CHANGES
  - APPROVED
  - REJECTED
  - PROVISIONING
  - DEPLOYED
  - FAILED
- On approval, call the provisioning function.
- Add simple fake login using query parameter or hardcoded role for demo:
  - developer
  - admin
- Do not implement real auth yet, but document how Azure Entra ID would be used in production.

Request fields:
- team_name
- environment
- app_type
- requested_cpu
- requested_memory
- image
- requested_by
- supervisor_email
- business_justification
- status
- admin_comment
- ai_recommendation
- deployment_log
- error_message
- created_at
- reviewed_at
- deployed_at

AI reviewer:
- Do not call paid AI APIs.
- Create deterministic rule-based recommendations.
- Also generate a "Prompt to paste into ChatGPT/Codex" for deeper AI review.
- Example:
  - If dev request asks for more than 1 CPU or more than 1Gi memory, flag as medium risk.
  - If prod environment requested, flag as high risk.
  - Recommend approval, changes, or rejection based on rules.

Provisioner:
- Use Jinja2 to render Kubernetes YAML from templates.
- Generate namespace name as team-{team_name}-{environment}.
- Apply YAML using kubectl subprocess.
- Capture stdout/stderr into deployment_log.
- If kubectl fails, mark request FAILED.
- If successful, mark DEPLOYED.
- Include a DRY_RUN mode so local demo works without AKS.

Default app:
- Python FastAPI app.
- Endpoints:
  - /
  - /health
  - /ready
  - /metrics
  - /team-info
- Read TEAM_NAME, ENVIRONMENT, APP_VERSION from environment variables.
- Dockerfile:
  - python slim image
  - non-root user
  - expose 8000
  - run uvicorn
- /metrics should return simple Prometheus-style text.

Kubernetes templates:
For each approved request create:
- Namespace
- ResourceQuota
- LimitRange
- ServiceAccount
- Role
- RoleBinding
- ConfigMap
- Deployment
- ClusterIP Service
- NetworkPolicy

Kubernetes security:
- runAsNonRoot: true
- allowPrivilegeEscalation: false
- drop all capabilities
- CPU and memory requests/limits
- liveness probe on /health
- readiness probe on /ready

NetworkPolicy:
- default deny ingress
- allow ingress to app port 8000
- allow DNS egress if needed

Azure infra scripts:
create-azure.sh:
- variables for location, resource group, AKS name, ACR name, app service name
- create resource group
- create ACR Basic
- create VNet and AKS subnet
- create AKS Free tier with one small node
- attach ACR to AKS
- create App Service Plan using low-cost/free tier if available
- create Linux Web App for Python portal
- get AKS credentials
- print cost warning and cleanup reminder

build-push-default-app.sh:
- build Docker image
- push to ACR
- print full image name

deploy-portal.sh:
- deploy portal to Azure App Service using az webapp up or zip deployment
- set startup command
- set environment variables:
  - DRY_RUN=false
  - DEFAULT_IMAGE=<acr image>

destroy-azure.sh:
- delete full resource group

Docs:
README must include:
- project purpose
- target architecture
- Azure resources
- AKS resources
- traffic flow
- approval flow
- data storage
- permissions model
- cost-control strategy
- local run instructions
- Azure deployment instructions
- cleanup instructions
- CV bullet points

Make code simple, readable, and beginner-friendly. Add comments where useful.