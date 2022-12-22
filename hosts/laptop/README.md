# Installation Notes

## Prerequisites

Go into BIOS and disable secure boot and fast boot.
Boot into installation ISO and open terminal.

## Part 1: Partitioning

``` shell
# parted /dev/nvme0n1 -- mklabel gpt
# parted /dev/nvme0n1 -- mkpart primary 512MB -8GB
# parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100%
# parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB
```

## Part 2: Formatting

``` shell
# mkfs.btrfs -L nixos /dev/nvme0n1p1
# mkswap -L swap /dev/nvme0n1p2
# mkfs.fat -F 32 -n boot /dev/nvme0n1p3
```

## Part 3: Mounting Partitions

``` shell
# mount /dev/disk/by-label/nixos /mnt
# mkdir -p /mnt/boot
# mount /dev/disk/by-label/boot /mnt/boot
# swapon /dev/nvme0n1p2
```

# Part 4: Flake Magic

``` shell
# nix-env -iA nixos.git
# git clone https://github.com/pnguyen4/nixos-configuration.git /mnt/
# nixos-install --flake /mnt/nixos-configuration#nixos-latitude
```

Set root password when prompted then boot into installation.

``` shell
# reboot
```

# Part 5: After Install

Set user password.

``` shell
# passwd user
```

Move flake folder to desired location.

``` shell
# rm -rf /nixos-configuration
$ git clone (...) ~/
```

