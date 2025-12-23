# Spring Boot API - Kubernetes PoC

This project demonstrates a GitOps-based deployment of a Spring Boot API application using Argo CD and Helm. It includes an Argo CD ApplicationSet to manage deployments across multiple environments (dev, prd) with environment-specific configurations.

### Components

* Argo CD ApplicationSet: Automates the deployment of the application to defined clusters.
* Helm Chart: Contains the templates for Kubernetes resources (Deployment, Service, Ingress, etc.).
* Environment Values: Specific configuration values for `dev` and `prd` environments.

## Prerequisites

* Helm installed.
* Kubectl installed.
* Kubernetes cluster credentials present on host.
* Argo CD installed on the management cluster.

## Assumptions

* POD_IP env variable should have only IP of the pod on which it's present
* Application execution is simulated. The container runs a shell script that sleeps indefinitely (untill killed by readinessProbe probe) instead of starting the actual Spring Boot application.

## Usage

1. Confirm cluster config
```bash
kubectl config get-contexts
```

2. Create namespaces
```bash
kubectl create namespace spring-boot-api-dev
kubectl create namespace spring-boot-api-prd
# Verify
kubectl get namespaces
```

3. Install aplication
```bash
helm upgrade --install -n spring-boot-api-dev hello-poc charts/spring-boot-api --values environments/dev/values.yaml
helm upgrade --install -n spring-boot-api-prd hello-poc charts/spring-boot-api --values environments/prd/values.yaml
```

4. Verify application 
```bash
# Status
# Pods are not marked as READY see charts/spring-boot-api/templates/deployment.yaml:49
kubectl -n spring-boot-api-dev get all
kubectl -n spring-boot-api-prd get all
# Configuration
kubectl -n spring-boot-api-dev get pods -o wide
kubectl -n spring-boot-api-prd get pods -o wide
kubectl -n spring-boot-api-dev exec -it $POD_NAME -- /bin/sh
kubectl -n spring-boot-api-prd exec -it $POD_NAME -- /bin/sh
cat /app/config.json
echo $POD_IP
exit
```

5. Clean up
```bash
helm uninstall -n spring-boot-api-dev hello-poc
helm uninstall -n spring-boot-api-prd hello-poc
kubectl delete spring-boot-api-dev
kubectl delete namespace spring-boot-api-prd
```
