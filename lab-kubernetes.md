---
# Page settings
layout: default
keywords:
comments: false

# Hero section
title: Kubernetes
description: Let's apply the basics of Kubernetes and play with Azure Kubernetes Service (AKS)

# Author box
author:
    title: About Author
    title_url: '#'
    external_url: true
    description: Facundo is a solutions architect at BoxBoat. He was been working with Azure for many years. He started using Azure as a .NET developer when it was new.

# Micro navigation
micro_nav: true

# Page navigation
page_nav:
    prev:
        content: Intro to Docker
        url: '/lab-docker'
---

## Pre-Requisites
- Azure CLI
- An Azure Subscription with **Contributor** rights
- `kubectl`

## Deploying Clippy

First, let's create a resource group to place the material in.

``` shell
az group create -g rg-boxboat-wkshp-[myname] -l eastus --tags owner=[myname] customer=Internal
```

Then, let's create an Azure Container registry (ACR).

``` shell
az acr create -g rg-boxboat-wkshp-[myname] -n [myname]BoxBoatWorkshopRegistry -l eastus --sku Standard
```

Now, let's create the Azure Kubernetes Service (AKS) cluster. This might take a while. Notice how it's using the `--attach-acr` flag. This flag tells the Azure CLI to configure the authentication for the ACR registry from the AKS cluster.

``` shell
az aks create -n azaks-boxboat-wkshp-[myname]-001 -g rg-boxboat-wkshp-[myname] --generate-ssh-keys --attach-acr [myname]BoxBoatWorkshopRegistry
```

Now, authenticate against the Azure Kubernetes Service. Notice how it configures the `~/.kube/config` file.
``` shell
az aks get-credentials --resource-group rg-boxboat-wkshp-[myname] --name azaks-boxboat-wkshp-[myname]-001
```

> Note: If you don't have `kubectl`, run `az aks install-cli` to install `kubectl`

Now, run clippy! But you won't be able to see it just yet.
```
kubectl run party-clippy --generator=run-pod/v1 --image=r.j3ss.co/party-clippy
```

Inspect the YAML
``` shell
kubectl get pod/party-clippy -o yaml
```

To see clippy, we must espose the pod to the internet. Let's create a Kubernetes _service_.

``` shell
kubectl expose pod/party-clippy --port 80 --target-port 8080 --type LoadBalancer
```

Now, view the YAML. 
```shell
kubectl get service/party-clippy -o yaml
```

You'll notice an IP Address under `status.IPAddress`. 

Open up your browser, type in the IP Address.

Hello Clippy!

```
 _________________________________
/ It looks like you're building a \
\ microservice.                   /
 ---------------------------------
 \
  \
     __
    /  \
    |  |
    @  @
    |  |
    || |  /
    || ||
    |\_/|
    \___/
```

## Using your container registry

Now, in most scenarios, you won't be deploying an enterprise application from a public container registry. 
Instead, you will be likely be using a private container registry like Azure Container Registry (ACR). 

Let's move the clippy container image into your _own_ container registry you created before.

Microsoft has clear documentation on how to do this. [See here](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-import-images#import-from-a-public-registry). They also provide options on how to import private container images from other registries into ACR.

``` shell
az acr import --name [myname]BoxBoatWorkshopRegistry --source r.j3ss.co/party-clippy:latest --image=party-clippy:latest
```

``` shell
az acr repository list -n [myname]BoxBoatWorkshopRegistry
```

Now, since the `party-clippy` is in the container registry, let's re-deploy clippy so that the image being pulled comes from the private registry instead.

``` shell
kubectl get svc/party-clippy -o=jsonpath='{.status.loadBalancer.ingress[*].ip}'
```

``` shell
$ curl [ip from above]
 _________________________________
/ It looks like you're building a \
\ microservice.                   /
 ---------------------------------
 \
  \
     __
    /  \
    |  |
    @  @
    |  |
    || | /
    || ||
    |\_/|
    \___/
```

## Exploring features on AKS

Go to the Azure portal and try to do the following: 

- Find AKS Cluster
- Find the Azure Container Registry. Then enable geo-replication to another region.
- Find the node pool for that cluster
- Find the VMs part of that node pool

Great. Then, try to scale from 3 nodes to 2 nodes using the Azure portal. 

You can observe from the Azure Cloud Shell by:

``` bash
# authenticate to aks
az aks get-credentials -n azaks-boxboat-wkshp-[myname]-001 -g rg-boxboat-wkshp-[myname]
```

Then, issuing `kubectl` commands to watch the node being removed.

``` bash
kubectl get nodes -w
```

Try scaling one more time. This time use the Azure CLI to remove another node and scale to a _single_ instance.

```
# this takes some time
az aks scale --name azaks-boxboat-wkshp-[myname]-001 --node-count 1 --resource-group rg-boxboat-wkshp-[myname]

# see the status once again
kubectl get nodes
```

Is clippy still running? We removed two nodes so far. 2/3 chances that it's not.

``` shell
kubectl get pods
```

## Making Clippy reliable

If clippy is not running, let's make it reliable by making a Kubernetes deployment.

You can keep using the Azure Cloud Shell, or authenticate from your own workstation (you'll have to `az login` first).

Assumming you have VS Code (Cloud Shell already has it installed), then create a new `deployment.yaml` file.
```
code deployment.yaml
```

Then paste in this snippet and fill in the placeholders.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: clippy-deployment
spec:
  selector:
    matchLabels:
      app: clippy
  template:
    metadata:
      labels:
        app: clippy
    spec:
      containers:
      - name: clippy
        image: [myname]BoxBoatWorkshopRegistry.azurecr.io/party-clippy
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 8080
```

Deploy it.

```
kubectl apply -f deployment.yaml
```

Watch the deployment.

``` 
kubectl get deployment -w
```

Is Clippy running?

Probably not. We haven't configured a service to point to the proper label. The previous load balancer we created was using the shortcut: `kubectl expose` which targeted a single pod. 

Let's create a proper service. Create another file called `service.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: clippy-service
spec:
  type: LoadBalancer
  selector:
    app: clippy
  ports:
  - port: 80
    targetPort: 8080
```

And, deploy it. 

``` bash
kubectl apply -f service.yaml
```

Great, wait for the public IP to be assigned (`External IP`).

``` bash
kubectl get svc -w
```

Once it finishes, is Clippy running now?

``` bash
$ curl [External IP from Above]

 _________________________________
/ It looks like you're building a \
\ microservice.                   /
 ---------------------------------
 \
  \
     __
    /  \
    |  |
    @  @
    |  |
    || | /
    || ||
    |\_/|
    \___/
```

Great! Now that clippy is running. 

Try stopping the AKS cluster (it will deallocate all the worker nodes) and re-creating it. 

``` bash
az aks stop --name  azaks-boxboat-wkshp-[myname]-001 --resource-group rg-boxboat-wkshp-[myname]

az aks stop --name  azaks-boxboat-wkshp-[myname]-001 --resource-group rg-boxboat-wkshp-[myname]
```

When the cluster stops, Clippy's pod will die. 

When the cluster starts-up, Clippy's pod will be re-created. 

After it finishes, check-up on Clippy again. 


That's it!

Congrats and thanks for following-up on this lab!


## Clean-Up

Delete all the resources created in the resource group with

```
az group delete -g rg-boxboat-wkshp-[myname]
```



