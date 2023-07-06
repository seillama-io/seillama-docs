# Install Nvidia CUDA on RHEL

Tested on RHEL8.

Master doc: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html

Verify You Have a CUDA-Capable GPU:

```sh
lspci | grep -i nvidia
```

Verify You Have a Supported Version of Linux:

```sh
uname -m && cat /etc/*release
```

Verify the System Has gcc Installed:

```sh
gcc --version
```

Verify the System has the Correct Kernel Headers and Development Packages Installed:

```sh
sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r)
```

Network Repo Installation for RHEL 8:

```sh
export distro=rhel8
export arch=x86_64
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch/cuda-$distro.repo
sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch/cuda-$distro.repo
sudo dnf clean expire-cache
```

Install CUDA SDK:

```sh
sudo dnf module install nvidia-driver:latest-dkms
sudo dnf install cuda
```

Try it: 

```sh
nvidia-smi
```
