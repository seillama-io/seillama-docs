# Useful aliases

Useful aliases you can add to your `.bashrc` or `.zshrc` for day to day Kubernetes operations:

```sh
alias k='kubectl'
# kn $1 to switch current namespace
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
# kx $1 to switch current context
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
```
