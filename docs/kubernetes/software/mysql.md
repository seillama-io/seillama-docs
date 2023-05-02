# MySQL

[MySQL](https://www.mysql.com/) is an open-source relational database management system (RDBMS) available under the terms of the GNU General Public License.

To deploy MysQL in Kubernetes (or Red Hat OpenShift), we are going to use a Helm chart provided by Bitnami. [Bitnami](https://bitnami.com/) makes it easy to get open source software up and running on any platform, including laptop, Kubernetes and major cloud providers.

## Prerequisites

- Kubernetes cluster accessible with `kubectl` CLI
- Install [Helm](https://helm.sh/docs/intro/install/)

## Supporting Docs

- [MySQL Helm Chart](https://bitnami.com/stack/mysql/helm)

## Install MySQL

Get the `bitnami` Helm repository:

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami
```

Install the chart (provide a valid `${NAMESPACE}`):

```sh
helm install mysql bitnami/mysql -n ${NAMESPACE}
```

**Optional**: if running on OpenShift, grant `privileged` SCC to the `mysql` service account in `${NAMESPACE}` namespace:

```sh
oc adm policy add-scc-to-user privileged -z mysql -n ${NAMESPACE}
```
