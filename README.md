##### Table of Contents
- [Introduction](#introduction)
- [Environment](#environment)
- [Credits](#credits)
- [Prerequisites](#prerequisites)
- [Pre-Demo](#pre-demo)
- [Demo-Part-A: Run A Chaos Workflow (Pod Kill With Availability Check) To Test Resilience](#demo-part-a-run-a-chaos-workflow-pod-kill-with-availability-check-to-test-resilience)
- [Demo-Part-B: Convert A Chaos Workflow To A Pre-Defined Workflow](#demo-part-b-convert-a-chaos-workflow-to-a-pre-defined-workflow)


## Introduction
Simple Demo Block for Harness Chaos Engineering (standalone). 

## Environment
The demo has been tested on GKE with Kubernetes v1.21.x. It should ideally work on other Kubernetes clusters equally well, 
with minor changes to service type (NodePort/Loadbalancer/Ingress)

## Credits
The sample Kubernetes application used in this demo is originally from **@ecointet-harness**'s [platform-demo](https://github.com/wings-software/platform-demo2) with some minor tweaks to the container image and installation manifest (app deployed as a statefulset with PVs from a default storage class as opposed to a deployment using GCS bucket). 

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
  
## Pre-Demo

Before getting into the chaos runs & post-chaos actions on the platform, the users can be given a quick tour of the dashboard: with a few pointers
provided on the chaos-agents, chaoshub(s) and user-management/teaming capabilities. 

## Demo-Part-A: Run A Chaos Workflow (Pod Kill With Availability Check) To Test Resilience

### Objective

Demonstrate how a chaos workflow can be constructed by picking a suitable fault (chaosexperiment) from the ChaosHub (in this case: generic/pod-delete) 
and adding a probe (in this case: httpProbe) to validate our hypothesis around application availability and performance. 

### Chaos Particulars

Scenario|Hypothesis|SLI |SLO|
--------|----------|----|---|
Kill the web-app replica| The pod is rescheduled & up immediately. There is no loss of access| `avg_over_time(probe_success{job="prometheus-blackbox-exporter", namespace="monitoring"}[60s:1s]) * 100`| > 99.95%

**Probe-Definition**: 

```yaml
probe:
- name: platform-website-check
  type: httpProbe
  mode: Continuous
  runProperties:
    probeTimeout: 5
    retry: 2
    interval: 5
    probePollingInterval: 1
    initialDelaySeconds: 1
    stopOnFailure: false
  httpProbe/inputs:
    url: http://platform-demo.platform-demo.svc.cluster.local:8000/
    insecureSkipVerify: false
    method:
      get:
        criteria: ==
        responseCode: "200"
```

### Observation

- The app replica is rescheduled but is not available/ready for requests immediately due to some initialDelay period/startup time. 

  ![image](https://user-images.githubusercontent.com/21166217/164224265-571192c4-704d-4a37-badd-bb8962fd2305.png)

- There is loss of access to the app for nearly 60s 

  ![image](https://user-images.githubusercontent.com/21166217/164224992-64e54f51-44ed-4294-80b9-74d3e61e3c5c.png)

- The HTTP probe & thereby the chaos-workflow is seen to fail 

  ![image](https://user-images.githubusercontent.com/21166217/164225249-96b98fdc-b804-4bd9-add4-3ea8d0a2ed33.png)

  ![image](https://user-images.githubusercontent.com/21166217/164225109-1c4aea00-c8c6-4ed5-8d0a-be88f0478f4c.png)

### Mitigation

[Scale](https://github.com/chaosnative/harness-chaos-demo/blob/main/scripts/scale-webapp) the application to multiple replicas.

With this, the hypothesis is validated successfully & chaos workflow is seen to succeed.

![image](https://user-images.githubusercontent.com/21166217/164227634-36e9be84-fc89-435d-b0d5-87f74fae3187.png)

![image](https://user-images.githubusercontent.com/21166217/164227451-867662f8-5b05-48c7-95fb-09738dd9efcb.png)

![image](https://user-images.githubusercontent.com/21166217/164227258-3739a19e-3c65-4e24-97be-d2bfbaf15d6d.png)

### Summary

The following aspects were covered: 

- The procedure to construct and execute a chaos-workflow against a desired agent with specific hypothesis (via probes) 
- Viewing chaos metrics, logs & workflow status  

## Demo-Part-B: Convert A Chaos Workflow To A Pre-Defined Workflow

### Objective

Demonstrate how a chaos workflow which has been tested for desired impact (such as the one built  in [Demo-Part-A](https://github.com/chaosnative/harness-chaos-demo#demo-part-a-run-a-chaos-workflow-pod-kill-with-availability-check-to-test-resilience)) can be converted into a "Pre-defined Workflow" and stored in a 
Git repo for on-demand/ready execution whenever needed. 

This feature helps organizations/users created a dedicated (public/private) chaos artifact source with custom workflow templates mapped to specific reliability-test scenarios. 

### Steps to create pre-defined workflow

- Create a Git repository (public/private) 

- Download the workflow manifest from chaos-center (click the three-dots against the desired workflow in the "Schedules" tab of the "Litmus Workflows" page) 
  ![image](https://user-images.githubusercontent.com/21166217/164232626-b0cf7d1f-6573-4a85-87ae-c08b270d620a.png)

- Remove the entries in the `metadata.labels` section of `Workflow` resource as well as the `metadata.labels` section of the `ChaosEngine` resource(s) embedded 
  input artifact(s) in one or more `template` definitions of the workflow
  
  ![image](https://user-images.githubusercontent.com/21166217/164239712-bb5064a4-6b44-45c0-a335-a53e874a2c56.png)
  ![image](https://user-images.githubusercontent.com/21166217/164239947-3c789986-98cc-4faf-a3b3-b0800c742518.png)
  
- Place it in the git repository under a `workflows` parent directory (as in [this](https://github.com/chaosnative/harness-chaos-demo/tree/main/workflows) repo), 
  under a folder named appropriately (hereby referred as _workflow-folder_), alongside a `ChartServiceVersion` YAML file (such as [this](https://github.com/chaosnative/harness-chaos-demo/blob/main/workflows/harness-chaos-demo/harness-chaos-demo.chartserviceversion.yaml) one) that describes the workflow. 
  
  *Note: Ensure that the chartserviceversion yaml is named `<workflow-folder-name>-chartserviceversion.yaml`* 
  
- (Optional) Create an `icons` folder inside the `workflows` parent directory (such as [this](https://github.com/chaosnative/harness-chaos-demo/tree/main/workflows/icons) one) and place a desired image (.png) in it with the same name as the _workflow-folder_

- Place the [charts](https://github.com/chaosnative/harness-chaos-demo/tree/main/charts) directory at the repo root, alongside the `workflows` parent directory. 

- Add a new ChaosHub on chaos-center pointing to the git chaos artifact source 

  ![image](https://user-images.githubusercontent.com/21166217/164237438-faa13533-1571-4542-9663-50ae25ecb448.png)
  ![image](https://user-images.githubusercontent.com/21166217/164238021-5422363d-4e96-4956-87fc-2a71e0e981cd.png)
  
- Browse the newly added ChaosHub to view the pre-defined workflow available for execution: 

  ![image](https://user-images.githubusercontent.com/21166217/164238237-6d6a1045-2491-4cb4-ab0c-36c69f317240.png)
  
- Schedule a chaos workflow run using the *pre-defined workflow template* option in the chaos workflow construction wizard

  ![image](https://user-images.githubusercontent.com/21166217/164238611-afaf3964-60ae-45c9-b779-01ff492ebca9.png)


  







