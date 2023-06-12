# Enable Infra GitOps with FluxCD

[Flux](https://fluxcd.io/) is a set of continuous and progressive delivery solutions for Kubernetes that are open and extensible.

## Prerequisites

- A Kubernetes cluster.
- A GitHub personal access token **with repo permissions**. See the GitHub documentation on [creating a personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line).

## Getting started

Heavily based on following documentation: https://fluxcd.io/flux/get-started/

Install the Flux CLI:

```sh
brew install fluxcd/tap/flux
```

Export your GitHub credentials:

```sh
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```

Check you have everything needed to run Flux by running the following command:

```sh
flux check --pre
```

Install Flux onto your cluster:

```sh
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=k8s-gitops \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```

## Encrypting secrets using Hashicorp Vault

Prerequisites:
- [Hashicorp Vault](https://developer.hashicorp.com/vault/docs/what-is-vault) instance created and accessible at `$VAULT_ADDR`.

Provide required `VAULT_ADDR` and `VAULT_TOKEN` environment variables:

```sh
export VAULT_ADDR=https://vault.example.com # changeme
export VAULT_TOKEN=hvs.qsj...dfqs # changeme
```

Create an encryption key that you are going to use to encrypt your K8s secrets (**or** use an existing one), e.g. `fluxcd-sops-key`:

```sh
vault write sops/keys/fluxcd-sops-key type=rsa-4096
```

Create a secret the vault token, the key name must be `sops.vault-token` to be detected as a vault token:

```sh
echo $VAULT_TOKEN | kubectl create secret generic sops-hcvault \
--namespace=flux-system \
--from-file=sops.vault-token=/dev/stdin
```

Use sops to encrypt a Kubernetes Secret:

```sh
sops --hc-vault-transit $VAULT_ADDR/v1/sops/keys/fluxcd-sops-key --encrypt \
--encrypted-regex '^(data|stringData)$' --in-place basic-auth.yaml
```

And finally set the decryption secret in the Flux `Kustomization` to `sops-hcvault`.
