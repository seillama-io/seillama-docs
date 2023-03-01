# NGINX Ingress Controller

The [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) is an implementation of a Kubernetes Ingress Controller for NGINX. The Ingress is a Kubernetes resource that lets you configure an HTTP load balancer for applications running on Kubernetes, represented by one or more Services. Such a load balancer is necessary to deliver those applications to clients outside of the Kubernetes cluster.

The Ingress resource supports Content-based routing and TLS/SSL termination for each hostname.

## Prereqs

- Kubernetes cluster accessible with `kubectl` CLI
- Install [Helm](https://helm.sh/docs/intro/install/)

## Install

```sh
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```
