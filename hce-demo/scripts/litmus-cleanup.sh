#!/bin/bash
echo "\033[31m  \033[5m  Caution \033[0m  \033[1m - This script will delete the namespace litmus and kubera \033[0m"
kubectl config current-context
echo "Do you want to cleanup Litmus for this cluster"
echo  Enter  Press "\033[32m 0 \033[0m"  to continue  Press "\033[31m any other key \033[0m" to Abort
read line
if [ "$line" -eq "0" ]
then
        echo "\033[32m Cleanup Started \033[0m" 
        echo "  Deleting ChaosEngines"
        kubectl delete chaosengines.litmuschaos.io --all -A
        echo "  Deleting ChaosResults"
        kubectl delete chaosresults.litmuschaos.io --all -A
        echo "  Deleting ChaosExperiments"
        kubectl delete chaosexperiments.litmuschaos.io --all -A
        echo "  Deleting Litmus Namespace"
        kubectl delete ns litmus
        echo "  Deleting Cluster Role Binding"
        kubectl get clusterrolebinding | grep -i "argo\|hce\|litmus\|subscriber\|chaos" | awk '{print $1}' | xargs -n 1 kubectl delete clusterrolebinding
        echo "  Deleting Cluster Role"
        kubectl get clusterrole | grep -i "argo\|hce\|litmus\|subscriber\|chaos" | awk '{print $1}' | xargs -n 1 kubectl delete clusterrole
        echo "\033[32m Cleanup Done \033[0m" 
else
        echo  "\033[31m Aborting Cleanup \033[0m" 
fi
exit
