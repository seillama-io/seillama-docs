# Create LVM volume

This section explains the steps to create an LVM (Logical Volume Management) volume and mount it in Linux. LVM allows you to manage disk storage more flexibly and efficiently by abstracting physical disks into logical volumes.

## Check available disks

First, let's check the available disks on your system. Open a terminal and run:

```sh
sudo fdisk -l
```

Identify the disk you want to use for creating the LVM volume. For example, it might be something like `/dev/sdb`.

## Create a Physical Volume (PV)

Next, we need to initialize the chosen disk as a Physical Volume for LVM, e.g.:

```sh
sudo pvcreate /dev/sdb
```

## Create a Volume Group (VG)

Now, create a Volume Group that will hold the Physical Volume(s), e.g.:

```sh
sudo vgcreate data-vg /dev/sdb
```

Here, `data-vg` is the name of the Volume Group, and you can choose a different name if you prefer.

## Create a Logical Volume (LV)

Create a Logical Volume within the Volume Group. This is the volume you will be able to mount and use as a regular disk.

```sh
sudo lvcreate -l 100%FREE -n data-lv data-vg
```

Here, `100%FREE` represents the size of the Logical Volume, it means that the volume will take all remaining space. `data-lv` is the name of the Logical Volume. Feel free to adjust the size and name according to your needs.

## Format the Logical Volume

Format the Logical Volume with a file system (e.g., ext4) to make it usable, e.g:

```sh
sudo mkfs.ext4 /dev/data-vg/data-lv
```

## Mount the Logical Volume

Create a directory where you want to mount the Logical Volume, and then mount it, e.g:

```sh
sudo mkdir /mnt/data-lv-mountpoint
sudo mount /dev/data-vg/data-lv /mnt/data-lv-mountpoint
```

## Automatically Mount at Boot (Optional)

If you want the Logical Volume to be automatically mounted when the system starts, you can add an entry to the `/etc/fstab` file.

Open `/etc/fstab` in a text editor:

```sh
sudo nano /etc/fstab
```

Add the following line at the end of the file:

```sh
/dev/data-vg/data-lv  /mnt/data-lv-mountpoint  ext4  defaults  0  0
```

**Note**: replace `data-vg` and `data-lv` with your Volume Group and Logical Volume names, and make sure the mount point directory exists.

Your LVM volume is now created, formatted, mounted, and ready to use. You can access it from the specified mount point (`/mnt/data-lv-mountpoint` in this example).
