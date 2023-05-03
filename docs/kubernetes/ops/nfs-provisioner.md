# NFS Provisioner

!!! info "Note"
    Tested with K3S

## Setup NFS Server

#### Create a NFS data mount (optional but recommended)

!!! info "Note"
    Setup based on Ubuntu 20.04 using LVM

- Add a disk to the VM
- Create a LVM partition on the new disk (GPT)

```shell
sudo cfdisk /dev/sdb
```

- Create PV/VG/LV and format the LV

```shell
# Create the Physical Volume with the newly created partition
sudo pvcreate /dev/sdb1
sudo pvdisplay

# Create a Volume Group with the newly PV
sudo vgcreate data-vg /dev/sdb1
sudo vgdisplay

# # Create a Logcal Volumein the new VG
sudo lvdisplay
sudo lvcreate -l 100%FREE -n data-lv data-vg

#Format the new LV
sudo mkfs.ext4 /dev/data-vg/data-lv

```

- Mount the new device

```shell
# Create a folder to mount the device
sudo mkdir  /export
sudo chown nobody:nogroup /export
sudo chmod 775 /export

#Get the LV Path
sudo lvdisplay
#  --- Logical volume ---
#  LV Path                /dev/data-vg/data-lv
#  ...

# Get the device UUID
sudo blkid /dev/data-vg/data-lv
#/dev/data-vg/data-lv: UUID="0dd3c7f9-d42c-4fb3-9bbb-cbe35d6e4f80" TYPE="ext4"

# Add device to fstab for automount
sudo vim /etc/fstab
# UUID=0dd3c7f9-d42c-4fb3-9bbb-cbe35d6e4f80 /export ext4 defaults 0 1

# Mount everything (allow to check if it will mount or not, and be sure the server will reboot :) )
sudo mount -a

#check if it's correctly mounted 
mount

```

#### Install NFS Server

```shell
# Install NFS server package
sudo apt install nfs-kernel-server

# Add an export
sudo vim /etc/exports
# /export *(rw,sync,no_subtree_check)
sudo exportfs -ra
```

#### Optional: Configure firewall

```shell
# Get NFS Server port
rpcinfo -p | grep nfs

# Open port in firewall
sudo ufw allow 2049
sudo ufw status
```

## Install NFS client on each Kubernetes node

!!! info "Note"
    Setup based on Ubuntu 20.04 nodes

```shell
sudo apt install nfs-common -y
```

## Deploy the NFS Provisioner

[https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner)

#### Setup based on K3S

- Create a `helmchart-nfs.yaml` file:

```shell
vim helmchart-nfs.yaml
```

```yaml
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: nfs
  namespace: nfs-provisioner
spec:
  chart: nfs-subdir-external-provisioner
  repo: https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
  targetNamespace: nfs-provisioner
  set:
    nfs.server: 10.3.13.1
    nfs.path: /export
    storageClass.name: nfs
```

- Create a new `nfs-provisioner` namespace and apply the yaml file:

```shell
kubectl create ns nfs-provisioner
kubectl -f helmchart-nfs.yaml -n helmchart-nfs.yaml
kubectl get pod -n helmchart-nfs.yaml
```

#### Setup based on Helm CLI

Prerequisites:

- Install Helm CLI: [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)

```sh
$ kubectl create ns nfs-provisioner
$ helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
$ helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=10.3.13.1 \
    --set nfs.path=/export \
    --set storageClass.name=nfs \
    -n nfs-provisioner
```

### Set default Storage Class

```sh
kubectl patch sc nfs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Test NFS Provisioning

#### Create a Persistent Volume Claim

```shell
kubectl create ns test-prov
cat <<EOF | kubectl apply -n test-prov -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim
spec:
  storageClassName: nfs
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
EOF
```

#### Create Pod

```shell
cat <<EOF | kubectl apply -n test-prov -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-pvc
spec:
  selector:
    matchLabels:
      app: test-pvc
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: test-pvc
    spec:
      containers:
      - name: test-pvc-container
        image: alpine:3.13
        command: [ "/bin/sh", "-c", "--" ]
        args: [ "while true; do echo $(hostname) $(date) >> /data/test;sleep 1; done;" ]
        volumeMounts:
          - name: vol1
            mountPath: "/data"
      volumes:
        - name: vol1
          persistentVolumeClaim:
            claimName: test-claim
EOF
```
