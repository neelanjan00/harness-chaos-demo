#!/bin/bash
if [ $1 == "SCALE_DOWN" ];
then
    echo "Please enter the name of namespace:"
    read ns_name
    kubectl scale deploy --all --replicas=0 -n $ns_name
    exit_status=$?
    if [ $exit_status -eq 1 ]; then
        echo Unable to scale down the deployments in $ns_name namespace
        exit $exit_status
    else 
        echo All the deployments in $ns_name namepace is scaled to 0.
    fi
elif [ $1 == "SCALE_UP" ];
then
    echo "Please enter the name of namespace:"
    read ns_name
    kubectl scale deploy --all --replicas=1 -n $ns_name
    exit_status=$?
    if [ $exit_status -eq 1 ]; then
        echo Unable to scale up the deployments in $ns_name namespace
        exit $exit_status
    else 
        echo All the deployments in $ns_name namepace is scaled to 1.
    fi
else
    echo "Invalid Argument: Please pass 'SCALE_UP' to scale the deployments to 1 replicas in your ns and pass 'SCALE_DOWN' to scale the deployments to 0 replica"
fi