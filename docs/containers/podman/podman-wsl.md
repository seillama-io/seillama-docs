# Install Podman on Windows Subsystem for Linux

[Podman](https://podman.io/) is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Containers can either be run as root or in rootless mode.

Podman is supported on Windows but by default sets up during install it's own WSL2 instance, which is great if you are fine using Windows powershell to run `podman` commands, but in my case I heavily rely on my custom Ubuntu WSL instance to work on Windows, so I want to be able to run `podman` there.

This document shows how to install Podman in Ubuntu WSL2 (tested with Podman `v3.4.4` on Ubuntu `22.04`).

Install required dependencies:

```sh
sudo apt update -y
sudo apt install -y podman qemu-system
```

Initialize Podman machine:

```sh
podman machine init
```

Download required `gvproxy` binary from [GitHub releases](https://github.com/containers/gvisor-tap-vsock/releases) `e.g.`:

```sh
sudo wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.6.1/gvproxy-linux -O /usr/libexec/podman/gvproxy
sudo chmod +x /usr/libexec/podman/gvproxy
```

Grant `rw` access to `kvm`, required to start Podman machine:

```sh
sudo chmod 666 /dev/kvm
```

Start Podman machine:

```sh
podman machine start
```
