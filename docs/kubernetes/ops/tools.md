# Useful Tools

Useful tools (aliases, plugins, commands) that I found useful on a daily basis of managing K8s clusters:

## Aliases

Useful aliases you can add to your `.bashrc` or `.zshrc` for day to day Kubernetes operations:

```sh
alias k='kubectl'
# kn $1 to switch current namespace
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
# kx $1 to switch current context
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
```

## Plugins

Useful plugins you can install to speed your day to day Kubernetes operations:

### Prerequisites

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

### `kubectl ctx`: Context switcher


```sh
kubectl krew install ctx
kubectl ctx # List contexts
kubectl ctx ${NEW_CTX} # Switch current context to ${NEW_CTX}
```

### `kubectl ns`: Namespace switcher

```sh
kubectl krew install ns
kubectl ns # List namespaces
kubectl ns ${NEW_NS} # Switch current namespace to ${NEW_NS}
```

## Commands

- Delete a namespace that is stuck `terminating`:
    ```sh
    export NAMESPACE=<CHANGEME>
    kubectl proxy &
    kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >/tmp/patch.json
    curl -k -H "Content-Type: application/json" -X PUT --data-binary @/tmp/patch.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize
    ```
- Delete stuck objects:
    ```sh
    kubectl patch ${TYPE} ${NAME} -p '{"metadata":{"finalizers": []}}' --type=merge
    ```
