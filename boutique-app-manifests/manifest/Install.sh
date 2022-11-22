#!/bin/bash
##Create  namepace
echo "Please enter the name of namespace:"
read ns_name
kubectl create ns $ns_name
exit_status=$?
if [ $exit_status -eq 1 ]; then
    echo "Unable to create namespace"
    exit $exit_status
else 
    echo $ns_name is created
fi
## Applying Boutique app manifest
kubectl apply -f https://raw.githubusercontent.com/chaosnative/harness-chaos-demo/main/boutique-app-manifests/manifest/app.yaml -n $ns_name
exit_status=$?
if [ $exit_status -eq 1 ]; then
    echo "Unable to apply app manifest"
    exit $exit_status
else 
    echo Boutique app is deployed in $ns_name namepace
fi
## Applying monitoring setup
kubectl apply -f https://raw.githubusercontent.com/chaosnative/harness-chaos-demo/main/boutique-app-manifests/manifest/monitoring.yaml -n $ns_name
exit_status=$?
if [ $exit_status -eq 1 ]; then
    echo "Unable to apply monitoring manifest"
    exit $exit_status
else 
    echo Monitoring setup  is deployed in $ns_name namepace
fi