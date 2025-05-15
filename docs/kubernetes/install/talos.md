# Kubernetes cluster under Talos Linux OS

This doc is about the installation of a simple kubernetes cluster with a single node running on Talos Linux OS from a Proxmox instance.

Main docs:
- [https://www.talos.dev](https://www.talos.dev)
- [https://www.talos.dev/v1.9/introduction/getting-started/](https://www.talos.dev/v1.9/introduction/getting-started/)

Requirements:
- Proxmox server instance
- Homebrew

## Talos Linux OS installation on a Proxmox VM

1. Download latest Talos Linux ISO image from [github releases](https://github.com/siderolabs/talos/releases). 
2. Upload the image into your Proxmox instance using the web interface (`Datacenter > pve > local (pve) > ISO images > Upload`)
3. Create a VM booting with the image (`Create VM > OS > ISO image`)
4. Boot the machine

## Static IP adress setup for your VM

1. From your Proxmox instance using the web interface: retrieve the MAC adress of your new VM running on Talos OS (`Datacenter > pve > YOUR_VM_INSTANCE > Hardware > Network device (net0)`)
2. From you router, assign a static IP to your VM using its MAC adress (e.g from Freebox OS: `Freebox settings > DHCP > Static leases > Add a DHCP static lease`)

## Cluster setup

During this step, we will setup our Talos cluster to run a fully functionnal Kubernetes cluster.

### Talosctl installation

If you don't have `talosctl` running on your local workstation, please install it using:

```sh
brew install siderolabs/tap/talosctl
```

### Talos configuration

Set environment variables:
* `CLUSTER_NAME` is an arbitrary name, used as a label in your local client configuration. It should be unique in the configuration on your local workstation.
* `CONTROL_PLANE_IP` is the static IP adress you assigned to your VM above, which will serve as the control plane of your Talos cluster.

```sh
export CLUSTER_NAME=home-lab
export CONTROL_PLANE_IP=192.168.1.2
```

Generate talos cluster machines configurations using:

```sh
talosctl gen config $CLUSTER_NAME https://${CONTROL_PLANE_IP}:6443
```

You should then have the following output, as Three files are created in your current directory:
* controlplane.yaml: Configuration file to apply to your Talos cluster control plane node
* worker.yaml: Configuration file to apply to each of your Talos cluster worker nodes (we won't use it in this documentation)
* talosconfig: Configuration of your talos cluster

```
generating PKI and tokens
created /Users/user/controlplane.yaml
created /Users/user/worker.yaml
created /Users/user/talosconfig
```

Optionnal: You can update your local workstation Talos clusters configuration (`.talos/config`) with `./talosconfig` content so it handle newly created Talos cluster.

```yaml
context: <your-cluster-name>
contexts:
    home-lab:
        endpoints: [<your-control-plane-node-ip>]
        ca: <your-ca>
        crt: <your-crt>
        key: <your-key>

```

Edit `./controlplane.yaml` in order to set the following directive in order to make sure that your kubernetes master node will be able to run workload:

```yaml
    allowSchedulingOnControlPlanes: true
```

Apply the configuration of your talos control plane node using:

```sh
talosctl apply-config --insecure -n $CONTROL_PLANE_IP --file ./controlplane.yaml \
  --talosconfig=./talosconfig
```

### Kubernetes bootstrap

Bootstrap Kubernetes with your Talos cluster using:

```sh
talosctl bootstrap --nodes $CONTROL_PLANE_IP --endpoints $CONTROL_PLANE_IP \
  --talosconfig=./talosconfig
```

After a few moment you should be able to retrieve your kubernetes cluster configuration which will be automatically added (merged) into your local Kubernetes configuration (`.kube/config`):

```sh
talosctl kubeconfig --nodes $CONTROL_PLANE_IP --endpoints $CONTROL_PLANE_IP \
  --talosconfig=./talosconfig
```

Your kubernetes cluster should now be running. To verify the installation:

1. If you do not have kubectl installed, please run:

```sh
brew install kubectl
```

2. Verify that your current kube context is the one from the newly created cluster (`admin@${CLUSTER_NAME}`) by running:

```sh
kubectl config current-context
```

3. Run the following command:

```sh
kubectl get pods --all-namespaces
```

If such result appear, then congratulations your kubernetes cluster under Talos OS is properly running:

```sh
NAMESPACE     NAME                                       READY   STATUS    RESTARTS         AGE
kube-system   coredns-xxxxxxxxxx-xxxxx                   1/1     Running   0                1s
kube-system   coredns-xxxxxxxxxx-xxxxx                   1/1     Running   0                1s
kube-system   kube-apiserver-talos-xxx-xxx               1/1     Running   0                1s
kube-system   kube-controller-manager-talos-xxx-xxx      1/1     Running   0                1s
kube-system   kube-flannel-xxxxx                         1/1     Running   0                1s
kube-system   kube-proxy-xxxxx                           1/1     Running   0                1s
kube-system   kube-scheduler-talos-xxx-xxx               1/1     Running   0                1s
```

## *Optionnal*: Kubernetes cluster initial setup

In this section we'll setup our kubernetes cluster to be fully prepared to run applications (metrics, ingress etc.).

### Metrics server

In order to monitor metrics from our cluster, we need to deploy a metrics server.

Doc:
* [https://kubernetes-sigs.github.io/metrics-server/](https://kubernetes-sigs.github.io/metrics-server/)

1. If you do not have kubectl installed, please run:

```sh
brew install helm
```

2. Add metrics-server helm repository by using the following command:

```sh
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
``` 

3. Run the following command in order to deploy metrics-server with the following values (we're only adding insecure tls in order to skip unnecessary tls verification when performing internal metrics API calls within the cluster):

```yml
helm install metrics-server metrics-server/metrics-server --namespace kube-system -f - <<EOF
defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --kubelet-insecure-tls
EOF
```

4. After a few moments run the following command to verify the installation:

```sh
kubectl get pods -n kube-system | grep ^metrics-server
```

If such result appear, then congratulations your metrics-server is properly running:

```sh
kube-system   metrics-server-xxxxxxxxxx-xxxxx            1/1     Running   0                1s
```

### MetalLB as cluster external load balancer

To handle traffic coming from outside our cluster we will deploy metallb as the default/main external Load Balancer.

Doc:
- [https://metallb.io/](https://metallb.io/)
- [https://metallb.io/installation/](https://metallb.io/installation/)
- [https://metallb.io/configuration/](https://metallb.io/configuration/)

1. Add the metallb Helm repository to your Helm configuration:

```sh
helm repo add metallb https://metallb.github.io/metallb
helm repo update
```

2. Deploy metallb Helm chart:

```sh
helm install metallb metallb/metallb --namespace kube-system -f - <<EOF
labels:
  pod-security.kubernetes.io/audit: privileged
  pod-security.kubernetes.io/enforce: privileged
  pod-security.kubernetes.io/warn: privileged
EOF
```

3. Deploy complementary resources (IPAddressPool & L2Advertisement):

```sh
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: public-pool
  namespace: kube-system
spec:
  addresses:
  - <your-control-plane-node-ip>-<your-control-plane-node-ip>
EOF
```

```sh
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: public-pool-l2-advertisement
  namespace: kube-system
spec:
  ipAddressPools:
  - public-pool
EOF
```

4. After a few moments run the following command to verify the installation:

```sh
kubectl get pods -n kube-system | grep ^metallb
```

If such result appear, then congratulations your metallb external Load Balancer is properly running:

```sh
metallb-controller-xxxxxxxxxx-xxxxx                1/1     Running   0                1s
metallb-speaker-xxxxx                              1/1     Running   0                1s
```

### Traefik ingress controller

To handle the routing within your cluster, we will deploy traefik as the default/main ingress controller.

Doc:
- [https://v2.doc.traefik.io/traefik/](https://v2.doc.traefik.io/traefik/)
- [https://v2.doc.traefik.io/traefik/getting-started/install-traefik/](https://v2.doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart/)

1. Add the Traefik Helm repository to your Helm configuration:

```sh
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
```

2. Deploy Traefik Helm chart:

```sh
helm install traefik traefik/traefik --namespace kube-system -f - <<EOF
providers:
  kubernetesIngress:
    publishedService:
      enabled: false
  kubernetesGateway:
    enabled: true
gateway:
  listeners:
    web:
      namespacePolicy: All
EOF
```

3. After a few moments run the following command to verify the installation:

```sh
kubectl get pods -n kube-system | grep ^traefik
```

If such result appear, then congratulations your traefik ingress controller is properly running:

```sh
traefik-xxxxxxxxxx-xxxxx                1/1     Running   0                1s
```
