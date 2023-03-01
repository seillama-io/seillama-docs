# Wiki.js

[Wiki.js](https://js.wiki/) is an open source Wiki software that allows you to kake documentation a joy to write using a beautiful and intuitive interface!

## Prereqs

- Kubernetes cluster accessible with `kubectl` CLI
- [Cert Manager](https://cert-manager.io/docs/installation) configured in K8s cluster, with `letsencrypt-prod` [ClusterIssuer](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/#step-6---configure-a-lets-encrypt-issuer) created. 
- Install [Helm](https://helm.sh/docs/intro/install/)

## *Optional*: Create custom PostgreSQL DB

**Note**: This is only required for `arm` based deployment as the default Wiki.js PostgreSQL image is only available for `amd64` architectures.

```sh
helm repo add romanow https://romanow.github.io/helm-charts/
helm repo update
helm install wiki-pg romanow/postgres -n wiki --create-namespace
```

## Deploy Wiki.js using Helm

Edit your `wiki.values.yaml` file to configure your deployment:


```sh
vim wiki.values.yaml
```

```yaml
# wiki.values.yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: wiki.seillama.dev
      paths:
        - path: "/"
          pathType: Prefix
  tls:
    - secretName: wiki-tls
      hosts:
        - wiki.seillama.dev

postgresql:
  enabled: false
  postgresqlHost: wiki-pg
  postgresqlUser: postgres
  postgresqlDatabase: postgres
  existingSecret: wiki
  existingSecretKey: postgresql-password
```

Deploy Wiki.js

```sh
helm repo add requarks https://charts.js.wiki
helm repo update
helm install wiki requarks/wiki -n wiki -f wiki.values.yaml
```
