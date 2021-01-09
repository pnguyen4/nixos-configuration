# NixOS BTRFS Raid1 on LUKS with mirrored ESP for UEFI boot

Each Disk will have an EFI System Partition and an encrypted LUKS partition. No swap on hard disks.
This setup should only be used on systems with modern CPUs because of the cost of double-encryption.

## Part 1: Identify Disks and Set Variables

Find your hard disks (i.e. /dev/sda and /dev/sdb). It is assumed that they
are of the same size and geometry for the purpose of this guide.

    # lsblk

Find persistent identification strings for your devices (i.e. wwn-0x500...)

    # ls -l /dev/disk/by-id

Set Variables for later use

    # DISK1=/dev/disk/by-id/{_id string of your 1st disk here_}
    # DISK2=/dev/disk/by-id/{_id string of your 2nd disk here_}

## Part 2: Partition Disks

Reset partition table

    # parted $DISK1 -- mklabel gpt

Create ESP partition

    # sgdisk -n1:1M:+512M -t1:EF00 $DISK1

Create LUKS partition with rest of space

    # sgdisk -n2:0:0 -t2:8309 $DISK1

Clone partition table to other disk

    # sfdisk --dump $DISK1 | sfdisk $DISK2

## Part 3: Enable Encryption With Passphrases

I use the same passphrase for both devices and set an option to reuse passphrase on boot to avoid typing too much

    # cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 512 -h sha256 --verify-passphrase $DISK1-part2
    # cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 512 -h sha256 --verify-passphrase $DISK2-part2
    # cryptsetup luksOpen $DISK1-part2 crypted-nixos1
    # cryptsetup luksOpen $DISK2-part2 crypted-nixos2

## Part 4: Setup Filesystems

    # mkfs.vfat $DISK1-part1
    # mkfs.vfat $DISK2-part1

Take note of the UUID string of the resulting RAID 'device'

    # mkfs.btrfs -m raid1 -d raid1 /dev/mapper/crypted-nixos1 /dev/mapper/crypted-nixos2
    # RAID=/dev/disk/by-uuid/{_uuid string of your raid setup here_}

I use a simple btrfs scheme: one toplevel subvolume for root and one nested subvolume for /home

    # mount $RAID /mnt
    # btrfs subvolume create /mnt/nixos
    # umount /mnt
    # mount -t btrfs -o subvol=nixos,compress=zstd,noatime $RAID /mnt
    # btrfs subvolume create /mnt/home

This ensures that the system is bootable even if one disk goes offline. Caveat: btrfs will complain if you don't boot in degraded mode

    # mkdir -p /mnt/boot/efi
    # mkdir /mnt/boot/efi-fallback
    # mount $DISK1-part1 /mnt/boot/efi
    # mount $DISK2-part1 /mnt/boot/efi-fallback

## Addendum: Adding Swap

I found that not having swap was less than ideal so I decided to put a swap partition on a spare ssd.

    # SWAP=/dev/disk/by-id/{_id string of spare ssd_}
    # parted $DISK1 -- mklabel gpt
    # sgdisk -n1:0:0 -t1:8309 $SWAP
    # cryptsetup luksFormat --type luks2 -c aes-xts-plain64 -s 512 -h sha256 --verify-passphrase $SWAP
    # cryptsetup luksOpen $SWAP crypted-swap
    # mkswap /dev/mapper/crypted-swap
    # swapon /dev/mapper/crypted-swap
    
## Part 5: Install NixOS

    # nixos-generate-config --root /mnt

Last time I tried this nixos-generate-config failed to detect my second luks partition. It also did not correctly set my btrfs mounting options. I moved and corrected all disk configuration to my configuration.nix and deleted the duplicate options in hardware-configuration.nix

    # vim /mnt/etc/nixos/hardware-configuration.nix

Make your changes to system configuration before installation (feel free to use my example on github)

    # vim /mnt/etc/nixos/configuration.nix
    # nixos-install

Fingers crossed

    # reboot
    
## References:

https://gist.github.com/MaxXor/ba1665f47d56c24018a943bb114640d7

https://elis.nu/blog/2019/08/encrypted-zfs-mirror-with-mirrored-boot-on-nixos/

https://kennyballou.com/blog/2019/07/nixos-md-luks-lvm-setup

https://nixos.wiki/wiki/Bootloader

https://nixos.org/manual/nixos/stable/index.html#sec-obtaining

https://jappieklooster.nl/nixos-on-encrypted-btrfs.html

