# Kubernetes install - Kubespray

Main docs:

- [https://kubespray.io/#/docs/getting-started](https://kubespray.io/#/docs/getting-started)
- [https://kubernetes.io/docs/setup/production-environment/tools/kubespray/](https://kubernetes.io/docs/setup)

### Prereqs

[https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#1-5-meet-the-underlay-requirements](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#1-5-meet-the-underlay-requirements)

### Inventory file

[https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#2-5-compose-an-inventory-file](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#2-5-compose-an-inventory-file)

Inside bastion:

```shell
git clone https://github.com/kubernetes-sigs/kubespray
cd kubespray
export CLUSTER_NAME="CLUSTER_NAME"
cp -r inventory/sample inventory/${CLUSTER_NAME}
declare -a IPS=(10.0.0.11 10.0.0.12 10.0.0.13 10.0.0.14 10.0.0.15 10.0.0.16)
CONFIG_FILE=inventory/${CLUSTER_NAME}/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

### Configure Deployment

[https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#3-5-plan-your-cluster-deployment](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#3-5-plan-your-cluster-deployment)

Edit `inventory/${CLUSTER_NAME}/group_vars/all/all.yml` to update following config variables:

```
cloud_provider: "external"
external_cloud_provider: "vsphere"
```

Edit `inventory/${CLUSTER_NAME}/group_vars/all/vsphere.yml` to update following config variables:

```
## Values for the external vSphere Cloud Provider
external_vsphere_vcenter_ip: "vcr72.example.com"
external_vsphere_vcenter_port: "443"
external_vsphere_insecure: "true"
external_vsphere_user: "<VSPHERE_USERNAME>"
external_vsphere_password: "<VSPHERE_PASSWORD>"
external_vsphere_datacenter: "TEST"
external_vsphere_kubernetes_cluster_id: "<CLUSTER_NAME>"

## Vsphere version where located VMs
external_vsphere_version: "7.0.3"

## To use vSphere CSI plugin to provision volumes set this value to true
vsphere_csi_enabled: false
vsphere_csi_controller_replicas: 1
```

### Deploy cluster

[https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#4-5-deploy-a-cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/#4-5-deploy-a-cluster)

```shell
ansible-playbook -i inventory/${CLUSTER_NAME}/hosts.yml -b -v cluster.yml
```

### Access Cluster

Once cluster has been deployed, run following from your local machine to copy kube config file:

```shell
cd $HOME/.kube
echo "get /root/.kube/config ${CLUSTER_NAME}" | sftp -s "sudo /usr/lib/openssh/sftp-server" ${MASTER_NODE_USERNAME}@${MASTER_NODE_IP}
server="https://${MASTER_NODE_IP}:6443" yq -i ".clusters[0].cluster.server = env(server)" ${CLUSTER_NAME}
export KUBECONFIG=$HOME/.kube/${CLUSTER_NAME}
kubectl get nodes
```

### Known issues

#### VSphere CSI driver

We've had an issue with VSphere CSI driver deployment within the cluster, to be looked at...

#### Install without storage option

When installing using VSphere external provider without VSphere CSI driver, worker nodes are unschedulable due to a `taint` added to worker nodes specifying that the node is not initialized nor schedulable even though the nodes seem ready, healthy and schedulable. To fix this issue run the following command for each node:

```sh
kubectl taint nodes worker-1 node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule-
```
