# Docker Registry

This document shows how to deploy an on-prem private Docker Registry on Kubernetes, using Helm.

## Prerequisites

- Kubernetes cluster accessible with `kubectl` CLI
- [Helm](https://helm.sh/docs/intro/install/) CLI
- [CFSSL](https://github.com/cloudflare/cfssl/releases/latest) CLI (at least `cfssl` and `cfssljson`).
- [htpasswd](https://httpd.apache.org/docs/current/programs/htpasswd.html) CLI
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) installed in the cluster
- Some LB (e.g. HAProxy) is set up to balance `registry.<BASE_DOMAIN>` to cluster Nginx Ingress Controller load balancer.

## Generate TLS certs

Create a working directory `$HOME/docker-registry`:

```sh
mkdir $HOME/docker-registry
cd $HOME/docker-registry
```

Get the Docker Registry Helm repository:

```sh
helm repo add twuni https://twuni.github.io/docker-registry.helm
helm repo update twuni
```

Create a script `registry-tls.sh` that will generate TLS CA, certificate and corresponding secrets:

```sh
touch registry-tls.sh
```

Put the following content:
 
```sh
#!/bin/bash
set -e

#############
## setup environment
NAMESPACE=${NAMESPACE:-docker-registry}
RELEASE=${RELEASE:-registry}
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
kubectl delete secret ${RELEASE}-tls -n ${NAMESPACE}
kubectl delete secret ${RELEASE}-tls-ca -n ${NAMESPACE}
kubectl -n ${NAMESPACE} create secret tls ${RELEASE}-tls \
  --cert=${RELEASE}.pem \
  --key=${RELEASE}-key.pem
kubectl -n ${NAMESPACE} create secret generic ${RELEASE}-tls-ca \
  --from-file=${RELEASE}.${DOMAIN}.crt=ca.pem

```

Run the script, provide a valid base `DOMAIN` e.g. `apps.k8s.example.com`:

```sh
chmod u+x registry-tls.sh
export DOMAIN="<YOUR_DOMAIN>"
./registry-tls.sh
```

## Configure and Deploy Helm Chart

Generate default user and password for registry, provide valid `USERNAME` and `PASSWORD`:

```sh
htpasswd -Bbn ${USERNAME} ${PASSWORD} > .htpasswd
```

Install Helm Chart:

```sh
helm upgrade --install registry twuni/docker-registry -n docker-registry --create-namespace --set secrets.htpasswd=$(cat .htpasswd)
```

## Configure Ingress

Create Ingress file, provide valid TLS `hosts` and rule `host`:

```yaml
# $HOME/docker-registry/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: registry-ingress
  namespace: docker-registry
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - registry.apps.k8s.example.com # change me
    secretName: registry-tls
  rules:
  - host: registry.apps.k8s.example.com # change me
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: registry-docker-registry
            port:
              number: 5000

```

Apply ingress configuration:

```sh
kubectl apply -f ingress.yaml
```

## *Optional*: Registry access from external K8s cluster

On each worker node of your K8s cluster that will need access to this private registry, put the content of your `ca.pem` in a file `/usr/local/share/ca-certificates/private-docker-registry.crt` and restart your container runtime *e.g.* on Ubuntu with `docker` runtime:

```sh
sudo su -
cat <<EOF > /usr/local/share/ca-certificates/private-docker-registry.crt
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
EOF
sudo update-ca-certificates
sudo systemctl restart docker
```
