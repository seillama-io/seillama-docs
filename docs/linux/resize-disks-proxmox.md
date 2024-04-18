# Resize Proxmox Linux VM disk 

## Supporting Docs

- [Resize disks](https://pve.proxmox.com/wiki/Resize_disks)

## Resizing guest disk

On pve shell:

```sh
qm list # Find VM id
qm resize <vmid> <disk> <size> # e.g. qm disk resize 201 scsi1 +4T
```

## Enlarge the partition(s) in the virtual disk

On linux VM shell:

```sh
sudo fdisk -l
sudo parted /dev/sdb
```

Resize the partition 1 (LVM PV) to occupy the whole remaining space of the hard drive):

```sh
(parted) print
Warning: Not all of the space available to /dev/sdb appears to be used, you can
fix the GPT to use all of the space (an extra 268435456 blocks) or continue
with the current setting? 
Fix/Ignore? F
(parted) resizepart 1 100%
(parted) print
(parted) quit
```

## Enlarge the filesystem(s) in the partitions on the virtual disk

On linux VM shell:

```sh
sudo pvresize /dev/sdb1
sudo lvdisplay
sudo lvresize --extents +100%FREE --resizefs /dev/hdd-vg/hdd-lv
```
