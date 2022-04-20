# harness-chaos-demo
Simple Demo Block for Harness Chaos Engineering (standalone). 

## Environment
The demo has been tested on GKE with Kubernetes v1.21.x. It should ideally work on other Kubernetes clusters equally well, 
with minor changes to service type (NodePort/Loadbalancer/Ingress)

## Credits
The sample Kubernetes application used in this demo is originally from @ecointet-harness's [platform-demo](https://github.com/wings-software/platform-demo2) with some minor tweaks to the container image and installation manifest (app deployed as a statefulset with PVs from a default storage class as opposed to a deployment using GCS bucket). 

*Note: The choice of app is to maintain some level of consistency with the standard Harness (CI/CD/FF/CCM) demos, so that the demo-artifacts can be reused even after HCE is fully integrated as a module within the Harness platform.*

## Prerequisites 
- Prepare your Kubernetes cluster
- Apply the Kubernetes manifests to install the [Captain Canary Web Application](https://github.com/chaosnative/harness-chaos-demo/tree/main/k8s/web-app)
- Download the  [Harness Chaos Engineering (Standalone)](http://hce.chaosnative.com/manifests/ci/hce-cluster-scope.yaml) installation manifest & apply on the 
  cluster to run the control plane microservices. Setup access to the dashboard via the right service type. 
- Login to chaos-center dashboard with admin credentials (`admin/litmus`) and verify successful connect of the `Self-Agent`
- Setup monitoring infra using Prometheus & Grafana ([kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) 
  helm chart is a great way to achive this)
- Setup the blackbox-exporter in order to start capturing the basic accessibility attributes of the Captain Canary Web App (this includes running the blackbox 
  exporter [deployment/service](https://github.com/chaosnative/harness-chaos-demo/blob/main/k8s/monitoring/blackbox-exporter.yaml) & creating the [servicemonitor](https://github.com/chaosnative/harness-chaos-demo/blob/main/k8s/monitoring/servicemonitor-blackbox-exporter.yaml) against it)
- Begin scraping the Chaos metrics by creating the servicemonitor aginst the [chaos-exporter](https://github.com/chaosnative/harness-chaos-demo/blob/main/k8s/monitoring/servicemonitor-chaos-exporter.yaml) service (installed automagically as part of the Self-Agent setup)
- Leverage a simple chaos-annotated [grafana dashboard](https://github.com/chaosnative/harness-chaos-demo/blob/main/monitoring/grafana/platform-demo-dashboard.json) 
  to track the availability & average access duration/latency of the Web App.
  
  Here are some screenshots to help do the readiness-check of the demo setup: 
  
  ![image](https://user-images.githubusercontent.com/21166217/164219892-3480572f-2a14-4eaf-91e9-bb9f9aab26a8.png)
  ![image](https://user-images.githubusercontent.com/21166217/164220267-17160244-d633-4ae5-af7a-699cc388e7e0.png)
  ![image](https://user-images.githubusercontent.com/21166217/164220170-c94b9956-a225-44b7-ae45-2711fb773475.png)




