# Cert-Manager

[Cert-Manager](https://cert-manager.io/) is a powerful and extensible X.509 certificate controller for Kubernetes and OpenShift workloads. It will obtain certificates from a variety of Issuers, both popular public Issuers as well as private Issuers, and ensure the certificates are valid and up-to-date, and will attempt to renew certificates at a configured time before expiry.

## Prereqs

- Kubernetes cluster accessible with `kubectl` CLI
- [Helm](https://helm.sh/docs/intro/install/) CLI
- [CFSSL](https://github.com/cloudflare/cfssl/releases/latest) CLI

## Install (Helm)

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.0 \
  --set installCRDs=true
```

## Self-Signed cluster issuer

```yaml
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-cluster-issuer
spec:
  selfSigned: {}
EOF
```

You can then use it as follow:

```yaml
# example-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kuard
  annotations:
    kubernetes.io/ingress.class: "nginx"    
    cert-manager.io/issuer: "selfsigned-cluster-issuer"
spec:
  tls:
  - hosts:
    - example.example.com
    secretName: quickstart-example-tls
  rules:
  - host: example.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kuard
            port:
              number: 80
```
