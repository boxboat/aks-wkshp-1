## Pre-Requisites
- Install Azure CLI
- Use Cloud Shell
- An Azure Subscription
- Contributor Rights to Subscription

## Create a resource group to put the workshop content in

```
az group create -g rg-boxboat-wkshp-facundo -l eastus --tags owner=Facundo customer=Internal
```

## Create an Azure Container registry

```
az acr create -g rg-boxboat-wkshp-facundo -n FacundoBoxBoatWorkshopRegistry -l eastus --sku Standard
```

## Create an AKS cluster

```
az aks create -n azaks-boxboat-wkshp-facundo-001 -g rg-boxboat-wkshp-facundo --generate-ssh-keys --attach-acr FacundoBoxBoatWorkshopRegistry
```

## Authenticate against the Azure Kubernetes Service
```
az aks get-credentials --resource-group rg-boxboat-wkshp-facundo --name azaks-boxboat-wkshp-facundo-001
```

## Run Clippy

kubectl run party-clippy --generator=run-pod/v1 --image=r.j3ss.co/party-clippy

## View the YAML

kubectl get pod/party-clippy -o yaml

## Create a service to expose it to the internet

kubectl expose pod/party-clippy --port 80 --target-port 8080 --type LoadBalancer

## View the YAML

kubectl get service/party-clippy -o yaml

## Open the URL

Hello Clippy!


## Clean Up Resources

```
az group delete -g rg-boxboat-wkshp-facundo
```

## More Resources

AKS Workshop at Microsoft