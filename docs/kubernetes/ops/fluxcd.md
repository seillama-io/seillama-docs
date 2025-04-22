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

## Encrypting secrets using OpenPGP

Generate a GPG/OpenPGP key with no passphrase (`%no-protection`):

```sh
export KEY_NAME="cluster0.yourdomain.com"
export KEY_COMMENT="flux secrets"

gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF
```

The above configuration creates an rsa4096 key that does not expire. For a full list of options to consider for your environment, see [Unattended GPG key generation](https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html).

Retrieve the GPG key fingerprint (second row of the sec column):

```sh
gpg --list-secret-keys ${KEY_NAME}
```

Export the public and private key pair from your local GPG keyring and create a Kubernetes secret named `sops-gpg` in the `flux-system` namespace:

```sh
gpg --export-secret-keys ${KEY_NAME} |
kubectl create secret generic sops-gpg \
--namespace=flux-system \
--from-file=sops.asc=/dev/stdin
```

**Note**: It’s a good idea to back up this secret-key/K8s-Secret with a password manager or offline storage.

### Configure in-cluster secrets decryption

Create a kustomization for reconciling the secrets on the cluster:

```sh
flux create kustomization my-secrets \
--source=flux-system \
--path=./clusters/cluster0 \
--prune=true \
--interval=10m \
--decryption-provider=sops \
--decryption-secret=sops-gpg
```

**Note** that the `sops-gpg` can contain more than one key, SOPS will try to decrypt the secrets by iterating over all the private keys until it finds one that works.

### Optional: Export the public key into the Git directory 

Commit the public key to the repository so that team members who clone the repo can encrypt new files:

```sh
gpg --export --armor ${KEY_NAME} > ./clusters/cluster0/.sops.pub.asc
```

Check the file contents to ensure it’s the public key before adding it to the repo and committing.

```sh
git add ./clusters/cluster0/.sops.pub.asc
git commit -am 'Share GPG public key for secrets generation'
```

Team members can then import this key when they pull the Git repository:

```sh
gpg --import ./clusters/cluster0/.sops.pub.asc
```

**Note**: The public key is sufficient for creating brand new files. The secret key is required for decrypting and editing existing files because SOPS computes a MAC on all values. When using solely the public key to add or remove a field, the whole file should be deleted and recreated.

### Encrypting secrets using OpenPGP 

Generate a Kubernetes secret manifest with `kubectl`:

```sh
kubectl -n default create secret generic basic-auth \
--from-literal=user=admin \
--from-literal=password=change-me \
--dry-run=client \
-o yaml > basic-auth.yaml
```

Encrypt the secret with SOPS using your GPG key:

```sh
sops encrypt --in-place --pgp ${PUB_KEY_FP} basic-auth.yaml
```

You can now commit the encrypted secret to your Git repository.

**Note**: Note that you shouldn’t apply the encrypted secrets onto the cluster with kubectl. SOPS encrypted secrets are designed to be consumed by kustomize-controller.

## Quick examples

### Create Helm Release

```sh
❯ flux create hr open-webui \               
    --namespace=chat \
    --source=HelmRepository/open-webui.flux-system \
    --chart=open-webui \
    --values=../charts/open-webui.values.yaml \ 
    --chart-version="6.4.0" --export > ./apps/k8s-home/chat/open-webui.release.yaml
```
