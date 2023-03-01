# K8s useful aliases

Useful aliases you can add to your `.bashrc` or `.zshrc` for day to day Kubernetes operations:

```sh
alias k='kubectl'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
```
