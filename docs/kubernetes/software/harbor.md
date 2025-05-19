# Harbor

[Harbor](https://goharbor.io/) is an open source registry that secures artifacts with policies and role-based access control, ensures images are scanned and free from vulnerabilities, and signs images as trusted. Harbor, a [CNCF](https://www.cncf.io/) Graduated project, delivers compliance, performance, and interoperability to help you consistently and securely manage artifacts across cloud native compute platforms like Kubernetes and Docker.

## Prerequisites

- Kubernetes/OpenShift cluster accessible with `kubectl` CLI
- Install [Helm](https://helm.sh/docs/intro/install/)
- `yq` CLI [installed](https://github.com/mikefarah/yq/#install) on your workstation

## Supporting Docs

- [Deploying Harbor with High Availability via Helm](https://goharbor.io/docs/2.7.0/install-config/harbor-ha-helm/)

## Install Harbor

1. Get the Harbor Helm repository:
    ```sh
    helm repo add harbor https://helm.goharbor.io
    helm repo update harbor
    ```
2. Create `harbor` namespace:
    ```sh
    kubectl create ns harbor
    ```
3. *OpenShift Only*: If installing in OpenShift, add the `privileged` security context constraint to `default` service account in the `harbor` namespace:
    ```sh
    oc adm policy add-scc-to-user privileged -z default -n harbor
    ```
4. Install the chart, **provide a valid** `HARBOR_DOMAIN`:
    ```sh
    export HARBOR_DOMAIN=harbor.example.com
    helm install harbor harbor/harbor -n harbor --create-namespace --set externalURL=https://core.${HARBOR_DOMAIN} --set expose.ingress.hosts.core=core.${HARBOR_DOMAIN} --set expose.ingress.hosts.notary=notary.${HARBOR_DOMAIN}
    ```

After a successful deployment and if your ingress strategy is properly configured you should be able to access your Harbor instance at `https://core.harbor.example.com`. To login you will find the `admin` password by running the following command:

```sh
export HARBOR_ADMIN_PASSWORD=$(kubectl get secret -n harbor harbor-core -o yaml | yq .data.HARBOR_ADMIN_PASSWORD | base64 -d)
```

## *Optional*: Start using Harbor

### Login to created registry

E.g. with `skopeo`, use `admin` as user and `${HARBOR_ADMIN_PASSWORD}`:

```sh
skopeo login --tls-verify=false core.${HARBOR_DOMAIN}
```

To test and push a sample image, you can run:

```sh
skopeo copy --tls-verify=false docker://docker.io/busybox:latest docker://core.${HARBOR_DOMAIN}/library/busybox:latest --override-arch amd64 --override-os linux
```

### Create pull secret in K8s/OpenShift

E.g. with docker config file accessible at `~/.config/containers/auth.json`:

```sh
kubectl create secret generic registry-config -n ci-tools \
    --from-file=.dockerconfigjson=$HOME/.config/containers/auth.json \
    --type=kubernetes.io/dockerconfigjson
```
