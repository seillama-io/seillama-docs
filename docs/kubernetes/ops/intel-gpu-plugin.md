# Intel GPU plugin on Kubernetes

This guide will help you get started with leveraging Intel GPUs in your Kubernetes cluster. Whether you're a seasoned Kubernetes user or just getting started, you'll find everything you need to to harness the power of Intel GPUs for your workloads. Let's dive in! 🌟

## Content

- [Intel GPU plugin on Kubernetes](#intel-gpu-plugin-on-kubernetes)
  - [Content](#content)
  - [Installation with NFD](#installation-with-nfd)
  - [Conclusion](#conclusion)
  - [References](#references)

## Installation with NFD

**Note**: Replace `<RELEASE_VERSION>` with the desired [release tag](https://github.com/intel/intel-device-plugins-for-kubernetes/tags) or `main` to get `devel` images.

**Note**: Add `--dry-run=client -o yaml` to the `kubectl` commands below to visualize the yaml content being applied.

Deploy GPU plugin with the help of NFD ([Node Feature Discovery](https://github.com/kubernetes-sigs/node-feature-discovery)). It detects the presence of Intel GPUs and labels them accordingly. GPU plugin’s node selector is used to deploy plugin to nodes which have such a GPU label.

```sh
# Start NFD - if your cluster doesn't have NFD installed yet
$ kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd?ref=<RELEASE_VERSION>'

# Create NodeFeatureRules for detecting GPUs on nodes
$ kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/nfd/overlays/node-feature-rules?ref=<RELEASE_VERSION>'

# Create GPU plugin daemonset
$ kubectl apply -k 'https://github.com/intel/intel-device-plugins-for-kubernetes/deployments/gpu_plugin/overlays/nfd_labeled_nodes?ref=<RELEASE_VERSION>'
```

## Conclusion

Congratulations! You've successfully set up the Intel GPU plugin on your Kubernetes cluster. With this setup, you can now leverage the power of Intel GPUs to accelerate your workloads. Enjoy the enhanced performance and capabilities that Intel GPUs bring to your Kubernetes environment! 🚀✨

## References

- [Intel GPU plugin installation](https://intel.github.io/intel-device-plugins-for-kubernetes/cmd/gpu_plugin/README.html#installation)
