Use Terraform code to deploy the infra
Create Terraform deployment pipeline
Running the pipeline via self hosted agent in github

Service Principal name for the deployment identity is :
serviceprincipal
Service Principal id for the deployment identity is :
3ebdf63b-b0bf-4c9e-b120-7d565a94239a

Subscription name : Katona.Balint
Subscription id : 39023a16-af6f-4b68-8498-e36556540d33
Remote storage account name : defaultstac0231
Remote storage account container name : default

I need dedicated deployment pipeline for the app service / portal infra :
VNET rg : rg-01
VNET name : vnet01
Subnet name : subnet-2-portal
Subnet address space : 172.16.0.64/27

For the AKS application to be deployed :
VNET rg : rg-01
VNET name : vnet01
Subnet name : subnet-3-aks
Subnet address space : 172.16.0.192/26

create the solution module based, if possible use terragrunt, so later when there will be more environments, it will be easier to create the configs
