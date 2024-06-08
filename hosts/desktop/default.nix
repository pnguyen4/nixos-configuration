# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader Settings
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    enableCryptodisk = true;
    mirroredBoots = [
      {
        devices = [ "nodev" ];
        efiSysMountPoint = "/boot/efi";
        path = "/boot/efi";
      }
      {
        devices = [ "nodev" ];
        efiSysMountPoint = "/boot/efi-fallback";
        path = "/boot/efi-fallback";
      }
    ];
  };

  # Storage & Swap
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b04a4d37-b78e-4dcc-ae0b-010cb58e2911";
    fsType = "btrfs";
    options = [ "subvol=nixos" "compress=zstd" "noatime" "autodefrag" ];
  };
  boot.initrd.luks = {
    reusePassphrases = true;
    devices."crypted-nixos1".device = "/dev/disk/by-uuid/51dccb88-ffb9-41fc-ad2d-8d1a495fb085";
    devices."crypted-nixos2".device = "/dev/disk/by-uuid/140c4fdc-d067-4d49-b305-f84706caa019";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/122c1b66-6c3f-4f0b-8a4f-e6d09c0b69d5";
      encrypted = {
        enable = true;
        label = "crypted-swap";
        blkDev = "/dev/disk/by-uuid/7eabef9d-6f00-4edb-bd1d-43a474417953";
      };
    }
  ];
  boot.resumeDevice = "/dev/mapper/crypted-swap";

  # Monthly btrfs scrubbing:
  # - Read all data and metadata blocks and verify checksums.
  # - Automatically repair corrupted blocks.
  services.btrfs.autoScrub.enable = true;

  # GPU Passthrough for VMs
  # boot.kernelParams = [ "amd_iommu=on" "vfio-pci.ids=1002:687f,1002:aaf8" ]; # vega 56
  # boot.kernelParams = [ "amd_iommu=on" "vfio-pci.ids=1002:6939,1002:aad8" ]; # r9 380
  # boot.kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  # boot.blacklistedKernelModules = [ "amdgpu" ];
  # boot.initrd.kernelModules = [ "vfio_pci" "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [ "amdgpu.mcbp=0" ];
  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu.ovmf.enable = true;
  #   qemu.runAsRoot = false;
  #   onBoot = "ignore";
  #   onShutdown = "shutdown";
  # };
  # virtualisation.spiceUSBRedirection.enable = true;

  # Networking Settings
  networking = {
    hostName = "nixos-machine";
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };
  services.resolved.enable = true;

  # Configure AMD video drivers
  services.xserver.videoDrivers = [ "amdgpu" ];
  # Requiring login for a password-protected encrypted machine is redundant
  services.displayManager.autoLogin = {
    enable = true;
    user = "user";
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # Tool to Overclock GPU and Control Fans
  programs.corectrl.enable = true;

  # Installs Steam and enables all necessary system options
  programs.steam = {
    enable = true;
  };

  programs.java.enable = true;

  # Bluetooth
  # hardware.bluetooth.enable = true;
  # hardware.bluetooth.package = pkgs.bluezFull;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "video" "libvirtd" "networkmanager" "jupyter" "corectrl"];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget vim parted pciutils git # virtmanager samba
  ];

  # Security Settings
  hardware.cpu.amd.updateMicrocode = true;

  # Power Savings
  powerManagement.cpuFreqGovernor = "ondemand";

  services.teamviewer.enable = true;
  hardware.ledger.enable = true;

  # Samba for shared folder with virtual machine
#  services.samba = {
#    enable = false;
#    enableNmbd = true;
#    securityType = "user";
#    extraConfig = ''
#      workgroup = WORKGROUP
#      server string = smbnix
#      netbios name = smbnix
#      security = user
#      ntlm auth = yes
#      hosts allow = 192.168.122.  localhost
#      hosts deny = 0.0.0.0/0
#      guest account = nobody
#      map to guest = bad user
#    '';
#    shares = {
#      public = {
#        path = "/home/user/Public";
#        browseable = "yes";
#        "read only" = "yes";
#        "guest ok" = "no";
#        "create mask" = "0644";
#        "directory mask" = "0755";
#      };
#    };
#  };
#
#  # Apparently samba service doesn't open the ports it needs
#  networking.firewall.allowedTCPPorts = [ 445 139 ];
#  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
