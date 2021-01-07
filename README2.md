# Import container registry
az acr import --name FacundoBoxBoatWorkshopRegistry --source r.j3ss.co/party-clippy:latest --image=party-clippy:latest

# Verify that the container was imported
az acr repository list -n FacundoBoxBoatWorkshopRegistry

# Now let's redeploy clippy, first see that it's running
kubectl get pods

# Then delete
kubectl delete pod/party-clippy

# now see that it's gone
kubectl get pods

# Run party clippy from the container registry
kubectl run party-clippy --generator=run-pod/v1 --image=FacundoBoxBoatWorkshopRegistry.azurecr.io/party-clippy

# Get party clippy
kubectl get pod/party-clippy -o yaml

# Get the public IP address
kubectl get svc/party-clippy -o jsonpath=".status.loadBalancer.ingress.ip"

# yay clippy
curl 40.76.154.17
