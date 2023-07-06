# HashiCorp Vault

[HashiCorp Vault](https://developer.hashicorp.com/vault/docs/what-is-vault) is an identity-based secrets and encryption management system. A secret is anything that you want to tightly control access to, such as API encryption keys, passwords, and certificates. Vault provides encryption services that are gated by authentication and authorization methods. Using Vault’s UI, CLI, or HTTP API, access to secrets and other sensitive data can be securely stored and managed, tightly controlled (restricted), and auditable.

## Prerequisites

- Kubernetes cluster accessible with `kubectl` CLI
- [Helm](https://helm.sh/docs/intro/install/) CLI
- If you want to setup external ingress, you'll need [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) installed in the cluster and [Cert-Manager](/kubernetes/ops/cert-manager) configured with `letsencrypt-prod` cluster issuer.

## Install HashiCorp Vault - Helm

[HashiCorp Vault Helm chart documentation](https://developer.hashicorp.com/vault/docs/platform/k8s/helm).

Add HashiCorp Helm repository:

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update hashicorp
```

Deploy Vault chart (uncomment ingress related values if you want to enable ingress):

```sh
helm upgrade --install hc-vault hashicorp/vault -n hc-vault --create-namespace \
    --set global.tlsDisable=false # --set server.ingress.enabled=true \
    # --set server.ingress.ingressClassName=nginx \
    # --set-json server.ingress.annotations='{"cert-manager.io/cluster-issuer":"letsencrypt-prod"}' \
    # --set-json server.ingress.hosts='[{"host":"hc-vault.example.com"}]'\
    # --set-json server.ingress.tls='[{"secretName":"hc-vault-tls","hosts":["hc-vault.example.com"]}]'
```

## Access Vault UI

If you have enabled ingress in above step and configured DNS resolution to your custom domain, you should be able to access the UI at `https://hc-vault.example.com`.

If not, forward local machine port `8200` to HC Vault pod port `8200`:

```sh
kubectl port-forward hc-vault-0 8200:8200
```

Then open the following URL in your web browser: `127.0.0.1:8200`

You can then get started by creating your [first secret](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-first-secret).
