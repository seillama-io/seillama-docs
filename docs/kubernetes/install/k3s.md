# Kubernetes install - K3s

Main docs:

- [https://k3s.io/](https://k3s.io/)
- [https://docs.k3s.io/quick-start](https://docs.k3s.io/quick-start)

### Master Node

Run the K3s install script from master node:

```sh
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -
```

Once the install is done, fetch node token to add nodes to the cluster and copy it for next step:

```sh
sudo cat /var/lib/rancher/k3s/server/node-token
K100f4662d45c9160374695...dbcc53a11::server:b108c...bcb17c
```

### Worker Node(s)

Run the K3s install script from each worker node:

```sh
curl -sfL https://get.k3s.io | K3S_URL=https://${K3S_MASTER_NODE_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} sh -
```

### Access Cluster

Once cluster has been deployed, run following from your local workstation to copy kube config file from master node:

```shell
cd $HOME/.kube
echo "get /etc/rancher/k3s/k3s.yaml ${CLUSTER_NAME}" | sftp -s "sudo /usr/lib/openssh/sftp-server" ${MASTER_NODE_USERNAME}@${MASTER_NODE_IP}
server="https://${MASTER_NODE_IP}:6443" yq -i ".clusters[0].cluster.server = env(server)" ${CLUSTER_NAME}
export KUBECONFIG=$HOME/.kube/${CLUSTER_NAME}
kubectl get nodes
```
