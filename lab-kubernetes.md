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
    description: [myname] is a solutions architect at BoxBoat. He was been working with Azure for many years. He started using Azure as a .NET developer when it was new.

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

## Create a resource group to put the workshop content in

```
az group create -g rg-boxboat-wkshp-[myname] -l eastus --tags owner=[myname] customer=Internal
```

## Create an Azure Container registry

```
az acr create -g rg-boxboat-wkshp-[myname] -n [myname]BoxBoatWorkshopRegistry -l eastus --sku Standard
```

## Create an AKS cluster

```
az aks create -n azaks-boxboat-wkshp-[myname]-001 -g rg-boxboat-wkshp-[myname] --generate-ssh-keys --attach-acr [myname]BoxBoatWorkshopRegistry
```

## Authenticate against the Azure Kubernetes Service
```
az aks get-credentials --resource-group rg-boxboat-wkshp-[myname] --name azaks-boxboat-wkshp-[myname]-001
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
