# GitLab EE

This document shows how to deploy an on-prem private GitLab Instance on Kubernetes, using Helm.

## Prereqs

- Kubernetes cluster accessible with `kubectl` CLI
- Install [Helm](https://helm.sh/docs/intro/install/)
- Install [CFSSL](https://github.com/cloudflare/cfssl/releases/latest) CLI (at least `cfssl` and `cfssljson`).

## Supporting Docs

- [GitLab EE](https://docs.gitlab.com/ee/install/)
- [GitLab Runner](https://docs.gitlab.com/runner/install/kubernetes.html)

## GitLab

Create a working directory `$HOME/gitlab`:

```
mkdir $HOME/gitlab
cd $HOME/gitlab
```

Get the GitLab Helm repository:

```sh
helm repo add gitlab https://charts.gitlab.io
helm repo update gitlab
```

Create a script `gitlab-tls.sh` that will generate GitLab TLS CA and certificate and corresponding secrets:

```sh
touch gitlab-tls.sh
```

Put the following content:

```sh
#!/bin/bash
set -e

#############
## setup environment
NAMESPACE=${NAMESPACE:-gitlab}
RELEASE=${RELEASE:-gitlab}
DOMAIN=${DOMAIN:-apps.k8s.example.com}
## stop if variable is unset beyond this point
set -u
## known expected patterns for SAN
CERT_SANS="*.${RELEASE}.${DOMAIN},*.${DOMAIN}"

#############
## generate default CA config
cfssl print-defaults config > ca-config.json
## generate a CA
echo '{"CN":"'${RELEASE}.${DOMAIN}.ca'","key":{"algo":"ecdsa","size":256}}' | \
  cfssl gencert -initca - | \
  cfssljson -bare ca -
## generate certificate
echo '{"CN":"'${RELEASE}.${DOMAIN}'","key":{"algo":"ecdsa","size":256}}' | \
  cfssl gencert -config=ca-config.json -ca=ca.pem -ca-key=ca-key.pem -profile www -hostname="${CERT_SANS}" - |\
  cfssljson -bare ${RELEASE}

#############
## load certificates into K8s
kubectl create ns ${NAMESPACE}
kubectl -n ${NAMESPACE} create secret tls ${RELEASE}-tls \
  --cert=${RELEASE}.pem \
  --key=${RELEASE}-key.pem
kubectl -n ${NAMESPACE} create secret generic ${RELEASE}-tls-ca \
  --from-file=${RELEASE}.${DOMAIN}.crt=ca.pem

```

Run the script, provide a valid base `DOMAIN` e.g. `apps.k8s.example.com`:

```sh
chmod u+x gitlab-tls.sh
export DOMAIN="<YOUR_DOMAIN>"
./gitlab-tls.sh
```

Populate your Helm chart config `gitlab.values.yaml` like the following, provide a valid `domain`:

```yaml
# $HOME/gitlab/gitlab.values.yaml
global:
  hosts:
    domain: apps.k8s.example.com

  ingress:
    configureCertmanager: false
    tls:
      enabled: true
      secretName: gitlab-tls

  certificates:
    customCAs:
    - secret: gitlab-tls-ca

certmanager:
  installCRDs: false
  install: false

gitlab-runner:
  install: false

```

**Note**: you can check all available configuration by running `helm show values gitlab/gitlab`.

Install Helm chart using your custom configuration:

```sh
helm install gitlab gitlab/gitlab --timeout=600s --values gitlab.values.yaml -n gitlab
```

Wait until all pods are running:

```sh
watch kubectl get pods -n gitlab
```

## GitLab Runner

Create a sub folder `gitlab-runner` and move to there:

```sh
mkdir gitlab-runner
cd gitlab-runner
```

Create your GitLab Runner configuration `gitlab-runner.values.yaml` like the following, provide a valid `gitlabUrl` and `runnerRegistrationToken`:

```yaml
# $HOME/gitlab/gitlab-runner/gitlab-runner.values.yaml
gitlabUrl: https://gitlab.apps.k8s.example.com
runnerRegistrationToken: "AoDG...31SGP"
certsSecretName: gitlab-tls-ca

```

**Note**: see [how to retrieve your runner registration token](https://docs.gitlab.com/runner/install/kubernetes.html#required-configuration).

Install Helm chart using your custom configuration:

```sh
helm install --namespace gitlab gitlab-runner -f gitlab-runner.values.yaml gitlab/gitlab-runner
```

Wait for runner pod to be up and running:

```sh
watch kubectl get pods -n gitlab
```
