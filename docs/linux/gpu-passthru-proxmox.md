# Intel iGPU passthru to Proxmox VM

Hey there! 👋 In this section, we'll be covering the `Full iGPU Passthrough` to a Proxmox Virtual Machine for an Intel integrated iGPU.

**Warning**: You will lose the ability to use the onboard graphics card to access the Proxmox console since Proxmox won't be able to use the Intel's GPU.

1. Edit the grub configuration file `/etc/default/grub` and find the line that starts with `GRUB_CMDLINE_LINUX_DEFAULT`. By default, it should look like this: `GRUB_CMD_LINUX_DEFAULT="quiet"`
   - Add `intel_iommu=on iommu=pt` to this line. 
2. Update the grub configuration for the next reboot with `update-grub`.
3. Add `vfio` modules to `/etc/modules` to allow PCI passthrough:

    ```test
    # Modules required for PCI passthrough
    vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd

    # Modules required for Intel GVT-g Split
    kvmgt
    ```

4. Update configuration changes made in your `/etc` filesystem:
    ```sh
    update-initramfs -u -k all
    ```
5. Reboot Proxmox.
6. Verify that `IOMMU` is enabled: `dmesg | grep -e DMAR -e IOMMU`
   - **Note**: There should be a line that looks like `DMAR: IOMMU enabled`. If there is no output, something is wrong.
7. Find the PCI address of the iGPU: `lspci -nnv | grep VGA`. This should result in output similar to this (If you have multiple VGA, look for the one that has the `Intel` in the name):
    ```
    00:02.0 VGA compatible controller [0300]: Intel Corporation CometLake-S GT2 [UHD Graphics 630] [8086:3e92] (prog-if 00 [VGA controller])
    ```
8. Create or edit your VM. Make sure the `Machine` type is set to `q35`.
9.  Open the web GUI and navigate to the `Hardware` tab of the VM you want to add a vGPU. Click `Add` above the device list and then choose `PCI Device`. Open the `Device` dropdown and select the iGPU, which you can find using its PCI address. This list uses a different format for the PCI addresses id, `00:02.0` is listed as `0000:00:02.0
   1. Select `All Functions`, `ROM-Bar`, `PCI-Express` and then click `Add`.
10. Connect to the VM via SSH or any other remote access protocol you prefer. Install the latest version of Intel's Graphics Driver or use the Intel Driver & Support Assistant.
11. Linux VM: Boot the VM. To test the iGPU passthrough was successful, you can use the following command:
    ```
    sudo lspci -nnv | grep VGA
    ```
    - The output should include the Intel iGPU:
    ```
    00:10.0 VGA compatible controller [0300]: Intel Corporation UHD Graphics 630 (Desktop) [8086:3e92] (prog-if 00 [VGA controller])
    ```

12. Now we need to check if the GPU's Driver initialization is working.
    ```
    cd /dev/dri && ls -la
    ```

The output should include the `renderD128`.

In conclusion, successfully passing through an Intel iGPU to a Proxmox VM involves several critical steps, from modifying the GRUB configuration to ensuring the correct modules are loaded and the VM is properly configured. By following these steps, you can harness the power of your integrated GPU within a virtual environment, enhancing the performance and capabilities of your virtual machines. This process not only allows for better resource utilization but also opens up new possibilities for running graphically intensive applications within your VMs.

## References

- [Proxmox iGPU Passthrough to VM](https://www.laub-home.de/wiki/Proxmox_iGPU_Passthrough_to_VM_(Intel_Integrated_Graphics))

