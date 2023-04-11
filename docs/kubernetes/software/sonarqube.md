# SonarQube

[SonarQube](http://www.sonarqube.org/) is a self-managed, automatic code review tool that systematically helps you deliver clean code. As a core element of our Sonar solution, SonarQube integrates into your existing workflow and detects issues in your code to help you perform continuous code inspections of your projects. The tool analyses 30+ different programming languages and integrates into your CI pipeline and DevOps platform to ensure that your code meets high-quality standards.

## Prerequisites

- Kubernetes cluster accessible with `kubectl` CLI
- Install [Helm](https://helm.sh/docs/intro/install/)

## Supporting Docs

- [SonarQube Helm Chart](https://bitnami.com/stack/sonarqube/helm)

## SonarQube

Get the `bitnami` Helm repository:

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami
```

Install the chart:

```sh
export SONARQUBE_PASSWORD=<CHANGE_ME>
helm install sonarqube bitnami/sonarqube -n sonarqube --create-namespace --set sonarqubePassword=${SONARQUBE_PASSWORD}
```

**Optional**: if running on OpenShift, grant `privileged` SCC to the `default` and `sonarqube` service accounts in `sonarqube` namespace:

```sh
oc adm policy add-scc-to-user privileged -z default -n sonarqube
oc adm policy add-scc-to-user privileged -z sonarqube -n sonarqube
```
