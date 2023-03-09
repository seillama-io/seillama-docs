# Self-hosting platform on Raspberry Pi - K3s

This doc helps deploy a Kubernetes self-hosting platform on Raspberry Pi devices with [K3s](https://k3s.io/).

It uses a Terraform modules I have created to deploy the necessary  software in the cluster.

## Roadmap

- [x] Configure Kubernetes cluster
- [x] Self-host password manager: Bitwarden
- [x] Self-host IoT dev platform: Node-RED
- [x] Self-host home cloud: NextCloud
- [x] Self-host home Media Center
  - [x] Transmission
  - [x] Flaresolverr
  - [x] Jackett
  - [x] Sonarr
  - [x] Radarr
  - [ ] Plex
- [ ] Self-host ads/trackers protection: Pi-Hole

## Prerequisites

- Accessible K8s/K3s cluster on your Pi.
  - With `cert-manager` CustomResourceDefinition installed: `kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.16.0/cert-manager.crds.yaml`
- For transmission bittorrent client, an OpenVPN config file stored in `openvpn.ignore.ovpn`, with `auth-user-pass` set to `/config/openvpn-credentials.txt` (auto auth), including cert and key.

## Usage

Clone the repository:
```sh
$ git clone https://github.com/NoeSamaille/terraform-self-hosting-platform-rpi
$ cd terraform-self-hosting-platform-rpi
```

Configure your environment:
```sh
$ mv terraform.tfvars.template terraform.tfvars
$ vim terraform.tfvars
```

Once it's done you can start deploying resources:
```sh
$ source scripts/init.sh # Generates service passwords
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
... output ommited ...
Apply complete! Resources: 32 added, 0 changed, 0 destroyed.
```

To destroy all the resources:
```sh
$ terraform destroy --auto-approve
... output ommited ...
Apply complete! Resources: 0 added, 0 changed, 32 destroyed.
```

## How to set up nodes

### Base pi set up

**Note**: here we'll set up `pi-master` i.e. our master pi, if you have additional workers (optional) you'll then have to repeat the following steps for each of the workers, replacing references to `pi-master` by `pi-worker-1`, `pi-worker-2`, etc.

1. Connect via SSH to the pi:
    ```sh
    user@workstation $ ssh pi@<PI_IP>
    ... output ommited ...
    pi@raspberrypi:~ $
    ```
2. Change password:
    ```sh
    pi@raspberrypi:~ $ passwd
    ... output ommited ...
    passwd: password updated successfully
    ```
3. Change host names:
    ```sh
    pi@raspberrypi:~ $ sudo -i
    root@raspberrypi:~ $ echo "pi-master" > /etc/hostname
    root@raspberrypi:~ $ sed -i "s/$HOSTNAME/pi-master/" /etc/hosts
    ```
4. Enable container features:
    ```sh
    root@raspberrypi:~ $ sed -i 's/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/' /boot/cmdline.txt
    ```
5. Make sure the system is up-to-date:
    ```sh
    root@raspberrypi:~ $ apt update && apt upgrade -y
    ```
6. Configure a static IP, **Note** that This could be also done at the network level via the router admin (DHCP):
    ```sh
    root@raspberrypi:~ $ cat <<EOF >> /etc/dhcpcd.conf
    interface eth0
    static ip_address=<YOUR_STATIC_IP_HERE>/24
    static routers=192.168.1.1
    static domain_name_servers=1.1.1.1
    EOF
    ```
7. Reboot:
    ```sh
    root@raspberrypi:~ $ reboot
    ```
8. Wait for a few sec, then connect via SSH to the pi using the new static IP you've just configured:
    ```sh
    user@workstation $ ssh pi@<PI_IP>
    ... output ommited ...
    pi@pi-master:~ $ 
    ```

### OPTIONAL: Set up NFS disk share

#### Create NFS Share on Master Pi

1. On master pi, run the command `fdisk -l` to list all the connected disks to the system (includes the RAM) and try to identify the disk.
    ```sh
    pi@pi-master:~ $ sudo fdisk -l
    ```
2. If your disk is new and freshly out of the package, you will need to create a partition.
    ```sh
    pi@pi-master:~ $ sudo mkfs.ext4 /dev/sda 
    ```
3. You can manually mount the disk to the directory `/mnt/hdd`.
    ```sh
    pi@pi-master:~ $ sudo mkdir /mnt/hdd
    pi@pi-master:~ $ sudo chown -R pi:pi /mnt/hdd/
    pi@pi-master:~ $ sudo mount /dev/sda /mnt/hdd
    ```
4. To automatically mount the disk on startup, you first need to find the Unique ID of the disk using the command `blkid`:
    ```sh
    pi@pi-master:~ $ sudo blkid

    ... output ommited ...
    /dev/sda: UUID="0ac98c2c-8c32-476b-9009-ffca123a2654" TYPE="ext4"
    ```
5. Edit the file `/etc/fstab` and add the following line to configure auto-mount of the disk on startup:
    ```sh
    pi@pi-master:~ $ sudo -i
    root@pi-master:~ $ echo "UUID=0ac98c2c-8c32-476b-9009-ffca123a2654 /mnt/hdd ext4 defaults 0 0" >> /etc/fstab
    root@pi-master:~ $ exit
    ```
6. Reboot the system
    ```sh
    pi@pi-master:~ $ sudo reboot
    ```
7. Verify the disk is correctly mounted on startup with the following command:
    ```sh
    pi@pi-master:~ $ df -ha /dev/sda

    Filesystem      Size  Used Avail Use% Mounted on
    /dev/sda        458G   73M  435G   1% /mnt/hdd
    ```
8. Install the required dependencies:
    ```sh
    pi@pi-master:~ $ sudo apt install nfs-kernel-server -y
    ```
9. Edit the file `/etc/exports` by running the following command:
    ```sh
    pi@pi-master:~ $ sudo -i
    root@pi-master:~ $ echo "/mnt/hdd-2 *(rw,no_root_squash,insecure,async,no_subtree_check,anonuid=1000,anongid=1000)" >> /etc/exports
    root@pi-master:~ $ exit
    ```
10. Start the NFS Server:
    ```sh
    pi@pi-master:~ $ sudo exportfs -ra
    ```

#### Mount NFS share on Worker(s)

**Note**: repeat the following steps for each of the workers `pi-worker-1`, `pi-worker-2`, etc.

1. Install the necessary dependencies:
    ```sh
    pi@pi-worker-x:~ $ sudo apt install nfs-common -y
    ```
2. Create the directory to mount the NFS Share:
    ```sh
    pi@pi-worker-x:~ $ sudo mkdir /mnt/hdd
    pi@pi-worker-x:~ $ sudo chown -R pi:pi /mnt/hdd
    ```
3. Configure auto-mount of the NFS Share by adding the following line, where `<MASTER_IP>:/mnt/hdd` is the IP of `pi-master` followed by the NFS share path:
    ```sh
    pi@pi-worker-x:~ $ sudo -i
    root@pi-worker-x:~ $ echo "<MASTER_IP>:/mnt/hdd   /mnt/hdd   nfs    rw  0  0" >> /etc/fstab
    root@pi-worker-x:~ $ exit
    ```
4. Reboot the system
    ```sh
    pi@pi-worker-x:~ $ sudo reboot
    ```
5. **Optional**: to mount manually you can run the following command, where `<MASTER_IP>:/mnt/hdd` is the IP of `pi-master` followed by the NFS share path:
    ```sh
    pi@pi-worker-x:~ $ sudo mount -t nfs <MASTER_IP>:/mnt/hdd /mnt/hdd
    ```

### Setup K3s

#### Start K3s on Master pi

```sh
pi@pi-master:~ $ curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC=" --no-deploy servicelb --no-deploy traefik" sh -
```

#### Register workers

1. Get K3s token on master pi, copy the result:
    ```sh
    pi@pi-master:~ $ sudo cat /var/lib/rancher/k3s/server/node-token
    K103166a17...eebca269271
    ```
2. Run K3s installer on worker (repeat on each worker):
    ```sh
    pi@pi-worker-x:~ $ curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" K3S_URL="https://<MASTER_IP>:6443" K3S_TOKEN="K103166a17...eebca269271" sh -
    ```

#### Access K3s cluster from workstation

1. Copy kube config file from master pi:
    ```sh
    user@workstation:~ $ scp pi@<MASTER_IP>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
    ```
2. Edit kube config file to replace `127.0.0.1` with `<MASTER_IP>`:
    ```sh
    user@workstation:~ $ vim ~/.kube/config
    ```
3. Test everything by running a `kubectl` command:
    ```sh
    user@workstation:~ $ kubectl get nodes -o wide
    ```

### Tear down K3s

1. Worker(s)

```sh
user@workstation:~ $ sudo /usr/local/bin/k3s-agent-uninstall.sh
```

2. Master

```sh
pi@pi-master:~ $ sudo /usr/local/bin/k3s-uninstall.sh
```

## Known issues

### Node-RED authentication

Node-RED authentication isn't set up by default atm, you can set it up by scaling the deployment down, editing the `settings.js` file to enable authentication and scaling the deployment back up:

```
pi@pi-master:~ $ kubectl scale deployment/node-red --replicas=0 -n node-red
pi@pi-master:~ $ vim /path/to/node-red/settings.js
pi@pi-master:~ $ kubectl scale deployment/node-red --replicas=1 -n node-red
```

You can either set up authentication through GitHub ([Documentation](https://github.com/node-red/node-red-auth-github)):

```js
# settings.js
... Ommited ...
    adminAuth: require('node-red-auth-github')({
        clientID: "<GITHUB_CLIENT_ID>",
        clientSecret: "<GITHUB_CLIENT_SECRET>",
        baseURL: "https://node-red.<DOMAIN>/",
        users: [
            { username: "<GITHUB_USERNAME>", permissions: ["*"]}
        ]
    }),
... Ommited ...
```

Or classic user-pass authentication (generate a password hash using `node -e "console.log(require('bcryptjs').hashSync(process.argv[1], 8));" <your-password-here>`):

```js
# settings.js
... Ommited ...
    adminAuth: {
        type: "credentials",
        users: [
            {
                username: "admin",
                password: "$2a$08$zZWtXTja0fB1pzD4sHCMyOCMYz2Z6dNbM6tl8sJogENOMcxWV9DN.",
                permissions: "*"
            },
            {
                username: "guest",
                password: "$2b$08$wuAqPiKJlVN27eF5qJp.RuQYuy6ZYONW7a/UWYxDTtwKFCdB8F19y",
                permissions: "read"
            }
        ]
    },
... Ommited ...
```

More information in the [Docs: Securing Node-RED](https://nodered.org/docs/user-guide/runtime/securing-node-red).
