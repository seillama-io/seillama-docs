# Useful plugins

Useful plugins you can install to speed your day to day Kubernetes operations:

## Prerequisites

- `kubectl` CLI
- Kubernetes [krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/) plugin manager:

    ```sh
    (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
    )
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    ```

## `kubectl ctx`: Context switcher


```sh
kubectl krew install ctx
kubectl ctx # List contexts
kubectl ctx ${NEW_CTX} # Switch current context to ${NEW_CTX}
```

## `kubectl ns`: Namespace switcher

```sh
kubectl krew install ns
kubectl ns # List namespaces
kubectl ns ${NEW_NS} # Switch current namespace to ${NEW_NS}
```
