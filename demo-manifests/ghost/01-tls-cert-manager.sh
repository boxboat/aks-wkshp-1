#!/bin/bash -e

# Create namespace
kubectl create ns cert-manager | :

# Label the ingress-basic namespace to disable resource validation
kubectl label namespace cert-manager cert-manager.io/disable-validation=true --overwrite

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update > /dev/null

# Install the cert-manager Helm chart
helm upgrade --install \
  cert-manager \
  --namespace cert-manager \
  --version v1.1.0 \
  --set installCRDs=true \
  --set nodeSelector."beta\.kubernetes\.io/os"=linux \
  jetstack/cert-manager
