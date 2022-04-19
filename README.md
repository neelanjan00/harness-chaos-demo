# harness-chaos-demo
Simple Demo Block for Harness Chaos Engineering (standalone)

## Environment
The demo has been tested on GKE with Kubernetes v1.21.x. It should ideally work on other Kubernetes clusters equally well, 
with minor changes to service access type (NodePort/Loadbalancer/Ingress)

## Credits
The sample application used in this demo is originally from @ecointet-harness's [platform-demo](https://github.com/wings-software/platform-demo2) with some minor tweaks to the container image and deployment manifest (app deployed as a statefulset with PVs from a default storage class). 

## 
