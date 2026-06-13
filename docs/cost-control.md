# Cost Control

- Keep AKS on the Free tier with a single small node for demos.
- Use Basic ACR unless image throughput requires more.
- Run the portal on a low-cost Linux App Service plan.
- Prefer `DRY_RUN=true` for local demos to avoid accidental cluster changes.
- Tag resources clearly and delete the resource group after each workshop or interview demo.
- Introduce expiry policies later so temporary namespaces are removed automatically.
