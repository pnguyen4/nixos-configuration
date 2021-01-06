# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "22f6736e628958f05222ddaadd7df7818fe8f59d";
    ref = "release-20.09";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
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
  boot.kernelParams = [ "amd_iommu=on" "pcie_aspm=off" "vfio-pci.ids=1002:687f,1002:aaf8" ];
  boot.kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.blacklistedKernelModules = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "vfio_pci" "amdgpu" ];
  boot.extraModprobeConfig = ''
    softdep amdgpu pre: vfio vfio-pci
    options vfio-pci ids=1002:687f,1002:aaf8
  '';
  boot.initrd.preDeviceCommands = ''
    DEVS="0000:0a:00.0 0000:0a:00.1"
    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    modprobe -i vfio-pci
  '';
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # Define your hostname.
  networking.hostName = "nixos-machine";

  # Set your time zone.
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
    layout = "dvorak";
    # NixOS uses systemd to launch x11 but at least this way xorg runs rootless
    displayManager.gdm.enable = true;
    # This is a single user system
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
    # No more screen tearing!
    deviceSection = ''
      Option "TearFree" "true"
    '';
  };

  # Configure AMD video drivers
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.acpid.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };
  home-manager.users.user = import /home/user/home.nix;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget vim parted pciutils git virtmanager
  ];

  fonts.fonts = with pkgs; [
    terminus_font
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Sorry Stallman
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
