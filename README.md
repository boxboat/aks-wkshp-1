So for this lab, we're going to deploy clippy as a web app. It's going to be running as a pod in Kubernetes on Azure. Then we'll expose clippy as a kubernetes service and access it from the browser. 

In the second part, we'll move the container image for Clippy on our own private container registry. Then, we'll see how to update our Kubernetes configuration so that AKS pulls the container image from our private ACR.

Lastly, on the third part, we'll go to Azure portal and enable features on AKS. We'll see what useful features are available to us on top of Kubernetes provided by Azure.

## Pre-Requisites
- Install Azure CLI
- Use Cloud Shell
- An Azure Subscription
- Contributor Rights to Subscription

After you have everything installed, let's create a resource group for this workshop. Later, it will make things much easier to clean-up.

## Create a resource group to put the workshop content in

```
az group create -g rg-boxboat-wkshp-facundo -l eastus --tags owner=Facundo customer=Workshop
```

Next, we're going to start by creating a container registry.

## Create an Azure Container registry

```
az acr create -g rg-boxboat-wkshp-facundo -n FacundoBoxBoatWorkshopRegistry -l eastus --sku Standard
```

## Create an AKS 

```
az aks create -n azaks-boxboat-wkshp-facundo-001 -g rg-boxboat-wkshp-facundo --generate-ssh-keys --attach-acr FacundoBoxBoatWorkshopRegistry
```

## Authenticate against the Azure Kubernetes Service
```
az aks get-credentials --resource-group rg-boxboat-wkshp-facundo --name azaks-boxboat-wkshp-facundo-001
```

## Run Clippy
```
kubectl run party-clippy --generator=run-pod/v1 --image=r.j3ss.co/party-clippy
```
## View the YAML
```
kubectl get pod/party-clippy -o yaml
```
## Create a service to expose it to the internet
```
kubectl expose pod/party-clippy --port 80 --target-port 8080 --type LoadBalancer
```
## View the YAML
```
kubectl get service/party-clippy -o yaml
```
## Open the URL

Hello Clippy!


## Clean Up Resources

```
az group delete -g rg-boxboat-wkshp-facundo
```

## More Resources

AKS Workshop at Microsoft
