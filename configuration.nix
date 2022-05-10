# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "7244c6715cb8f741f3b3e1220a9279e97b2ed8f5";
    ref = "release-21.11";
  };
  unstable = import <unstable> {};
in
  {
    imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Home-Manager Module
    (import "${home-manager}/nixos")
  ];

  # Bootloader Settings
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    enableCryptodisk = true;
    mirroredBoots = [
      { devices = [ "nodev" ];
      efiSysMountPoint = "/boot/efi";
      path = "/boot/efi";
    }
    { devices = [ "nodev" ];
    efiSysMountPoint = "/boot/efi-fallback";
    path = "/boot/efi-fallback";
  }
];
  };

  # Storage & Swap
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b04a4d37-b78e-4dcc-ae0b-010cb58e2911";
    fsType = "btrfs";
    options = [ "subvol=nixos" "compress=zstd" "noatime" ];
  };
  boot.initrd.luks.devices."crypted-nixos1".device =
    "/dev/disk/by-uuid/51dccb88-ffb9-41fc-ad2d-8d1a495fb085";
    boot.initrd.luks.devices."crypted-nixos2".device =
      "/dev/disk/by-uuid/140c4fdc-d067-4d49-b305-f84706caa019";
      boot.initrd.luks.reusePassphrases = true;
      swapDevices = [
        { device = "/dev/disk/by-uuid/122c1b66-6c3f-4f0b-8a4f-e6d09c0b69d5";
        encrypted = {
          enable = true;
          label = "crypted-swap";
          blkDev = "/dev/disk/by-uuid/7eabef9d-6f00-4edb-bd1d-43a474417953";
        };
      }
    ];
    boot.resumeDevice = "/dev/mapper/crypted-swap";

  # NTFS support via FUSE
  boot.supportedFilesystems = [ "ntfs" ];

  # Monthly btrfs scrubbing:
  # - Read all data and metadata blocks and verify checksums.
  # - Automatically repair corrupted blocks.
  services.btrfs.autoScrub.enable = true;

  # Automatic Garbage Collection of Nix Store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Save Space by Optimizing the Store (hardlink identical files)
  nix.autoOptimiseStore = true;

  # GPU Passthrough for VMs
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelParams = [ "amd_iommu=on" "vfio-pci.ids=1002:687f,1002:aaf8" ]; # vega 56
  boot.kernelParams = [ "amd_iommu=on" "vfio-pci.ids=1002:6939,1002:aad8" ]; # r9 380
  boot.kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.blacklistedKernelModules = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "vfio_pci" "amdgpu" ];
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Networking Settings
  networking = {
    hostName = "nixos-machine";
    networkmanager = {
      enable = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  # Configure X Server and Window Manager
  services.xserver = {
    enable = true;
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "dvorak";
    # No more screen tearing!
    deviceSection = ''
      Option "TearFree" "true"
    '';
    # NixOS uses systemd to launch x11 but at least this way xorg runs rootless
    displayManager.gdm.enable = true;
    # This is a single user system with FDE
    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };
    # Use home manager configure window manager
    desktopManager.session = [
      { manage = "desktop";
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} $HOME/.hm-xsession &
          waitPID=$!
        '';
      }
    ];
    # desktopManager.wallpaper.mode = "scale";
  };

  # Configure AMD video drivers
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.acpid.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # Installs Steam and enables all necessary system options
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Oculus Rift
  services.udev.extraRules = ''
    KERNEL=="hidraw*", RTTRS{busnum}=="1", ATTRS{idVendor}=="2833", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="2833", MODE="0666", GROUP="plugdev"
  '';

  # Enable CUPS to print documents
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  # Zeroconf Service to Locate Printer
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # Bluetooth
  # hardware.bluetooth.enable = true;
  # hardware.bluetooth.package = pkgs.bluezFull;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire ={
    enable = true;
    package = unstable.pipewire;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Overlays and Overrides for non-offical packages
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "video" "libvirtd" "networkmanager" "jupyter" ];
  };
  home-manager.users.user = import /home/user/home.nix;
  home-manager.useGlobalPkgs = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget vim parted pciutils git virtmanager samba
  ];

  # Ricing
  programs.dconf.enable = true;
  fonts.fonts = with pkgs; [
    # DejaVu fonts are already installed
    emacs-all-the-icons-fonts
    ibm-plex                           # has my favorite serif font
    iosevka                            # primary programming font
    (iosevka.override {                # secondary programming font
      set = "slab";
      privateBuildPlan = ''
        [buildPlans.iosevka-slab]
        family = "Iosevka Slab"
        spacing = "normal"
        serifs = "slab"
      '';
    })
    noto-fonts-cjk                     # for asian languages
    noto-fonts                         # for unicode coverage
    symbola                            # for more unicode coverage
    terminus_font                      # good bitmap font
  ];

  # Sorry Stallman Senpai
  nixpkgs.config.allowUnfree = true;

  # Security Settings
  hardware.cpu.amd.updateMicrocode = true;
  security.protectKernelImage = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Samba for shared folder with virtual machine
  services.samba = {
    enable = false;
    enableNmbd = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      ntlm auth = yes
      hosts allow = 192.168.122.  localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      public = {
        path = "/home/user/Public";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # Apparently samba service doesn't open the ports it needs
  networking.firewall.allowedTCPPorts = [ 445 139 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
