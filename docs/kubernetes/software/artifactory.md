# JFrog Artifactory

## Prereqs

- Kubernetes cluster accessible with `kubectl` CLI
- Install [Helm](https://helm.sh/docs/intro/install/)

## Supporting Docs

- [Artifactory Helm Chart](https://github.com/jfrog/charts/tree/master/stable/artifactory)

## Artifactory

Get the JFrog Helm repository:

```sh
helm repo add jfrog https://charts.jfrog.io
helm repo update jfrog
```

Install the chart:

```sh
helm upgrade --install artifactory --namespace artifactory jfrog/artifactory --create-namespace
```
